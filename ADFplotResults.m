classdef ADFplotResults < handle
	properties
		avenum = 20;
		nmax = 200;
		nmax2 = 500;
		algorithm;
		unknownSystem;
		algoNames;
		legendPosition = 'north';
		% saveData;
        	adfGraph;
        	gnum = 0;                   % number of graph
        	inputSignal;
		fontsizeAxes = 14;
		fontsizeText = 14;
		fontsizeLabel = 16;
		lineWidth = 4;
        isOctave;
		errs;
		msds;
	end
	methods
        % Constructor
		function obj = ADFplotResults(varargin)
			if nargin > 0
				for i = 1: nargin
					str1 = varargin{i}{1};
					if strncmp(str1, 'algo', 4)
						algos = varargin{i};
						na = length(algos);
						for j = 1:na-1
							obj.algorithm{j} = algos{j+1};
							obj.algoNames{j} = obj.algorithm{j}.name;
						end
                        algnums = j
					elseif strncmp(str1, 'dlen', 4)
						obj.avenum = varargin{i}{2};
						obj.nmax = varargin{i}{3};
					elseif strncmp(str1, 'graph', 4)
                        obj.gnum = length(varargin{i});
                        obj.adfGraph = varargin{i}{2};
					end
				end
			end
            obj.isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
		end

		function obj = setNumIteration(obj, avenum, nmax)
			obj.avenum = avenum;
			obj.nmax = nmax;
		end

		function obj = setLegendPosition(obj, position)
			obj.legendPosition = position;
		end

		function obj = setFontsizeAxes(obj, size)
			obj.fontsizeAxes = size;
		end

		function obj = setFontsizeText(obj, size)
			obj.fontsizeText = size;
		end

		function obj = setFontsizeLabel(obj, size)
			obj.fontsizeLabel = size;
		end

		function obj = setLineWidth(obj, width)
			obj.lineWidth = width;
		end

		function obj = setUnknown(obj, unknown)
			obj.unknownSystem = unknown;
		end

		function plotmseold(obj, err, color)
			e2 = err .^2;
			plot(10*log10(e2), color);
		end

		function handle = plotAverageMSE(obj, err, num, color)
			e2 = 0;
			for i = 1: num
				ei = err(:,i);
				e2 = e2 + ei.^2;
			end
			handle = plot(10*log10(e2/num), color);
			set(handle, 'linewidth', 2);
		end

		function plotMSEs(obj, errs, en)
			algonum = length(obj.algorithm)
			%f = figure('visible', 'off');
			figure();
			hold off;
			legends = 0;
			set(0, 'defaultAxesFontSize', obj.fontsizeAxes);
			set(0, 'defaultTextFontSize', obj.fontsizeText);
			set(0, 'defaultAxesFontName', 'Helvetica');
			set(0, 'defaultTextFontName', 'Helvetica');
			% cline = ['b', 'r', 'g', 'k', 'c', 'y', 'm'];
			cline = ['b', 'r', 'g', 'c', 'k', 'm', 'y'];
			for j = 1 : algonum
				merr = zeros(obj.nmax,obj.avenum);
				merr(:, :) = errs(j, :, :);
				handle = obj.plotAverageMSE(merr, en, cline(j));
				if j == 1
					hm = [handle];
					legends = [cellstr(obj.algoNames{j})];
				else
					hm = [hm, handle];
					legends = [legends; cellstr(obj.algoNames{j})];
				end
				hold on;
			end
			grid on
			xlabel('Iteration n', 'FontSize', obj.fontsizeLabel);
			ylabel('Mean Square Error [dB]', 'FontSize', obj.fontsizeLabel);
			[tleg, objh, outh, outm] = legend(hm, legends, 'Location', obj.legendPosition);
			legend boxoff;
			set(objh, 'LineWidth', obj.lineWidth);

            fname = sprintf('saveMSEs-%s.fig', datestr(now, 'yyyymmdd-HHMMSS'));
            if (obj.isOctave)
            else
                savefig(fname);
            end
		end

		function handle = plotAverageMSD(obj, err, num, color)
			e2 = 0;
			for i = 1: num
				ei = err(:,i);
				e2 = e2 + ei;
			end
			handle = plot(10*log10(e2/num), color);
			set(handle, 'linewidth', obj.lineWidth);
		end

		function errs = getErrs(obj)
			errs = obj.errs;
		end

		function msds = getMSDs(obj)
			msds =  obj.msds;
		end

		function plotMSDs(obj, msds, en)
			algonum = length(obj.algorithm);
			%f = figure('visible', 'off');
			figure();
			hold off;
			legends = 0;
			set(0, 'defaultAxesFontSize', obj.fontsizeAxes);
			set(0, 'defaultTextFontSize', obj.fontsizeText);
			set(0, 'defaultAxesFontName', 'Helvetica');
			set(0, 'defaultTextFontName', 'Helvetica');
			%cline = ['b', 'r', 'g', 'k', 'c', 'y', 'm'];
			cline = ['b', 'r', 'g', 'c', 'k', 'm', 'y'];
			for j = 1 : algonum
				merr = zeros(obj.nmax,obj.avenum);
				merr(:, :) = msds(j, :, :);
				handle = obj.plotAverageMSD(merr, en, cline(j));
				if j == 1
					hm = [handle];
					legends = [cellstr(obj.algoNames{j})];
				else
					hm = [hm, handle];
					legends = [legends; cellstr(obj.algoNames{j})];
				end
				hold on;
			end
			grid on
			xlabel('Iteration n', 'FontSize', obj.fontsizeLabel);
			ylabel(' MSD [dB]', 'FontSize', obj.fontsizeLabel);
			[tleg, objh, outh, outm] = legend(hm, legends, 'Location', obj.legendPosition);
			legend boxoff;
			set(objh, 'LineWidth', obj.lineWidth);

            fname = sprintf('saveMSDs-%s.fig', datestr(now, 'yyyymmdd-HHMMSS'));
            if (obj.isOctave)
            else
                savefig(fname);
            end
		end

		function handle = plotAverageDiffMSD(obj, err, num, color)
            esize = size(err);
            elen = esize(1);
            err2 = zeros(elen, num);
            err2(1:elen-1, :) = err(2:elen, :);
            err3 = err - err2;
			e2 = 0;
			for i = 1: num
				ei = err3(:,i);
				e2 = e2 + ei;
			end
			%handle = plot(10*log10(abs(e2)/num), color);
			handle = plot((e2/num), color);
			set(handle, 'linewidth', 1);
		end

		function plotDiffMSDs(obj, msds, en)
			algonum = length(obj.algorithm);
			%f = figure('visible', 'off');
			figure();
			hold off;
			legends = 0;
			set(0, 'defaultAxesFontSize', obj.fontsizeAxes);
			set(0, 'defaultTextFontSize', obj.fontsizeText);
			set(0, 'defaultAxesFontName', 'Helvetica');
			set(0, 'defaultTextFontName', 'Helvetica');
			%cline = ['b', 'r', 'g', 'k', 'c', 'y', 'm'];
			cline = ['b', 'r', 'g', 'c', 'k', 'm', 'y'];
			for j = 1 : algonum
				merr = zeros(obj.nmax,obj.avenum);
				merr(:, :) = msds(j, :, :);
				handle = obj.plotAverageDiffMSD(merr, en, cline(j));
				if j == 1
					hm = [handle];
					legends = [cellstr(obj.algoNames{j})];
				else
					hm = [hm, handle];
					legends = [legends; cellstr(obj.algoNames{j})];
				end
				hold on;
			end
			grid on
			xlabel('Iteration n', 'FontSize', obj.fontsizeLabel);
			ylabel(' Diff MSD', 'FontSize', obj.fontsizeLabel);
			[tleg, objh, outh, outm] = legend(hm, legends, 'Location', obj.legendPosition);
			legend boxoff;
			set(objh, 'LineWidth', obj.lineWidth);

            fname = sprintf('saveDMSDs-%s.fig', datestr(now, 'yyyymmdd-HHMMSS'));
            if (obj.isOctave)
            else
                savefig(fname);
            end
		end

		function plotNEEs(obj, nees, en)
			algonum = length(obj.algorithm);
			%f = figure('visible', 'off');
			figure();
			hold off;
			legends = 0;
			set(0, 'defaultAxesFontSize', obj.fontsizeAxes);
			set(0, 'defaultTextFontSize', obj.fontsizeText);
			set(0, 'defaultAxesFontName', 'Helvetica');
			set(0, 'defaultTextFontName', 'Helvetica');
			%cline = ['b', 'r', 'g', 'k', 'c', 'y', 'm'];
			cline = ['b', 'r', 'g', 'c', 'k', 'm', 'y'];
			for j = 1 : algonum
				merr = zeros(obj.nmax,obj.avenum);
				merr(:, :) = nees(j, :, :);
				handle = obj.plotAverageMSD(merr, en, cline(j));
				if j == 1
					hm = [handle];
					legends = [cellstr(obj.algoNames{j})];
				else
					hm = [hm, handle];
					legends = [legends; cellstr(obj.algoNames{j})];
				end
				hold on;
			end
			grid on
			xlabel('Iteration n', 'FontSize', obj.fontsizeLabel);
			ylabel(' NEE [dB]', 'FontSize', obj.fontsizeLabel);
			[tleg, objh, outh, outm] = legend(hm, legends, 'Location', obj.legendPosition);
			legend boxoff;
			set(objh, 'LineWidth', obj.lineWidth);

            fname = sprintf('saveNEEs-%s.fig', datestr(now, 'yyyymmdd-HHMMSS'));
            if (obj.isOctave)
            else
                savefig(fname);
            end
		end

		function outputEps(obj, name)
			if nargin == 1
				print -color -deps figoutput.eps
			elseif nargin == 2
				%print -color -deps name
				print(gcf, '-color', '-deps', name);
			end
		end
	end
end
