%% compute_geoid.m
% Compute Geoid and orthometric hight
% Author: Taro Suzuki

clear; close all; clc;
addpath ../

%% Latitude, Longitude, Ellipsoidal height
llh = [35 139 100];
pos = gt.Gpos(llh,"llh");

%% Geoid heigh
gh = pos.geoid(); % RTKLIB internal Geoid model (EGM96 1°x1°)

disp("Geoid Height (m):");
disp(gh);

%% Orthometric height
oh = pos.orthometric();

disp("Orthometric Height (m):");
disp(oh);
disp(pos.h-gh);
