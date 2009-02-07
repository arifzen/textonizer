img = rgb2gray(imread('../in/EGGS.png'));

[ windows, coord ] = extractWindows(img, 30, 25, 10, 5);
