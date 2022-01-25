classdef Mic

    properties
        % Required inputs:
        % 1. Name for mic
        % 2. .mat FR voltage file
        % 3. Frequency range to be covered
        % 4. Number of elements in the tested frequency range
        % 5. .mat PSD voltage file
        % 6. Sampling frequency
        % 7. Microphone sensitivity (optional)
        name
        micVoltFile
        freqRange
        numFreqs
        psdFile
        sampFreq
        micSensDBV % STILL TO BE IMPLEMENTED...

        % Calculated variables:
        micSensVolt
        lvlSensDBV
        lvlSensVolt
        logFreqArray
        linFreqArray
        freqArray
        lvlDBsplFR
        lvlDBsplPSD
        lvlVoltFR
        lvlVoltPSD
        micVoltFR
        micVoltPSD
        normVoltFR
        normVoltPSD
        normDBFR
        normDBPSD
        meanGain
        stdDev
        tolerance
    end

    methods
        function obj = Mic(name, micVoltFile, freqRange, numFreqs, psdFile, sampFreq, micSensDBV)
            % This constructor takes in required voltage data and a few
            % other details, and then automatically calculates
            % everything needed and plots the frequency response (FR), the power
            % spectral density (PSD), and other characteristic details all from
            % one object instantiation.

            % Required inputs:
            obj.name = name;
            obj.micVoltFile = micVoltFile;
            obj.freqRange = freqRange;
            obj.numFreqs = numFreqs;
            obj.psdFile = psdFile;
            obj.sampFreq = sampFreq;

            % Optional: include mic sensitivity.
            obj.micSensDBV = micSensDBV;
            obj.micSensVolt = 10^(obj.micSensDBV/20);
            % Level Meter Sensitivity 10mV/1dB
            % http://www.extech.com/products/resources/HD600_UM-en.pdf
            obj.lvlSensVolt = 0.01;
            % Converted to sensitivity in dBV leads to -40 dBV sensitivity.
            % https://www.analog.com/media/en/analog-dialogue/volume-46/number-2/articles/understanding_microphone_sensitivity.pdf
            obj.lvlSensDBV = 20*log10(obj.lvlSensVolt);
            [obj.logFreqArray, obj.linFreqArray] = getFreqArrays(obj);

            % COME READ ME!!! https://acousticnature.com/journal/which-microphone-sensitivity-is-better-dbv-vs-mv

%             obj.lvlDBsplFR = lvlArrayAvgDB(obj);
            % FIX ME!!! FAKE DATA FOR TESTING!!!
            obj.lvlDBsplFR = [56.4, 61.7, 72.5, 80.1, 88, 90.1, 87.2, 87, 82.9, 80.8, 80.4, 79, ...
                82, 80.3, 84.5, 82, 89, 87.4, 88.2, 86.3, 87.3, 85.7, 85.3, 88.6, 87];

%             obj.lvlDBsplFR = lvlArrayAvgDB(obj);
            % FIX ME!!! FAKE DATA FOR TESTING!!!
            obj.lvlDBsplPSD = [56.4, 61.7, 72.5, 80.1, 88, 90.1, 87.2, 87, 82.9, 80.8, 80.4, 79, ...
                82, 80.3, 84.5, 82, 89, 87.4, 88.2, 86.3, 87.3, 85.7, 85.3, 88.6, 87];

            % Convert sound pressure dB to voltage:
            % https://electronics.stackexchange.com/questions/96205/how-to-convert-volts-to-db-spl
            obj.lvlVoltFR = dbsplToVolt(obj, 'Log');
            obj.lvlVoltPSD = dbsplToVolt(obj, 'Lin');

%             obj.micVoltFR = avgMicVolt(obj, 'Log');
%             obj.micVoltPSD = avgMicVolt(obj, 'Lin');
            % FIX ME!!! FAKE DATA FOR TESTING!!!
            obj.freqArray = obj.logFreqArray(2:24);
            volt = avgMicVolt(obj, 'Log');
            obj.micVoltFR = [9e-5, volt, 0.0015];

            % Normalize two data sets via voltage gain ratio.
            obj.normVoltFR = obj.micVoltFR./obj.lvlVoltFR;
            % Convert to dB.
            obj.normDBFR = 20*log10(obj.normVoltFR);
            % Find the mean gain, the standard deviation, and the
            % corresponding tolerance percentage.
            obj.meanGain = sum(obj.normDBFR)/length(obj.normDBFR);
            obj.stdDev = sqrt((sum(obj.normDBFR.^2)/length(obj.normDBFR)) - (obj.meanGain^2));
            obj.tolerance = (((obj.meanGain - obj.stdDev) - obj.meanGain)*100)/obj.meanGain;

            % Display all results.
            figure('Name', obj.name, 'NumberTitle', 'off');
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
            plotFreqResp(obj);
            dispFreqRespDetails(obj);
            plotPSD(obj);
        end

        function plotFreqResp(obj)
            % Plots FR graphs for the mic, the level meter, and then the
            % normalized response.
            subplot(2, 3, 1);
            semilogx(obj.logFreqArray, obj.micVolt); grid on;
            xlabel('Frequency (Hz)'); ylabel('Voltage (V)');
            title('Mic Voltage Data');
        
            subplot(2, 3, 2);
            semilogx(obj.logFreqArray, obj.lvlVolt); grid on;
            xlabel('Frequency (Hz)'); ylabel('Voltage (V)');
            title('Level Meter Voltage');
        
            subplot(2, 3, 3);
            semilogx(obj.logFreqArray, obj.normDB); grid on; ylim([-80, 0]);
            xlabel('Frequency (Hz)'); ylabel('Normalized Mic Voltage Gain (dB)');
            title('True Frequency Response');
        end

        function dispFreqRespDetails(obj)
            % Displays the mic FR mean gain, standard deviation, and
            % tolerance on the figure.
            ax = subplot(2, 3, 6);
            title('True Frequency Response Details');
            str1 = sprintf('Mean Normalized Gain: %0.2f dB', obj.meanGain);
            str2 = sprintf('Standard Deviation: +-%0.2f dB', obj.stdDev);
            str3 = sprintf('Tolerance: +-%0.2f%%', obj.tolerance);
            str = [str1, newline, str2, newline, str3];
            if (obj.micSensDBV ~= -Inf)
                str4 = sprintf('Rated Mic Sensitivity (dBV): %0.2f dBV', obj.micSensDBV);
                str5 = sprintf('Rated Mic Sensitivity (Voltage): %0.4f V', obj.micSensVolt);
                str = [str, newline, newline, str4, newline, str5];
            end
            text(0.5, 0.95, str, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'baseline');
            set(ax, 'visible', 'off');
            set(ax.Title, 'visible', 'on');
        end

        function plotPSD(obj)
            % Plots PSD graphs for the mic, the level meter, and then the
            % normalized response.

%             load(obj.psdFile);
%             [psd, freqs] = periodogram(micPSDVoltWhite, [], [], obj.sampFreq);
%             subplot(2, 3, 4);
%             plot(freqs, 10*log10(psd));
%             xlabel('Hz'); ylabel('dB/Hz');
%             title('Power Spectral Density (White Noise)');
% 
%             [psd, freqs] = periodogram(micPSDVoltSine, [], [], obj.sampFreq);
%             subplot(2, 3, 5);
%             plot(freqs, 10*log10(psd));
%             xlabel('Hz'); ylabel('dB/Hz');
%             title('Power Spectral Density (Sine Wave)');

            subplot(2, 3, 5);
            t = 0:1/obj.sampFreq:1-1/obj.sampFreq;
            x = cos(2*pi*100*t) + sin(2*pi*150*t) + randn(size(t));
            [pxx, f] = periodogram(x, rectwin(length(x)), length(x), obj.sampFreq);
            plot(f, 10*log10(pxx));
            xlabel('Hz'); ylabel('dB/Hz');
            title('Power Spectral Density');

%             subplot(2, 3, 5);
%             t = 0:1/obj.sampFreq:1-1/obj.sampFreq;
% 
%             % Build the signal into its frequency components.
%             for i = 1:length(x)
% 
% 
%             x = cos(2*pi*100*t) + sin(2*pi*150*t) + randn(size(t));
%             [pxx, f] = periodogram(x, rectwin(length(x)), length(x), obj.sampFreq);
%             plot(f, 10*log10(pxx));
%             xlabel('Hz'); ylabel('dB/Hz');
%             title('Power Spectral Density');
        end

        function builtSignal = buildPSDSig(obj)
            hello
        end


        function micVoltAvg = avgMicVolt(obj)
            % Parses and averages the many recorded voltages for each
            % frequency and condenses the averaged values into one 1D
            % voltage array.

            load(obj.micVoltFile);
            freqArrayStr = string(obj.freqArray);
            % micVoltArray50 = MicProgramDataParser(a_50);
            % micVoltArray63 = MicProgramDataParser(a_63);
            % micVoltArray79 = MicProgramDataParser(a_79); ...
            for i = 1:length(freqArrayStr)
                micVoltArray = genvarname(['micVoltArray', char(freqArrayStr(i))]);
                str = sprintf(' = MicProgramDataParser(obj, a_%d);', obj.freqArray(i));
                eval([micVoltArray, str]);
            end
            
            % micVoltAvg50 = sum(micVoltArray50)/length(micVoltArray50);
            % micVoltAvg63 = sum(micVoltArray63)/length(micVoltArray63);
            % micVoltAvg79 = sum(micVoltArray79)/length(micVoltArray79); ...
            for i = 1:length(freqArrayStr)
                micVoltAvg = genvarname(['micVoltAvg', char(freqArrayStr(i))]);
                str = sprintf(' = sum(micVoltArray%d)/length(micVoltArray%d);', obj.freqArray(i), obj.freqArray(i));
                eval([micVoltAvg, str]);
            end
        
            % micVoltAvg = [micVoltAvg50, micVoltAvg63, micVoltAvg79, ...
            micVoltAvg = zeros([1, length(freqArrayStr)]);
            for i = 1:length(micVoltAvg)
                micVoltA = genvarname(['micVoltAvg', char(freqArrayStr(i))]);
                str1 = sprintf(['micVoltAvg(i) = ', micVoltA, ';']);
                eval(str1);
            end
        end

        function dataArray = MicProgramDataParser(~, str)
            % Parses the data obtained via the automated program in the
            % Data Retrieval folder.

            % Typical audio analyzer data string looks like this:
            % ["+01479E-05", "+01484E-05", ... "+01493E-05"]
            L = length(str);
            dataArray = zeros([1, L]);
            for i = 1:L
                dataArray(i) = str2double(str(i));
            end
        end

        function dataArray = InstrControlDataParser(~, str)
            % Parses the data if recorded manually via Instrument Control.
            % If the provided automated program in the Data Retrieval
            % folder was used, this function is not needed.

            % Typical audio analyzer data string looks like this:
            % +01479E-05+01484E-05 ... +01493E-05+014
            
            % Cuts off last voltage value where recording timeout happens
            % and there is not enough time for it to store all the
            % characters of the last voltage data point.
            rem = mod(length(str), 10);
            str = str(1:end - rem);
            
            % Separates string and converts to an array of double values.
            % Usually ends up having around 42 data points.
            L = length(str)/10;
            dataArray = zeros([1, L]);
            for i = 1:L
                dataArray(i) = str2double(str(1:10));
                str = str(11:end);
            end
        end

        function lvlVolt = dbsplToVolt(obj, spacing)
            % Converts the DBspl gain from the level meter to voltage. The
            % level meter mic sensitivity is needed to properly calculate
            % this.

            if (strcmp(spacing, 'Log'))
                lvlDBspl = obj.lvlDBsplFR;
            else
                lvlDBspl = obj.lvlDBsplPSD;
            end

            % Calculations reference:
            % https://electronics.stackexchange.com/questions/96205/how-to-convert-volts-to-db-spl
            lvlVolt = zeros([1, length(lvlDBspl)]);
            for i = 1:length(lvlDBspl)
                % Subtract unit Pascal, 1 Pa = 94 dB.
                lvlVolt(i) = lvlDBspl(i) - 94;
                % Subtract the level meter microphone sensitivity.
                lvlVolt(i) = lvlVolt(i) - obj.lvlSensDBV;
                % Convert from dB to voltage gain ratio. 
                lvlVolt(i) = 10^(lvlVolt(i)/20);
                % Multiply the ratio by the level meter voltage sensitivity
                % to get actual measured level meter voltage.
                lvlVolt(i) = lvlVolt(i)*obj.lvlSensVolt;
            end
        end

        function lvlDBspl = lvlArrayAvgDB(obj)
            % Takes the retrieved level meter data, makes proper
            % conversions, and averages the data for each frequency.
            % Returns a 1D array of averaged level meter DBspl gain
            % corresponding to each tested frequency.
            lvlDBCellArray = getLevelMeterData(obj);
            len = length(lvlDBCellArray);
            lvlDBspl = zeros([1, len]);
            for i = 1:len        
                % Cannot linearly average values from a logarithmic scale.
                % Converting DBspl to power is necessary.
                gainRatio = 10.^(lvlDBCellArray{i}/10);
                power = gainRatio * 10^(-12);
                avgPower = sum(power)/length(power);
                % Convert back to DBspl.
                gainRatio = avgPower / (10^(-12));
                lvlDBspl(i) = 10*log10(gainRatio);
            end
        end

        function [logLvlDBCellArray, linLvlDBCellArray] = getLevelMeterData(obj)
            % Chooses the folder for each frequency set and then calls the
            % TraverseFiles function that parses the data from each level
            % meter .txt file. Returns a cell array of the interpreted data
            % for each.
            cd 'Log Level Meter Files';
            logLvlDBCellArray = TraverseFiles;
            cd '../';
            cd 'Lin Level Meter Files';
            linLvlDBCellArray = TraverseFiles;
            cd '../';
        end

        function [logFreqArray, linFreqArray] = getFreqArrays(obj)
            % Calculates linearly and logarithmically spaced frequency
            % arrays based on the specified range and number of frequency
            % elements.

            % Logarithmically spaced for FR plots.
            i = linspace(log10(obj.freqRange(1)), log10(obj.freqRange(2)), obj.numFreqs);
            logFreqArray = zeros([1, length(i)]);
            roundFactor = 0; j = 1;
            while (j <= length(i))
                logFreqArray(j) = round(10^(i(j)), roundFactor);
                if ((j == 2) && (logFreqArray(2) == logFreqArray(1)))
                    j = 0;
                    roundFactor = roundFactor + 1;
                end
                j = j + 1;
            end

            % Linearly spaced for PSD plots.
            i = linspace(obj.freqRange(1), obj.freqRange(2), obj.numFreqs);
            linFreqArray = zeros([1, length(i)]);
            roundFactor = 0; j = 1;
            while (j <= length(i))
                linFreqArray(j) = round(i(j), roundFactor);
                if ((j == 2) && (linFreqArray(2) == linFreqArray(1)))
                    j = 0;
                    roundFactor = roundFactor + 1;
                end
                j = j + 1;
            end

        end
    end
end