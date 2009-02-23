function [Z] = mapDistance(M,T,channels)
% Compare a map and a map's template

Z = numel(T)-mapMatch(M, T, channels);