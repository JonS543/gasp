
[FileNam,PathNam,~] = uigetfile('.set','Select an ICA file');
file2use = [PathNam FileNam]; disp(file2use)


loc = find(file2use == '\' | file2use == '/');
FileName = file2use(loc(end)+1:end);
PathName = file2use(1:loc(end));
eeglab;
%% append the following to the set name
newlabel = '-rmEye';

%% Load and display components of selected file
EEG = pop_loadset('filename',FileName,'filepath',PathName);
EEG = eeg_checkset( EEG );
disp('Number of Trials')
disp(EEG.trials)
if isempty(EEG.icachansind); error('No ICA components found. Select a file with ICA components');end

%% Auto find eye channels
EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
horzIndx  = 41; blinkIndx = 42;

hData = reshape(EEG.data(horzIndx,:,:),1,[]);
bData = reshape(EEG.data(blinkIndx,:,:),1,[]);
hVal = nan(1,size(EEG.icaact,1));
bVal = nan(1,size(EEG.icaact,1));
for iICA = 1:size(EEG.icaact,1);
icaChk = reshape(EEG.icaact(iICA,:,:),1,[]);

hVal(iICA) = abs(corr(hData',icaChk'));
bVal(iICA) = abs(corr(bData',icaChk'));
end
[maxHval, maxHindx] = max(hVal);
[maxBval, maxBindx] = max(bVal);
disp(['Blink Comp: ',num2str(maxBindx),' | Corr: ',num2str( maxBval)]);
disp(['Horz Comp: ' ,num2str(maxHindx),' | Corr: ',num2str( maxHval)]);
EEG.etc.bComp = [maxBindx,maxBval];
EEG.etc.hComp = [maxHindx,maxHval];
EEG.etc.bhCorr =[bVal',hVal'];

if maxBval > .5 && maxHval > .5
    EEG.reject.gcompreject([maxHindx,maxBindx]) = 1;
elseif maxBval > .5 
    EEG.reject.gcompreject(maxBindx) = 1;
elseif maxHval > .5
    EEG.reject.gcompreject(maxHindx) = 1;
end
%% create plots
pop_eegplot( EEG, 1, 1, 1);
pop_eegplot( EEG, 0, 1, 1);
pop_selectcomps(EEG, 1:size(EEG.icawinv,2) );

disp(['Blink Comp: ',num2str(maxBindx),' | Corr: ',num2str( maxBval)]);
disp(['Horz Comp: ' ,num2str(maxHindx),' | Corr: ',num2str( maxHval)]);
%% Wait for acknowledgement before continuing script
f = figure('Name','Close to Continue');
h = uicontrol('Position',[20 20 200 40],'String','Continue',...
    'Callback','uiresume(gcbf)');
%disp('This will print immediately');
uiwait(gcf);
%disp('This will print after you click Continue');
close(f);

%% reject componets
comps2rej = find(EEG.reject.gcompreject == 1);
disp(['Removing Components: ' num2str(comps2rej)]);

%% calculating the removal for TF bufferzones
if isfield(EEG,'buff')
    component_keep = setdiff_bc(1:size(EEG.icaweights,1), comps2rej);
    %Removing prebuffer
    disp('Adjusting Buffer Zones')
    data = EEG.buff.preICAact(component_keep,:,:);
    sizeData = size(data);
    data = reshape(data,[sizeData(1) sizeData(2)*sizeData(3)]);
    compproj = EEG.icawinv(:, component_keep)*data;
    compproj = reshape(compproj, size(compproj,1), sizeData(2), sizeData(3));
    EEG.buff.preData(EEG.icachansind,:,:) = compproj;
    EEG.buff.preICAact = EEG.buff.preICAact(component_keep,:,:);
    
    %Removing postBuffer
    data = EEG.buff.postICAact(component_keep,:,:);
    sizeData = size(data);
    data = reshape(data,[sizeData(1) sizeData(2)*sizeData(3)]);
    compproj = EEG.icawinv(:, component_keep)*data;
    compproj = reshape(compproj, size(compproj,1), sizeData(2), sizeData(3));
    EEG.buff.postData(EEG.icachansind,:,:) = compproj;
    EEG.buff.postICAact = EEG.buff.postICAact(component_keep,:,:);
end

%% Removing from actual data
EEG = pop_subcomp( EEG, comps2rej, 0);
EEG = eeg_checkset( EEG );
EEG = pop_editset(EEG, 'comments', char(EEG.comments,['Removed Eye Components :' num2str(comps2rej)]));
EEG.setname = [FileName(1:end-4) newlabel];

%% Create a new dataset with eye components removed
EEG = pop_saveset( EEG, 'filename',[EEG.setname '.set'],'filepath',PathName);
disp(['** New file created: ' PathName '\' EEG.setname '.set **'])
disp('Number of Trials')
disp(EEG.trials)
close('all')
%eeglab redraw

%% Log the process
logABS = fileparts(which(mfilename));
fn_LOG_output('single',logABS, mfilename, fullfile(PathName,[EEG.setname '.set']))
eeglab redraw
disp('Done')