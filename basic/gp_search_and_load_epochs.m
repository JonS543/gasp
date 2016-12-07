function [ epCell,foundfiles ] = gp_search_and_load_epochs( genORG, epoch_ABS,field_name, field_values )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%field_name  = 'eventlbl';
%field_values = {'BC','AC'};
%epoch_ABS = 'C:\Users\jstrunk3\Dropbox\GT\proj\test_EEG_tools\test_data\ya14\epochs';

if nargin < 3; field_name = []; end
if nargin < 4; field_values = []; end

[ output_indx, ~ ] = fn_search_data_structure( genORG.trial_info, field_name, field_values );


%% create extention list
[ extCell ] = fn_num2str_lead_zeros( output_indx);
exLookUp = cell(1,length(extCell));
for i1 = 1:length(extCell)
    exLookUp{i1} = ['*.ep_',extCell{i1}];
end

[ foundfiles, ~] = fn_search_within_single_dir( epoch_ABS, exLookUp);
[ epCell ] = gp_load_epoch( [], epoch_ABS, foundfiles );
end

