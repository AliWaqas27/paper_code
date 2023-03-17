function[] = plot_graph()
clear all;
close all

load Eval2

Terms = ["Accuracy","MAP","MRR"];
l = ["Dataset1","Dataset2","Dataset3","Dataset4","Dataset5"];
pn = [5: 5: 20];
for i = 1 : 5  %% for all datasets
    for k = 1 : 3  %% for all terms
        for p = 1 : 4 %% for all retrievals
            for j = 1 : 5 %% for all algorithms
                val(p,j) = Eval2{i,p,j}(k);
            end
        end
        val = sort(val);
        figure
        plot(pn,val(:, 1),'-*r', 'LineWidth', 2, 'markersize',10); hold on
        plot(pn,val(:, 2),'-*b', 'LineWidth', 2, 'markersize',10)
        plot(pn,val(:, 3),'-*m', 'LineWidth', 2, 'markersize',10)
        plot(pn,val(:, 4),'-*c', 'LineWidth', 2, 'markersize',10)
        plot(pn,val(:, 5),'-*k', 'LineWidth', 2, 'markersize',10)
        xlabel('No of files Retrieved');
        ylabel(Terms{k});
%         h = legend('PSO-CDNN [28]','JA-CDNN  [29]','GWO-CDNN [26]','SFO-CDNN [27]','HGW-SFO-CDNN');
        h = legend('PSO-CDNN','JA-CDNN','GWO-CDNN','SFO-CDNN','HGW-SFO-CDNN');
        set(h,'fontsize',10,'Location','NorthEastOutside')
        print('-dtiff', '-r300', ['.\Results\Alg', Terms{k},l{i}])
        
    end
    
    for k = 1 : 3  %% for all terms
        for p = 1 : 4 %% for all retrievals
            for j = 6 : 9 %% for all Methods
                if j == 9
                    val2(p,4) = Eval2{i,p,5}(k);
                else
                    val2(p,j-5) = Eval2{i,p,j}(k);
                end
            end
        end
        val2 = sort(val2);
        figure
        bar(val2,'Linewidth',2)
        set(gca,'FontSize',14)
%         h1 = legend('CNN  [30]','DNN  [31]','CDNN  [32]','HGW-SFO-CDNN');
        h1 = legend('CNN','DNN','CDNN','HGW-SFO-CDNN');
        set(h1,'FontSize',12,'Location','best');
        ylabel(Terms{k},'FontSize',14);
        xlabel('No of files Retrieved','FontSize',14);
        xticklabels({'5','10','15','20'})
        print('-dtiff', '-r500', ['.\Results\Models', Terms{k},l{i}]);
        
    end
end

end