function [Eval] = Model_CNN(Feat,All_Scores,  n, pos)


layers = [
    imageInputLayer([size(Feat,1) size(Feat,2) size(Feat,3)])
    convolution2dLayer(3,16,'Padding','same')
    convolution2dLayer(3,16,'Padding','same')
    convolution2dLayer(3,16,'Padding','same')
    convolution2dLayer(3,16,'Padding','same')
    reluLayer
    fullyConnectedLayer(1)  %length(unique(tr_lab))
    %softmaxLayer
    regressionLayer];

options = trainingOptions('sgdm','MaxEpochs',2, ...                
    'InitialLearnRate',0.001);

rng('default')
net = trainNetwork(Feat, All_Scores', layers, options);
net_out = predict(net, Feat);
rank = sort(net_out, 'descend');
first_N_ranks = rank(1:n);
present1 = find(first_N_ranks == net_out(pos)'); 




if isempty(present1)
    Accuracy = abs(mean(first_N_ranks)/numel(pos));
    Precision = abs(mean(first_N_ranks)/n);
    MRR =  abs(1/5 * mean(1/rank(1)));  % Mean Reciprocal Rank (MRR)
else
    Accuracy = numel(present1)/numel(pos);
    Precision = numel(present1)/n;
    MRR =  abs(1/5 * mean(1/rank(present1(1))));
end

Eval = [Accuracy Precision MRR];

end
