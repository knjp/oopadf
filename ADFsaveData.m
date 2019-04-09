classdef ADFsaveData < handle
    properties
        numAlgorithms = 1;
        enum = 0;
        dataBuffer
    end

    methods
        function obj = ADFsaveData(algonum, algorithms, ensembleNum, nLength)
            obj.numAlgorithms = algonum;
            fmax = algonum
            for i = 1:algonum
                datanum = algorithms{i}.getSaveNum()
            end
            obj.enum = ensembleNum;
            obj.dataBuffer = zeros(1, nLength);
        end

        function obj = updateSaveData(obj, algorithms)
            buf = algorithms{1}.getSaveData();
            obj.dataBuffer = obj.dataBuffer + buf;
        end

        function obj = saveDataPlot(obj, algorithms)
            buf = algorithms{1}.getSaveData();

            buf = obj.dataBuffer/ obj.enum;
            figure; hold off;
            plot(buf);
        end

    end
end
