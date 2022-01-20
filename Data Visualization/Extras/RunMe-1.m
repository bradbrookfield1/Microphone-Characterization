close all; clear; clc;

% Samples taken of each frequency.
Fs = 24000;

% Create frequency arrays.
% Small - 25 pts, Medium - 50 pts, Large - 100 pts
% Logarithmically spaced.
i = 1.6:0.1:4;
freqOS = zeros([1, length(i)]);
for j = 1:length(i)
    freqOS(j) = round(10^(i(j)));
end

i = 1.6:0.05:4.05;
freqOM = zeros([1, length(i)]);
for j = 1:length(i)
    freqOM(j) = round(10^(i(j)));
end

i = 1.6:0.025:4.075;
freqOL = zeros([1, length(i)]);
for j = 1:length(i)
    freqOL(j) = round(10^(i(j)));
end

% Linearly spaced.
i = 50:320:8000;
freqIS = zeros([1, length(i)]);
for j = 1:length(i)
    freqIS(j) = i(j);
end

i = 50:160:8000;
freqIM = zeros([1, length(i)]);
for j = 1:length(i)
    freqIM(j) = i(j);
end

i = 50:80:8000;
freqIL = zeros([1, length(i)]);
for j = 1:length(i)
    freqIL(j) = i(j);
end

% Parse level meter data files, average them, and load them here.
% lvlDBOS = LvlArrayAvgDB('Log', 'Small');
% lvlDBOM = LvlArrayAvgDB('Log', 'Medium');
% lvlDBOL = LvlArrayAvgDB('Log', 'Large');
% lvlDBIS = LvlArrayAvgDB('Lin', 'Small');
% lvlDBIM = LvlArrayAvgDB('Lin', 'Medium');
% lvlDBIL = LvlArrayAvgDB('Lin', 'Large');

% dB meter readings.
lvlPowerDBOS = [60, 64.8, 73.2, 79.9, 89, 90.1, 89.2, 89.8, 89.6, 88.4, 88.2, ...
    86.2, 85.7, 83.9, 86.4, 90, 92.5, 94.4, 93.7, 90.5, 94.8, 91, 96, 96.5, 95];

lvlAvgPowerDBOS = LvlAvgDB(lvlPowerDBOS);
% lvlAvgLogMedium = LvlAvgDB(lvlMeterLogMedium);
% lvlAvgLogLarge = LvlAvgDB(lvlMeterLogLarge);
% lvlAvgLinSmall = LvlAvgDB(lvlMeterLinSmall);
% lvlAvgLinMedium = LvlAvgDB(lvlMeterLinMedium);
% lvlAvgLinLarge = LvlAvgDB(lvlMeterLinLarge);

% From sound pressure decibels to sound pressure gain ratio.
lvlPowerGainOS = 10.^(lvlPowerDBOS/10);
% From sound pressure gain ratio to sound pressure watts/m^2.
lvlPowerOS = lvlPowerGainOS * 10^(-12);
lvlVoltOS = sqrt(lvlPowerOS * Fs);

% Taking the average of the recorded amplitude voltages from the audio
% analyzer, then converting it to power.
micVoltOS = AvgAmplitude(freqOS, 'newMic1freqResp3-10pt.mat');
micVoltOS = [9e-5, micVoltOS, 0.0015];
micVoltDBOS = 20*log10(micVoltOS./lvlVoltOS);
micPowerOS = VoltToPower(micVoltOS, Fs);
micPowerDBOS = 10*log10(micPowerOS / 10^(-12));
micAvgPowerDBOS = VoltToAvgDB(micVoltOS, Fs);
micRatedPowerDBOS = micAvgPowerDBOS - lvlAvgPowerDBOS;

% [lvlN, lvlC, lvlS] = normalize(lvlVoltOS);
% micN = normalize(micVoltOS, 'center', lvlC, 'scale', lvlS);

% fixedN = micN./lvlN;

% micN = (micN .* micVoltOS);

% TRUEMicVoltOS = micN + lvlC;

trueMicVoltOS = (micN*lvlS) + lvlC;

trueMicVoltDBOS = 20*log10(micN./lvlVoltOS);

trueMicPowerOS = VoltToPower(micN, Fs);

trueMicPowerGainOS = trueMicPowerOS / (10^(-12));
trueMicPowerDBOS = 10*log10(trueMicPowerGainOS);

% Volt to dB and back to power and to dB. Compare.

% Then prep plots.

% Then fix frequency responses.













% Personalized plot function.
figure('Name', 'Mic 1 Power Spectral Density', 'NumberTitle', 'off');
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
FRPlotMic(micPowerDBOS, 1, trueMicPowerDBOS, freqOS, lvlPowerDBOS);
% micpsd = dspdata.psd(micVoltOS, freqOS, 'Fs', Fs);
% plot(micpsd);
