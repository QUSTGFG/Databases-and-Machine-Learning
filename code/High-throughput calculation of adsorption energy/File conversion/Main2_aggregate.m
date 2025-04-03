clc
clear
%%Please execute the code first: Main1_change_std.m
% Specify the path to the folder containing the CSV file
folder_path = 'F:/FeCo/adsorb/O2/93/'; % Fill in the address of the file to be converted

% Get all CSV files in the specified folder
files = dir(fullfile(folder_path, '*.csv'));

% Initialize an empty matrix to store all data and filenames.
data_matrix = [];

% Iterate through each CSV file
for i = 1:numel(files)
    file_path = fullfile(folder_path, files(i).name);
    
    % Reading CSV files
    data = readmatrix(file_path);
    
    % Extract the second row of data and add it to the matrix, as well as adding the file name as the first column of data
    if size(data, 1) >= 2
        second_row_data = data(2, :);
        file_name = string(files(i).name);
        data_with_filename = [file_name, second_row_data];
        data_matrix = [data_matrix; data_with_filename];
    end
end

% Converting matrices to tables
var_names = [{'File_name'}, {'Total_energy'}, {'Adsorption_energy'}, {'Rigid_adsorption_energy'}, {'Deformation_energy'}, {'dEad/dNi'}];
T = array2table(data_matrix, 'VariableNames', var_names);

% Saving the final processed data to a new CSV file
outputFilePath = fullfile(folder_path, 'output.csv');
writetable(T, outputFilePath);
disp('All the data and file names in the second row have been organized in the output.csv file.');
