clc; clear; close all;
addpath ..\
basepath = '.\data\';

%% Read RINEX observation and navigation file
nav = rtklib.readrnxnav([basepath 'base.nav']);
obs = rtklib.readrnxobs([basepath 'rover.obs']);

%% Generate RTKLIB config file
opt = rtklib.loadopts();                % Load RTKLIB default configration
opt.pos1.navsys = double(gt.C.NAVSYS_GREQC);    % Satellite system used for positioning
opt.pos1.elmask = 30;                   % elevation mask
opt.pos1.snrmask_r = gt.C.ON;           % SNR mask ON
opt.pos1.snrmask_L1 = 35*ones(1,9);     % L1 SNR mask
rtklib.saveopts([basepath 'spp.conf'], opt); % save configration to file

% load RTKLIB config file
% opt = rtklib.loadopts([basepath 'spp.conf']);  % load configration from file

%% Single point positioning
sol = rtklib.pntpos(obs, nav, opt);

%% ECEF to ENU
orgxyz = sol.rr(1, 1:3); % first position is coordinate origin
orgllh = rtklib.xyz2llh(orgxyz);
enu = rtklib.xyz2enu(sol.rr(:,1:3), orgllh);
venu = rtklib.ecef2enu(sol.rr(:,4:6), orgllh);

%% Plot
f = figure;
f.Position(2) = f.Position(2)-f.Position(4);
f.Position(4) = 2*f.Position(4);
tiledlayout(4,1,'TileSpacing','Compact');
axy = nexttile(1, [2 1]);
plot(enu(:,1), enu(:,2), 'b.-');
xlabel('East (m)');
ylabel('North (m)');
grid on; hold on; axis equal;
az = nexttile;
plot(enu(:,3), 'b.-');
grid on; hold on;
ylabel('Up (m)');
asat = nexttile;
plot(sol.ns, 'b.-');
grid on; hold on;
ylabel('Number of satellites');
linkaxes([az asat], 'x');