clear; clc; close all;
addpath ../
datapath = "./data/static/";

%% Read RTKLIB solution file (static data)
gsol = gt.Gsol(datapath+"rover_rtk.pos");

%% Compute mean position of fixed solution
gpos = gsol.mean(gt.C.SOLQ_FIX);

%% Write mean position to file
gpos.outPos(datapath+"rover_position.txt","llh");

%% Plot
% set mean position to origin
gsol.setOrg(gpos.llh, "llh");

% plot fixed position (mean position is center)
gsol.plot(gt.C.SOLQ_FIX);
