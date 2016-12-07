function [ genORG ] = create_genORG_from_EEGLAB( inEEG, savePathABS, modfields, trial_info )
%inEEG = EEGLAB datastructure
% modfields = 1 x N cell array with each cell containing a 1 x 2 cell array
% with the field name in column 1 and field value in column 2
% trial_info.head = 1 x N cell, with labels for each column of
% 'trial_info.data'
% 'trial_info.data' = M x N cell array each row = an epoch, each row index
% should also corrospond to the index of the epoch (ex: row 100 == epoch
% 100)

if 1 == 0;
    inEEG = EEG;
    modfields = {...
    {'set_name','ducktales'};
    {'group','happydance'};
    };
end

% savePathABS = 0 (don't save), 1(save in same location as input file),
% 'path ABS' (save in spesified location)
if nargin < 2; savePathABS = 0; end
if nargin < 3; modfields = []; end
if nargin < 4; trial_info = []; end

if savePathABS == 1; savePathABS = EEG.filepath; end
%% grab default EEGLAB fieldnames
copy_EEGLAB = {'filepath','setname','subject','group','session','srate',...
'xmax','xmin','times','pnts','nbchan','chanlocs','trials','epoch','comments',...
'history','etc','event','urevent','ref','EVENTLIST','chaninfo','datfile',...
    };

%% Check EEGlLAB field names for existing and if not, create an empty value 

chkStruct = [];
for ii = 1:length(copy_EEGLAB)
    if isfield(inEEG,copy_EEGLAB{ii})
        chkStruct.(copy_EEGLAB{ii}) = inEEG.(copy_EEGLAB{ii});
    else
        chkStruct.(copy_EEGLAB{ii}) = [];
    end
end

%% Grab data from EEGLAB, set defaults and move into genORG
genORG = [];
genORG.file_path = savePathABS;
genORG.set_name  = chkStruct.setname;
genORG.file_type = '.genorg';
genORG.file_name = [];
genORG.epoch_fld = 'epochs';
genORG.subject   = chkStruct.subject;
genORG.group     = chkStruct.group;
genORG.session   = chkStruct.session;
genORG.srate     = chkStruct.srate;
genORG.xmax      = round(chkStruct.xmax*1000);
genORG.xmin      = round(chkStruct.xmin*1000);
genORG.tseries   = round(chkStruct.times);
genORG.pnts      = chkStruct.pnts;
genORG.nbchan    = chkStruct.nbchan;
genORG.chanlocs  = chkStruct.chanlocs;
genORG.nbepochs  = chkStruct.trials;
genORG.epoch     = chkStruct.epoch;
genORG.comments  = chkStruct.comments;
genORG.history   = chkStruct.history;
genORG.etc       = chkStruct.etc;

genORG.other.event   = chkStruct.event;
genORG.other.urevent = chkStruct.urevent;
genORG.other.ref     = chkStruct.ref;
genORG.other.EVENTLIST = chkStruct.EVENTLIST;
genORG.other.chaninfo  = chkStruct.chaninfo;
genORG.other.datfile   = chkStruct.datfile;

if ~isempty(modfields)
    for ii = 1:length(modfields)
        genORG.(modfields{ii}{1}) = modfields{ii}{2};
    end
end

genORG.file_name = [genORG.set_name,genORG.file_type];
genORG.trial_info = trial_info;
genORG.trial_list = [];
genORG.datalbl = {}; 
genORG.datacfg = {};

%% save file if requested
if savePathABS ~= 0
    savefld  = fullfile(genORG.file_path);
    if ~exist(savefld,'dir'); mkdir(savefld); end
    savefile = fullfile(savefld,genORG.file_name);
    save(savefile, 'genORG');
    disp(['Saved: ',savefile]);
end


end

