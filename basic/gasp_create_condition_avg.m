[anal_dir ] = ini_testTools;
gp_initialize_external_toolbox( 'fieldtrip' )
%baseABS = 'C:\Users\strun\Dropbox\GT\proj\test_EEG_tools\';
baseABS = 'C:\Users\jstrunk3\Dropbox\GT\proj\test_EEG_tools\';

%% Define Data to use 
input_fld_ABS = fullfile(baseABS,'test_data','ya24');
input_file    = 'ya24ep-arB-aBlink-ica2-rmEye-icAR.genorg';

%% Define which data your would like to select
field_name  = 'eventlbl'; 
field_values = {'BC','AC'};

%% Load organizational file
[ genORG ]    = fn_load_file( input_fld_ABS, input_file );
input_epochABS = fullfile(genORG.file_path,genORG.epoch_fld);

%% Select and load relevant epochs
[ epCell,foundfiles ] = gp_search_and_load_epochs( genORG, input_epochABS,field_name, field_values );


%% Create a condition file using a measure of central tendancy 
% epoch list, central tendancy measure / measurement value, which data to use, are we baseling
% single trials before hand

%Find which analysis you want to pull
searchField = 'lbl_user'; %lbl_freq or lbl_time
searchValue = 'testMe'; 

cfg = [];
cfg.inType     = [];
cfg.searchField= searchField;
cfg.searchValue= searchValue;
cfg.add_dimord = 'rpttap';
[ data ] = gasp2fieldtrip( cfg, epCell);


function [ genCOND ] = ft_create_condition_avg( incfg, data )
if ~isfield(incfg,'subject');   incfg.subject   = []; end %cell array of electrode
if ~isfield(incfg,'group');     incfg.group     = []; end %cell array of electrode
if ~isfield(incfg,'session');   incfg.session   = []; end %cell array of electrode
if ~isfield(incfg,'set_name');  incfg.set_name  = []; end %cell array of electrode
if ~isfield(incfg,'file_path'); incfg.file_path = []; end %cell array of electrode

cfg = [];
cfg.label  = data.label; 
cfg.freq   = data.freq; 
cfg.time   = data.time; 
cfg.addstruct.elec    = data.elec;
cfg.addstruct.fsample = data.fsample;
cfg.addstruct.etc     = data.etc;

[ pow ] = ft_return_pow( cfg, data.fourierspctrm );


[ itc ] = ft_return_itpc( cfg, data.fourierspctrm );
[itc] = ft_checkdata(itc);

%% genCOND data structure
genCOND.set_name    = genORG.set_name;
genCOND.genORG_path = genORG.file_path;
genCOND.cond_fld    = 'cond';
genCOND.cond_name   = 'gencond';
genCOND.file_name   = [genCOND.set_name,'.',genCOND.cond_name];
genCOND.file_path   = fullfile(genCOND.genORG_path,genCOND.cond_fld);
genCOND.subject     = genORG.subject;
genCOND.group       = genORG.group;
genCOND.session     = genORG.session;

genCOND.srate    = data.fsample;
genCOND.xmax     = data.time(end);
genCOND.xmin     = data.time(1);
genCOND.tseries  = data.time;
genCOND.pnts     = length(data.time);
genCOND.nbchan   = size(data.fourierspctrm,2);
genCOND.chanlocs = data.elec;

genCOND.pow = pow;
genCOND.itc = itc;

end