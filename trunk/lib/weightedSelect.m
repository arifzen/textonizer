function index = weightedSelect(weights, isMax)

if nargin < 1
    selfTest();
    return;
end

if nargin < 2
    isMax = false;
end

A = weights/sum(weights);
[maxValue,maxInd] = sort(A(:));
p = maxValue/sum(maxValue);
p2 = cumsum(p);
if isMax
    rank = length(p2);
    assert(~isempty(rank));
else
    rank = find(p2>rand,1,'first');
end
index = maxInd(rank);

function selfTest()

W = [2 4 2 8 2 32];
%W = rand(1,100);
bins = W*0;

for iter=1:10000
    index = weightedSelect(W,true);
    bins(index) = bins(index) + 1;
end
p1 = W/sum(W);
p2 = bins/sum(bins);
disp([p1;p2]);
