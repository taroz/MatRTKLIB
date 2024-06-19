clc; clear; close all;
addpath ..\
basepath = '.\data\kinematic\';

%% Read RTKLIB solution file
gsol = gt.Gsol([basepath 'rover_rtk.pos']);

%% Check solution time interval
% Solution contains many missing epochs
gsol.time.plotDiff();

% This is incorrect fixed rate
fprintf('Fixed rate=%.1f%% (%d/%d)\n',...
    gsol.solStatRate(gt.C.SOLQ_FIX), ...
    gsol.solStatCount(gt.C.SOLQ_FIX), ...
    gsol.n);

%% Create solution for fixed time interval (insert NaN)
gsol_fixed = gsol.fixedInterval();
gsol_fixed.time.plotDiff(); ylim([0 1]);

% This is correct fixed rate
fprintf('Fixed rate=%.1f%% (%d/%d)\n',...
    gsol_fixed.solStatRate(gt.C.SOLQ_FIX), ...
    gsol_fixed.solStatCount(gt.C.SOLQ_FIX), ...
    gsol_fixed.n);
