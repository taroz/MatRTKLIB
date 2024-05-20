clear; clc; close all;
addpath ..\
basepath = ".\data\";

%% Read RINEX observation file
gobs = gt.Gobs(basepath+"rover.obs");

%% Edit observation interval
% 0.2s (5Hz) to 1.0s (1Hz)
fprintf('observation interval: %f\n', gobs.dt);
gobs_1Hz = gobs.fixedInterval(1.0);
fprintf('observation interval: %f\n', gobs_1Hz.dt);

%% write RINEX observation
gobs_1Hz.outObs(basepath+"rover_1Hz.obs");
