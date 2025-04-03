function change_2_std(folder_path)
% Get all CSV files in a folder
files = dir(fullfile(folder_path, '*.csv'));
% Specific text to be deleted
specific_text1 = '</datum>';
specific_text2 = '<datum status="1">';
% Loop through each file
for i = 1:length(files)
    file_path = fullfile(folder_path, files(i).name);
    data = readtable(file_path);
    % Generate an array of strings containing the default column names
    default_col_names = strcat('Var', string(1:width(data)));
    % Resetting the column names of a table
    data.Properties.VariableNames = default_col_names;
    % Find all lines before the first plain number
    idx0 = find(cellfun(@(x) ~isnan(str2double(x)), data.Var1), 1, 'first') - 1;
    % Delete all lines before the first plain number
    data(1:idx0, :) = [];
    % Delete all columns after the first plain number
    data = data(:, 1: idx0 + 1);
    % Find all lines after the last plain number
    idx3 = find(cellfun(@(x) ~isnan(str2double(x)), data.Var1), 1, 'last') + 1;
    % Delete all lines after the last plain number
    data(idx3:end, :) = [];
    % Finds the index of a line containing specific text
    idx1 = contains(data.Var1, specific_text1);
    idx2 = contains(data.Var1, specific_text2);
    idx22 = idx1+idx2;
    idx22 = logical(idx22);
    % Delete lines containing specific text
    data(idx22, :) = [];
    % Converting table data to double-precision arrays with table2array
    data = table2array(data);
    for ii = 1:numel(data)
        data{ii} = str2double(data{ii});
    end
    data = cell2mat(data);
    % Initialize the new data matrix
    newData = [];
    colCount = 0; % Initialize the column counter
    for j = 1:size(data, 1)
        if any(isnan(data(j,:))) % Determine if a NaN value exists
            colCount = colCount+1; % When a NaN value is encountered, the column counter is incremented by 1
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
        % Extract each column in the matrix
        column = newData(:, i1);
        % Delete rows with all zeros in the column
        non_zero = any(column, 2); % Find the rows that are not all zero
        column = column(non_zero, :); % Delete rows with all zeros
        % Storing non-zero columns
        for j2 = 1:size(column,1)
            non_zero_columns{j2,i1} = column(j2,1);
        end
    end
    % Find the index of the column to be deleted
    cols_to_delete = [];
    for col = 1:size(non_zero_columns, 2)
        if isempty(non_zero_columns{1, col}) || all(cellfun(@isempty, non_zero_columns(:, col))) || all(cellfun(@(x) isequal(x, 0), non_zero_columns(:, col)))
            cols_to_delete = [cols_to_delete, col];
        end
    end
    % Delete the specified column
    non_zero_columns(:, cols_to_delete) = [];
    non_zero_columns = non_zero_columns';
    %Convert to table
    tbl = cell2table(non_zero_columns,'VariableNames',{'Total_energy' 'Adsorption_energy' 'Rigid_adsorption_energy' 'Deformation_energy' 'dEad/dNi'});
    % Saving the final processed data to a new CSV file
    outputFilePath = fullfile(folder_path, [files(i).name]);
    writetable(tbl, outputFilePath);
    disp(['The data after removing specific text from the ' files(i).name ' has been saved to ' outputFilePath ' .']);
end
end