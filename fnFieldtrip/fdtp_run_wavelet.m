function [ tfData,outD ] = fdtp_run_wavelet( incfg, data )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
% tfData.powspctrm = abs(tfData.fourierspctrm).^2;
% tfData.instphase = angle(tfData.fourierspctrm);
% freqnew=ft_checkdata(tfData,'cmbrepresentation','sparsewithpow');
if 1 == 0
    incfg = [];
    incfg.timeOfInt = [-500 2000];
    incfg.freqOfInt = 2:2:10;
    incfg.numCycles = 5;
    incfg.padLength = [];
end
% Data should include some buffer zones (due to signal loss in wavlet transform)
if ~isfield(incfg,'timeOfInt');    incfg.timeOfInt = []; end
% fliping the epoch will do modify each trial by mirroring it around each
% side of the epoch 'no': leaves the epoch alone and makes no adjustments,
% 'yes' mirrors the entire epoch around the begining and end point, 'toi':
% mirrors the entire epoch around the minimum and maximum time of interest
% points
if ~isfield(incfg,'flipEpoch'); incfg.flipEpoch = 'no'; end %'no','yes','toi'
if ~isfield(incfg,'flipSize');  incfg.flipSize  = .5; end % a number 0 - 1 to indicate the proportion of the Epoch to mirror around
% which frequencies are we interested in processing
if ~isfield(incfg,'freqOfInt');    incfg.freqOfInt = 3:30; end
% how many wavelet cycles before signal tapers down to zero, smaller =
% better temporal resolution, larger = better spectral resolution
if ~isfield(incfg,'numCycles');    incfg.numCycles = 5; end
% padLength: number of seconds to add to each side of the data before transform
if ~isfield(incfg,'padLength');    incfg.padLength = []; end
% use 50hz sample rate after frequency decomposition
if ~isfield(incfg,'freqTimeInterval');  incfg.freqTimeInterval= 20; end
% incfg.chanLbls = {'Fz','Cz','Pz'}
if ~isfield(incfg,'chanlabels');     incfg.chanlabels = []; end
% output type is which data we are interested in power:'pow';
%   cross spectral density (coherence): 'csd';
if ~isfield(incfg,'outputType');     incfg.outputType = 'fourier'; end
%fieldtrip automaticly ussumes everything is in seconds
if ~isfield(incfg,'insecs');     incfg.insecs = 0; end

%% modify data based on desire to flip
flipDetails.type = incfg.flipEpoch;
if ~strcmpi(incfg.flipEpoch,'no')
    timeIncrement = (1000/data.fsample);
    
    if iscell(data.trial) &&  iscell(data.time)
        runNtimes = length(data.trial);
        trialisCell = 1;
    else
        runNtimes = 1;
        trialisCell = 0;
    end
    for iTrial = 1:runNtimes
        if trialisCell == 1;
            tmpTime = data.time{iTrial};
            tmpData = data.trial{iTrial};
        else
            tmpTime = data.time;
            tmpData = data.trial;
        end
        
        if strcmpi(incfg.flipEpoch,'toi')
            toiIndx = nearest(tmpTime,incfg.timeOfInt);
        elseif strcmpi(incfg.flipEpoch,'yes');
            toiIndx = [1,length(tmpTime)];
        end
        useTime = tmpTime(toiIndx(1):toiIndx(2));
        flipLength = round(length(useTime)*incfg.flipSize);
        frontFlipIndx = 1:flipLength;
        backFlipIndx  = flipLength+1:length(useTime);
        
        %create new time array
        frontTime = -((length(frontFlipIndx)*timeIncrement)+abs(useTime(1))):timeIncrement:useTime(1)-timeIncrement;
        backTime  = useTime(end)+timeIncrement:timeIncrement: ((length(backFlipIndx)*timeIncrement)+abs(useTime(end)));
        newTime   = horzcat(round(frontTime),useTime,round(backTime));
        tVals = nan(1,length(newTime)-1);
        for i = 2:length(newTime); tVals(i-1) = newTime(i) - newTime(i-1); end
        if range(unique(tVals)) > 2; error('inconsistent sample rate for mirroring data'); end
        
        %create new data array
        useData   = tmpData(:,toiIndx(1):toiIndx(2));
        frontData = fliplr(useData(:,frontFlipIndx));
        backData  = fliplr(useData(:,backFlipIndx));
        newData = horzcat(frontData,useData,backData);
        
        %Update trial structure
        if trialisCell == 1;
            data.time{iTrial} = newTime;
            data.trial{iTrial} = newData;
        else
            data.time = newTime;
            data.trial = newData;
        end
        
    end
    
    flipDetails.timeInc   = timeIncrement;
    flipDetails.orgTime   = tmpTime;
    flipDetails.newTime   = newTime;
    flipDetails.frontTime = frontTime;
    flipDetails.backTime  = backTime;
    flipDetails.useTime   = useTime;
    flipDetails.timeInt   = unique(tVals);
end

if iscell(data.time);   timevals = data.time{1}; end
if isnumeric(data.time);timevals = data.time; end

%% Pad Length = the amount of zeros around each epoch that we want to add
% round the length of the trial up to the closest whole number and add 4 (in
%seconds
if isempty(incfg.padLength);
    epochLims = [timevals(1),timevals(end)];
    epochRange = range(epochLims);
    incfg.padLength = ceil(epochRange)+4;
end

%% if no spesific channels are selected, run on all head channels
if isempty(incfg.chanlabels)
    chanInds = ~ismember(lower(data.elec.label),...
        lower({'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8','Blink','Horz'}));
    incfg.chanlabels = data.elec.label(chanInds);
end

%% Default the time range of interest if none is spesified (this will take the minimum time for the lowest frequnecy of interest)
if isempty(incfg.timeOfInt)
    rmVal = ((1000/min(incfg.freqOfInt))*incfg.numCycles)/2;
    incfg.timeOfInt = [timevals(1)+rmVal,timevals(end)-rmVal];
end

%% wavelet details

if length(incfg.numCycles) == 1
    cycleArray = incfg.numCycles*ones(1,length(incfg.freqOfInt));
elseif length(incfg.numCycles) == length(incfg.freqOfInt);
    cycleArray = incfg.numCycles; %incase we setup a complex wavelet
end

% Calculate Spectral bandwidth  = (frequency / (number of cycles)) * 2
SpBand = (incfg.freqOfInt ./ cycleArray) * 2;
SpBandmin = incfg.freqOfInt - (SpBand /2);
SpBandmax = incfg.freqOfInt + (SpBand /2);
% Calculate Wavelet duration (temporal flitering) = ((numberof cyles)/frequency)/ pi
waveDur = (cycleArray ./ incfg.freqOfInt) / pi;

tf_metrics = horzcat(incfg.freqOfInt',cycleArray',SpBand',SpBandmin',SpBandmax',(round(waveDur*1000))');
tf_out = vertcat({'freq(hz)','cycles','SpBandrange','SpBandmin','SpBandmax','waveDur(ms)'},num2cell(tf_metrics));

%% Check for time (since everything is setup to get passed through and referenced as MS, this probably doesn't matter
% if incfg.insecs == 0
%     incfg.padLength = incfg.padLength/1000;
%     incfg.timeOfInt = incfg.timeOfInt/1000;
%     incfg.freqTimeInterval = incfg.freqTimeInterval/1000;
%     if ~iscell(data.time); data.time = {data.time} ;end
%     for ii = 1:length(data.time)
%         data.time{ii} = data.time{ii}/1000;
%     end
% end
%% run analysis
disp('Running Wavelet Conversion');

tic
%trial settings
cfg = [];
cfg.trials      = 'all';
cfg.keeptrials  = 'yes';
cfg.channel     = incfg.chanlabels;

%TF settings (get power and cross channel coherence, complex fourier)
cfg.method = 'wavelet';
cfg.output = incfg.outputType; %'fourier'; % 'powandcsd';
cfg.pad    = incfg.padLength;
cfg.width  = incfg.numCycles;
cfg.foi    = incfg.freqOfInt;
cfg.toi    = incfg.timeOfInt(1):incfg.freqTimeInterval:incfg.timeOfInt(2);

% I don't think this actually matters at all keeping in for the hell of it
%correctedTOI = timevals(nearest(timevals,incfg.timeOfInt));
%cfg.toi    = correctedTOI(1):incfg.freqTimeInterval:correctedTOI(2);


tfData           = ft_freqanalysis(cfg, data);

tProcTime = toc;
%% Analysis Details
outD.outputType = incfg.outputType;
outD.padLength  = incfg.padLength;
outD.numCycles  = incfg.numCycles;
outD.freqOfInt  = incfg.freqOfInt;
outD.toi        = cfg.toi;
outD.procTime   = tProcTime;
outD.flipDetails     = flipDetails;
outD.diags = tf_out;
outD.nbchan = length(tfData.label);
outD.chanlabels = tfData.label;
outD.srate  = (length(tfData.time)/(range(tfData.time)/1000));
outD.times  = round(tfData.time);
outD.xmin   = outD.times(1);
outD.xmax   = outD.times(end);
outD.pnts   = length(tfData.time);



end

