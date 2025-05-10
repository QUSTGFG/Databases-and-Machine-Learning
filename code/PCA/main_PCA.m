clearvars
close all
% 1. Importing data sets
data = load('materials data.txt'); % Data File Path
% Use logical indexes to find rows containing inf
rows_with_inf = any(isinf(data), 2);
% Remove lines containing inf
data = data(~rows_with_inf, :);
X = data(:, 2:end); % Extract features, assuming the first column is a category label
Y = data(:, 1); % Extract category tags
% 2. Standardized data
[X_norm, mu, sigma] = zscore(X);
% 3. Calculate the covariance matrix
covariance_matrix = cov(X_norm);
% 4. Compute eigenvalues and eigenvectors
[eigenvectors, eigenvalues] = eig(covariance_matrix);
% 5. Sorting the feature values
[~, sorted_indices] = sort(diag(eigenvalues), 'descend');
eigenvalues_sorted = eigenvalues(sorted_indices, sorted_indices);
eigenvectors_sorted = eigenvectors(:, sorted_indices);
% 6. Selection of the number of principal components
k = 2; % Suppose you want to keep the first 2 principal components
% 7. Projection data
projected_data = X_norm * eigenvectors_sorted(:, 1:k);
% 8. Plotting feature sensitivity and classification results
figure;
scatter(projected_data(:, 1), projected_data(:, 2), 50, Y, 'filled');
xlabel('Principal Component 1');
ylabel('Principal Component 2');
title('PCA: Feature Sensitivity and Classification Results');
% 9. Output feature sensitivity
feature_sensitivity = eigenvalues_sorted(1:k, 1:k) / sum(diag(eigenvalues_sorted));
disp('Feature Sensitivity:');
disp(feature_sensitivity);
% 10. Plotting the correspondence of features to the distribution of classification results
figure;
num_features = size(X, 2);
for i = 1:num_features
    subplot(2, num_features, i);
    boxplot(X_norm(:, i), Y);
    xlabel(['Feature ', num2str(i)]);
end
for i = 1:num_features
    subplot(2, num_features, i+num_features);
    histogram(X_norm(Y==1, i), 'Binwidth', 0.5);
    hold on;
    histogram(X_norm(Y==2, i), 'Binwidth', 0.5);
    legend('POD', 'OXD');
    xlabel(['Feature ', num2str(i)]);
    ylabel('Counts');
end
sgtitle('Feature and Class Distribution');
% 12. Adding a classification range to the classification results
figure;
scatter(projected_data(:, 1), projected_data(:, 2), 50, Y, 'filled');
hold on;
xlabel('Principal Component 1');
ylabel('Principal Component 2');
title('PCA: Feature Sensitivity and Classification Results');
% Calculate the elliptic parameters for each category
class1_data = projected_data(Y == 1, :);
class2_data = projected_data(Y == 2, :);
mean_class1 = mean(class1_data);
cov_class1 = cov(class1_data);
[U1, ~, ~] = svd(cov_class1);
semimajor_axis_class1 = 2 * sqrt(max(eig(cov_class1)));
semiminor_axis_class1 = 2 * sqrt(min(eig(cov_class1)));
angle_class1 = atan2(U1(2,1),U1(1,1));
mean_class2 = mean(class2_data);
cov_class2 = cov(class2_data);
[U2, ~, ~] = svd(cov_class2);
semimajor_axis_class2 = 2 * sqrt(max(eig(cov_class2)));
semiminor_axis_class2 = 2 * sqrt(min(eig(cov_class2)));
angle_class2 = atan2(U2(2,1),U2(1,1));
% Drawing Ellipses
t = linspace(0, 2*pi, 100);
x1 = semimajor_axis_class1 * cos(t);
y1 = semiminor_axis_class1 * sin(t);
x2 = semimajor_axis_class2 * cos(t);
y2 = semiminor_axis_class2 * sin(t);
ellipse1 = [x1; y1]' * [cos(angle_class1), -sin(angle_class1); sin(angle_class1), cos(angle_class1)];
ellipse2 = [x2; y2]' * [cos(angle_class2), -sin(angle_class2); sin(angle_class2), cos(angle_class2)];
plot(mean_class1(1)+ellipse1(:,1), mean_class1(2)+ellipse1(:,2), 'r', 'LineWidth', 2);
plot(mean_class2(1)+ellipse2(:,1), mean_class2(2)+ellipse2(:,2), 'g', 'LineWidth', 2);
% Output feature sensitivity
feature_sensitivity = eigenvalues_sorted(1:k, 1:k) / sum(diag(eigenvalues_sorted));
disp('Feature Sensitivity:');
disp(feature_sensitivity);
%13 Plotting bipolt plots of eigenvectors
figure;
biplot(eigenvectors_sorted(:,1:k));
xlabel('Principal Component 1');
ylabel('Principal Component 2');
title('PCA: Feature Vectors');
% Adding labels to feature vectors
hold on;
for i = 1:num_features
    text(eigenvectors_sorted(i, 1), eigenvectors_sorted(i,k), sprintf('v%d', i),...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
end
hold off;