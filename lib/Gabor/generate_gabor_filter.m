function [ gabor_filter ] = generate_gabor_filter(orientation, frequency, sx, sy)
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

filter_cutoff_in_stds = 2.0;
rotation_matrix = [cos(orientation), sin(orientation); - sin(orientation), cos(orientation)];

unrotated_half_filter_size_x = ceil(filter_cutoff_in_stds * sqrt(sx));
unrotated_half_filter_size_y = ceil(filter_cutoff_in_stds * sqrt(sy));

bounding_box = [unrotated_half_filter_size_x, unrotated_half_filter_size_y; - unrotated_half_filter_size_x, unrotated_half_filter_size_y; unrotated_half_filter_size_x, - unrotated_half_filter_size_y; - unrotated_half_filter_size_x, - unrotated_half_filter_size_y];
bounding_box = (rotation_matrix * bounding_box')';
half_filter_size_x = max(abs(bounding_box(:, 1)));
half_filter_size_y = max(abs(bounding_box(:, 2)));

x = (-half_filter_size_x):half_filter_size_x;
y = (-half_filter_size_y):half_filter_size_y;

[x y] = meshgrid(x, y);

rotated_x = x * cos(orientation) + y * sin(orientation);
rotated_y = - x * sin(orientation) + y * cos(orientation);

gabor_filter = (1 / sqrt(2 * pi * sx * sy)) * exp(- 0.5 * (rotated_x.^2 / sx + rotated_y.^2 / sy)) .* exp(i * 2 * pi * frequency * rotated_x);