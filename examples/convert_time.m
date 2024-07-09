%% convert_time.m
% Convert GPS time, calender time and UTC time to each other
% Author: Taro Suzuki

clear; close all; clc;
addpath ../

%% Calendar time vector
epochs = [2024 6 17 1 2 3;...
          2024 6 17 1 2 4];

t1 = gt.Gtime(epochs);

disp("GPS time of week (s):");
disp(t1.tow);
disp("GPS week:");
disp(t1.week);

%% GPS time of week
t2 = gt.Gtime(t1.tow, t1.week);

disp("Calendar time vector:");
disp(t2.ep);

%% MATLAB date time
t3 = gt.Gtime(datetime("now","TimeZone","UTC")); % UTC

disp("Current time in UTC:");
disp(t3.t);

%% UTC to GPST
utcflag = true;
t4 = gt.Gtime(t3.ep, utcflag);

disp("Leap time:");
disp(t3.t-t4.t);

%% Day of year, Day of week, Seconds of day
disp("Current time:");
disp(t4.t);

disp("Day of year:");
disp(t4.doy);

disp("Day of week:");
disp(t4.dow);

disp("Seconds of day:");
disp(t4.sod);

