function dataArray = LevelMeterDataParser(str)
    % Parses the data for a level meter .txt file.
    if str(57) == ';'
        initOffset = 57;
    else
        initOffset = 56;
    end
    startOfData = initOffset + 23;
    numSamples = int64((length(str) - (initOffset + 2)) / 33);
    dataArray = zeros([1, numSamples]);
    for i = 1:numSamples
        dataArray(i) = str2double(str(startOfData:(startOfData+4)));
        startOfData = startOfData + 32;
    end
end
