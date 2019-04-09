classdef ADFsimulation < handle
    properties
        avenum = 20;
        nmax = 200;
        nmax2 = 500;
        algorithm;
        unknownSystem;
        algoNames;
        legendPosition = 'north';
        % saveData;
        adfGraph;
        gnum = 0;                   % number of graph
        inputSignal;
    end
    methods
        % Constructor
        function obj = ADFsimulation(varargin)
            if nargin > 0
                for i = 1: nargin
                    str1 = varargin{i}{1};
                    if strncmp(str1, 'algo', 4)
                        algos = varargin{i};
                        na = length(algos);
                        for j = 1:na-1
                            obj.algorithm{j} = algos{j+1};
                            obj.algoNames{j} = obj.algorithm{j}.name;
                        end
                    elseif strncmp(str1, 'dlen', 4)
                        obj.avenum = varargin{i}{2};
                        obj.nmax = varargin{i}{3};
                    elseif strncmp(str1, 'graph', 4)
                        obj.gnum = length(varargin{i});
                        obj.adfGraph = varargin{i}{2};
                    end
                end
            end
            % obj.inputSignal = SystemInput();
        end

        function obj = setNumIteration(obj, avenum, nmax)
            obj.avenum = avenum;
            obj.nmax = nmax;
        end

        function obj = setLegendPosition(obj, position)
            obj.legendPosition = position;
        end

        function obj = setUnknown(obj, unknown)
            obj.unknownSystem = unknown;
        end

        function initialize(obj, unknown)
            algonum = length(obj.algorithm);
            for a = 1 : algonum
                obj.algorithm{a}.initAlgorithm();
            end
            blen = obj.algorithm{1}.getFlen + 1;
            for i = 1 : blen % must be checked
                [input, output] = unknown.getOutputSample(unknown.getInputSample());
                for a = 1 : algonum
                    obj.algorithm{a}.initBuffer(input, output);
                end
            end
            unknown.setTime(0);
        end

        function plotmseold(obj, err, color)
            e2 = err .^2;
            plot(10*log10(e2), color);
        end

        function handle = plotAverageMSE(obj, err, num, color)
            e2 = 0;
            for i = 1: num
                ei = err(:,i);
                e2 = e2 + ei.^2;
            end
            handle = plot(10*log10(e2/num), color);
            set(handle, 'linewidth', 2);
        end

        function plotResults(obj, errs, en)
            algonum = length(obj.algorithm);
            %f = figure('visible', 'off');
            figure();
            hold off;
            legends = 0;
            set(0, 'defaultAxesFontSize', 14);
            set(0, 'defaultTextFontSize', 14);
            set(0, 'defaultAxesFontName', 'Helvetica');
            set(0, 'defaultTextFontName', 'Helvetica');
            % cline = ['b', 'r', 'g', 'k', 'c', 'y', 'm'];
            cline = ['b', 'r', 'g', 'c', 'k', 'm', 'y'];
            for j = 1 : algonum
                merr = zeros(obj.nmax,obj.avenum);
                merr(:, :) = errs(j, :, :);
                handle = obj.plotAverageMSE(merr, en, cline(j));
                if j == 1
                    hm = [handle];
                    legends = [cellstr(obj.algoNames{j})];
                else
                    hm = [hm, handle];
                    legends = [legends; cellstr(obj.algoNames{j})];
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

        function handle = plotAverageMSD(obj, err, num, color)
            e2 = 0;
            for i = 1: num
                ei = err(:,i);
                e2 = e2 + ei;
            end
            handle = plot(10*log10(e2/num), color);
            set(handle, 'linewidth', 2);
        end

        function plotMSDs(obj, msds, en)
            algonum = length(obj.algorithm);
            %f = figure('visible', 'off');
            figure();
            hold off;
            legends = 0;
            set(0, 'defaultAxesFontSize', 14);
            set(0, 'defaultTextFontSize', 14);
            set(0, 'defaultAxesFontName', 'Helvetica');
            set(0, 'defaultTextFontName', 'Helvetica');
            %cline = ['b', 'r', 'g', 'k', 'c', 'y', 'm'];
            cline = ['b', 'r', 'g', 'c', 'k', 'm', 'y'];
            for j = 1 : algonum
                merr = zeros(obj.nmax,obj.avenum);
                merr(:, :) = msds(j, :, :);
                handle = obj.plotAverageMSD(merr, en, cline(j));
                if j == 1
                    hm = [handle];
                    legends = [cellstr(obj.algoNames{j})];
                else
                    hm = [hm, handle];
                    legends = [legends; cellstr(obj.algoNames{j})];
                end
                hold on;
            end
            grid on
            xlabel('Iteration n', 'FontSize', 16);
            ylabel(' MSD [dB]', 'FontSize', 16);
            [tleg, objh, outh, outm] = legend(hm, legends, 'Location', obj.legendPosition);
            legend boxoff;
            set(objh, 'LineWidth', 4);
        end

        function outputEps(obj, name)
            if nargin == 1
                print -color -deps figoutput.eps
            elseif nargin == 2
                %print -color -deps name
                print(gcf, "-color", "-deps", name);
            end
        end

        %%
        %% the main loop of simulation
        %%
        function simulation(obj)
            avenum = obj.avenum;
            nmax = obj.nmax;
            nmax2 = obj.nmax2;
            unknown = obj.unknownSystem;
            algonum = length(obj.algorithm)
            errs = zeros(algonum, nmax, avenum);
            msds = zeros(algonum, nmax, avenum); % mean squared deviation
            outputs = zeros(algonum, nmax, avenum);

            for en = 1: avenum
                en
                obj.initialize(unknown);
                for i = 1:nmax
                    [input, output] = unknown.getOutputSample(unknown.getInputSample());
                    for a = 1: algonum
                        [outputs(a,i,en),errs(a,i,en)] = obj.algorithm{a}.iteration(input, output);
                        unk = unknown.getCoefficients();
                        [msds(a,i,en)] = obj.algorithm{a}.calcMSD(unk);
                    end
                end
                %obj.plotResults(errs, en);
                if obj.gnum > 0
                    obj.adfGraph.updateData(obj.algorithm);
                end
            end
            obj.plotResults(errs, avenum);
            obj.plotMSDs(msds, avenum);
            % print -color -deps figsim.eps
        end
    end
end
