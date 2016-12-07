function [ genCOND ] = fdtp_quantify_condition( incfg, data )
if ~isfield(incfg,'subject');   incfg.subject   = []; end %cell array of electrode
if ~isfield(incfg,'group');     incfg.group     = []; end %cell array of electrode
if ~isfield(incfg,'session');   incfg.session   = []; end %cell array of electrode
if ~isfield(incfg,'set_name');  incfg.set_name  = []; end %cell array of electrode
if ~isfield(incfg,'file_path'); incfg.file_path = []; end %cell array of electrode
if ~isfield(incfg,'cond_fld');  incfg.cond_fld = 'cond'; end %cell array of electrode

%% Get data
cfg = [];
cfg.label  = data.label; 
cfg.freq   = data.freq; 
cfg.time   = data.time; 
cfg.addstruct.elec    = data.elec;
cfg.addstruct.fsample = data.fsample;
cfg.addstruct.etc     = data.etc;

[ pow ] = fdtp_return_pow( cfg, data.fourierspctrm );
[ itc ] = fdtp_return_itpc( cfg, data.fourierspctrm );

%% genCOND data structure
genCOND.set_name    = incfg.set_name;
genCOND.genORG_path = incfg.file_path;
genCOND.cond_fld    = incfg.cond_fld;
genCOND.cond_name   = 'gencond';
genCOND.file_name   = [genCOND.set_name,'.',genCOND.cond_name];
genCOND.file_path   = fullfile(genCOND.genORG_path,genCOND.cond_fld);
genCOND.subject     = incfg.subject;
genCOND.group       = incfg.group;
genCOND.session     = incfg.session;

genCOND.srate    = data.fsample;
genCOND.xmax     = data.time(end);
genCOND.xmin     = data.time(1);
genCOND.tseries  = data.time;
genCOND.pnts     = length(data.time);
genCOND.nbchan   = size(data.fourierspctrm,2);
genCOND.chanlocs = data.elec;

genCOND.pow = pow;
genCOND.itc = itc;

%% save file if requested
if ~isempty(genCOND.genORG_path)
    savefld  = fullfile(genCOND.file_path);
    if ~exist(savefld,'dir'); mkdir(savefld); end
    savefile = fullfile(savefld,genCOND.file_name);
    save(savefile, 'genCOND');
    disp(['Saved: ',savefile]);
end
end