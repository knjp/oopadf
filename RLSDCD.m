classdef RLSDCD < AdaptiveFilter
    properties
        H = 1;
        Nu = 4;
        Mb = 8;
        ff = 0.98;        % the forgetting factor
        kp;
        mmax;
        R = 10^-3;        % Auto correlation matrix
        r = 0;        % Cross correlation matrix
    end
    methods
        function obj = RLSDCD(hlen)
            obj@AdaptiveFilter(hlen);
            obj.name = 'RLS-DCD';
        end
        function obj = initAlgorithm(obj)
            initAlgorithm@AdaptiveFilter(obj);
            obj.R = 10^-3;        % Auto correlation matrix
            obj.r = 0;        % Cross correlation matrix
        end
        function obj = update(obj, e, input)
            R = obj.R;
            r = obj.r;
            w = obj.Coefficients;
            ff = obj.ff;

            R = ff * R + input * input';
            beta = ff*r + e*input;

            dhh = zeros(obj.flen, 1);
            r = beta;
            alf = obj.H/2;
            mm = 1;

            for k = 1 : obj.Nu
                [rmax, p] = max(abs(r));
                while abs(r(p)) <= alf/2 * R(p,p)
                    alf = alf/2;
                    mm = mm + 1;
                    if mm > obj.Mb
                        break;
                    end
                end
                if mm > obj.Mb
                    break;
                end
                dhh(p) = dhh(p) + sign(r(p))*alf;
                r = r - sign(r(p))*alf * R(:, p);
            end
            w = w + dhh;
            obj.r = r;
            obj.R = R;
            obj.Coefficients = w;
        end
    end
end
