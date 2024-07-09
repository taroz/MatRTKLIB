%% edit_rinex_observation1.m
% Read and write RINEX observation
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% Read RINEX observation file
gobs = gt.Gobs(datapath+"rover.obs");

%% Change observation interval
% 0.2s (5Hz) to 1.0s (1Hz)
fprintf('observation interval: %f\n', gobs.dt);
gobs_1Hz = gobs.fixedInterval(1.0);
fprintf('observation interval: %f\n', gobs_1Hz.dt);

%% Write RINEX observation
gobs_1Hz.outObs(datapath+"rover_1Hz.obs");
