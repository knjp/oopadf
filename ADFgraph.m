classdef ADFgraph < handle
    properties
        numAlgorithms = 1;
        enum = 0;
        dataBuffer;
        adfs;
        legendPosition = 'north';
    end

    methods
        function obj = adfgraph(varname, algorithms, ensembleNum, nLength)
            anum = length(algorithms)
            obj.numAlgorithms = anum;
            for i = 1:anum
                datanum = algorithms{i}.getSaveNum()
            end
            obj.enum = ensembleNum;
            obj.dataBuffer = zeros(anum, nLength);
            obj.adfs = algorithms;
        end

        function obj = updateData(obj, algorithms)
            for i = 1:obj.numAlgorithms
                buf = obj.adfs{i}.getSaveData();
                obj.dataBuffer(i, :) = obj.dataBuffer(i, :) + buf';
            end
        end

        function obj = graphPlot2(obj, algorithms)
            figure; hold off;
            for i = 1:obj.numAlgorithms
                % buf = obj.adfs{i}.getSaveData();
                buf = obj.dataBuffer(i,:)/ obj.enum;
                plot(buf);
                hold on;
            end
        end

        function handle = plotAverage(obj, err, num, color)
            e2 = 0;
            for i = 1: num
                ei = err(:,i);
                e2 = e2 + ei.^2;
            end
            handle = plot(10*log10(e2/num), color);
            set(handle, 'linewidth', 2);
        end

        function obj = graphPlot(obj, algorithms)
            algonum = obj.numAlgorithms;
            figure;
            hold off;
            legends = 0;
            set(0, 'defaultAxesFontSize', 14);
            set(0, 'defaultTextFontSize', 14);
            set(0, 'defaultAxesFontName', 'Helvetica');
            set(0, 'defaultTextFontName', 'Helvetica');
            cline = ['b', 'r', 'g', 'k', 'c', 'y', 'm'];
            for j = 1 : algonum
                % merr = zeros(obj.nmax,obj.avenum);
                buf = obj.dataBuffer(j, :)/obj.enum;
                %handle = obj.plotAverage(merr, en, cline(j));
                handle = plot(buf, cline(j));
                if j == 1
                    hm = [handle];
                    legends = [cellstr(obj.adfs{j}.name)];
                else
                    hm = [hm, handle];
                    legends = [legends; cellstr(obj.adfs{j}.name)];
                end
                hold on;
            end
            grid on
            xlabel('Iteration n', 'FontSize', 16);
            ylabel('Mean Square Error [dB]', 'FontSize', 16);
            [tleg, objh, outh, outm] = legend(hm, legends, 'Location', obj.legendPosition);
            legend boxoff;
            set(objh, 'LineWidth', 4);
        end
    end
end

