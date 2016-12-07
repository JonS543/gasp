function [genORG, epCell ] = gasp_run_freq(incfg, epCell, genORG )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3; genORG = []; end

%incfg = [];
if ~isfield(incfg,'lbl_user');     incfg.lbl_user  = []; end
if ~isfield(incfg,'padLength');    incfg.padLength  = []; end
if ~isfield(incfg,'num_cycles');   incfg.num_cycles = 5; end
if ~isfield(incfg,'timeOfInt');    incfg.timeOfInt  = []; end
if ~isfield(incfg,'outputType');   incfg.outputType = 'fourier'; end %fourier will be able to convert between power and instantanuous phase
if ~isfield(incfg,'saveEpoch');    incfg.saveEpoch = 1; end

% If you want the script to create your frequency array use these variables
if ~isfield(incfg,'min_freq');    incfg.min_freq = []; end
if ~isfield(incfg,'max_freq');    incfg.max_freq = []; end
if ~isfield(incfg,'num_freq');    incfg.num_freq = []; end
if ~isfield(incfg,'spacing_freq');incfg.spacing_freq = 'lin'; end %'log', 'lin'
if ~isfield(incfg,'round_freq');  incfg.round_freq = 1; end % Number of values to round the frequnecy to (0 = no rounding)

% If you want ot pass through your frequency values use this (numbers here
% override the calculated values
if ~isfield(incfg,'freqArray');   incfg.freqArray = []; end


%% Setup variables and data
if ~iscell(epCell); epCell = {epCell}; end
nCycles = incfg.num_cycles;
timeOfInt = incfg.timeOfInt;
if strcmpi(incfg.outputType,'fourier');
    dtype = 'fourierspctrm';
end

if ~isempty(incfg.freqArray)
    freqArray = incfg.freqArray;
else
    if strcmpi(incfg.spacing_freq,'lin')
        %this might be good to use the percent change baseline conversion
        freqArray = linspace(incfg.min_freq,incfg.max_freq,incfg.num_freq);
    elseif strcmpi(incfg.spacing_freq,'log')
        %this might be good to use a db baseline conversion
        freqArray = logspace(incfg.min_freq,incfg.max_freq,incfg.num_freq);
    end
    if incfg.round_freq > 0
        freqArray = round(freqArray,incfg.round_freq);
    end
end
%% Create labels
freqlbl = ['c(',num2str(nCycles),...
    ')f(',num2str(round(freqArray(1))),...
    'to',num2str(round(freqArray(end))),...
    'n',num2str(length(freqArray)),')'];

timelbl = ['t(',num2str(round(timeOfInt(1))),'to',num2str(round(timeOfInt(end))),')'];
%% Convert data into a fieldtrip array for processing
[ data ] = gasp2fieldtrip( [], epCell);

%% Run Frequency
%gp_initialize_external_toolbox( 'fieldtrip' );
cfg = [];
cfg.timeOfInt = timeOfInt;
cfg.freqOfInt = freqArray;
cfg.numCycles = nCycles;
[ tfData,procDetails ] = fdtp_run_wavelet( cfg, data );

%% Header data
if isempty(incfg.lbl_user); incfg.lbl_user = [freqlbl,timelbl]; end
indxN = length(genORG.datalbl)+1;
genORG.datalbl(indxN).lbl_user = incfg.lbl_user;
genORG.datalbl(indxN).lbl_freq = freqlbl;
genORG.datalbl(indxN).lbl_time = timelbl;

genORG.datacfg{indxN} = procDetails;
%% for each epoch
fprintf('Updating Epoch: \n');
for iEpoch = 1:length(epCell);
    genEPOCH = epCell{iEpoch};
    % setup labels
    indxN = length(genEPOCH.datalbl)+1;
    genEPOCH.datalbl(indxN).lbl_user = incfg.lbl_user;
    genEPOCH.datalbl(indxN).lbl_freq = freqlbl;
    genEPOCH.datalbl(indxN).lbl_time = timelbl;
    
    % Save data
    genEPOCH.data{indxN}.data   = squeeze(tfData.(dtype)(iEpoch,:,:,:));
    genEPOCH.data{indxN}.dataType = dtype;
    genEPOCH.data{indxN}.dimord = 'chan_freq_time';
    genEPOCH.data{indxN}.label  = tfData.label;
    genEPOCH.data{indxN}.time   = tfData.time;
    genEPOCH.data{indxN}.freq   = tfData.freq;
    genEPOCH.data{indxN}.elec   = tfData.elec;
    genEPOCH.data{indxN}.cfg    = tfData.cfg;
    
    epCell{iEpoch} = genEPOCH;
    if rem(iEpoch,10) == 0; fprintf('%d, ',iEpoch); end
    if rem(iEpoch,100) == 0; fprintf('\n'); end
    %% save file if requested
    if incfg.saveEpoch > 0
        savefld  = fullfile(genEPOCH.file_path);
        if ~exist(savefld,'dir'); error(['Save Dir does not exist: ', savefld]); end
        savefile = fullfile(savefld,genEPOCH.file_name);
        save(savefile, 'genEPOCH');
    end
    
end
fprintf('\n');
end

