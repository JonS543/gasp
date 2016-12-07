function [ newEpochList ] = gp_eeglab_proc_epoch( epochlist, fieldOfInt, valOfInt )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if 1 == 0 ; epochlist = EEG.epoch;end

if nargin < 2; fieldOfInt = 'eventlatency'; end
if nargin < 3; valOfInt = 0; end


%% Initialize new epoch data structure (only includes a single event code for onset)
grabfields = fieldnames(epochlist)';
newEpochList = [];
for ii = 1:size(grabfields,2); newEpochList.(grabfields{ii}) = []; end
    
%% Find the data that corrosponds to the event of interest within each epoch and grab the data for that event only
for ii = 1:size(epochlist,2)
   valIndx = cell2mat(epochlist(ii).(fieldOfInt)) == valOfInt;
   
   for i2 = 1:size(grabfields,2)
       if iscell(epochlist(ii).(grabfields{i2})(valIndx))
           newEpochList(ii).(grabfields{i2}) = epochlist(ii).(grabfields{i2}){valIndx}; %#ok
       else
           newEpochList(ii).(grabfields{i2}) = epochlist(ii).(grabfields{i2})(valIndx); %#ok
       end
   end
end

