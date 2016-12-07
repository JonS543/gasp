function [ itc ] = fdtp_return_itpc( incfg, fourierspctrm )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%fourierspctrm = 4D Matrix (dimord = 'rpt_chan_freq_time')

if ~isfield(incfg,'label');   incfg.label = []; end %cell array of electrode
if ~isfield(incfg,'freq');    incfg.freq = []; end  %Array with frequency values
if ~isfield(incfg,'time');    incfg.time = []; end  %Array with time values
if ~isfield(incfg,'addstruct');  incfg.addstruct = []; end

if isempty(incfg.label)
    for i1 = 1:size(fourierspctrm,2);incfg.label{i1} = ['chan',num2str(i1)]; end
end

if isempty(incfg.freq); incfg.freq = 1:size(fourierspctrm,3); end
if isempty(incfg.time); incfg.time = 1:size(fourierspctrm,4); end
%% Get intertrial Coherence
% code pulled from the Fieldtrip website
% instphase = angle(fourierspctrm); % this might work too
itc = [];
itc.label     = incfg.label;
itc.freq      = incfg.freq;
itc.time      = incfg.time;
itc.dimord    = 'chan_freq_time';

N = size(fourierspctrm,1);
% compute inter-trial phase coherence (itpc) 
itc.itpc      = fourierspctrm./abs(fourierspctrm);         % divide by amplitude  
itc.itpc      = sum(itc.itpc,1);   % sum angles
itc.itpc      = abs(itc.itpc)/N;   % take the absolute value and normalize
itc.itpc      = squeeze(itc.itpc); % remove the first singleton dimension

% compute inter-trial linear coherence (itlc)
itc.itlc      = sum(fourierspctrm) ./ (sqrt(N*sum(abs(fourierspctrm).^2)));
itc.itlc      = abs(itc.itlc);     % take the absolute value, i.e. ignore phase
itc.itlc      = squeeze(itc.itlc); % remove the first singleton dimension

if ~isempty(incfg.addstruct)
    useFields = fieldnames(incfg.addstruct);
    for i1 = 1:length(useFields)
        itc.(useFields{i1}) = incfg.addstruct.(useFields{i1});
    end
end
[itc] = ft_checkdata(itc);
%% how to plot
% figure
% subplot(2, 1, 1);
% imagesc(itc.time, itc.freq, squeeze(itc.itpc(1,:,:))); 
% axis xy
% title('inter-trial phase coherence');
% subplot(2, 1, 2);
% imagesc(itc.time, itc.freq, squeeze(itc.itlc(1,:,:))); 
% axis xy
% title('inter-trial linear coherence');
end

