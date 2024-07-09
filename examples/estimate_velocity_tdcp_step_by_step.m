%% estimate_velocity_tdcp_step_by_step.m
% Step by step example of velocity estimation by TDCP
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/static/";

%% Read RINEX observation and navigation file
nav = gt.Gnav(datapath+"base.nav");
obs = gt.Gobs(datapath+"rover.obs");

%% Initial position/velocity
posini = gt.Gpos(repmat(obs.pos.xyz,[obs.n 1]),"xyz"); % Approximate position
velini = gt.Gvel(zeros(obs.n,3),"xyz"); % Approximate velocity

%% Select observations for position computation
SNR_TH = 30; % SNR threshold (dBHz)
mask = obs.L1.S<SNR_TH;
obs.maskL(mask);
obs.maskLLI(); % Carrier phase mask using LLI flag (Important!)

%% Compute carrier phase residuals
sat = gt.Gsat(obs,nav);
sat.setRcvPosVel(posini,velini);
obs = obs.residuals(sat);

%% Compute TDCP
tdcp = diff(obs.L1.resL); % TDCP between t+1 and t (m)
doppler = (obs.L1.resD(1:end-1,:)+obs.L1.resD(2:end,:))/2; % Mean Doppler residuals between t+1 and t (m/s)

% Cycle slip detection using Doppler
dDL = tdcp/obs.dt-doppler; % TDCP/dt-Doppler (m/s)

% Plot TDCP-Doppler
figure;
plot(tdcp/obs.dt-doppler);
grid on;
ylabel("TDCP-Doppler (m/s)");
title("TDCP-Doppler");

% Exclude TDCP outlier
dDL_th = 1.0;
tdcp(abs(dDL)>dDL_th) = NaN;

%% Relative position estimation
xlog = zeros(obs.n,4); % For logging solution
dxyz = diff(posini.xyz); % Relative position

for i=1:obs.n-1
    x = [dxyz(i,:) 0]'; % [dx dy dz ddtr]' Relative position and clock
    
    % resL = obs.L-(rate-ddts)
    % restdcp = obs.L(t+1)-obs.L(t)-ddtr
    restdcp = tdcp(i,:)-x(4);
    
    idx = ~isnan(restdcp); % Index not NaN
    nobs = nnz(idx); % Number of current observation

    % Simple elevation angle dependent weight model
    varL90 = 0.02^2; % (m)^2
    w = 1./(varL90./sind(sat.el(i,idx))); 

    % Design matrix
    H = zeros(nobs,4);
    H(:,1) = -sat.ex(i,idx)'; % LOS vector in ECEF X
    H(:,2) = -sat.ey(i,idx)'; % LOS vector in ECEF Y
    H(:,3) = -sat.ez(i,idx)'; % LOS vector in ECEF Z
    H(:,4) = 1.0;             % Relative reciever clock
    
    % Weighted least square
    % (y-H*x)'*diag(w)*(y-H*x)
    y = restdcp(idx)';
    dx = lscov(H,y,w);  % Relative position and clock
    
    % Solution correction
    x = x+dx;

    xlog(i,:) = x';
    fprintf("i=%d\n",i);
end

%% Plot velocity error
velest = gt.Gvel(xlog(:,1:3)/obs.dt,"xyz",obs.pos.xyz,"xyz"); % Convert from relative position to velocity
err = velest-gt.Gvel([0 0 0],"xyz",obs.pos.xyz,"xyz");
err.plot
disp("RMS ENU velocity error (m)");
err.rmsENU