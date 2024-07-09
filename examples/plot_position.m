%% plot_position.m
% Show position on map
% Author: Taro Suzuki

clear; close all; clc;
addpath ../

%% Generate position
enu = zeros(11,3); enu(:,1) = 0:100:1000;
orgxyz = [-3959340.203 3352854.274 3697471.413]; % position origin in ECEF

pos = gt.Gpos(enu,"enu");
pos.setOrg(orgxyz,"xyz");

%% Plot position
pos.plot
pos.plotMap
pos.plotSatMap

