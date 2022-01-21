function dataCellArray = TraverseFiles
    % Filters level meter .txt files, traverses them, calls the data parser
    % function, and stores all data into a 2D cell array with each row
    % corresponding to each file with recorded data for a given frequency.
    levelMeterFiles = dir;
    levelMeterFiles = levelMeterFiles(endsWith({levelMeterFiles.name}, '.txt'));
    
    len = length(levelMeterFiles);
    dataCellArray = cell(1, len);
    for i = 1:len
        str = fileread(levelMeterFiles(i).name);
        dataCellArray{i} = LevelMeterDataParser(str);
    end
end