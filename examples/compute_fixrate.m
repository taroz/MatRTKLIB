%% compute_fixrate.m
% Compute ambiguity fixed rate from RTK-GNSS solution
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
basepath = "./data/kinematic/";

%% Read RTKLIB solution file
gsol = gt.Gsol(basepath+"rover_rtk.pos");

%% Check solution time interval
% Solution contains many missing epochs
gsol.time.plotDiff();

fprintf("Time interval of solution is not constant (including missing): nepoch=%d\n",gsol.n);
% Status rate/count
disp(gt.C.SOLQNAME(1:7));
disp(gsol.statRate);
disp(gsol.statCount);

% This is incorrect fixed rate
gsol.showStatRate;
gsol.showFixRate;

%% Create solution for fixed time interval (insert NaN)
gsol_fixed = gsol.fixedInterval();
gsol_fixed.time.plotDiff(); ylim([0 1]);

fprintf("\n\nTime interval of solution is constant: nepoch=%d\n",gsol_fixed.n);
% Status rate/count
disp(gt.C.SOLQNAME(1:7));
disp(gsol_fixed.statRate);
disp(gsol_fixed.statCount);

% This is correct fixed rate
gsol_fixed.showStatRate;
gsol_fixed.showFixRate;