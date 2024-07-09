%% estimate_position_rtk_step_by_step.m
% Step by step example of RTK-GNSS positioning
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/static/"; % Static data

%% Read RINEX observation/navigation file
obsr = gt.Gobs(datapath+"rover.obs");
obsb = gt.Gobs(datapath+"base.obs");
nav = gt.Gnav(datapath+"base.nav");

% Select only GPS
obsr = obsr.selectSat(obsr.sys==gt.C.SYS_GPS);
[obsr,obsb] = obsr.commonObs(obsb);

%% Rover and base position
% Read reference position from text file
posr_ref = gt.Gpos(readmatrix(datapath+"rover_position.txt"),"llh");
posb = gt.Gpos(readmatrix(datapath+"base_position.txt"),"llh");

% Rover initial position
posr = posr_ref.copy();
posr.addOffset([10 10 10],"xyz"); % Add 10m offset

satr = gt.Gsat(obsr, nav); % Compute satellite position
satr.setRcvPos(posr); % Set receiver position

satb = gt.Gsat(obsb, nav); % Compute satellite position
satb.setRcvPos(posb); % Set receiver position

%% Select observations for position computation
SNR_TH = 30; % SNR threshold (dBHz)
EL_TH = 5; % Elevation angle threshold (deg)

mask = obsr.L1.S<SNR_TH | satb.el<EL_TH;
obsr.mask(mask); % Mask observation
obsb.mask(mask);
obsr.maskLLI();  % Carrier phase mask using LLI flag
obsb.maskLLI();

%% Compute residuals
obsr = obsr.residuals(satr); % Compute residuals
obsb = obsb.residuals(satb);

%% Single difference (rover-base)
obsrb = obsr-obsb;

%% Double difference
% Reference satellite (higest elevation angle)
refsatidx = satb.referenceSat();

% Double difference observation
obsrb = obsrb.doubleDifference(refsatidx);

% Difference of LOS vecotor
ex = satr.ex-satr.ex(:,refsatidx);
ey = satr.ey-satr.ey(:,refsatidx);
ez = satr.ez-satr.ez(:,refsatidx);

%% Simple elevation angle dependent weight model
varP90 = 0.8^2; % DD pseudorange (m)^2
wP = 1./(varP90./sind(satb.el)); 

varL90 = 0.005^2; % DD carrier phase (m)^2
wL = 1./(varL90./sind(satb.el));

%% Positioning
xlog = NaN(obsrb.n,3+obsrb.nsat);  % Ambiguity float solution
xalog = NaN(obsrb.n,3+obsrb.nsat); % Ambiguity fix solution
ratio = NaN(obsrb.n,1); % Ratio
stat = gt.C.SOLQ_FLOAT*ones(obsrb.n,1);
RATIO_TH = 3.0;

% Epoch loop
for i=1:obsrb.n
    idx = find(~isnan(obsrb.L1.resPdd(i,:)) &...
               ~isnan(obsrb.L1.resLdd(i,:))); % Index not NaN

    nobs = length(idx); % Number of current observation

    % Design matrix
    H = zeros(2*nobs,3+nobs);
    % DD pseudorange
    H(1:nobs,1) = -ex(i,idx)'; % LOS vector in ECEF X
    H(1:nobs,2) = -ey(i,idx)'; % LOS vector in ECEF Y
    H(1:nobs,3) = -ez(i,idx)'; % LOS vector in ECEF Z
    % DD carrier phase
    H(nobs+1:end,1) = -ex(i,idx)'; % LOS vector in ECEF X
    H(nobs+1:end,2) = -ey(i,idx)'; % LOS vector in ECEF Y
    H(nobs+1:end,3) = -ez(i,idx)'; % LOS vector in ECEF Z
    H(nobs+1:end,4:end) = diag(obsrb.L1.lam(idx)); % Ambiguities
    
    % Weighted least square
    % (y-H*x)'*diag(w)*(y-H*x)
    w = [wP(i,idx) wL(i,idx)];
    y = [obsrb.L1.resPdd(i,idx) obsrb.L1.resLdd(i,idx)]'; % Measurements: Pseudorange+Carrier phase
    [dx,~,~,Q] = lscov(H,y,w); % Weighted least squares

    x = posr.xyz+dx(1:3)'; % Float solution
    f = dx(4:end)'; % Float ambiguities

    % Logging float solution
    xlog(i,1:3) = x;
    xlog(i,3+idx) = f;

    Qf = Q(4:end,4:end); % Ambiguity covariance
    Qxf = Q(1:3,4:end);  % Position-Ambiguity covariance
    
    % LAMBDA (integer least-square estimation)
    [a,s] = rtklib.lambda(2,f,Qf); % Output top two solutions for ratio test

    % Ratio test
    ratio(i) = s(2)/s(1);
    xalog(i,:) = xlog(i,:);
    if ratio(i)>RATIO_TH
        df = f-a(1,:);  % Ambiguity difference
        x = x-(Qxf/Qf*df')'; % Fix solution

        % logging fix solution
        xalog(i,1:3) = x;
        xalog(i,3+idx) = a(1,:);
        stat(i) = gt.C.SOLQ_FIX;
    end
    fprintf("i=%d\n",i);
end

%% Plot solution
pos = gt.Gpos(xalog(:,1:3),"xyz",posr_ref.xyz,"xyz");
sol = gt.Gsol(obsrb.time,pos,stat);
sol.plot
sol.showStatRate

% Ratio
figure;
plot(ratio,'b.-'); hold on; grid on;
plot([0 obsrb.n], [RATIO_TH RATIO_TH],"r-","LineWidth",2);
ylabel("AR ratio");
legend("AR ratio","Threshold");