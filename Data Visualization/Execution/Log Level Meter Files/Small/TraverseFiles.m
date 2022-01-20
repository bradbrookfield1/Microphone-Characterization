function dataCellArray = TraverseFiles
    levelMeterFiles = dir(pwd);
    len = length(levelMeterFiles);
    dataCellArray = cell(1, (len - 4));
    j = 1;
    for i = 3:(len - 2)
        str = fileread(levelMeterFiles(i).name);
        dataCellArray{j} = LevelMeterDataParser(str);
        j = j + 1;
    end
end