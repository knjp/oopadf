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
        fontsizeAxes = 14;
        fontsizeText = 14;
        fontsizeLabel = 16;
        lineWidth = 4;

        errs;
        msds;

        plotResults;
    end
    methods
        % Constructor
        function obj = ADFsimulation(varargin)
            if nargin > 0
                for i = 1: nargin
                    str1 = varargin{i}{1};
                    if strncmp(str1, 'algo', 4)
                        algos = varargin{i};
                        algs = varargin{i};
                        na = length(algos);
                        for j = 1:na-1
                            obj.algorithm{j} = algos{j+1};
                            obj.algoNames{j} = obj.algorithm{j}.name;
                        end
                    elseif strncmp(str1, 'dlen', 4)
                        obj.avenum = varargin{i}{2};
                        obj.nmax = varargin{i}{3};
                        lens = varargin{i};
                    elseif strncmp(str1, 'graph', 4)
                        obj.gnum = length(varargin{i});
                        obj.adfGraph = varargin{i}{2};
                    end
                end
            end
            obj.plotResults = ADFplotResults(algs, lens);

            % obj.inputSignal = SystemInput();
        end

        function obj = setNumIteration(obj, avenum, nmax)
            obj.avenum = avenum;
            obj.nmax = nmax;
        end

        function obj = setLegendPosition(obj, position)
            obj.legendPosition = position;
        end

        function obj = setFontsizeAxes(obj, size)
            obj.fontsizeAxes = size;
        end

        function obj = setFontsizeText(obj, size)
            obj.fontsizeText = size;
        end

        function obj = setFontsizeLabel(obj, size)
            obj.fontsizeLabel = size;
        end

        function obj = setLineWidth(obj, width)
            obj.lineWidth = width;
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
            nees = zeros(algonum, nmax, avenum); % normalized error error
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
                        [nees(a,i,en)] = obj.algorithm{a}.calcNEE(unk);
                    end
                end
                %obj.plotResults(errs, en);
                if obj.gnum > 0
                    obj.adfGraph.updateData(obj.algorithm);
                end
            end
            obj.errs = errs;
            obj.msds = msds;
            %obj.plotResults.plotMSEs(errs, avenum);
            obj.plotResults.plotMSDs(msds, avenum);
            %obj.plotResults.plotNEEs(nees, avenum);
            obj.plotResults.plotDiffMSDs(msds, avenum);
            % print -color -deps figsim.eps
        end
    end
end
