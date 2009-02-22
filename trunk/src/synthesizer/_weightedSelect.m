function index = weightedSelect(weights,isMax)

if nargin < 2
    isMax = false;
end

A = weights/sum(weights);
[maxValue,maxInd] = sort(A(:));
   
total = sum(maxValue);
if ~(total > 0)
    index = [];
    return;
end

p = maxValue/sum(maxValue);
p2 = cumsum(p);
if isMax
    rank = length(p2);
    if isempty(rank)
        keyboard;
    end
else
    rank = find(p2>rand,1,'first');
end
index = maxInd(rank);

fprintf('wighted select - rank #%d/%d\n',length(p2)-rank+1,length(p2));
