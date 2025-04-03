function change_2(folder_path)
% Get all CSV files in a folder
files = dir(fullfile(folder_path, '*.csv'));
% Loop through each file
for i = 1:length(files)
    file_path = fullfile(folder_path, files(i).name);
    data = readtable(file_path);
    % Delete the last 50 rows of data
    data = data(1:end-50, :);
    % Delete the last seven columns of data
    data = data(:, 1:end-7);
    % Converting table data to double-precision arrays with table2array
    data = table2array(data);
    % Initialize the new data matrix
    newData = [];
    colCount = 0; % Initialize the column counter
    for j = 1:size(data, 1)
        if any(isnan(data(j,:))) % Determine if a NaN value exists
            colCount = colCount + 1; % When a NaN value is encountered, the column counter is incremented by 1
        else
            newData(end+1, colCount+1:colCount+size(data, 2)) = data(j, :); % Adding non-NaN data
        end
    end
    % Get the number of columns in the matrix
    num_cols = size(newData, 2);
    % Initialize the cell array for storing non-zero-valued columns
    non_zero_columns = cell(1, num_cols);
    % Loop through each column
    for i1 = 1:2:num_cols
        % Extract every two columns in the matrix
        column = newData(:, i1:i1+1);
        % Delete rows with all zeros in both columns
        non_zero = any(column, 2); % Find the rows that are not all zero
        column = column(non_zero, :); % Delete rows with all zeros
        % Storing non-zero columns
        for j2 = 1:size(column,1)
            non_zero_columns{j2,i1} = column(j2,1);
            non_zero_columns{j2,i1+1} = column(j2,2);
        end
    end
    % Convert to table
    tbl = cell2table(non_zero_columns,'VariableNames',{'X_s' 'Y_s' 'X_p' 'Y_p' 'X_d' 'Y_d' 'X_f' 'Y_f' 'X_sum' 'Y_sum'});
    % Saving the final processed data to a new CSV file
    outputFilePath = fullfile(folder_path, [files(i).name]);
    writetable(tbl, outputFilePath);
    disp(['Documents ' files(i).name ' to extract the DOS data for each track has been saved to the ' outputFilePath ' .']);
end
end