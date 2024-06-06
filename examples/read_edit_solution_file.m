clc; clear; close all;
addpath ..\
basepath = '.\data\';

%% Example 1
% read RTKLIB solution file and plot
disp('run example 1...');

% gt.Gsol
gsol = gt.Gsol([basepath 'rover_rtk.pos']);

% plot position
gsol.pos.plot();


%% Example 2
% edit solution at fixed time intervals
disp('run example 2...');

% check solution time interval
gsol.time.plotDiff();
fprintf('time interval=%.1f\n', gsol.dt);

% incorrect fixed rate
fprintf('fixed rate=%.1f%% (%d/%d)\n',...
    nnz(gsol.stat>0)/gsol.n*100, nnz(gsol.stat>0), gsol.n);

% Create solution for fixed time interval (insert NaN)
gsol_fixed = gsol.fixedInterval();
gsol_fixed.pos.plot()

% correct fixed rate
fprintf('time interval=%.1f\n', gsol_fixed.dt);
fprintf('fixed rate=%.1f%% (%d/%d)\n',...
    nnz(gsol_fixed.stat>0)/gsol_fixed.n*100, nnz(gsol_fixed.stat>0), gsol_fixed.n);


%% Example 3
% trim solution
disp('run example 3...');
gsol.plot

% select only ambiguity fixed solutions
gsol1 = gsol.select(gsol.stat==gt.C.SOLQ_FIX);
gsol1.plot

% select from index
gsol2 = gsol.select(1:10)


% select from time span
ts = gt.Gtime([2023 07 11 06 04 30]);
te = gt.Gtime([2023 07 11 06 04 40]);
gsol3 = gsol.selectTimeSpan(ts, te)

% select from time span amd interval
gsol4 = gsol.selectTimeSpan(ts, te, 1.0)