clc; clear; close all;
addpath ..\

%% Latitude, Longitude, Ellipsoidal height
llh = [35 139 100];
pos = gt.Gpos(llh,"llh");

%% Geoid heigh
gh = pos.geoid(); % RTKLIB internal Geoid model (EGM96 1°x1°)

disp("Geoid Height:");
disp(gh);

%% Orthometric height
oh = pos.orthometric();

disp("Orthometric Height:");
disp(oh);
disp(pos.h-gh);
