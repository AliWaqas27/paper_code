%   SUNFLOWER OPTIMIZATION (SFO) ALGORITHM FOR NONLINEAR UNCONSTRAINED
%                             OPTIMIZATION
%
%
% Copyright (c) 2018, Guilherme Ferreira Gomes
% All rights reserved.
%
%
% Please cite this algorithm as:
%
% Gomes, G. F., da Cunha, S. S., & Ancelotti, A. C.
% A sunflower optimization (SFO) algorithm applied to damage identification
% on laminated composite plates. Engineering with Computers, p. 1-8, 2018.
% DOI: https://doi.org/10.1007/s00366-018-0620-8
%% Test Function optimization examples:
%
% clear all
% close all
% clc
% format long
%
% set(0,'DefaultAxesFontName', 'Times New Roman')
% set(0,'DefaultAxesFontSize', 14)
% set(0,'DefaultTextFontname', 'Times New Roman')
% set(0,'DefaultTextFontSize', 26)
%
% n = 20;           %number of sunflowers
% p = 0.05;         %pollination rate best values 0.01 < p < 0.10
% m = 0.1;          %mortality rate, best values 0.01 > m < 0.10
% s = 1-(p+m);      %survival rate, best values 0.80 > s < 0.90
% d = 2;            %problem dimension
% LB = [-5 -5];     %lower bounds
% UB = [5 5];       %upper bounds
% n_iter = 100;     %max number os iterations/gerations
%
% %Objective test functions
% Fun1 = @(x)  100*(x(2)-x(1)^2)^2+(1-x(1))^2;                 % rosenbrok (1,1)
% Fun2 = @(x) (x(1)+2*x(2)-7)^2+(2*x(1)+x(2)-5)^2;             % booth (1,3)
% Fun3 = @(x) (1.5-x(1)*(1-x(2)))^2+(2.25-x(1)*(1-x(2)^2))^2;  % beale's (3,0.5)
% Fun4 = @(x) 0.26*(x(1)^2+x(2)^2)-0.48*x(1)*x(2)              % matyas (0,0)
%
% Fun = Fun4; %choose the objtective test function
%
% [x,fval,iter,state,population]=sfo(Fun,n,p,m,d,LB,UB,n_iter);
%% SunFLower Optimization Function

function [fmin,state,best,time]=SFO(Plants, Fun, LB, UB, n_iter)
% n = number of plants
% p = pollination rate
% m = mortality rate
% d = problem dimension
% LB = lower bounds
% UB = upper bounds
% n_iter = max number os gerations
p = 0.5;
m = 0.7;
[n, d] = size(Plants);
for i=1:n
    Fitness(i)=feval(Fun, Plants(i,:));
end
[fmin,I]=min(Fitness);
best=Plants(I,:);
S=Plants;
lb = LB(1,:);
ub = UB(1, :);
tic;
for t=1:n_iter
 
    for i=1:n
        % pollination
        for j=1:(round(p*n))
            S(j,:) = (Plants(j,:)-Plants(j+1,:))*rand(1) + Plants(j+1,:);
        end
        
        % steps
        for j=(round(p*n)+1):(round(n*(1-m)))
            S(j,:)=Plants(j,:)+rand*((best-Plants(j,:))/(norm((best-Plants(j,:)))));
        end
        
        % mortality of m% plants
        for j = ((round(n*(1-m)))+1):n
            S(j,:)= (UB(j,:)-LB(j,:))*rand+LB(j,:);
        end
        
        for j = ((round(n*(1-m)))+1):n
            for k=1:length(LB)
                S(j,k)= (UB(k)-LB(k))*rand+LB(k);
            end
        end
        S(i,:)=bound_check(S(i,:),lb,ub);
        
        Fnew = feval(Fun, S(i,:));
        if (Fnew <= Fitness(i))
            Plants(i,:) = S(i,:);
            Fitness(i) = Fnew;
        end
        if  Fnew <= fmin
            best = S(i,:);
            fmin = Fnew;
        end
    end
    state(t,:) = [n_iter best fmin];
    population{t} = S;
end
time = toc;
end

function s = bound_check(s,lb,ub)
ns_tmp=s;
I=ns_tmp<lb;
ns_tmp(I)=lb(I);
J=ns_tmp>ub;
ns_tmp(J)=ub(J);
s=ns_tmp;
end
