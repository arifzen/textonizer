A = imread('resources\bricks01.jpg');
A = rgb2gray(A);

imshow(A);
textons = extractTextons(A);

textonAmount = length(textons);

figure;
for iter = 1:textonAmount
    subplot(1,textonAmount,iter);
    texton = textons(iter, :, :);
	imshow(texton);
end