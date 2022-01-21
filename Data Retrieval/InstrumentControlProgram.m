%% INSTRUMENTCONTROLPROGRAM Code for communicating with an instrument.
%
%   This is the machine generated representation of an instrument control
%   session. The instrument control session comprises all the steps you are
%   likely to take when communicating with your instrument. These steps are:
%   
%       1. Instrument Connection
%       2. Instrument Configuration and Control
%       3. Disconnect and Clean Up
% 
%   To run the instrument control session, type the name of the file,
%   InstrumentControlProgram, at the MATLAB command prompt.
% 
%   The file, INSTRUMENTCONTROLPROGRAM.M must be on your MATLAB PATH. For additional information 
%   on setting your MATLAB PATH, type 'help addpath' at the MATLAB command 
%   prompt.
% 
%   Example:
%       instrumentcontrolprogram;
% 
%   See also SERIAL, GPIB, TCPIP, UDP, VISA, BLUETOOTH, I2C, SPI.
% 
%   Creation time: 14-Oct-2021 11:40:31

%% Instrument Connection
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
% freqArray = getLogFreqArray('Large');
% freqArray = getLogFreqArray('Medium');
freqArray = getLogFreqArray('Small');
% freqArray = getLinFreqArray('Large');
% freqArray = getLinFreqArray('Medium');
% freqArray = getLinFreqArray('Small');
freqArrayStr = strings([1, length(freqArray)]);
for i = 1:length(freqArray)
    freqArrayStr(i) = convertCharsToStrings([num2str(freqArray(i)), '.0']);
end

str1 = 'FR';
% str2 = 'HZAP0.1VLM1LNL0LNT3';
str2 = 'HZAP0.1VLM1L0LNT3';
% str2 = 'HZAP0.1VLM1L05.0SPLNT3';
strRead = ' = convertCharsToStrings(fscanf(obj1, ''%s''));';
strStartFreqList = ' = strings([1, ptsPerFreq]);';
strRecTime = ' = toc(tStart);';

for i = 1:length(freqArray)
    obj1.EOSMode = 'write';
    strWrite = [str1, char(freqArrayStr(i)), str2];
    fprintf(obj1, strWrite);
    a = genvarname(['a_', char(string(freqArray(i)))]);
    eval([a, strStartFreqList]);
    tEl = genvarname(['tElapsed_', char(string(freqArray(i)))]);
    pause('on');
    pause(2);
    pause('off');
    tStart = tic;
    for j = 1:ptsPerFreq
        obj1.EOSMode = 'read';
        eval([a, '(j)', strRead]);
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
