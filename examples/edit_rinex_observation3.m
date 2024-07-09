%% edit_rinex_observation3.m
% Modify RINEX observation interval
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% Read RINEX observation file
gobs = gt.Gobs(datapath+"rover_1Hz.obs");

%% Fixed observation interval
% Observations missing a few seconds due to satellite signal blockage
gobs.time.plotDiff();
fprintf('Original: Number of epochs: %d\n', gobs.n);

% NaN is inserted into the observation when missing
gobs_fix = gobs.fixedInterval(gobs.dt); % interval is 1.0 s
gobs_fix.time.plotDiff();
fprintf('Fixed: Number of epochs: %d\n', gobs_fix.n);