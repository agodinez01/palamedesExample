function [data1] = parseData(data, all)

if ~isnumeric(all)
    error('Error. \n value for all must be numeric, not %s. ', class(all))

elseif ~iscell(data)
    error('Error. \n value for data must be cell, not %s. ', class(data))
    
end

[row,col] = size(data); % Get dimensions of dataset

if all == 0 % If building dataset for for each condition seperately
    x = [];
    y = [];
    n = [];

    for i=1:row
        for j=1:col
            x = [x, data{i,j}.x];
            y = [y, data{i,j}.y];
            n = [n, data{i,j}.n];
                
        end
    end
    
    data1 = [];
    data1.x = x(1:length(unique(x)));
    
    data1.y = [];
    data1.n = [];
    k = 1;
    while k < col
        if k == 1
            data1.y = data{k}.y;
            data1.n = data{k}.n;
        elseif (k ~= 1) && (k < col) 
            data1.y = data1.y + data{k}.y;
            data1.n = data1.n + data{k}.n;
        end
        k = k+1;
    end

elseif all == 1 % If building entire dataset to analyze all subjects and conditions
    x = [];
    y = [];
    n = [];
    c = [];
    s = [];
    
    for i=1:row
        for j = 1:col
            x = [x, data{i,j}.x];
            y = [y, data{i,j}.y];
            n = [n, data{i,j}.n];
            c = [c, data{i,j}.c];
            s = [s, data{i,j}.s];
        end
    end
    
    data1 = [];
    data1.x = x;
    data1.y = y;
    data1.n = n;
    data1.c = c;
    data1.s = s;

end
