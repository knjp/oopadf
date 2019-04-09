classdef RLS < AdaptiveFilter
    properties
        lambda = 0.95   ;    % the fogetting factor
        sigma = 0.000001;
        p    ;               % The inverse of correlation matrix
        kvec        ; % The kalman vector
    end
    methods
        function obj = RLS(flen)
            obj@AdaptiveFilter(flen);
            obj.kvec = zeros(flen, 1);
            obj.p = 1/obj.sigma * eye(flen);
            obj.name = 'RLS';
        end
        function obj = initAlgorithm(obj)
            initAlgorithm@AdaptiveFilter(obj);
            obj.kvec = zeros(obj.flen, 1);
            obj.p = 1/obj.sigma * eye(obj.flen);
        end
        function obj = update(obj, e, input)
            % xa = input'*input;
            w2 = obj.Coefficients;
            p = obj.p;
            lambda = 1/obj.lambda;
            k = lambda * p * input/(1+lambda * input' * p * input);
            hdiff = k * e;
            obj.Coefficients = w2 + hdiff;
            obj.p = lambda*p - lambda * k * input' * p;
            % obj.Coefficients = w2;
        end
        end
end
