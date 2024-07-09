%% convert_coordinate.m
% Convert LLH, ECEF and ENU position to each other
% Author: Taro Suzuki

clear; close all; clc;
addpath ../

%% Latitude, Longitude, Ellipsoidal height
llh = [35      139      100;
       35.0001 139.0001 200];

pos1 = gt.Gpos(llh,"llh");

disp("ECEF:")
disp(pos1.xyz)

%% ECEF
pos2 = gt.Gpos(pos1.xyz,"xyz");

disp("LLH:")
disp(pos2.llh)

%% ENU
orgllh = [35 139 100];
pos3 = gt.Gpos(llh,"llh",orgllh,"llh");

disp("ENU:")
disp(pos3.enu)

%% Set coordinate origin
pos2.setOrg(orgllh,"llh");

disp("ENU:")
disp(pos2.enu)

%% ENU to LLH
enu = [0 0 0;
       1 1 1];

pos4 = gt.Gpos(enu,"enu",orgllh,"llh");

disp("LLH:")
disp(pos4.llh)
