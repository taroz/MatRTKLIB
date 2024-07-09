%% edit_solution.m
% Read position solution file and trim solution
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = './data/kinematic/';

%% Read RTKLIB solution file
gsol = gt.Gsol([datapath 'rover_rtk.pos']);

%% Select only ambiguity fixed solutions
gsolfix = gsol.select(gsol.stat==gt.C.SOLQ_FIX);
gsolfix.plot

%% Select from index
gsolsel1 = gsol.select(1:10)
gsolsel1.plot

%% Select from time span
ts = gt.Gtime([2023 07 11 06 04 30]);
te = gt.Gtime([2023 07 11 06 06 40]);
gsolsel2 = gsol.selectTimeSpan(ts, te)
gsolsel2.plot
