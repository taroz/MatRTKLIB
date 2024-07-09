%% evaluate_position_error.m
% Evaluate positioning accuracy and plot error
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% Read RTKLIB solution file
sol = gt.Gsol(datapath+"rover_rtk.pos");
sol.plot

%% Read reference position
solref = gt.Gsol(datapath+"reference_1Hz.pos");

%% Set position origin
% Start position is origin
sol.setOrg(solref.pos.llh(1,:),"llh");
solref.setOrg(solref.pos.llh(1,:),"llh");

%% Match solution size
sol = sol.fixedInterval(1.0); % 5Hz to 1Hz

%% Compute error
err = sol-solref;

%% Display error statistics
r3d = err.rms3D % rms of 3D distance error
[m3d, sd3d] = err.mean3D % mean of 3D distance error

%% Plot
err.plot % 2D + hight error
err.plot3D % 3D distance error
err.plotCDF3D % Cumulative Distribution Function of 3D distance error