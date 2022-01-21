function [logFreqArray, linFreqArray] = getFreqArrays(freqRange, numFreqs)
    % Calculates linearly and logarithmically spaced frequency
    % arrays based on the specified range and number of frequency
    % elements.

    % Logarithmically spaced for FR plots.
    i = linspace(log10(freqRange(1)), log10(freqRange(2)), numFreqs);
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
    i = linspace(freqRange(1), freqRange(2), numFreqs);
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