classdef Mic

    properties
        % Required inputs:
        % 1. Name for mic
        % 2. .mat FR and PSD voltage file
        % 3. Frequency range to be covered
        % 4. Number of elements in the tested frequency range
        % 5. Sampling frequency
        % 6. Microphone sensitivity (optional)
        name
        dataFile
        freqRange
        numFreqs
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
        function obj = Mic(name, dataFile, freqRange, numFreqs, sampFreq, micSensDBV)
            % This constructor takes in required voltage data and a few
            % other details, and then automatically calculates
            % everything needed and plots the frequency response (FR), the power
            % spectral density (PSD), and other characteristic details all from
            % one object instantiation.

            % Required inputs:
            obj.name = name;
            obj.dataFile = dataFile;
            obj.freqRange = freqRange;
            obj.numFreqs = numFreqs;
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

            [obj.lvlDBsplFR, obj.lvlDBsplPSD] = lvlArrayAvgDB(obj);
            % FIX ME!!! FAKE DATA FOR TESTING!!!
%             obj.lvlDBsplFR = [56.4, 61.7, 72.5, 80.1, 88, 90.1, 87.2, 87, 82.9, 80.8, 80.4, 79, ...
%                 82, 80.3, 84.5, 82, 89, 87.4, 88.2, 86.3, 87.3, 85.7, 85.3, 88.6, 87];
            % FIX ME!!! FAKE DATA FOR TESTING!!!
%             obj.lvlDBsplPSD = [56.4, 61.7, 72.5, 80.1, 88, 90.1, 87.2, 87, 82.9, 80.8, 80.4, 79, ...
%                 82, 80.3, 84.5, 82, 89, 87.4, 88.2, 86.3, 87.3, 85.7, 85.3, 88.6, 87];

            % Convert sound pressure dB to voltage:
            % https://electronics.stackexchange.com/questions/96205/how-to-convert-volts-to-db-spl
            [obj.lvlVoltFR, obj.lvlVoltPSD] = dbsplToVolt(obj);

            [obj.micVoltFR, obj.micVoltPSD] = avgMicVolt(obj);
            % FIX ME!!! FAKE DATA FOR TESTING!!!
%             obj.freqArray = obj.logFreqArray(2:24);
%             [volt, ~] = avgMicVolt(obj);
%             obj.micVoltFR = [9e-5, volt, 0.0015];

            % Normalize the data sets.
            obj.normVoltFR = obj.micVoltFR./obj.lvlVoltFR;
            obj.normVoltPSD = obj.micVoltPSD./obj.lvlVoltPSD;
            % Convert to dB.
            obj.normDBFR = 20*log10(obj.normVoltFR);
            % Find the mean gain, the standard deviation, and the
            % corresponding tolerance percentage for FR.
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
            subplot(2, 4, 1);
            semilogx(obj.logFreqArray, obj.micVoltFR); grid on;
            xlabel('Frequency (Hz)'); ylabel('Voltage (V)');
            title('Mic Voltage Data');
        
            subplot(2, 4, 2);
            semilogx(obj.logFreqArray, obj.lvlVoltFR); grid on;
            xlabel('Frequency (Hz)'); ylabel('Voltage (V)');
            title('Level Meter Voltage');
        
            subplot(2, 4, 3);
            semilogx(obj.logFreqArray, obj.normDBFR); grid on; ylim([-80, 0]);
            xlabel('Frequency (Hz)'); ylabel('Normalized Mic Voltage Gain (dB)');
            title('True Frequency Response');
        end

        function dispFreqRespDetails(obj)
            % Displays the mic FR mean gain, standard deviation, and
            % tolerance on the figure.
            ax = subplot(2, 4, 4);
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

            voltMicPSD = buildPSDSig(obj, obj.micVoltPSD);
            voltLvlPSD = buildPSDSig(obj, obj.lvlVoltPSD);
            voltNormPSD = buildPSDSig(obj, obj.normVoltPSD);
            [pMic, fMic] = periodogram(voltMicPSD, rectwin(length(voltMicPSD)), length(voltMicPSD), obj.sampFreq);
            [pLvl, fLvl] = periodogram(voltLvlPSD, rectwin(length(voltLvlPSD)), length(voltLvlPSD), obj.sampFreq);
            [pNorm, fNorm] = periodogram(voltNormPSD, rectwin(length(voltNormPSD)), length(voltNormPSD), obj.sampFreq);
            subplot(2, 4, 5);
            plot(fMic, 10*log10(pMic));
            xlabel('Hz'); ylabel('dB/Hz');
            title('Mic Power Spectral Density');
            subplot(2, 4, 6);
            plot(fLvl, 10*log10(pLvl));
            xlabel('Hz'); ylabel('dB/Hz');
            title('Level Meter Power Spectral Density');
            subplot(2, 4, 7);
            plot(fNorm, 10*log10(pNorm));
            xlabel('Hz'); ylabel('dB/Hz');
            title('Normalized Power Spectral Density');
        end

        function builtSignal = buildPSDSig(obj, volt)
            t = 0:1/obj.sampFreq:1-1/obj.sampFreq;
            builtSignal = zeros([1, length(t)]);
            for i = 1:obj.numFreqs
                builtSignal = builtSignal + volt(i)*sin(2*pi*obj.linFreqArray(i)*t);
%                 x = sin(2*pi*150*t) + randn(size(t));
            end
        end


        function [logMicVoltAvg, linMicVoltAvg] = avgMicVolt(obj)
            % Parses and averages the many recorded voltages for each
            % frequency and condenses the averaged values into one 1D
            % voltage array.

            load(obj.dataFile);
            logFreqArrayStr = string(obj.logFreqArray);
            linFreqArrayStr = string(obj.linFreqArray);
            % logMicVoltArray50 = MicProgramDataParser(fr_50);
            % logMicVoltArray63 = MicProgramDataParser(fr_63);
            % logMicVoltArray79 = MicProgramDataParser(fr_79); ...
            for i = 1:obj.numFreqs
                logMicVoltArray = genvarname(['logMicVoltArray', char(logFreqArrayStr(i))]);
                linMicVoltArray = genvarname(['linMicVoltArray', char(linFreqArrayStr(i))]);
                logStr = sprintf(' = MicProgramDataParser(obj, fr_%d);', obj.logFreqArray(i));
                linStr = sprintf(' = MicProgramDataParser(obj, psd_%d);', obj.linFreqArray(i));
                eval([logMicVoltArray, logStr]);
                eval([linMicVoltArray, linStr]);
            end
            
            % logMicVoltAvg50 = sum(logMicVoltArray50)/length(logMicVoltArray50);
            % logMicVoltAvg63 = sum(logMicVoltArray63)/length(logMicVoltArray63);
            % logMicVoltAvg79 = sum(logMicVoltArray79)/length(logMicVoltArray79); ...
            for i = 1:obj.numFreqs
                logMicVoltAvg = genvarname(['logMicVoltAvg', char(logFreqArrayStr(i))]);
                linMicVoltAvg = genvarname(['linMicVoltAvg', char(linFreqArrayStr(i))]);
                logStr = sprintf(' = sum(logMicVoltArray%d)/length(logMicVoltArray%d);', ...
                    obj.logFreqArray(i), obj.logFreqArray(i));
                linStr = sprintf(' = sum(linMicVoltArray%d)/length(linMicVoltArray%d);', ...
                    obj.linFreqArray(i), obj.linFreqArray(i));
                eval([logMicVoltAvg, logStr]);
                eval([linMicVoltAvg, linStr]);
            end
        
            % logMicVoltAvg = [logMicVoltAvg50, logMicVoltAvg63, logMicVoltAvg79, ...
            logMicVoltAvg = zeros([1, obj.numFreqs]);
            linMicVoltAvg = zeros([1, obj.numFreqs]);
            for i = 1:obj.numFreqs
                logMicVoltA = genvarname(['logMicVoltAvg', char(logFreqArrayStr(i))]);
                linMicVoltA = genvarname(['linMicVoltAvg', char(linFreqArrayStr(i))]);
                logStr = sprintf(['logMicVoltAvg(i) = ', logMicVoltA, ';']);
                linStr = sprintf(['linMicVoltAvg(i) = ', linMicVoltA, ';']);
                eval(logStr);
                eval(linStr);
            end
        end

        function dataArray = MicProgramDataParser(~, strArray)
            % Parses the data obtained via the automated program in the
            % Data Retrieval folder.

            % Typical audio analyzer data string array looks like this:
            % ["+01479E-05", "+01484E-05", ... "+01493E-05"]
            L = length(strArray);
            dataArray = zeros([1, L]);
            for i = 1:L
                dataArray(i) = str2double(strArray(i));
            end
        end

        function dataArray = InstrControlDataParser(~, str)
            % Parses the data if recorded manually via Instrument Control.
            % If the provided automated program in the Data Retrieval
            % folder was used, this function is not needed.

            % Typical audio analyzer data string looks like this:
            % "+01479E-05+01484E-05 ... +01493E-05+014"
            
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

        function [logLvlVolt, linLvlVolt] = dbsplToVolt(obj)
            % Converts the DBspl gain from the level meter to voltage. The
            % level meter mic sensitivity is needed to properly calculate
            % this.

            % Calculations reference:
            % https://electronics.stackexchange.com/questions/96205/how-to-convert-volts-to-db-spl
            logLvlVolt = zeros([1, length(obj.lvlDBsplFR)]);
            linLvlVolt = zeros([1, length(obj.lvlDBsplPSD)]);
            for i = 1:obj.numFreqs
                % Subtract unit Pascal, 1 Pa = 94 dB.
                logLvlVolt(i) = obj.lvlDBsplFR(i) - 94;
                linLvlVolt(i) = obj.lvlDBsplPSD(i) - 94;
                % Subtract the level meter microphone sensitivity.
                logLvlVolt(i) = logLvlVolt(i) - obj.lvlSensDBV;
                linLvlVolt(i) = linLvlVolt(i) - obj.lvlSensDBV;
                % Convert from dB to voltage gain ratio. 
                logLvlVolt(i) = 10^(logLvlVolt(i)/20);
                linLvlVolt(i) = 10^(linLvlVolt(i)/20);
                % Multiply the ratio by the level meter voltage sensitivity
                % to get actual measured level meter voltage.
                logLvlVolt(i) = logLvlVolt(i)*obj.lvlSensVolt;
                linLvlVolt(i) = linLvlVolt(i)*obj.lvlSensVolt;
            end
        end

        function [logLvlDBspl, linLvlDBspl] = lvlArrayAvgDB(obj)
            % Takes the retrieved level meter data, makes proper
            % conversions, and averages the data for each frequency.
            % Returns a 1D array of averaged level meter DBspl gain
            % corresponding to each tested frequency.
            [logLvlDBCellArray, linLvlDBCellArray] = getLevelMeterData(obj);
            logLvlDBspl = zeros([1, obj.numFreqs]);
            linLvlDBspl = zeros([1, obj.numFreqs]);
            for i = 1:obj.numFreqs        
                % Cannot linearly average values from a logarithmic scale.
                % Converting DBspl to power is necessary.
                logGainRatio = 10.^(logLvlDBCellArray{i}/10);
                linGainRatio = 10.^(linLvlDBCellArray{i}/10);
                logPower = logGainRatio * 10^(-12);
                linPower = linGainRatio * 10^(-12);
                logAvgPower = sum(logPower)/length(logPower);
                linAvgPower = sum(linPower)/length(linPower);
                % Convert back to DBspl.
                logGainRatio = logAvgPower / (10^(-12));
                linGainRatio = linAvgPower / (10^(-12));
                logLvlDBspl(i) = 10*log10(logGainRatio);
                linLvlDBspl(i) = 10*log10(linGainRatio);
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