classdef NLMS < AdaptiveFilter
    properties
        stepsize = 1.0; % Normalized step size parameter
        stabilize = 0.00001;  % Normalized step size parameter
    end
    methods
        function obj = NLMS(hlen)
            obj@AdaptiveFilter(hlen);
            obj.name = 'NLMS';
        end

        function obj = setStepsize(obj, stepsize)
            obj.stepsize = stepsize;
        end

        function obj = update(obj, e, input)
            xa = input'*input;
            w2 = obj.Coefficients;
            w2 = w2 + obj.stepsize/(xa+ obj.stabilize) * e * input;
            obj.Coefficients = w2;
        end
    end
end
