clc;
clear;
close all;
% Setting the folder path
folder_path = 'F:/FeCo/DOS/93/';% Fill in the address of the file to be converted
file_pattern = fullfile(folder_path, '*.csv');
file_pattern1 = fullfile(folder_path, '*.txt');
dos = 3;
bf = 3;
% Get all CSV files in a folder
csv_files = dir(file_pattern);
% Get all TXT files in a folder
txt_files = dir(file_pattern1);
% Create x range
x_range = linspace(-30, 30, 100000);
x1_range = linspace(-30, 30, 100000);
matrix_data = [];
column_names = {};
for iii = 1:2:2*dos
    iiii = (iii+1)/2;
    if iiii == 1
        suffix = 's';
    elseif iiii == 2
        suffix = 'p';
    elseif iiii == 3
        suffix = 'd';
    elseif iiii == 4
        suffix = 'f';
    elseif iiii == 5
        suffix = 'g';
    elseif iiii == 6
        suffix = 'h';
    else
        suffix = 'excited state';
    end
    % Stores all interpolated curve data
    all_interp_data = [];
    all_integrated_values = [];
    figure;
    hold on;
    file_path1 = fullfile(folder_path, txt_files.name);
    % Reads TXT file data, skipping the first header line
    data1 = readmatrix(file_path1, 'HeaderLines', 1);
    % Get file name as legend
    [~, file_name1, ~] = fileparts(file_path1);
    % Extract the correct columns as x and y values
    x1 = data1(:, iii); % Assuming that the x-value is in the first column
    y1 = data1(:, iii+1); % Assuming that the y-value is in the second column
    % Removing NaN values
    nan_indices1 = isnan(x1) | isnan(y1);
    x1(nan_indices1) = [];
    y1(nan_indices1) = [];
    % Creating Interpolation Functions
    F1 = griddedInterpolant(x1, y1, 'linear');
    % Interpolation of data
    y1_interp = F1(x1_range);
    % Drawing Interpolation Lines
    plot(x1_range, y1_interp, 'DisplayName', file_name1);
    title(['Doped substrates' suffix 'orbital diagram']);
    hold off;
    strongest_peaks = [];
    strongest_locs = [];
    strongest_areas = [];
    figure;
    hold on;
    for i = 1:length(csv_files)
        file_path = fullfile(folder_path, csv_files(i).name);
        % Read CSV file data, skipping the first header line
        data = readmatrix(file_path, 'HeaderLines', 1);
        % Get file name as legend
        [~, file_name, ~] = fileparts(file_path);
        % Extract the correct columns as x and y values
        x = data(:, iii); % Assuming that the x-value is in the first column
        y = data(:, iii+1); % Assuming that the y-value is in the second column
        % Removing NaN values
        nan_indices = isnan(x) | isnan(y);
        x(nan_indices) = [];
        y(nan_indices) = [];
        % Creating Interpolation Functions
        F = griddedInterpolant(x, y, 'linear');
        % Interpolation of data
        y_interp = F(x_range);
        % Store the interpolated curve data
        all_interp_data = [all_interp_data; y_interp];
        % Drawing Interpolation Lines
        plot(x_range, y_interp, 'DisplayName', file_name);
        % Calculate the difference between each set of curves and the mean curve
        diff_data = y_interp - mean(all_interp_data, 1);
        % search for peaks
        [peaks, locs] = findpeaks(y_interp, x_range);
        % Calculate peak area
        areas = zeros(size(peaks));
        for i3 = 1:length(peaks)
            left_index = find(x_range < locs(i3), 1, 'last');
            right_index = find(x_range > locs(i3), 1);
            areas(i3) = trapz(x_range(left_index:right_index), y_interp(left_index:right_index));
        end
        % Find the three strongest peaks
        [sorted_peaks, sorted_indices] = sort(peaks, 'descend');
        strongest_peaks = [strongest_peaks;sorted_peaks(1:bf)];
        strongest_locs = [strongest_locs;locs(sorted_indices(1:bf))];
        strongest_areas = [strongest_areas;areas(sorted_indices(1:bf))];
        plot(locs, peaks, 'ro'); % Plotting Peak Points
        plot(locs(sorted_indices(1:bf)), sorted_peaks(1:bf), 'go', 'MarkerSize', 5); % Mapping the three strongest peaks
        legend('Original Curve', 'Peaks', 'Strongest Peaks');
        % Calculate the integral of the difference and store
        integrated_value = trapz(x_range, diff_data);
        all_integrated_values = [all_integrated_values; integrated_value];
    end
    hold off;
    % Calculate the average curve of all curves
    avg_interp_data = mean(all_interp_data, 1);
    % Create a new chart to plot the mean curve and the difference between multiple sets of curves and the mean curve.
    figure;
    hold on;
    % Plotting the average value curve
    plot(x_range, avg_interp_data, 'LineWidth', 2, 'DisplayName', 'average value curve');
    % Calculate the difference between each set of curves and the mean curve
    diff_data = all_interp_data - repmat(avg_interp_data, size(all_interp_data, 1), 1);
    % Plotting the difference between each set of curves and the mean curve
    for i = 1:size(diff_data, 1)
        plot(x_range, diff_data(i, :), 'LineStyle', '--', 'DisplayName', sprintf('average differential curve (math.) %d', i-1));
    end
    hold off;
    xx = size(diff_data, 1);
    xx = 0:1:xx-1;
    xlabel('X-axis labels');
    ylabel('Y-axis labels');
    title([suffix 'orbital curve']);
    legend('off');
    grid on;
    figure;
    hold on;
    % Plotting the initial curve
    plot(x1_range, y1_interp, 'LineWidth', 2, 'DisplayName', 'initial curve');
    % Calculate the difference between each set of curves and the initial curve
    diff_data1 = all_interp_data - repmat(y1_interp, size(all_interp_data, 1), 1);
    % Plotting the difference between each set of curves and the mean curve
    for i = 1:size(diff_data1, 1)
        plot(x1_range, diff_data1(i, :), 'LineStyle', '--', 'DisplayName', sprintf('Initial Difference Curve %d', i-1));
    end
    hold off;
    % Plotting the integral of the difference into a bar graph
    figure;
    hold on
    bar(xx,all_integrated_values);
    xlabel('Group No.');
    ylabel('point value');
    title([suffix 'Integration results for orbital differences']);
    grid on;
    hold off
    matrix_data1 = [strongest_locs,strongest_peaks,strongest_areas];
    matrix_data = [matrix_data,matrix_data1];
    column_names1 = {[suffix '1_X'], [suffix '2_X'], [suffix '3_X'], [suffix '1_Y'], [suffix '2_Y'], [suffix '3_Y'], [suffix '1_area'], [suffix '2_area'], [suffix '3_area']};
    column_names = [column_names, column_names1];
end
% Converting a matrix to a table and adding column names
data_table = array2table(matrix_data, 'VariableNames', column_names);
% Specify the name of the file to be saved
file_path = fullfile(folder_path, 'matrix_data.csv');
% Save as CSV file
writetable(data_table, file_path);