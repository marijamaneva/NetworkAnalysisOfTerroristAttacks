clc; clearvars; close all;
%% load data
gtdData = readtable('GTD.csv');
%% clean columns
columnsToKeep = {'eventid', 'iyear','country','country_txt'...
    'region','region_txt','doubtterr','success','suicide'...
    'attacktype1','attacktype1_txt'...
    'targtype1','targtype1_txt','corp1','target1','natlty1','natlty1_txt','targsubtype1_txt'...
    'gname','gname2','motive'...
    'weaptype1','weaptype1_txt','weaptype2','weaptype2_txt','nkill','nkillter'}; 

gtdData = gtdData(:, columnsToKeep);

%% Delete doubtfull
condition1 = gtdData.doubtterr == 0; 
%% Delete multinational
condition2 = gtdData.natlty1 ~= 999; 
%% Delete unsuccess
condition3 = gtdData.success == 1; 
%% Delete unknown terrorist
condition4 = ~strcmp(gtdData.gname, 'Unknown'); 
%% Delete unknown target
condition5 = gtdData.targtype1 ~= 20; 
%% Delete unknown target
condition6 = gtdData.iyear ~= 1993; 

finalcond = condition1 & condition2 & condition3 & condition4 & condition5 & condition6;
gtdData = gtdData(finalcond, :);

%% clean not common terrorists

columnValues = gtdData.gname;

% Convert cell array to a categorical array
categoricalValues = categorical(columnValues);

% Count the occurrences of each unique value
uniqueValues = categories(categoricalValues);
counts = countcats(categoricalValues);

% Select values that have counts greater than or equal to the threshold
selectedValues = uniqueValues(counts >= 50);

rowsToKeep = ismember(gtdData.gname, selectedValues);
gtdData = gtdData(rowsToKeep, :);


%% clean Nan
nanThreshold = 0.8;  % Set the threshold for NaN values

columnNames = gtdData.Properties.VariableNames;
% Iterate over all columns
for i = 1:numel(columnNames)
    % Get the current column name
    columnName = columnNames{i};
    
    % Check if the column is numeric
    if isnumeric(gtdData.(columnName))
        % For numeric columns, use isnan
        nanValues = isnan(gtdData.(columnName));
    else
        % For non-numeric columns, use ismissing
        nanValues = ismissing(gtdData.(columnName));
    end
    
    % Find columns with more than nanThreshold NaN values
    if sum(nanValues) > nanThreshold * size(gtdData, 1)
        % Remove the identified columns
        gtdData.(columnName) = [];
    end
end



%% write to new file
writetable(gtdData, 'processedGTD.csv');



