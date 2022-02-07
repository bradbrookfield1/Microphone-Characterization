%% Instrument Connection

% This program is based on a MATLAB sample GPIB adapter connection program
% as specified in README.md. This program instantiates the GPIB object and
% runs a series of programmable commands to the audio analyzer and
% essentially alternates between writing the desired frequency change
% command and reads the data as shown on the display. That data is then
% saved to a specified .mat file, and then the GPIB object is closed.
close all; clear; clc;

% Find a GPIB object.
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 28, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('NI', 0, 28);
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);

%% Instrument Configuration and Control

ptsPerFreq = 10;
[logfreqArray, linfreqArray] = getFreqArrays([32, 8000], 25);

logfreqArrayStr = strings([1, length(logfreqArray)]);
linfreqArrayStr = strings([1, length(linfreqArray)]);
for i = 1:length(logfreqArray)
    logfreqArrayStr(i) = convertCharsToStrings([num2str(logfreqArray(i)), '.0']);
    linfreqArrayStr(i) = convertCharsToStrings([num2str(linfreqArray(i)), '.0']);
end

str1 = 'FR';
% str2 = 'HZAP0.1VLM1LNL0LNT3';
str2 = 'HZAP0.1VLM1L0LNT3';
% str2 = 'HZAP0.1VLM1L05.0SPLNT3';
strRead = ' = convertCharsToStrings(fscanf(obj1, ''%s''));';
strStartFreqList = ' = strings([1, ptsPerFreq]);';
strRecTime = ' = toc(tStart);';

% For logarithmically spaced array for FR plots.
for i = 1:length(logfreqArray)
    obj1.EOSMode = 'write';
    strWrite = [str1, char(logfreqArrayStr(i)), str2];
    fprintf(obj1, strWrite);
    fr = genvarname(['fr_', char(string(logfreqArray(i)))]);
    eval([fr, strStartFreqList]);
    tEl = genvarname(['tFR_', char(string(logfreqArray(i)))]);
    pause('on');
    pause(2);
    pause('off');
    tStart = tic;
    for j = 1:ptsPerFreq
        obj1.EOSMode = 'read';
        eval([fr, '(j)', strRead]);
        obj1.EOSMode = 'write';
        fprintf(obj1, strWrite);
%         pause('on');
%         pause(2);
%         pause('off');
    end    
    eval([tEl, strRecTime]);  
    obj1.EOSMode = 'read';
    eval(['junk', strRead]);
end

% For linearly spaced array for PSD plots.
for i = 1:length(linfreqArray)
    obj1.EOSMode = 'write';
    strWrite = [str1, char(linfreqArrayStr(i)), str2];
    fprintf(obj1, strWrite);
    psd = genvarname(['psd_', char(string(linfreqArray(i)))]);
    eval([psd, strStartFreqList]);
    tEl = genvarname(['tPSD_', char(string(linfreqArray(i)))]);
    pause('on');
    pause(2);
    pause('off');
    tStart = tic;
    for j = 1:ptsPerFreq
        obj1.EOSMode = 'read';
        eval([psd, '(j)', strRead]);
        obj1.EOSMode = 'write';
        fprintf(obj1, strWrite);
%         pause('on');
%         pause(2);
%         pause('off');
    end    
    eval([tEl, strRecTime]);  
    obj1.EOSMode = 'read';
    eval(['junk', strRead]);
end

obj1.EOSMode = 'write';
fprintf(obj1, 'FR50.0HZAP0.0VLM1LNL0LNT3');
save('newMic1freqResp3-10pt.mat');

%% Disconnect and Clean Up

% Disconnect from instrument object, obj1.
fclose(obj1);

% The following code has been automatically generated to ensure that any
% object manipulated in TMTOOL has been properly disposed when executed
% as part of a function or script.

% Clean up all objects.
delete(obj1);
clear obj1;
