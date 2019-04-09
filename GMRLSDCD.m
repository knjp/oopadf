%%  RLS-DCD with GMM
%%
classdef GMRLSDCD < AdaptiveFilter
    properties
        H = 1;
        Nu = 4;
        Mb = 8;
        ff = 0.98;        % the forgetting factor
        kp;
        mmax;
        R = 10^-3;        % Auto correlation matrix
        r = 0;        % Cross correlation matrix
        %%%%%%
        aven = 1;
        lenmkg = 20;        % length for making gmm
        vgmm;
        gnum = 5;           % number of Gaussian distributions used in GMM
        forgetmu;
        forgetstd;
        bwidth;
    end
    methods
        function obj = GMRLSDCD(hlen, gnum, forgetmu, forgetstd, bwidth)
            obj@AdaptiveFilter(hlen);
            obj.name = 'RLS-DCD(vgmm)';

            %
            obj.forgetmu = forgetmu;
            obj.forgetstd = forgetstd;
            obj.bwidth = bwidth;
            obj.gnum = gnum;
            for j = 1:hlen
            end
            obj.vgmm = VGMM(obj.flen, obj.gnum);
            obj.vgmm.setForgetmu(forgetmu);
            obj.vgmm.setForgetstd(forgetstd);
            obj.vgmm.setBandwidth(bwidth);
        end
        function obj = initAlgorithm(obj)
            initAlgorithm@AdaptiveFilter(obj);
            obj.R = 10^-3;        % Auto correlation matrix
            obj.r = 0;        % Cross correlation matrix
            obj.vgmm = VGMM(obj.flen, obj.gnum);
            obj.vgmm.setForgetmu(obj.forgetmu);
            obj.vgmm.setForgetstd(obj.forgetstd);
            obj.vgmm.setBandwidth(obj.bwidth);
            obj.aven = 1;
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

            w2 = w + dhh;
            wupdate = zeros(obj.flen, 1);
            n = obj.aven;

            if(n < obj.lenmkg)
               obj.vgmm.initModel(w2);
            else
               obj.vgmm.updateModel(w2);
            end

            wupdate = obj.vgmm.calcAverage();
            obj.aven = n + 1;
            obj.Coefficients = wupdate;

            obj.r = r;
            obj.R = R;
%            obj.Coefficients = w;
        end
    end
end
