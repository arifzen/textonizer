function showVisualTextonAnalysis(rgbImg, textonMap)

close all;

fh2 = figure;
fh = figure;

textonAmount = unique(textonMap(:));
imh = imshow(rgbImg);

recth = imrect(gca, [10 10 100 100]);

api = iptgetapi(recth);
api.addNewPositionCallback(@(pos) sub(pos, textonMap, textonAmount, fh2));

fcn = makeConstrainToRectFcn('imrect',...
                 get(gca,'XLim'),get(gca,'YLim'));             
api.setDragConstraintFcn(fcn);

function sub(pos, textonMap, textonAmount, fh2)

I = imcrop(textonMap, round(pos));    
figure(fh2);

hist(I(:),textonAmount);
%imagesc(I);

