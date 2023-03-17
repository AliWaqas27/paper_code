function [bestfit,bestfitness,bestsol,time]=GWO_SFO(Positions,objfun,Lb,Ub,Max_iter)
ub = Ub(1,:);
lb = Lb(1,:);
[n,dim] = size(Positions,2);
% initialize alpha, beta, and delta_pos
Alpha_pos=zeros(1,dim);
Alpha_score=inf; %change this to -inf for maximization problems

Beta_pos=zeros(1,dim);
Beta_score=inf; %change this to -inf for maximization problems

Delta_pos=zeros(1,dim);
Delta_score=inf; %change this to -inf for maximization problems

%Initialize the positions of search agents
% Positions=initialization(SearchAgents_no,dim,ub,lb);

Convergence_curve=zeros(1,Max_iter);

% SFO
p = 0.5;
m = 0.7;
for i=1:n
    Fitness(i)=feval(Fun, Positions(i,:));
end
[fmin,I]=min(Fitness);
best=Positions(I,:);
S=Positions;



l=0;% Loop counter
tic;
% Main loop
while l<Max_iter
    if rand > 0.5  %%% GWO
        for i=1:size(Positions,1)
            
            % Return back the search agents that go beyond the boundaries of the search space
            Flag4ub=Positions(i,:)>ub;
            Flag4lb=Positions(i,:)<lb;
            Positions(i,:)=(Positions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
            
            % Calculate objective function for each search agent
            fitness=feval(objfun,Positions(i,:));
            
            % Update Alpha, Beta, and Delta
            if fitness<Alpha_score
                Alpha_score=fitness; % Update alpha
                Alpha_pos=Positions(i,:);
            end
            
            if fitness>Alpha_score && fitness<Beta_score
                Beta_score=fitness; % Update beta
                Beta_pos=Positions(i,:);
            end
            
            if fitness>Alpha_score && fitness>Beta_score && fitness<Delta_score
                Delta_score=fitness; % Update delta
                Delta_pos=Positions(i,:);
            end
        end
        
        
        a=2-l*((2)/Max_iter); % a decreases linearly fron 2 to 0
        
        % Update the Position of search agents including omegas
        for i=1:size(Positions,1)
            for j=1:size(Positions,2)
                
                r1=rand(); % r1 is a random number in [0,1]
                r2=rand(); % r2 is a random number in [0,1]
                
                A1=2*a*r1-a; % Equation (3.3)
                C1=2*r2; % Equation (3.4)
                
                D_alpha=abs(C1*Alpha_pos(j)-Positions(i,j)); % Equation (3.5)-part 1
                X1=Alpha_pos(j)-A1*D_alpha; % Equation (3.6)-part 1
                
                r1=rand();
                r2=rand();
                
                A2=2*a*r1-a; % Equation (3.3)
                C2=2*r2; % Equation (3.4)
                
                D_beta=abs(C2*Beta_pos(j)-Positions(i,j)); % Equation (3.5)-part 2
                X2=Beta_pos(j)-A2*D_beta; % Equation (3.6)-part 2
                
                r1=rand();
                r2=rand();
                
                A3=2*a*r1-a; % Equation (3.3)
                C3=2*r2; % Equation (3.4)
                
                D_delta=abs(C3*Delta_pos(j)-Positions(i,j)); % Equation (3.5)-part 3
                X3=Delta_pos(j)-A3*D_delta; % Equation (3.5)-part 3
                
                Positions(i,j)=(X1+X2+X3)/3;% Equation (3.7)
                
                
                
            end
        end
    else   %%% SFO
        Alpha_pos = best;
        for i=1:n
            % pollination
            for j=1:(round(p*n))
                S(j,:) = (Positions(j,:)-Positions(j+1,:))*rand(1) + Positions(j+1,:);
            end
            
            % steps
            for j=(round(p*n)+1):(round(n*(1-m)))
                S(j,:)=Positions(j,:)+rand*((Alpha_pos-Positions(j,:))/(norm((Alpha_pos-Positions(j,:)))));
            end
            
            % mortality of m% plants
            for j = ((round(n*(1-m)))+1):n
                S(j,:)= (Ub(j,:)-Lb(j,:))*rand+Lb(j,:);
            end
            
            for j = ((round(n*(1-m)))+1):n
                for k=1:length(LB)
                    S(j,k)= (Ub(k)-Lb(k))*rand+Lb(k);
                end
            end
            S(i,:)=bound_check(S(i,:),lb,ub);
            
            Fnew = feval(Fun, S(i,:));
            if (Fnew <= Fitness(i))
                Positions(i,:) = S(i,:);
                Fitness(i) = Fnew;
            end
            if  Fnew <= fmin
                Alpha_pos = S(i,:);
                fmin = Fnew;
            end
        end
        state = [Max_iter Alpha_pos fmin];
        population = S;
        Alpha_score = state;
    end
    l=l+1;
    bestfitness(l)=Alpha_score;
    bestfit = bestfitness(end);
    bestsol = Alpha_pos;
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
