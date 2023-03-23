function [stim_levels, num_yes, total_trials] = getFitParams(data, cond_col, response_col, response)

stim_levels = unique(data(:,cond_col))';

num_yes = nan(1,length(stim_levels));
total_trials = nan(1,length(stim_levels));

for i =1:length(stim_levels)
    ind = data(:,cond_col) == stim_levels(i);
    sub_matrix = data(ind,:);

    num_yes(1,i) = numel(find(sub_matrix(:,response_col) == response));
    total_trials(1,i) = length(sub_matrix);
end