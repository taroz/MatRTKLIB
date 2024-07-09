%% generate_solution_file.m
% Generate RTKLIB solution file
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = './data/kinematic/';

%% Read position from CSV file
data = readtable(datapath+"reference.csv","VariableNamingRule","preserve");

%% Generate gt.Gsol
time = gt.Gtime(data.("GPS TOW (s)"), data.("GPS Week"));
pos = gt.Gpos(data{:,3:5},"llh");
sol = gt.Gsol(time,pos);

%% 5Hz to 1Hz
sol = sol.fixedInterval(1.0);

%% Plot solution
sol.plot

%% Output solution file
sol.outSol(datapath+"reference_1Hz.pos");