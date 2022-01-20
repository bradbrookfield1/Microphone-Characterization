function dataCellArray = TraverseFiles
    levelMeterFiles = dir;
    levelMeterFiles = levelMeterFiles(endsWith({levelMeterFiles.name}, '.txt'));
    
    len = length(levelMeterFiles);
    dataCellArray = cell(1, len);
    for i = 1:len
        str = fileread(levelMeterFiles(i).name);
        dataCellArray{i} = LevelMeterDataParser(str);
    end
end