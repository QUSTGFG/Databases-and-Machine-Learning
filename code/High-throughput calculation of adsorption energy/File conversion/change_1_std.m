function change_1_std(folderPath)
% Define the xcd folder path
specificWord1 = '<value type="R8">';
specificWord2 = '</value>';
% Get all std files in a folder
fileList = dir(fullfile(folderPath, '*.std'));
% Loop through each XCD file and remove specific text and save it to a new CSV file
for i = 1:numel(fileList)
    % Reading std files
    fid = fopen(fullfile(folderPath, fileList(i).name), 'r');
    data = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    % Create a new cell array to store the processed data
    newData = cell(size(data{1}));
    % Remove specific text and save it to a new array of cells
    for j = 1:numel(data{1})
        % Remove specific text1
        tmpData = strrep(data{1}{j}, specificWord1, '');
        % Remove specific text2
        newData{j} = strrep(tmpData, specificWord2, '');
    end
    % Save the processed data to a new CSV file
    outputFilePath = [folderPath,'op_' fileList(i).name '.csv'];
    fid = fopen(outputFilePath, 'w');
    for k = 1:numel(newData)
        fprintf(fid, '%s\n', newData{k});
    end
    fclose(fid);
    disp(['The data after removing specific text from the ' fileList(i).name ' has been saved to ' outputFilePath ' .']);
end
end