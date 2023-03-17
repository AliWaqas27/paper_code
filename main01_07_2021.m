function[] = main01_07_2021()
clc;
clear all;
close all
warning off
dbstop if error


global CNN_Feat  All_Scores



%% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$   READ DATASETS & PRE-PROCESSING  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ %%
an = 0;                                     % Set 1 to recompute
if an == 1
    path = './data/';
    myinfo = dir(path);
    for i = 1 : length(myinfo)-2           % For all sub folders in the folder
        fname = strcat(path,myinfo(i+2).name,'/');
        myinfo1 = dir(fname);
        n = 1;
        if myinfo(i+2).name == "JDT" || myinfo(i+2).name == "Tomcat"
            for j = 1 : 2                  % For all sub folders in the folder
                fname2 = strcat(fname,myinfo1(j+2).name);
                
                %% for excel sheet
                if fname2(end-3 : end) == "xlsx"
                    excel_file = readcell(fname2);
                    
                    bugid = excel_file(2:end,2);
                    
                    bug_summary = excel_file(2:end,3);
                    split_sum = erasePunctuation(bug_summary);                 %%%Erase Punctuations
                    
                    bug_desc = excel_file(2:end,4);
                    
                    loc = excel_file(2:end,10);
                    %% if it is missing
                    mask1 = cellfun(@ismissing,  excel_file(:,4), 'UniformOutput', false);
                    o = 1;
                    for m = 2 : length(excel_file)
                        if unique(mask1{m, 1}) == 1
                            bug_desc{m-1, 1} = bug_summary{m-1, 1};
                        else
                            bug_desc{m-1, 1} = bug_desc{m-1, 1};
                        end
                        myloc1 = strcat(split(loc{m-1,1},".java "), '.java'); 
                        myloc1{end,1} = myloc1{end,1}(1:end-5);
                        myloc{i}{o} =  myloc1;  
                        o = o + 1;
                    end
                    All_code_loc = cat(1, myloc{i}{:});
                    split_desc = erasePunctuation(bug_desc);                    %%%Erase Punctuations
                    %% else
                else
                    %% for folder
                    folder = fname2;
                    %% for all code files
                    for k = 1 : length(All_code_loc)
                        loc = strcat(folder,'/', All_code_loc{k});
                        string = extractFileText(loc);
                        code = extractAfter(string, "package");
                        code = erasePunctuation(code);                           %%%Erase Punctuations
                        split_code{i}{k} = splitSentences(code);                 %%%Splitting of code
                    end
                    %% for all bug files
                    for l = 1 : length(excel_file)-1
                        t = myloc{i}{l};
                        files = length(t);
                        while files > 0
                            bug_id{i}{n} = bugid{l, 1};
                            split_summary{i}{n} = split_sum{l, 1};
                            bug{i}{n} =  split_summary{i}{n};
                            split_description{i}{n} = split_desc{l, 1};
                            files = files - 1;
                            n = n + 1;
                        end
                    end
                end
            end
            %% else
        else
            for j = 1:length(myinfo1)-2   % For all sub folders in the folder
                fname2 = strcat(fname, myinfo1(j+2).name,'/');
                if fname2(end-3 : end-1) == "xml"
                    C = xml2struct(fname2);
                    number_of_bugs = length(C.Children);
                else
                    folder = fname2;
                end
            end
            %% for all bug files
            for k = 2 : 2 : number_of_bugs
                no_of_files = length(C.Children(k).Children(4).Children);
                for l = 2 : 2 : no_of_files
                    bug_id{i}{n} = C.Children(k).Attributes(2).Value;
                    
                    bug_summary = C.Children(k).Children(2).Children(2).Children.Data;
                    bug_summary = erasePunctuation(bug_summary);                                     %%%Erase Punctuations
                    split_summary{i}{n} = splitSentences(bug_summary);                               %%%Splitting of summary
                    
                    bug{i}{n} = [bug_id{i}{n}, ' ', split_summary{i}{n}{1,1}];
                    
                    if isempty(C.Children(k).Children(2).Children(4).Children)
                        split_description{i}{n}  = split_summary{i}{n};
                    else
                        bug_description = C.Children(k).Children(2).Children(4).Children.Data;
                        
                        bug_description = erasePunctuation(bug_description);                          %%%Erase Punctuations
                        split_description{i}{n} = splitSentences(bug_description);                    %%%Splitting of description
                    end
                    if (i == 3) ||  (i == 5)
                        newStr = replace(C.Children(k).Children(4).Children(l).Children.Data, '.', '/');
                        file_loc = strcat(newStr(1:end-5),".java");
                    else
                        
                        file_loc = C.Children(k).Children(4).Children(l).Children.Data;
                    end
                    loc = strcat(folder, file_loc);
                    string = extractFileText(loc);
                    code = extractAfter(string, "package");
                    code = erasePunctuation(code);                                                    %%%Erase Punctuations
                    split_code{i}{n} = splitSentences(code);                                          %%%Splitting of code
                    
                    n = n + 1;
                end
            end
            save bug_id bug_id
            save split_summary split_summary
            save bug bug
            save split_description split_description
            save split_code split_code
        end
    end
end





%% $$$$$$$$$$$$$$$$$$$$$$$$$ PREPARING DATAS(to find word2vector, bag of n-grams and TF-IDF) $$$$$$$$$$$$$$$$$$$$$$$$$$$ %%
an = 0;                                                                            % Set 1 to recompute
if an == 1
    load bug
    load bug_id
    list1 = {1, 3, 5};
    for i = 1: length(list1)
        for j = 1 : length(bug{list1{i}})
            bug{list1{i}}{1,j} = strcat("Bug ", bug{list1{i}}{1,j});                %% add Bug
            bug{list1{i}}{1,j} = convertStringsToChars( bug{list1{i}}{1,j});        %% Convert string class to char class
            bug_id{list1{i}}{1,j} = str2double( bug_id{list1{i}}{1,j});             %% Convert String class to double class
            split_description{list1{i}}{1,j} = split_description{list1{i}}{1,j}{1,1};
        end
    end
    save bug bug
    save bug_id bug_id
    save split_description split_description
end




%% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  FIND WORD2VECTOR, BAG OF N-GRAMS AND TF-IDF  FOR BUG-SUMMARY $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ %%
an = 0;                                                             % Set 1 to recompute
if an == 1
    load bug
    
    emb = fastTextWordEmbedding;
    
    for i = 1:length(bug)                                           % for all 5 datasets
        for j = 1 : length(bug{i})
            vec = [];
            tokens = tokenizedDocument(bug{i}(1,j));
            bag = bagOfNgrams(tokens);
            T = tfidf(bag);                                         % TFIDF
            c = full(T(1));
            for sn = 1:length(bug{i}(1,j))
                tf = c(sn,:);                                       % extracted features
                for m = 1 : length(tokens(sn,1).Vocabulary)
                    w2v = word2vec(emb, tokens(sn).Vocabulary(m));
                    if ~(isnan(w2v))
                        vec = [vec w2v(1:10)];
                    end
                end
            end
            Word_embed_BugSummary{i}{j} = [tf vec];
        end
    end
    save Word_embed_BugSummary Word_embed_BugSummary
end




%% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  FIND WORD2VECTOR, BAG OF N-GRAMS AND TF-IDF  FOR BUG-DESCRIPTION $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ %%
an = 0;                                                              % Set 1 to recompute
if an == 1
    load split_description
    
    emb = fastTextWordEmbedding;
    
    for i = 1:length(split_description)                              % for all 5 datasets
        for j = 1 : length(split_description{i})
            vec = [];
            tokens = tokenizedDocument(split_description{i}(1,j));
            bag = bagOfNgrams(tokens);
            T = tfidf(bag);                                         % TFIDF
            if ~(isempty(T))
                c = full(T);
            else
                c = 0;
            end
            for sn = 1:length(split_description{i}(1,j))
                tf = c(sn,:);                                       % extracted features
                for m = 1 : length(tokens(sn,1).Vocabulary)
                    w2v = word2vec(emb, tokens(sn).Vocabulary(m));
                    if ~(isnan(w2v))
                        vec = [vec w2v(1:10)];
                    end
                end
            end
            Word_embed_BugDescription{i}{j} = [tf vec];
        end
    end
    save Word_embed_BugDescription Word_embed_BugDescription
end





%% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  FIND WORD2VECTOR, BAG OF N-GRAMS AND TF-IDF  FOR CODE $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ %%
an = 0;                                                                    % Set 1 to recompute
if an == 1
    load split_code
    
    emb = fastTextWordEmbedding;
    
    for i = 1:length(split_code)                                           % for all 5 datasets
        for j = 1 : length(split_code{i})
            vec = [];
            tokens = tokenizedDocument(split_code{i}{1,j});
            bag = bagOfNgrams(tokens);
            T = tfidf(bag);                                         % TFIDF
            c = full(T);
            for sn = 1:length(split_code{i}{1,j})
                tf = c(sn,:);                                   % extracted features
                for m = 1 : length(tokens(sn,1).Vocabulary)
                    w2v = word2vec(emb, tokens(sn).Vocabulary(m));
                    if ~(isnan(w2v))
                        vec = [vec w2v(1:10)];
                    end
                end
            end
            Word_embed_code{i}{j} = [tf vec];
        end
    end
    save Word_embed_code Word_embed_code
end




%% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  DATA FORMATION BY ASSIGNING SCORES FOR EACH BUG REPORTS $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ %%
an = 0;                                                       % Set 1 to recompute
if an == 1
    load Word_embed_BugSummary
    load Word_embed_BugDescription
    load Word_embed_code
    
    for b = 1 : length(Word_embed_BugSummary)
        c = 1;
        while c <+ length(Word_embed_BugSummary{b})
            index{b}{c} = c;
            t = 1;
            while length(Word_embed_BugSummary{b}{c}) == length(Word_embed_BugSummary{b}{c + t})
                index{b}{c+t} = c;
                t = t + 1;
                if (c + t) >  length(Word_embed_BugSummary{b})
                    break
                end
            end
            c = c + t;
        end
    end
    save index index
    
    for i = 1 : length(Word_embed_BugSummary)                 % for all 5 datasets
        k = 1;
        for j = 1 : length(Word_embed_BugSummary{i})
            Datas = {Word_embed_BugSummary{i}{j}, Word_embed_BugDescription{i}{j}, Word_embed_code{i}{j}};
            m = numel(Datas);
            o = cellfun(@numel,Datas);
            out = zeros(max(o),m);
            for jj = 1:m
                out(1:o(jj),jj) = Datas{jj}(:);
            end
            [coeff, score] = pca(out);                        % Find PCA
            Data{i}(k,:) = zeros(1,16);
            Data{i}(k,1:9) = coeff(:);
            Feat{i}(:,:,:,k) = imresize(Data{i}(k,:),[4,4]);  % CNN acceptable data formation
            Scores{i}{k} = 1;                                 % Score
            randPos{i}{k} = j;                                % Position
            times = j;
            
            for l = k + 1 : k + 19                            % for random 20 combinations of bug reports
                randPos{i}{l} = randperm(length(Word_embed_BugSummary{i}),1);   % random Position for all Word_embed in each datasets
                Datas = {Word_embed_BugSummary{i}{j}, Word_embed_BugDescription{i}{j}, Word_embed_code{i}{randPos{i}{l}}};
                m = numel(Datas);
                o = cellfun(@numel,Datas);
                out = zeros(max(o),m);
                for jj = 1:m
                    out(1:o(jj),jj) = Datas{jj}(:);
                end
                [coeff, score] = pca(out);
                Data{i}(l,:) = zeros(1,16);
                Data{i}(l,1:9) = coeff(:);
                Feat{i}(:,:,:,l) = imresize(Data{i}(l,:),[4,4]);% CNN acceptable data formation
                Scores{i}{l} = randi([1 5])/10;                 % Assigning scores between 0.1 to 0.5
            end
            k = k + 20;
        end
    end
    save Data Data
    save Feat Feat
    save Scores Scores
    save randPos randPos
end





%% $$$$$$$$$$$  CNN FEATURES FOR OPTIMIZATION $$$$$$$$ %%
an = 0;                                                     % Set 1 to recompute
if an == 1
    load Feat
    load Scores
    for i = 1 : 5
        All_Scores = cell2mat(Scores{i});
        % get CNN network
        net_cnn{i} = get_network(Feat{i}, All_Scores);
        % weighted feature extraction
        featuresTrain{i} = activations(net_cnn{i}, Feat{i},'avgpool2d_2','OutputAs','rows');
    end
    save featuresTrain featuresTrain
    save net_cnn net_cnn
end




%% $$$$$$$$$$$  MULTI-OBJECTIVE CNN-BASED FEATURE EXTRACTION AND MODIFIED DNN-BASED LOCALIZATION $$$$$$$$$$$$$ %%
an = 0;                                                    % Set 1 to recompute
if an == 1
    load featuresTrain
    load Scores
    
    Npop = 10;
    Ch_len = 18;                                            % 16 for weight optimized  CNN , 2 for DNN hidden neuron optimization
    xmin = [zeros(Npop, 16) ones(Npop, 1) ones(Npop, 1) ];
    xmax = [ones(Npop, 16) 20.*ones(Npop, 1) 20.*ones(Npop, 1) ];
    initsol = unifrnd(xmin,xmax);
    itermax = 25;                                            % iteration value
    fname = 'obj_fun';
    
    
    
    for i = 1 : 5                                          % for all Datasets
        CNN_Feat = featuresTrain{i};
        All_Scores = cell2mat(Scores{i});
        
        disp('PSO')
        [bestfit,fitness,bestsol,time] = PSO(initsol,fname,xmin,xmax,itermax);               % PSO
        Pso(i).bf = bestfit; Pso(i).fit = fitness; Pso(i).bs = bestsol; Pso(i).ct = time;
        save Pso Pso
        
        disp('JAYA')
        [bestfit,fitness,bestsol,time] = JAYA(initsol,fname,xmin,xmax,itermax);              % JAYA
        Jaya(i).bf = bestfit; Jaya(i).fit = fitness; Jaya(i).bs = bestsol; Jaya(i).ct = time;
        save Jaya Jaya
        
        disp('GWO')
        [bestfit,fitness,bestsol,time] = GWO(initsol,fname,xmin,xmax,itermax);               % GWO
        Gwo(i).bf = bestfit; Gwo(i).fit = fitness; Gwo(i).bs = bestsol; Gwo(i).ct = time;
        save Gwo Gwo
        
        disp('SFO')
        [bestfit,fitness,bestsol,time] = SFO(initsol,fname,xmin,xmax,itermax);               % SFO
        Sfo(i).bf = bestfit; Sfo(i).fit = fitness; Sfo(i).bs = bestsol; Sfo(i).ct = time;
        save Sfo Sfo
        
        disp('PROPOSED')
        [bestfit,fitness,bestsol,time] = GWO_SFO(initsol,fname,xmin,xmax,itermax);            % GWO + SFO
        Prop(i).bf = bestfit; Prop(i).fit = fitness; Prop(i).bs = bestsol; Prop(i).ct = time;
        save Prop Prop
        
    end
else
    
    load Pso
    load Jaya
    load Gwo
    load Sfo
    load Prop
    
end





%% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$   RETRIEVAL   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ %%
an = 0;           % Set 1 to recompute
if an == 1
    load featuresTrain
    load Scores
    load index
    Query = 3;   % for third bug report
    for i =  1 : 5 % for all Datasets
        cnn_Feat = featuresTrain{i};
        Score = cell2mat(Scores{i});
        ind = find(cell2mat(index{i}) == Query);
        while isempty(ind)
            Query = Query + 1;
            ind = find(cell2mat(index{i}) == Query);
        end
        Tar = Score(ind(1)*20 - 19:ind(end)*20);
        pos = find(Tar == 1);
        per = [5, 10, 15, 20];
        for rk = 1 : 4
            for j = 1 : 5 % for all algorithms
                if j == 1; alg = Pso;
                elseif j == 2; alg = Jaya;
                elseif j == 3; alg = Gwo;
                elseif j == 4; alg = Sfo;
                else
                    alg = Prop;
                end
                Feat1 = cnn_Feat(ind(1)*20 - 19:ind(end)*20, :);
                sol = alg(i).bs;
                Eval{i,rk, j} = Model_CNN_DNN_prop(Feat1, Tar, sol, per(rk), pos);   %% Model CNN + DNN Optimized
            end
            load Feat
            Feat1 = Feat{i}(:, :, :,ind(1)*20 - 19:ind(end)*20);
            Eval{i,rk, 6} = Model_CNN(Feat1, Tar, per(rk), pos);                     %% Model CNN
            load Data
            Feat1 = Data{i}(ind(1)*20 - 19:ind(end)*20, :);
            Eval{i,rk, 7} = Model_DNN(Feat1, Tar,  per(rk), pos);                    %% Model DNN
            Feat1 = cnn_Feat(ind(1)*20 - 19:ind(end)*20, :);
            Eval{i,rk, 8} = Model_CNN_DNN(Feat1, Tar,  per(rk), pos);                %% Model CNN + DNN Without Optimization
        end
    end
    save Eval Eval
end



plot_results()
plot_graph()
end




