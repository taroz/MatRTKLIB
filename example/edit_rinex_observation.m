clear; clc; close all;
addpath ..\
basepath = '.\data\';

%% read RINEX observation file
gobs = gt.Gobs([basepath 'rover.obs']);

%% Example 1: edit observation interval
disp('run example 1...');

fprintf('observation interval: %f\n', gobs.dt); % 0.2s
gobs_1hz = gobs.fixedInterval(1.0);
fprintf('observation interval: %f\n', gobs_1hz.dt);  % 1s

% write RINEX observation
gobs_1hz.outObs([basepath 'rover_1Hz.obs']);

%% Example 2: trim observation
disp('run example 2...');

fprintf('start: %s\n', gobs.time.t(1)); % start time
fprintf('end  : %s\n', gobs.time.t(end)); % end time

% generate gt.Gtime
ts = gt.Gtime([2023 7 11 6 5 0]);
te = gt.Gtime(datetime('2023/07/11 6:10:00'));
gobs_trim = gobs.selectTimeSpan(ts, te);

fprintf('start: %s\n', gobs_trim.time.t(1)); % start time
fprintf('end  : %s\n', gobs_trim.time.t(end)); % end time

%% Example 3: fixed interval
disp('run example 3...');

% Observations missing a few seconds due to satellite signal blockage
gobs_trim.time.plotDiff();
fprintf('Number of epochs: %d\n', gobs_trim.n);

% NaN is inserted into the observed value when missing
gobs_trim_fix = gobs_trim.fixedInterval(gobs_trim.dt); % estimated interval is 0.2 s
gobs_trim_fix.time.plotDiff();
fprintf('Number of epochs: %d\n', gobs_trim_fix.n);

%% Example 4: exclude satellite system/satellites
disp('run example 4...');

% exclude satellite systems
gobs_1hz.plotNSat();
gobs_exsys = gobs_1hz.selectSat(gobs_1hz.sys==gt.C.SYS_GPS); % Only GPS
gobs_exsys.plotNSat();

% exclude G05 and G06
disp(gobs_exsys.satstr);
sidx = ~ismember(gobs_exsys.sat, rtklib.satid2no({'G05','G06'})); % gobs.sat is satno defined in RTKLIB
gobs_exsat = gobs_exsys.selectSat(sidx);
disp(gobs_exsat.satstr);
