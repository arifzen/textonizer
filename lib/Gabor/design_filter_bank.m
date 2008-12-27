function [filter_parameters] = design_filter_bank(orientation_spacing, num_of_frequency_steps, sampling_rate)

filter_parameters.sx = [];
filter_parameters.sy = [];
filter_parameters.frequency = [];
filter_parameters.orientation = [];

start_frequency = 0.4;
%start_frequency = 0.8;

current_frequency = start_frequency;

for k = 1:num_of_frequency_steps
    filter_bandwidth = 2 / 3 * current_frequency;
    sx = round(0.5 / pi / (filter_bandwidth^2));
    sy = round(0.5 * log(2) / (pi^2) / (current_frequency^2) / (tan(orientation_spacing / 2)^2));

    for orientation = 0:orientation_spacing:(pi)
        filter_parameters.sx = [filter_parameters.sx, sx];
        filter_parameters.sy = [filter_parameters.sy, sy];
        filter_parameters.frequency = [filter_parameters.frequency, current_frequency];
        filter_parameters.orientation = [filter_parameters.orientation, orientation];
    end

    current_frequency = current_frequency / 2;
end