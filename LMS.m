classdef LMS < AdaptiveFilter
    properties
        stepsize = 0.1; % Normalized step size parameter
    end
    methods

        function obj = LMS(hlen)
            obj@AdaptiveFilter(hlen);
            obj.name = 'LMS';
        end

        function obj = setStepsize(obj, stepsize)
            obj.stepsize = stepsize;
        end

        function obj = update(obj, n, e, input)
            xa = input'*input;
            w2 = obj.Coefficients;
            w2 = w2 + obj.stepsize * e * input;
            obj.Coefficients = w2;
        end
    end
end
