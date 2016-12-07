function [ zData ] = gp_calculate_zscore( inData, freq_mean, freq_std)
%inData should be in the following format:
% 4D Matrix (dimord = 'rpt_chan_freq_time')
% 3D Matrix (dimord = 'chan_freq_time')
% freq_mean = 1 x N array with the frequency mean to subject
% freq_std  = 1 x N array with the standard deviation to divide by

%% Create a 4D matrix with mean values
mat_mean = nan(size(inData));
mat_std  = nan(size(inData));
for i1 = 1:length(incfg.z_mean)
    if length(size(mat_mean)) == 4
        mat_mean(:,:,i1,:) = freq_mean(i1);
        mat_std(:,:,i1,:) = freq_std(i1);
    elseif length(size(mat_mean)) == 3
        mat_mean(:,i1,:) = freq_mean(i1);
        mat_std(:,i1,:) = freq_std(i1);
    end
end

cData  = inData-mat_mean;
zData  = cData./mat_std;

end

