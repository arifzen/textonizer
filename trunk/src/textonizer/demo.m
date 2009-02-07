A = imread('..\resources\fossil.PNG');
A = rgb2gray(A);

imshow(A);
textons = extractTextons(A);

textonAmount = size(textons, 1);

figure;
for iter = 1:textonAmount
    subplot(1,textonAmount,iter);
    texton = squeeze(textons(iter, :, :));
	imshow(texton);
end