clc
clear all
close all


mex BruteSearchMex.cpp
fprintf('Mex successifully completed\n');



N=100;%number of reference points
Nq=100;%number of query points
dim=50;%dimension of points
k=3;%number of neighbor
r=.1;%Search radius

p=rand(N,dim);
qp=rand(Nq,dim);


%% Nearest Neighbor

tic
[idc]=BruteSearchMex(p,qp);
toc                     %points
tic
[idc,dist]=BruteSearchMex(p,qp);%same but returns also the distance of
toc                             %points



%% K-Nearest neighbor
tic
kidc=BruteSearchMex(p,qp,'k',k);%find the K nearest neighbour for each
toc                             %query points

tic
[kidc,kdist]=BruteSearchMex(p,qp,'k',k);%same but returns also the distance
toc                                     %of points


%% Radius Search

% NOTE: Differently from the others the radius search only supports one
% input query point
tic
for i=1:Nq

    ridc=BruteSearchMex(p,qp(i,:),'r',r);%find thepoints within the
                                         %distance of the radius from query point

    [ridc,rdist]=BruteSearchMex(p,qp(i,:),'r',r);%same but returns also the
                                                   %     distance of pints

end
toc
