function index = weightedSelect(weights)

if nargin < 1
    selfTest();
    return;
end

A = weights/sum(weights);
[maxValue,maxInd] = sort(A(:));
p = maxValue/sum(maxValue);
p2 = cumsum(p);
index = maxInd(find(p2>rand,1,'first'));

function selfTest()

W = [2 4 2 8 2 32];
W = rand(1,100);
bins = W*0;

for iter=1:10000
    index = weightedSelect(W);
    bins(index) = bins(index) + 1;
end
p1 = W/sum(W);
p2 = bins/sum(bins);
disp([p1;p2]);
