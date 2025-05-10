function normalized_data = normalize(data)
    % Data normalized (mean 0, variance 1)
    normalized_data = (data - mean(data)) ./ std(data);
end