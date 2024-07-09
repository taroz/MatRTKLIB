%% plot_observation2.m
% Show raw GNSS measurements
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/static/";

%% Read RINEX observation file
gobs = gt.Gobs(datapath+"rover.obs");

%% Plot raw observation

% Pseudorange
figure;
plot(gobs.time.t, gobs.L1.P); grid on;
legend(gobs.satstr,"Location","eastoutside");
title("Pseudorange");
ylabel("Pseudorange (m)");

% Carrier phase
figure;
plot(gobs.time.t, gobs.L1.L); grid on;
legend(gobs.satstr,"Location","eastoutside");
title("Carrier phase");
ylabel("Carrier phase (cycle)");

% Doppler
figure;
plot(gobs.time.t, gobs.L1.D); grid on;
legend(gobs.satstr,"Location","eastoutside");
title("Doppler");
ylabel("Doppler (Hz)");

% SNR
figure;
plot(gobs.time.t, gobs.L1.S); grid on;
legend(gobs.satstr,"Location","eastoutside");
title("SNR");
ylabel("SNR (dB-Hz)");