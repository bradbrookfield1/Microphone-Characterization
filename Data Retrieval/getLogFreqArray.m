function freqArray = getLogFreqArray(sz)
    switch sz
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