close all; clear; clc;

% Mic(name, micVoltFile, freqRange, numFreqs, psdFile, sampFreq, micSensDBV);

% This is an analog signal, so the sampling frequency is essentially
% infinity, but we will assume a somewhat high number to keep the program
% from crashing.

% If no micSensDBV, leave as -Inf.

Mic('This Mic', 'newMic1freqResp3-10pt.mat', [32, 8000], 25, '', 100000, -Inf);