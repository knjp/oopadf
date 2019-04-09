classdef AdaptiveFilter < handle
    properties
        Coefficients
        InputVector
        flen        % the length of the filter
        name = 'Algorithm name';
        saveNum = 0;    % the number of data for saving after the simulation
        saveData = 0;    % the buffer for the save data
    end

    methods
        function obj = AdaptiveFilter(flen)
            obj.flen = flen;
            obj.Coefficients = zeros(flen, 1);
            obj.InputVector = zeros(flen, 1);
        end

        function obj = setName(obj, name)
            obj.name = name;
        end

        function flen = getFlen(obj)
            flen = obj.flen;
        end

        function savenum = getSaveNum(obj, varname)
            savenum = obj.saveNum;
        end

        function [y, error] = update(obj, e, input)
            % do nothing in the AdaptiveFilter class
            % You need to implement the adaptive algorithm for each subclass
        end

        function obj = initAlgorithm(obj)
            obj.Coefficients = zeros(obj.flen, 1);
            obj.InputVector = zeros(obj.flen, 1);
        end

        function [y, error] = initBuffer(obj, input, desire)
            obj.InputVector = [input; obj.InputVector(1:obj.flen-1)];
            y = obj.InputVector' * obj.Coefficients;
            error = desire - y;
        end

        function obj = initSaveData(obj)
            % should be overrode in the extended classes
        end

        function buf = getSaveData(obj)
            buf = obj.saveData;
        end

        function [y, error] = iteration(obj, input, desire)
            obj.InputVector = [input; obj.InputVector(1:obj.flen-1)];
            y = obj.InputVector' * obj.Coefficients;
            error = desire - y;
            obj = obj.update(error, obj.InputVector);
        end

        function msd = calcMSD(obj, coef)
            diff = coef - obj.Coefficients;
            msd = diff' * diff/(coef'*coef);
        end

        function plotmse(obj, err, color)
            e2 = err .^2;
            plot(10*log10(e2), color);
        end

        function plotAverageMSE(obj, err, num, color)
            e2 = 0;
            for i = 1: num
                ei = err(:,i);
                e2 = e2 + ei.^2;
            end
            plot(10*log10(e2/num), color);
        end
    end
end
