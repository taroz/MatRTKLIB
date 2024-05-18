% clear; clc; close all;
addpath ..\
basepath = '.\data\';

%% Read RINEX navigation and observation files
gnav = gt.Gnav([basepath 'base.nav']);
gobs = gt.Gobs([basepath 'rover_1Hz.obs']);

%% plot satellite constellation
% gobs.plot();
% gobs.plotSky(gnav);