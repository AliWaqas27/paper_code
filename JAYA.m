function [bestfit,bestfitness,bestso,time]=JAYA(x,objfun,Lb,Ub,maxGen)
mini = Lb(1,:);
maxi = Ub(1,:);
[row,var]=size(x);

f=feval(objfun,x);

gen=0;
tic;
while(gen<maxGen)
    xnew = updatepopulation(x,f);
    xnew = trimr(mini,maxi,xnew);
    fnew = feval(objfun,xnew);
    for i=1:row
        if(fnew(i)<f(i))
            x(i,:)=xnew(i,:);
            f(i)=fnew(i);
        end
    end
    gen = gen+1;
    [v,ind] = min(f);
    bestfitness(gen) = f(ind);
    bestsol(gen,:) = x(ind,:);      
end
time = toc;
bestso = bestsol(end,:);
bestfit = bestfitness(end);
end

function [xnew]=updatepopulation(x,f)
[row,col]=size(x);
[t,tindex]=min(f);
Best=x(tindex,:);
[w,windex]=max(f);
worst=x(windex,:);
xnew=zeros(row,col);
for i=1:row
    for j=1:col
        r=rand(1,2);
        xnew(i,j)=x(i,j)+r(1)*(Best(j)-abs(x(i,j)))-r(2)*(worst(j)-abs(x(i,j)));
    end
end
end

function[z]=trimr(mini,maxi,x)
[row,col]=size(x);
for i=1:col
    x(x(:,i)<mini(i),i)=mini(i);
    x(x(:,i)>maxi(i),i)=maxi(i);
end
z = x;
end