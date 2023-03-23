function [data] = data2PalamedesFormat(data_dir, condition_col, response_col, responses, blocks, num_sessions, num_conditions)

arguments
    data_dir string
    condition_col(1,:) double 
    response_col(1,:) double
    responses(1,:) double
    blocks(1,:) double
    num_sessions double
    num_conditions double
end

%   DATA2PALAMEDESFORMAT Goes through your files and formats your data for
%   use in Palamedes. See examples below.
%   
%   data_dir          = 'C:\Users\LocationOfyourData'
%   condition_col     = [2,3];         Condition column. One or more values
%   response_col      = 6;             Your response column. Single number.
%   responses         = [0,1,2,3,4];   A more common response would be binary [0,1] 
%   blocks            = [1,2];         Number of blocks. One or more values
%   num_sessions      = 3;             Number of sessions. Single value
%   num_conditions    = 3;             Number of conditions. Single value

cd(strcat(data_dir));
all_files = dir; 

% Get list of all subjects, files and blocks
subjects = nan(1,length(all_files)); 
files = cell(1,length(all_files));

for file = 1:length(all_files) % Go through each file
    if length(all_files(file).name) < 4 % If the file is less than 4 charachters, it's probably not data
        fprintf('%s is not a file \n', all_files(file).name)
        files{file} = nan; % Make a nan entry
        subjects(file) = nan;
    else
        fprintf('Working on file %s \n', all_files(file,:).name)
        fname = sprintf(all_files(file).name);
        split = strfind(fname, '_'); % Find the delimiter and store it in a variable

        if str2num(fname(split(1)+1: split(2)-1)) == 0 % If the session is equal to 0, it's a practice session and shouldn't be included
            files{file} = nan;
            fprintf('%s is a practice file. Will ignore. \n', fname)
        elseif (str2num(fname(split(1)+1: split(2)-1)) >= 1) && (str2num(fname(split(1)+1: split(2)-1)) <= num_sessions) 
            files{file} = fname;
            subjects(file) = str2num(fname(1:split(1)-1));
        end
    end
end

subjects(:,all(isnan(subjects),1)) = []; % Remove nans in array
subjects = unique(subjects); % Get subject ids

files(cellfun('isclass', files, 'double')) = []; % Remove nans in cell

sub_order = nan(1,length(subjects));

[row, col] = size(csvread(files{1})); % Get number of columns in a given file. Assuming you have the same number of columns across your files
all_sub_data = cell(length(subjects),1); % Allocate space for data

% Concatenate all subject files into one cell, where each index is the
% complete data for one subject. If you have different conditions as 
% seperate sessions or blocks, this is a good place to seperate the data. 
% Just add cells in the column direction and edit code in the 
% joinSubjectFiles function.
for i = 1:length(subjects)
    all_sub_data{i} = joinSubjectFiles(files, subjects(i));
    sub_order(i) = subjects(i);
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                      This will be unique to your data                   %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

sub_code_list = [];
data = [];

for idx = 1:length(all_sub_data)
    for cond = 1:num_conditions
        if cond == 1    % Size change less than and equal to 1
            data_idx{idx,cond} = find((all_sub_data{idx}(:,condition_col(1)) <= 1) & (all_sub_data{idx}(:,condition_col(2)) == 0));
            data{idx,cond} = all_sub_data{idx}(data_idx{idx,cond},:);
        elseif cond == 2 % Size change greater than and equal to 1
            data_idx{idx, cond} = find((all_sub_data{idx}(:,condition_col(1)) >= 1) & (all_sub_data{idx}(:,condition_col(2)) == 0));
            data{idx,cond} = all_sub_data{idx}(data_idx{idx,cond},:);
        elseif cond == 3 % Rotation change
            data_idx{idx,cond} = find(all_sub_data{idx}(:,condition_col(1)) == 1);
            data{idx,cond} = all_sub_data{idx}(data_idx{idx,cond},:);
        end
    end
end

% Vertically concatenate to get all data by conditions
data_for_fit= {};

for col = 1:num_conditions
    data_by_condition = vertcat(data{:,col});
    for resp = 1:length(responses)
        if (col == 1) || (col == 2)
            cond_col = condition_col(1);
        elseif col == 3
            cond_col = condition_col(2);
        end
        [stim_levels, num_yes, total_trials] = getFitParams(data_by_condition, cond_col, response_col, responses(resp));
        data_for_fit{col,resp}.x = flip(stim_levels);
        data_for_fit{col,resp}.y = flip(num_yes);
        data_for_fit{col,resp}.n = flip(total_trials);
        data_for_fit{col,resp}.c = ones(1,length(data_for_fit{col}.n)) * col;
        data_for_fit{col,resp}.s = ones(1,length(data_for_fit{col}.n)) * resp;
    end
    
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                                   End here                              %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

[data] = parseData(data_for_fit, 1);

