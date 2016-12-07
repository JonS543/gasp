function [ output_indx, output_args ] = fn_search_data_structure( inDataStruct, field_name, field_values )
%This function will sarch within the first level of a data structure of a
%given field and then return the index numbers and values for that were
%found
% field_name = string; %field to search
% field_values = single value or cell array to match in the field to search

if 1 == 0 ;
    inDataStruct = genORG.trial_info;
    field_name  = 'eventlbl';
    field_values = {'BC','AC'};
end

if nargin < 2; field_name = []; end
if nargin < 3; field_values = []; end

if ~isempty(field_name)
    if ~iscell(field_values); field_values = {field_values}; end
    
    allfields = fieldnames(inDataStruct);
    fieldindx = find(ismember(allfields,field_name) == 1, 1);
    if isempty(fieldindx); error('field not found'); end
    
    dataVals = cell(1,size(inDataStruct,2));
    for ii = 1:size(inDataStruct,2)
        dataVals{ii} = inDataStruct(ii).(field_name);
    end
    
    foundindx = ismember(dataVals,field_values);
else
    foundindx = ones(1,size(inDataStruct,2));
end

output_indx = find(foundindx == 1);
output_args = inDataStruct(foundindx);