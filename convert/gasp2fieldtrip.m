function [ data ] = gasp2fieldtrip( incfg, epCell)
%Function will take the epoched data from the gasp format and convert it to
%a fieldtrip


%% Outline Default Setup

%If only processing one epoch, convert it to a cell array
if ~iscell(epCell); epCell = {epCell}; end

if ~isfield(incfg,'inType');     incfg.inType     = 'EEG'; end
if ~isfield(incfg,'searchField');incfg.searchField= []; end
if ~isfield(incfg,'searchValue');incfg.searchValue= []; end
if ~isfield(incfg,'srate');      incfg.srate      = []; end
if ~isfield(incfg,'chanlabels'); incfg.chanlabels = []; end
if ~isfield(incfg,'chanpnts');   incfg.chanpnts   = []; end
if ~isfield(incfg,'add_dimord'); incfg.add_dimord = []; end %Could also be 'rpt', 'subj',

if isempty(incfg.srate) && strcmpi(incfg.inType,'eeg')
    incfg.srate      = epCell{1}.srate;
end
if isempty(incfg.chanlabels)
    incfg.chanlabels = {epCell{1}.chanlocs.labels};
end
if isempty(incfg.chanpnts)
    incfg.chanpnts = horzcat([epCell{1}.chanlocs.X]',[epCell{1}.chanlocs.Y]',[epCell{1}.chanlocs.Z]');
end

%% Default data structure parameters:

data.fsample    = incfg.srate;

data.label      = incfg.chanlabels;
data.elec.label = data.label;
data.elec.pnt   = incfg.chanpnts;

% Check to make sure that every electrode has an associated location
locDiff = length(data.elec.label) - size(data.elec.pnt,1);
if locDiff > 0
    data.elec.pnt = vertcat(data.elec.pnt,zeros(locDiff,size(data.elec.pnt,2)));
end

% Update versioning info
data.cfg.version.name = 'test_gasp_tools';
data.cfg.version.id   = 'v1.1.0';

%% If this is the amplitude by time EEG data

for i1 = 1:length(epCell)
    if strcmpi(incfg.inType,'eeg')
        data.trial{i1} = epCell{i1}.EEG;
        data.time{i1}  = epCell{i1}.tseries;
    else
        if ~isempty(incfg.searchField) && ~isempty(incfg.searchValue)
            dataFields = {epCell{i1}.datalbl.(incfg.searchField)};
            dataLoc = find(ismember(lower(dataFields),lower(incfg.searchValue)));
            if length(dataLoc) ~= 1; error(['Number of data elements found: ',num2str(length(dataLoc))]); end
            data.(epCell{i1}.data{dataLoc}.dataType){i1} = epCell{i1}.data{dataLoc}.data;
            data.time{i1} = epCell{i1}.data{dataLoc}.time;
            data.dimord = [incfg.add_dimord,'_',epCell{i1}.data{dataLoc}.dimord];
        end
    end
    
    %extra info (may not be needed)
    data.etc.trialinfo(i1)   = epCell{i1}.trialinfo;
    data.etc.epoch_index{i1} = epCell{i1}.epoch_index;
    data.etc.epoch_name{i1}  = epCell{i1}.epoch_name;
    data.etc.subject{i1}     = epCell{i1}.subject;
    data.etc.group{i1}       = epCell{i1}.group;
    data.etc.session{i1}     = epCell{i1}.session;
end

if strcmpi(incfg.add_dimord,'rpt') || strcmpi(incfg.add_dimord,'rpttap')
    aa = cat(4,data.(epCell{i1}.data{dataLoc}.dataType){:});
    data.(epCell{i1}.data{dataLoc}.dataType) = permute(aa,[4 1 2 3]);
    data.time = epCell{i1}.data{dataLoc}.time;
    data.freq = epCell{i1}.data{dataLoc}.freq;
    data.cumtapcnt = ones(size(aa,4),length(data.freq));
    data.fsample = 1000/((data.time(end) - data.time(1))/length(data.time));
end

[data] = ft_checkdata(data);
end

