clear; clc; close all;
addpath ..\
datapath = ".\data\";

%% Rover and base position
posr = gt.Gpos([-3817690.2015 3562847.3632 3650172.6616],'xyz');
posb = gt.Gpos([-3817690.2015 3562847.3632 3650172.6616],'xyz');

%% Read RINEX observation file
gobsr = gt.Gobs(datapath+"rover_1Hz.obs");
gobsb = gt.Gobs(datapath+"base_1Hz.obs");

%% Compute geodetic distance

[gobsr2,gobsb2] = gobsr.commonObs(gobsb);

satr = 
gobsrb = gobsr2-gbosb2;
