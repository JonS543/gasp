function [ genORG, allEPOCH, epochList ] = gp_eeglab2gasp( incfg, input_fld_ABS, input_file )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if ~isfield(incfg,'outputABS');  incfg.outputABS  = []; end
if ~isfield(incfg,'modfields');  incfg.modfields  = {}; end %{{'fieldname','value'}; {'fieldname2','value2'}};

%% Setup defaults
outputABS = incfg.outputABS;
modfields = incfg.modfields;


EEG = pop_loadset( 'filename', input_file, 'filepath', input_fld_ABS);

if isempty(outputABS); outputABS = EEG.filepath; end

%% Create files
% "trial_info" returns a data structure based on EEG.epoch that has one
% value for each epoch across any number of structure variables. This is
% then used for selection and identification of trials in subsequent
% analysis
[ trial_info ] = gp_eeglab_proc_epoch( EEG.epoch);

% Creates a general data structure with dataset values used for selection
% and organization
[ genORG ] = create_genORG_from_EEGLAB( EEG, outputABS, modfields, trial_info );

% Creates epoch data files
inEpoch  = EEG.data; trialinfo = trial_info; saveEpoch = 1;
[ epochList, allEPOCH ] = create_genEPOCH( genORG, inEpoch, trialinfo, saveEpoch );
genORG.trial_list = epochList;

if ~isempty(genORG.file_path)
    savefld  = fullfile(genORG.file_path);
    if ~exist(savefld,'dir'); mkdir(savefld); end
    savefile = fullfile(savefld,genORG.file_name);
    save(savefile, 'genORG');
    disp(['Saved: ',savefile]);
end
end

