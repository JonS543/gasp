function [ pow ] = fdtp_return_pow( incfg, fourierspctrm )
% UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%fourierspctrm = 4D Matrix (dimord = 'rpt_chan_freq_time')

if ~isfield(incfg,'label');   incfg.label  = []; end %cell array of electrode
if ~isfield(incfg,'freq');    incfg.freq   = []; end  %Array with frequency values
if ~isfield(incfg,'time');    incfg.time   = []; end  %Array with time values
if ~isfield(incfg,'addstruct');  incfg.addstruct = []; end
if ~isfield(incfg,'trimPercent');  incfg.trimPercent = 10; end
if ~isfield(incfg,'trials_only');  incfg.trials_only   = 0; end  %Array with time values

if isempty(incfg.label)
    for i1 = 1:size(fourierspctrm,2);incfg.label{i1} = ['chan',num2str(i1)]; end
end

if isempty(incfg.freq); incfg.freq = 1:size(fourierspctrm,3); end
if isempty(incfg.time); incfg.time = 1:size(fourierspctrm,4); end

inData = abs(fourierspctrm).^2;

pow = [];
pow.label     = incfg.label;
pow.freq      = incfg.freq;
pow.time      = incfg.time;

if incfg.trials_only == 1
    pow.dimord    = 'rpt_chan_freq_time';
    pow.powspctrm = inData;
else
    
    pow.dimord    = 'chan_freq_time';
    pow.median = squeeze(nanmedian(inData,1));
    pow.mean   = squeeze(nanmean(inData,1));
    pow.std    = squeeze(nanstd(inData,1));
    pow.tmean  = squeeze(trimmean(inData,incfg.trimPercent,1));
    pow.powspctrm = [];
end
if ~isempty(incfg.addstruct)
    useFields = fieldnames(incfg.addstruct);
    for i1 = 1:length(useFields)
        pow.(useFields{i1}) = incfg.addstruct.(useFields{i1});
    end
end
[pow] = ft_checkdata(pow);
end

