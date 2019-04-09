%%% GMM NLMS algorithm
%%%
classdef GMNLMS < AdaptiveFilter
    properties
        stepsize = 1.0; % Normalized step size parameter
        stabilize = 0.00001;  % Normalized step size parameter
        % means;        % gmm means
        % stds;        % gmm variants
        buff_input;        % gmm variants
        mnum;
        lenmkg = 20;        % length for making gmm
        sbuf;
        gwidth = 2.0;   % width of the gaussian distribution
        aven = 1;        % time index for averaging to make gmm
        vgmm;
        gnum = 5;           % number of Gaussian distributions used in GMM
        forgetmu;
        forgetstd;
        bwidth;
    end
    methods
        function obj = GMNLMS(hlen, slen, gnum, forgetmu, forgetstd, bwidth)
            obj@AdaptiveFilter(hlen);
            obj.name = 'gmm-nlms';
            obj.buff_input = zeros(hlen, 300);
            obj.sbuf = zeros(slen, 1);
            obj.saveNum = 1;
            obj.forgetmu = forgetmu;
            obj.forgetstd = forgetstd;
            obj.bwidth = bwidth;
            obj.gnum = gnum;
            obj.vgmm = VGMM(hlen, gnum);
            obj.vgmm.setForgetmu(forgetmu);
            obj.vgmm.setForgetstd(forgetstd);
            obj.vgmm.setBandwidth(bwidth);
        end

        function obj = setStepsize(obj, stepsize)
            obj.stepsize = stepsize;
        end

        function obj = initAlgorithm(obj)
            initAlgorithm@AdaptiveFilter(obj);
            obj.buff_input = zeros(obj.flen, 300);
            obj.aven = 1;
            obj.vgmm = VGMM(obj.flen, obj.gnum);
            obj.vgmm.setForgetmu(obj.forgetmu);
            obj.vgmm.setForgetstd(obj.forgetstd);
            obj.vgmm.setBandwidth(obj.bwidth);
        end

        function bufferName = initSaveData(obj)
            bufferName = 'Number of MM';
        end

        function [buf] = getSaveData(obj)
            buf = obj.sbuf;
        end

        function obj = setGwidth(obj, width)
            obj.gwidth = width;
        end

        function obj = plotMM(obj)
            plot(obj.sbuf);
        end

        function obj = update(obj, e, input)
            xa = input'*input;
            wold = obj.Coefficients;
            w2 = wold + obj.stepsize/(xa+ obj.stabilize) * e * input;

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

        end
    end
end
