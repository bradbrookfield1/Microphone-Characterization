close all; clear; clc;

% Mic(name, dataFile, freqRange, numFreqs, sampFreq, micSensDBV);

% This is an analog signal, so the sampling frequency is essentially
% infinity, but we will assume a somewhat high number to keep the program
% from crashing.

% If no micSensDBV, leave as -Inf.

Mic('This Mic', 'newMic1freqResp2-10pt.mat', [32, 8000], 25, 16000, -Inf);