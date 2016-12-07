function [ epCell ] = gp_load_epoch( incfg, file_path, file_names )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


if nargin < 3; file_names = [];end

if ~isfield(incfg,'verifyDataStruct');incfg.verifyDataStruct = {}; end
if ~isfield(incfg,'verbose');         incfg.verbose = 0; end
if ~isfield(incfg,'update_path');     incfg.update_path = 1; end
if ~isfield(incfg,'update_filename'); incfg.update_filename = 1; end

%% If no file names are passed through, select all files in directory
if isempty(file_names)
    [ file_names, ~ ] = fn_search_within_single_dir( file_path );
end
if ~iscell(file_names); file_names = {file_names};end


%% Load selected epochs
epCell = cell(1,length(file_names));
chkIndex = zeros(1,length(file_names));
for i1 = 1:length(file_names)
    if incfg.verbose == 1; disp(['Loading Epoch: ',file_names{i1}]);end
    [ genEPOCH ] = fn_load_file( file_path, file_names{i1} );
    
    if incfg.update_path == 1; genEPOCH.file_path = file_path; end
    if incfg.update_filename == 1; genEPOCH.file_name = file_names{i1}; end
    %% Check each epoch agaisnt the expected trial data
    if ~isempty(incfg.verifyDataStruct)
        if ~isequal(incfg.verifyDataStruct(i1),genEPOCH.trialinfo)
            chkIndex(i1) = i1;
        end
    end
    
    %% Create cell array of epochs
    epCell{i1} = genEPOCH;
end

%% verify and return verification check data
if sum(chkIndex) > 0
    errEpochs = sprintf('%d,',find(chkIndex > 0));
    error(['Expected epoch does not match ''trialinfo'': ', errEpochs]);
end

