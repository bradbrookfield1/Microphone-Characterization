classdef Mic

    properties
        name
        micVoltFile
        freqRange
        numFreqs
        micSensDBV
        psdFile
        sampFreq

        micSensVolt
        lvlSensDBV
        lvlSensVolt
        freqArray
        lvlDBspl
        lvlVolt
        micVolt
        normVolt
        normDB
        meanGain
        stdDev
        tolerance
    end

    methods
        function obj = Mic(name, micVoltFile, freqRange, numFreqs, psdFile, sampFreq)
            % This constructor takes in required voltage data and a few
            % other details, and then automatically calculates
            % everything needed and plots the frequency response (FR), the power
            % spectral density (PSD), and other characteristic details all from
            % one object instantiation.

            % Required inputs: 
            % 1. Name for mic
            % 2. .mat FR voltage file
            % 3. Frequency range to be covered
            % 4. Number of elements in the tested frequency range
            % 5. .mat PSD voltage file
            % 6. Sampling frequency
            obj.name = name;
            obj.micVoltFile = micVoltFile;
            obj.freqRange = freqRange;
            obj.numFreqs = numFreqs;
            obj.psdFile = psdFile;
            obj.sampFreq = sampFreq;

            % Optional: include mic sensitivity.
            obj.micSensDBV = 0;
            obj.micSensVolt = 10^(obj.micSensDBV/20);
            % Level Meter Sensitivity 10mV/1dB
            % http://www.extech.com/products/resources/HD600_UM-en.pdf
            obj.lvlSensVolt = 0.01;
            % Converted to sensitivity in dBV leads to -40 dBV sensitivity.
            % https://www.analog.com/media/en/analog-dialogue/volume-46/number-2/articles/understanding_microphone_sensitivity.pdf
            obj.lvlSensDBV = 20*log10(obj.lvlSensVolt);
            obj.freqArray = getFreqArray(obj);

%             obj.lvlDBspl = lvlArrayAvgDB(obj);
            obj.lvlDBspl = [56.4, 61.7, 72.5, 80.1, 88, 90.1, 87.2, 87, 82.9, 80.8, 80.4, 79, ...
                82, 80.3, 84.5, 82, 89, 87.4, 88.2, 86.3, 87.3, 85.7, 85.3, 88.6, 87];

            % Convert sound pressure dB to voltage:
            % https://electronics.stackexchange.com/questions/96205/how-to-convert-volts-to-db-spl
            obj.lvlVolt = dbsplToVolt(obj);

%             obj.micVolt = avgMicVolt(obj);

            % FIX ME!!! FAKE DATA FOR TESTING!!!
            fakeFreq = obj.freqArray(2:24);
            volt = avgMicVolt(obj, fakeFreq);
            obj.micVolt = [9e-5, volt, 0.0015];

            % Normalize two data sets via voltage gain ratio.
            obj.normVolt = obj.micVolt./obj.lvlVolt;
            % Convert to dB.
            obj.normDB = 20*log10(obj.normVolt);
            % Find the mean gain, the standard deviation, and the
            % corresponding tolerance percentage.
            obj.meanGain = sum(obj.normDB)/length(obj.normDB);
            obj.stdDev = sqrt((sum(obj.normDB.^2)/length(obj.normDB)) - (obj.meanGain^2));
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
            plot(obj.freqArray, obj.micVolt);
            set(gca, 'Xscale', 'log');
            set(gca, 'XTickLabel', {'10', '100', '1000', '10000'});
            xlabel('Frequency (Hz)'); ylabel('Voltage (V)');
            title('Mic Voltage Data');
        
            subplot(2, 3, 2);
            plot(obj.freqArray, obj.lvlVolt);
            set(gca, 'Xscale', 'log');
            set(gca, 'XTickLabel', {'10', '100', '1000', '10000'});
            xlabel('Frequency (Hz)'); ylabel('Voltage (V)');
            title('Level Meter Voltage');
        
            subplot(2, 3, 3);
            plot(obj.freqArray, obj.normDB);
            ylim([-80, 0]);
            set(gca, 'Xscale', 'log');
            set(gca, 'XTickLabel', {'10', '100', '1000', '10000'});
            xlabel('Frequency (Hz)'); ylabel('Normalized Mic Voltage Gain (dB)');
            title('True Frequency Response');
        end

        function dispFreqRespDetails(obj)
            % Displays the mic's mean gain, standard deviation, and
            % tolerance on the figure.
            ax = subplot(2, 3, 6);
            title('True Frequency Response Details');
            str1 = sprintf('Mean Normalized Gain: %0.2f dB', obj.meanGain);
            str2 = sprintf('Standard Deviation: +-%0.2f dB', obj.stdDev);
            str3 = sprintf('Tolerance: +-%0.2f%%', obj.tolerance);
            if (obj.micSensDBV == 0)
                str4 = sprintf('Rated Mic Sensitivity (dBV): N/A dBV');
                str5 = sprintf('Rated Mic Sensitivity (Voltage): N/A V');
            else
                str4 = sprintf('Rated Mic Sensitivity (dBV): %0.2f dBV', obj.micSensDBV);
                str5 = sprintf('Rated Mic Sensitivity (Voltage): %0.4f V', obj.micSensVolt);
            end
            str = [str1, newline, str2, newline, str3, newline, newline, str4, newline, str5];
            text(0.5, 0.95, str, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'baseline');
            set(ax, 'visible', 'off');
            set(ax.Title, 'visible', 'on');
        end

        function plotPSD(obj)
            % Plots FR graphs for the mic, the level meter, and then the
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
            title('Power Spectral Density (Sine Wave)');
        end

        function micVoltAvg = avgMicVolt(obj, freqArray)
            load(obj.micVoltFile);
            freqArrayStr = string(freqArray);
            % micVoltArray50 = MicProgramDataParser(a_50);
            % micVoltArray63 = MicProgramDataParser(a_63);
            % micVoltArray79 = MicProgramDataParser(a_79); ...
            for i = 1:length(freqArrayStr)
                micVoltArray = genvarname(['micVoltArray', char(freqArrayStr(i))]);
                str = sprintf(' = MicProgramDataParser(obj, a_%d);', freqArray(i));
                eval([micVoltArray, str]);
            end
            
            % micVoltAvg50 = sum(micVoltArray50)/length(micVoltArray50);
            % micVoltAvg63 = sum(micVoltArray63)/length(micVoltArray63);
            % micVoltAvg79 = sum(micVoltArray79)/length(micVoltArray79); ...
            for i = 1:length(freqArrayStr)
                micVoltAvg = genvarname(['micVoltAvg', char(freqArrayStr(i))]);
                str = sprintf(' = sum(micVoltArray%d)/length(micVoltArray%d);', freqArray(i), freqArray(i));
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
            % Typical audio analyzer data string looks like this:
            % ["+01479E-05", "+01484E-05", ... "+01493E-05"]
            L = length(str);
            dataArray = zeros([1, L]);
            for i = 1:L
                dataArray(i) = str2double(str(i));
            end
        end

        function dataArray = InstrControlDataParser(~, str)
            % Typical audio analyzer data string looks like this:
            % +01479E-05+01484E-05 ... +01493E-05+014
            
            % Cuts off last voltage value where recording timeout happens and there
            % is not enough time for it to store all the characters of the last
            % voltage data point.
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

        function lvlVolt = dbsplToVolt(obj)
            % Calculations reference:
            % https://electronics.stackexchange.com/questions/96205/how-to-convert-volts-to-db-spl
            lvlVolt = zeros([1, length(obj.lvlDBspl)]);
            for i = 1:length(obj.lvlDBspl)
                % Subtract unit Pascal, 1 Pa = 94 dB.
                lvlVolt(i) = obj.lvlDBspl(i) - 94;
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
            lvlDBCellArray = getLevelMeterData(obj);
            len = length(lvlDBCellArray);
            lvlDBspl = zeros([1, len]);
            for i = 1:len        
                gainRatio = 10.^(lvlDBCellArray{i}/10);
                power = gainRatio * 10^(-12);
                avgPower = sum(power)/length(power);
                gainRatio = avgPower / (10^(-12));
                lvlDBspl(i) = 10*log10(gainRatio);
            end
        end

        function lvlDBCellArray = getLevelMeterData(obj)
            switch obj.freqRange
                case 'Log'
                    cd 'Log Level Meter Files';
                otherwise
                    cd 'Lin Level Meter Files';
            end

            switch obj.numFreqs
                case 'Large'
                    cd 'Large';
                case 'Medium'
                    cd 'Medium';
                otherwise
                    cd 'Small';
            end

            lvlDBCellArray = TraverseFiles;
            cd '../';
            cd '../';
        end

        function freqArray = getFreqArray(obj)
            switch obj.freqRange
                case 'Log'
                    freqArray = getLogFreqArray(obj);
                otherwise
                    freqArray = getLinFreqArray(obj);
            end
        end

        function freqArray = getLogFreqArray(obj)
            switch obj.numFreqs
                case 'Large'
                    i = linspace(log10(32), log10(8000), 100);
                    freqArray = zeros([1, length(i)]);
                    for j = 1:length(i)
                        freqArray(j) = round(10^(i(j)));
                    end
                case 'Medium'
                    i = linspace(log10(32), log10(8000), 50);
                    freqArray = zeros([1, length(i)]);
                    for j = 1:length(i)
                        freqArray(j) = round(10^(i(j)));
                    end
                otherwise
                    i = linspace(log10(32), log10(8000), 25);
                    freqArray = zeros([1, length(i)]);
                    for j = 1:length(i)
                        freqArray(j) = round(10^(i(j)));
                    end
            end
        end

        function freqArray = getLinFreqArray(obj)
            switch obj.numFreqs
                case 'Large'
                    i = round(linspace(32, 8000, 100));
                    freqArray = zeros([1, length(i)]);
                    for j = 1:length(i)
                        freqArray(j) = i(j);
                    end
                case 'Medium'
                    i = round(linspace(32, 8000, 50));
                    freqArray = zeros([1, length(i)]);
                    for j = 1:length(i)
                        freqArray(j) = i(j);
                    end
                otherwise
                    i = round(linspace(32, 8000, 25));
                    freqArray = zeros([1, length(i)]);
                    for j = 1:length(i)
                        freqArray(j) = i(j);
                    end
            end
        end
    end
end