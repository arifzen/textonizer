function X = applyFilterBank(img, filterBank)
%APPLYFILTERBANK Summary of this function goes here
%   Detailed explanation goes here

    % Convert to luminance first
    if size(img, 3) > 1
        lumImg = rgb2gray(img);
    else
        lumImg = img;
    end

    % Allocate space
    X = zeros(numel(lumImg),length(filterBank));

    % Apply filters
    for iter=1:length(filterBank)

        %filteredImg = normxcorr2(real(filterBank{iter}),lumImg);
        %filteredImg = conv2(lumImg, filterBank{iter}, 'same');
        filteredImg = abs(imfilter(lumImg, filterBank{iter}, 'symmetric'));

        imagesc(real(filteredImg));
        colormap('gray');
        drawnow;

        % Covert to vector
        X(:,iter)= filteredImg(:);
    end
end