function [epochList, allEPOCH ] = create_genEPOCH( genORG, allEpoch, trialinfo, saveEpoch )
% genORG = data format with
% should pass through EEGLAB setup data epoch as chan x time x epoch array (same format as
% EEGLAB)


if nargin < 2; error('Not enough parameters'); end
if nargin < 3; trialinfo = []; end
if nargin < 4; saveEpoch = 0; end

allEPOCH = cell(1,size(allEpoch,3));
epochList = cell(size(allEpoch,3),4);
if isempty(trialinfo); trialinfo = cell(1,size(allEpoch,3)); end
fprintf('Creating Epoch: \n');
for iEpoch = 1:size(allEpoch,3)
    epochNum    = iEpoch;
    singleEpoch = allEpoch(:,:,iEpoch);
    if iscell(trialinfo(iEpoch))
        singleInfo  = trialinfo{iEpoch};
    else
        singleInfo  = trialinfo(iEpoch);
    end
    
    %% create file look up index
    if epochNum < 10;       addval = horzcat('000',num2str(epochNum));
    elseif epochNum < 100;  addval = horzcat('00',num2str(epochNum));
    elseif epochNum < 1000; addval = horzcat('0',num2str(epochNum));
    else addval = num2str(ii);
    end
    
    %% create file structure
    genEPOCH = [];
    genEPOCH.epoch_index = epochNum;
    genEPOCH.epoch_name  = ['ep_',addval];
    genEPOCH.set_name    = genORG.set_name;
    genEPOCH.genORG_path = genORG.file_path;
    genEPOCH.epoch_fld   = genORG.epoch_fld;
    genEPOCH.file_name   = [genEPOCH.set_name,'.',genEPOCH.epoch_name];
    genEPOCH.file_path   = fullfile(genEPOCH.genORG_path,genEPOCH.epoch_fld);
    genEPOCH.subject     = genORG.subject;
    genEPOCH.group       = genORG.group;
    genEPOCH.session     = genORG.session;
    genEPOCH.srate       = genORG.srate;
    genEPOCH.xmax        = genORG.xmax;
    genEPOCH.xmin        = genORG.xmin;
    genEPOCH.tseries     = genORG.tseries;
    genEPOCH.pnts        = genORG.pnts;
    genEPOCH.nbchan      = genORG.nbchan;
    genEPOCH.chanlocs    = genORG.chanlocs;
    
    
    genEPOCH.EEG         = singleEpoch;
    genEPOCH.trialinfo   = singleInfo;
    genEPOCH.datalbl     = {};
    genEPOCH.data        = {};
    
    allEPOCH{iEpoch} = genEPOCH;
    epochList{iEpoch,1} = genEPOCH.epoch_index;
    epochList{iEpoch,2} = genEPOCH.epoch_name;
    epochList{iEpoch,3} = genEPOCH.epoch_fld;
    epochList{iEpoch,4} = genEPOCH.file_name;
    
    
    if rem(iEpoch,10) == 0; fprintf('%d, ',iEpoch); end
    if rem(iEpoch,100) == 0; fprintf('\n'); end
    %% save file if requested
    if saveEpoch > 0
        savefld  = fullfile(genEPOCH.file_path);
        if ~exist(savefld,'dir'); mkdir(savefld); end
        savefile = fullfile(savefld,genEPOCH.file_name);
        save(savefile, 'genEPOCH');
    end
end
end

