function output = joinSubjectFiles(files, subject)

sessions = find(contains(files, num2str(subject))); % Find all the sessions from the indicated subject

session_name = {};
session_idx = [];
session = {};

% Get session name, index and load csv file for all sessions 
for idx = 1:length(sessions)
    session_name{idx} = files{sessions(idx)};
    session_idx(idx) = find(contains(files, session_name{idx}));
    session{idx} = csvread(files{session_idx(idx)});

    [rows, columns] = size(session{idx});
    split = strfind(session_name{idx}, '_'); % Find the delimiter and store it in a variable
    session{idx}(:,columns+1) = repelem(str2num(session_name{idx}(split(1)+1: split(2)-1)), length(session{idx}))'; % Add session id 
    session{idx}(:,columns+2) = repelem(str2num(session_name{idx}(split(2)+1: split(2)+1)), length(session{idx}))'; % Add block id
end

subData = vertcat(session{:});
output = subData;
