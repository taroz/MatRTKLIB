clear; clc; close all;
addpath ..\
basepath = ".\data\";

%% Read RINEX observation file
gobs = gt.Gobs(basepath+"rover_1Hz.obs");

%% Fixed observation interval
% Observations missing a few seconds due to satellite signal blockage
gobs.time.plotDiff();
fprintf('Original: Number of epochs: %d\n', gobs.n);

% NaN is inserted into the observation when missing
gobs_fix = gobs.fixedInterval(gobs.dt); % interval is 1.0 s
gobs_fix.time.plotDiff();
fprintf('Fixed: Number of epochs: %d\n', gobs_fix.n);