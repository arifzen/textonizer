% Rebuild texton filters
% S = zeros(100,100);
% for iter = 1:length(filterBank)
%     Si = real(filterBank{iter});
%     padSize = round(([100,100]-size(Si))/2);
%     
%     Si = padarray(Si,padSize);
%     S = S+Si;
% end;