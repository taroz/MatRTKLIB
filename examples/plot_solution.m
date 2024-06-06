clear; clc; close all;
addpath ..\
basepath = ".\data\";

%% Read RTKLIB solution file
gsol = gt.Gsol(basepath+"rover_rtk.pos");

%% Plot solution file
gsol.plot();

%% Plot only Fixed Position
gsol.plot(gt.C.SOLQ_FIX);

%% Plot all solutions
gsol.plotAll();
