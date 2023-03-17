function[Eval] = Model_CNN_DNN_prop(Feat,All_Scores, sol, n, pos)


fetaureWeight = double(Feat) .* repmat(double(sol(1:16)),length(Feat),1);


% Deep Neural Network (DNN)
net = feedforwardnet([round(sol(17)) round(sol(18))]);
Feat = double(fetaureWeight);
Tar = All_Scores;
net_1 = train(net,Feat',Tar);               % train data
net_out = net_1(Feat');
rank = sort(net_out, 'descend');
first_N_ranks = rank(1:n);

present1 = find(first_N_ranks == net_out(pos)');

if isempty(present1)
    Accuracy = mean(first_N_ranks)/numel(pos);
    Precision = mean(first_N_ranks)/n;
    MRR =  1/5 * mean(1/rank(1));  % Mean Reciprocal Rank (MRR)
else
    Accuracy = numel(present1)/numel(pos);
    Precision = numel(present1)/n;
    MRR =  1/5 * mean(1/rank(present1(1)));
end

Eval = [Accuracy Precision MRR];

end























