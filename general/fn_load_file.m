function [ outStruct ] = fn_load_file( file_path, file_name )
%Loads matlab data files, for those associated with the gasp toolbox it
%will update file path locations (better for across computer compatability)

if nargin < 2; file_name = []; end

% Create the absolute file path
load_full = fullfile(file_path,file_name);
% Search for folder slashs (both unix and windows)
slashLoc = find(load_full == '\' | load_full == '/');
% Load in the data structure(this will accomidate all file extensions that are 'mat' files)
%disp(['Loading File: ',load_full])
inStruct = load(load_full,'-mat');
% get the field name of the data structure 
orgStruct = fieldnames(inStruct);
% Remove the top layer to the inported data structure
outStruct = inStruct.(orgStruct{1});
%Update the file load location if it exists
if isfield(outStruct,'file_path')
    outStruct.file_path = load_full(1:slashLoc(end));
end


end

