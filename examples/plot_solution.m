clear; clc; close all;
addpath ..\
datapath = ".\data\kinematic\";

%% Read RTKLIB solution file
gsol = gt.Gsol(datapath+"rover_rtk.pos");

%% Plot solution file
gsol.plot();

%% Plot only Fixed Position
gsol.plot(gt.C.SOLQ_FIX);

%% Plot all solutions
gsol.plotAll();
