classdef SystemImpulseNoise < SystemTVS
    properties
        impulseAmp = 2.0;
        impulseProb = 0.001;
    end
    methods
        function obj = SystemImpulseNoise(coeff, coeff2)
            obj@SystemTVS(coeff, coeff2);
        end

        function setImpulseAmp(obj, amp)
            obj.impulseAmp = amp;
        end

        function setImpulseProb(obj, prob)
            obj.impulseProb = prob;
        end

        %
        % overriding the following method of SystemBaseLinear
        %
        function [input output] = getOutputSample(obj, newinput)
            obj.time = obj.time + 1;
            [input, y] = obj.unknownSystemMain(newinput);
            noise = obj.noiseStd * randn();

            % additive impulsive noise
            impulse = 0;
            der = rand();
            if der < obj.impulseProb;
                impulse = obj.impulseAmp;
            end
            output =  y + noise + impulse;
        end
    end
end
