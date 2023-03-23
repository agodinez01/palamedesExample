% Sample script to format your data and run Palamedes
clear all;
close all;

% Add path to Palamedes
addpath('C:\Program Files\MATLAB\R2021b\Palamedes1_11_2\Palamedes\') % Your Palamedes path
addpath('C:\Program Files\JAGS\JAGS-4.3.1\x64\bin\') % Your Jags path

data_dir = 'your_repository_directory\csv_data'; % CHANGE THIS!!
condition_col  = [2,3];
response_col   = 6;
responses      = [1,2,3,4];
blocks         = [1,2];
num_sessions   = 3;
num_conditions = 3;

data = data2PalamedesFormat(data_dir, condition_col, response_col, responses, blocks, 3, 3);
data.x = log10(data.x); % Log transform values

% Palamedes requires an ascending fit. Meaning that the smaller stimulus
% values should elicit a higher proportion of say 'yes' responses. You
% might need to flip your x-values to get around this. 

data.x = -1*data.x; % Flip x-values

% Run Palamedes for all subjects and conditions with a logistic (though you
% can use others like gumbel, weibull) and a constrained lower asymptote.
% you can also constrain the upper asymptote. See Palamedes Demos for more
% information on what you can do.
pfhb = PAL_PFHB_fitModel(data, 'PF', 'logistic', 'g', 'constrained');
PAL_PFHB_inspectFit(pfhb, 'all'); % Inspect all the fits

% Extract the threshold and slope, but you can also extract other
% parameters
threshold = [];
slope = [];
for c =1:num_conditions
    for r = 1:length(responses)
        threshold(c,r) = 10^(-1*pfhb.summStats.a.mean(c,r)); % Anti log and flip
        % threshold(c,r) = 10^(pfhb.summStats.a.mean(c,r)); % Only antilog;
        % No flip
        slope(c,r) = pfhb.summStats.b.mean(c,r);
    end
end

PAL_PFHB_drawViolins(pfhb, 'a')
PAL_PFHB_drawViolins(pfhb)