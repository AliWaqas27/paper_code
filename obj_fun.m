function[fitness] = obj_fun(soln)
global  All_Scores CNN_Feat


for i=1:size(soln,1)                            % for each solution
    sol = soln(i,:);
    
    fetaureWeight = CNN_Feat .* repmat(double(sol(1:16)),length(CNN_Feat),1);
    
    
    % Deep Neural Network (DNN)
    net = feedforwardnet([round(sol(17)) round(sol(18))]);
    Feat = double(fetaureWeight);
    Tar = All_Scores;
    net_1 = train(net,Feat',Tar);               % train data
    actual_score = Tar(1:60);
    predicted_score = net_1(Feat(1:60,:)');
    
    fitness(i) = mean(abs(actual_score - predicted_score));
    
end
end