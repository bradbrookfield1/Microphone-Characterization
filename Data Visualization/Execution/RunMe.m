close all; clear; clc;

% Mic(name, micVoltFile, freqRange, numFreqs, psdFile, sampFreq, micSensDBV);
% If no micSensDBV, leave as -Inf.
Mic('This Mic', 'newMic1freqResp3-10pt.mat', 'Log', 'Small', '', 1000, -Inf);
% Mic('This Mic', 'newMic1freqResp3-10pt.mat', [32, 8000], 25, '', 1000, -Inf);
