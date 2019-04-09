classdef SystemBaseLinear < handle
    properties (GetAccess = protected)
        coefficients;
        inputVector;
        noiseStd = 0;
        signalStd = 1;
        time = 0;
        osample = 0;    % the sample at one step before
        arcoef = 0.95;  % the coefficient of AR(1) process
    end
    properties (Dependent)
        Length
    end
    methods
        function obj = SystemBaseLinear(coeff)
            if nargin > 0
                [x, y] = size(coeff);
                if x>y
                    mb = coeff;
                else
                    mb = coeff';
                end
                obj.coefficients = mb;
                obj.inputVector = zeros(size(mb));
            end
        end

        function obj = set.coefficients(obj, coeff)
            if length(coeff) < 1
                error('Length must be positive')
                end
            obj.coefficients = coeff;
        end

        function val = get.Length(obj)
            val = length(obj.coefficients);
        end

        function obj = setCoefficients(obj, coeff)
            obj.coefficients = coeff;
        end

        function coeff = getCoefficients(obj)
            coeff = obj.coefficients;
        end

        function obj = setSignalStd(obj, std)
            obj.signalStd = std;
        end

        function setSNR(obj, snr)
            SNR_linear = 10^(snr/10);
            noise_power = obj.signalStd^2/SNR_linear;
            obj.noiseStd = sqrt(noise_power);
        end

        function setARcoef(obj, arcoef)
            obj.arcoef = arcoef;
        end

        function arcoef = getARcoef(obj)
            arcoef = obj.arcoef;
        end

        function setTime(obj, time)
            obj.time = time;
        end

        %
        % override the follwoing three functions to implement the unknown system.
        %
        function sample = getInputSample(obj)
            x = randn() + obj.osample*obj.arcoef;
            sample = obj.signalStd * (x/sqrt(1 + obj.arcoef));
            obj.osample = sample;
        end

        function [input output] = unknownSystemMain(obj, input)
            obj.inputVector = [input; obj.inputVector(1:obj.Length-1)];
            output = obj.inputVector' * obj.coefficients;
        end

        function [input output] = getOutputSample(obj, newinput)
            obj.time = obj.time + 1;
            [x, y] = obj.unknownSystemMain(newinput);
            input = x;
            noise = obj.noiseStd * randn();
            output =  y + noise;
        end

        function freq(obj,sig)
            if nargin > 1
                f = fft(sig, 1024);
            else
                f = fft(obj.coefficients, 1024);
            end
            a = abs(f);
            ft = 0:1/1024:1 -1/1024;
            plot(ft, 10*log10(a));
            title('Amplitude components');
            xlabel('Normalized Frequency');
        end

        function plot(obj)
            l = obj.Length;
            s = randn(l,1);
            plot(s);
            title(['test filter']);
        end
        function disp(obj)
            length = obj.Length;
            disp(['Filter length: ',num2str(length)]);
            disp(['Filter Coefficinets: ']);
            obj.coefficients'
            disp(['Input Vector: ']);
            obj.inputVector'
            disp(['Noise Std: ']);
            obj.noiseStd
        end
    end
end
