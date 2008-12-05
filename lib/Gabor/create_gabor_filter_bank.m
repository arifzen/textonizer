function [filters] = create_gabor_filter_bank(filter_parameters)

num_of_filters = length(filter_parameters.sx);
filters = cell(num_of_filters, 1);

for k = 1:num_of_filters
    filters{k} = generate_gabor_filter(filter_parameters.orientation(k), filter_parameters.frequency(k), filter_parameters.sx(k), filter_parameters.sy(k));
end