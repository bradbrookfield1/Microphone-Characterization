function freqArray = getLinFreqArray(sz)
    switch sz
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