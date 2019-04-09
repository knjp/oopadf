classdef GMRLS < AdaptiveFilter
    properties
        lambda = 0.95    ;    % the fogetting factor
        sigma = 0.000001;
        p        ; % The inverse of correlation matrix
        kvec        ; % The kalman vector
        %%%%%%
        aven = 1;
        lenmkg = 2;        % length for making gmm
        vgmm;
        gnum = 5;           % number of Gaussian distributions used in GMM
        forgetmu;
        forgetstd;
        bwidth;
        end
    methods
        function obj = GMRLS(flen, gnum, forgetmu, forgetstd, bwidth)
            obj@AdaptiveFilter(flen);
            obj.kvec = zeros(flen, 1);
            obj.p = 1/obj.sigma * eye(flen);
            obj.name = 'RLS(GMM)';

            obj.forgetmu = forgetmu;
            obj.forgetstd = forgetstd;
            obj.bwidth = bwidth;
            obj.gnum = gnum;
            obj.vgmm = VGMM(flen, gnum);
            obj.vgmm.setForgetmu(forgetmu);
            obj.vgmm.setForgetstd(forgetstd);
            obj.vgmm.setBandwidth(bwidth);
        end
        function obj = initAlgorithm(obj)
            initAlgorithm@AdaptiveFilter(obj);
            obj.kvec = zeros(obj.flen, 1);
            obj.p = 1/obj.sigma * eye(obj.flen);
            for j = 1:obj.flen
            end
            obj.vgmm = VGMM(obj.flen, obj.gnum);
            obj.vgmm.setForgetmu(obj.forgetmu);
            obj.vgmm.setForgetstd(obj.forgetstd);
            obj.vgmm.setBandwidth(obj.bwidth);

            obj.aven = 1;
            fmu = obj.forgetmu
            fstd = obj.forgetstd
        end
        function obj = update(obj, e, input)
            % xa = input'*input;
            wold = obj.Coefficients;
            p = obj.p;
            lambda = 1/obj.lambda;
            k = lambda * p * input/(1+lambda * input' * p * input);
            hdiff = k * e;
            % obj.Coefficients = wold + hdiff;
            obj.p = lambda*p - lambda * k * input' * p;

            w2 = wold + hdiff;
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
            % obj.Coefficients = w2;
        end
    end
end
