function [ ] = gp_initialize_external_toolbox( input_args )
%Some external toolboxes have initialization files of their own to deal
%with appropriate folder structure and matlab paths, these can be called
%from here as long as the basic path has been added to the toolbox

if 1 == 0; input_args = 'eeglab'; end

if ~iscell(input_args); input_args = {input_args} ;end

for i1 = 1:length(input_args)
    
    disp(['initializing: ', input_args{i1}])
    switch lower(input_args{i1})
        
        case 'eeglab'
            aa = which('eeglab');
            if isempty(aa); error(['Not found: ',input_args{i1}]); end
            eeglab
            
        case 'fieldtrip'
            aa = which('ft_defaults');
            if isempty(aa); error(['Not found: ',input_args{i1}]); end
            ft_defaults
            
        otherwise
            disp('no toolbox sected')
            
    end
end

end

