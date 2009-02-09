function tightMap = watertight(bwImg)

W = -1*ones(size(bwImg)+[2,2]);
W(2:end-1,2:end-1) = bwImg*(-2);

O = [1,-1,size(W,1),-size(W,1)];
stack = zeros(1000,1);
counter = 1;

while(true)
    blank = find(W==0,1);
    if isempty(blank)
        break;
    end
    
    head = 1;    
    stack(head) = blank;
    while(true)   
        %imagesc(W);
        %drawnow;
        cur = stack(head,:);
        W(cur) = counter;
        head = head - 1;
        
        for iter = 1:4
            ncur = cur + O(iter);
            if W(ncur) == 0
                W(ncur) = -3;
                head = head + 1;
                stack(head) = ncur;
            elseif W(ncur) == -2
                W(ncur) = counter;
            end                
        end
        if ~head
            break;
        end
    end
    counter = counter + 1;
end

W = double(W>0).*W;
tightMap = W(2:end-1,2:end-1);