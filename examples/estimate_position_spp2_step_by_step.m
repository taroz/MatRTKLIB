%% estimate_position_spp2_step_by_step.m
% Step by step example of single point positioning
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/static/"; % Static data

%% Read RINEX observation and navigation file
nav = gt.Gnav(datapath+"base.nav");
obs = gt.Gobs(datapath+"rover.obs");

%% Position reference
pos_ref = gt.Gpos(readmatrix(datapath+"rover_position.txt"),"llh");
pos_ini = pos_ref.copy;
pos_ini.addOffset([10 10 10],"xyz"); % Initial position is true position + 10 m offset

%% Compute residuals
sat = gt.Gsat(obs, nav); % Compute satellite position
sat.setRcvPos(pos_ini); % Set receiver position
obs = obs.residuals(sat); % Compute residuals

%% Select observations for position computation
SNR_TH = 25; % SNR threshold (dBHz)
EL_TH = 5; % Elevation angle threshold (deg)
mask = obs.L1.S<SNR_TH | sat.el<EL_TH;
obs.maskP(mask);

%% Simple elevation angle dependent weight model
varP90 = 0.5^2;
w = 1./(varP90./sind(sat.el)); 

%% Initials
nx = 3+length(unique(obs.sys)); % Position in ECEF and receiver clock [x,y,z,dtr]'
x = [pos_ini.xyz zeros(1,nx-3)]'; % Initial position
xlog = zeros(obs.n,nx); % For logging solution

%% Point positioning
for i=1:obs.n
    % resP = obs.P-(rng-dts+ion+trp)-dtr-tgd
    resP = obs.L1.resPc(i,:)-x(4)-nav.getTGD(sat.sat);
    resP(obs.sys==gt.C.SYS_GLO) = resP(obs.sys==gt.C.SYS_GLO)-x(5);
    resP(obs.sys==gt.C.SYS_GAL) = resP(obs.sys==gt.C.SYS_GAL)-x(6);
    resP(obs.sys==gt.C.SYS_QZS) = resP(obs.sys==gt.C.SYS_QZS)-x(7);
    resP(obs.sys==gt.C.SYS_CMP) = resP(obs.sys==gt.C.SYS_CMP)-x(8);

    idx = ~isnan(resP); % Index not NaN
    nobs = nnz(idx); % Number of current observation
    sys = obs.sys(idx);

    % Design matrix
    H = zeros(nobs,nx);
    H(:,1) = -sat.ex(i,idx)'; % LOS vector in ECEF X
    H(:,2) = -sat.ey(i,idx)'; % LOS vector in ECEF Y
    H(:,3) = -sat.ez(i,idx)'; % LOS vector in ECEF Z
    H(:,4) = 1.0;           % Reciever clock
    H(sys==gt.C.SYS_GLO,5) = 1.0;           % Reciever clock
    H(sys==gt.C.SYS_GAL,6) = 1.0;           % Reciever clock
    H(sys==gt.C.SYS_QZS,7) = 1.0;           % Reciever clock
    H(sys==gt.C.SYS_CMP,8) = 1.0;           % Reciever clock
    
    % Weighted least square
    % (y-H*x)'*diag(w)*(y-H*x)
    y = resP(idx)';
    dx = lscov(H,y,w(i,idx)); % position/clock error

    xlog(i,:) = (x+dx)';
    fprintf("i=%d\n",i);
end

%% Plot positioning error
posest = gt.Gpos(xlog(:,1:3),'xyz');
posest.setOrg(pos_ref.llh,"llh");
posest.plot