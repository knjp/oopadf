classdef SystemTVS < SystemBaseLinear
    properties
        coefficients2;
        nchange = 200;  % The time for changing the system
    end
    methods
        %%
        %%    Constructor
        %%
        function obj = SystemTVS(coeff1, coeff2)
            obj@SystemBaseLinear(coeff1);
            if nargin > 0
                [x, y] = size(coeff2);
                if x>y
                    mb = coeff2;
                else
                    mb = coeff2';
                end
                obj.coefficients2 = mb;
            end
        end
        function setNchange(obj, n)
            obj.nchange = n;
        end

        function coeff = getCoefficients(obj)
            if obj.time < obj.nchange
                coef = obj.coefficients;
            else
                coef = obj.coefficients2;
            end
            coeff = coef;
        end

        function [input output] = unknownSystemMain(obj, input)
            obj.inputVector = [input; obj.inputVector(1:obj.Length-1)];
            if obj.time < obj.nchange
                coef = obj.coefficients;
            else
                coef = obj.coefficients2;
            end
            output = obj.inputVector' * coef;
        end
    end
end
