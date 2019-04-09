% GMM class (Vector version)
%
classdef VGMM < handle
    properties
        length;         % length of the vector
        gnum;           % number of  Gaussian distribution
        means;
        stds;
        weights;
        used;
        forgetmu = 0.2;
        forgetstd = 0.2;
        %bwidth = 2.0;
        bwidth = 8.00;
    end
    methods
        function obj = VGMM(len, gnum)
            obj.length =  len;
            obj.gnum = gnum;
            obj.means = zeros(len, gnum);
            obj.stds = zeros(len, gnum);
            obj.weights = zeros(len, gnum);
            obj.used = zeros(len, gnum);
        end

        function obj = setForgetmu(obj, forgetmu)
            obj.forgetmu = forgetmu;
        end
        function obj = setForgetstd(obj, forgetstd)
            obj.forgetstd = forgetstd;
        end
        function obj = setBandwidth(obj, bwidth)
            obj.bwidth = bwidth;
        end

        function obj = initModel(obj, sample)
            fm = obj.forgetmu;
            fs = obj.forgetstd;
            i = 1;
            for j = 1:obj.length
                obj.used(j, i) = 1;
                obj.weights(j, i) = 1;

                omean = obj.means(j, i);
                ostd = obj.stds(j, i);
                newmean = (1-fm)*omean + fm*sample(j);
                istd = (sample(j) - omean).*(sample(j) - omean);
                newstd = (1-fs)*ostd*ostd + fs*istd;
                obj.means(j, i) = newmean;
                obj.stds(j, i) = sqrt(newstd);
            end
        end
        function obj = updateModel(obj, sample)
            for len = 1:obj.length
                %
                matched = 0;
                fm = obj.forgetmu;
                fs = obj.forgetstd;
                bwidth = obj.bwidth;
                %
                sample0 = sample(len);
                for i = 1:obj.gnum;
                    if obj.used(len, i) ~= 0
                        std = obj.stds(len, i);
                        mean = obj.means(len, i);
                        width = bwidth * std;
                        if sample0 < (mean + width) && sample0 > (mean - width)
                            obj.means(len, i) = (1-fm)*mean + fm*sample0;
                            stds = (1-fs)*std*std + fs*(sample0-mean)*(sample0-mean);
                            obj.stds(len, i)  = sqrt(stds);
                            obj.weights(len, i) = obj.weights(len, i) + 0.1;
                            numUsed = sum(obj.used(len,:) == 1);
                            for j = 1:obj.gnum
                                if j ~= i && obj.used(len, j) == 1
                                    obj.weights(len, j) = obj.weights(len,j) - 0.1/numUsed;
                                end
                            end
                            wall = sum(obj.weights(len,:));
                            obj.weights(len,:) = obj.weights(len,:)/wall;
                            obj.used(len,:) = 1 * (obj.weights(len,:) > 0.1);
                            matched = 1;
                            break;   % stop for loop
                        end
                    end
                end
                if matched == 0
                    for i = 1:obj.gnum
                        if obj.used(len, i) == 0
                            obj.used(len, i) = 1;
                            obj.means(len, i) = sample0;
                            obj.stds(len, i) = sqrt(1);
                            obj.weights(len, i) = obj.weights(len,i) + 0.1;
                            numUsed = sum(obj.used(len,:) == 1);
                            for j = 1:obj.gnum
                                if j ~= i && obj.used(len,j) == 1
                                    obj.weights(len,j) = obj.weights(len,j) - 0.1/numUsed;
                                end
                            end
                            wall = sum(obj.weights(len,:));
                            obj.weights(len,:) = obj.weights(len,:)/wall;
                            obj.used(len,:) = 1 * (obj.weights(len,:) > 0.1);
                            break;
                        end
                    end
                end
            end
        end
        function average = calcAverage(obj)
            average = zeros(obj.length, 1);
            for j = 1:obj.length
                average(j,1) = obj.weights(j,:) * obj.means(j,:)';
            end
        end
    end
end

