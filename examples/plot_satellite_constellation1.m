clear; clc; close all;
addpath ..\
basepath = ".\data\";

%% Read RINEX navigation and observation files
gnav = gt.Gnav(basepath+"base.nav");
gobs = gt.Gobs(basepath+"rover_1Hz.obs");

%% Plot satellite constellation
% Note: RINEX header position (gobs.pos) is used for receiver position
gobs.plotSky(gnav);