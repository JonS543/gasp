function [ ] = ini_gasp()
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

main_dir = fileparts(which('ini_gasp'));

%% Interval Folder structure
addpath(fullfile(main_dir, 'basic'));
addpath(fullfile(main_dir, 'convert'));
addpath(fullfile(main_dir, 'fnEEGLAB'));
addpath(fullfile(main_dir, 'fnFieldtrip'));
addpath(fullfile(main_dir, 'general'));


%% External toolboxes
addpath(fullfile(main_dir, 'external','eeglab13_6_5b'));
addpath(fullfile(main_dir, 'external','fieldtrip-20160706'));

%% External Toolboxes (will add them to the search path)
% a = dir(fullfile(main_dir, 'external'));
% for i1 = 1:length(a)
%     if a(i1).isdir == 1 && ~ismember(a(i1).name,{'.','..'}); 
%         addpath(fullfile(main_dir, 'external',a(i1).name));
%     end
% end
end

