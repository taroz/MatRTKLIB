%% edit_rinex_observation2.m
% Trim RINEX observation using time span
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% Read RINEX observation file
gobs = gt.Gobs(datapath+"rover_1Hz.obs");

%% Trim observation
fprintf('Original data\n');
fprintf('Number of epochs: %d\n', gobs.n);
fprintf('Start: %s\n', gobs.time.t(1)); % start time
fprintf('End  : %s\n', gobs.time.t(end)); % end time

% Generate gt.Gtime
ts = gt.Gtime([2023 7 11 6 5 0]); % start time
te = gt.Gtime(datetime('2023/07/11 6:10:00')); % end time

% Trim observation using time span
gobs_trim = gobs.selectTimeSpan(ts,te);

fprintf('Triming data\n');
fprintf('Number of epochs: %d\n', gobs_trim.n);
fprintf('Start: %s\n', gobs_trim.time.t(1)); % start time
fprintf('End  : %s\n', gobs_trim.time.t(end)); % end time