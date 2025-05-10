function [accuracy, sensitivity] = pca_classification(data, labels, num_components)
    % Parameters.
    % data: input data matrix, each row represents a sample, each column represents a feature.
    % labels: Input label vector, each element represents a category of the sample.
    % num_components: the number of principal components to select.
    % data normalization
    normalized_data = normalize(data);
    % Calculate the covariance matrix
    covariance_matrix = cov(normalized_data);
    % Compute eigenvalues and eigenvectors
    [v, d] = eig(covariance_matrix);
    % Sort the eigenvalues to obtain the top num_components principal components
    eigenvalues = diag(d);
    [sorted_eigenvalues, indices] = sort(eigenvalues, 'descend');
    selected_indices = indices(1:num_components);
    % Extraction of principal components
    principal_components = v(:, selected_indices);
    % (math.) lower dimensionality
    projected_data = normalized_data * principal_components;
    % Classifier training and testing
    classifier = fitcknn(projected_data, labels); % A k-nearest neighbor classifier is used here as an example
    predicted_labels = predict(classifier, projected_data);
    % Calculation of classification accuracy
    accuracy = sum(predicted_labels == labels) / numel(labels) * 100;
    % Calculate the sensitivity
    cm = confusionmat(labels, predicted_labels);
    sensitivity = diag(cm) ./ sum(cm, 2) * 100;
end