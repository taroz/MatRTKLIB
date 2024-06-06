classdef Gstat < handle
    % Gstat: solution/satellite status class
    %
    % Gstat Declaration:
    % obj = Gstat()
    % 
    % obj = Gstat(file)
    %   file      : 1x1, RTKLIB solution status file (???.stat)
    %
    % obj = Gnav(statstr)
    %   statstr   : MxN, ssat_t/stat_t struct array
    % ---------------------------------------------------------------------
    % Gopt Properties:
    %   n         : 1x1, Number of epochs
    %   nsat      : 1x1, Number of satellites
    %   sat       : 1x(obj.nsat), Satellite number defined in RTKLIB
    %   prn       : 1x(obj.nsat), Satellite prn/slot number
    %   sys       : 1x(obj.nsat), Satellite system (SYS_GPS, SYS_GLO, ...)
    %   satstr    : 1x(obj.nsat), Satellite id cell array ('Gnn','Rnn','Enn','Jnn','Cnn','Inn' or 'nnn')
    %   time      : 1x1, Time, gt.Gtime classGLONASS
    %   az        : 1x1, Azimath angle (deg)
    %   el        : 1x1, Elevation angle (deg)
    %   L1        : 1x1, L1 observation struct
    %     .vsat   : (obj.n)x(obj.nsat), SNR (dB-Hz)
    %     .resP   : (obj.n)x(obj.nsat), Pseudorange residuals (m)
    %     .resL   : (obj.n)x(obj.nsat), Carrier phase residuals (m)
    %     .snr    : (obj.n)x(obj.nsat), SNR (dB-Hz)
    %     .fix    : (obj.n)x(obj.nsat), SNR (dB-Hz)
    %     .slip   : (obj.n)x(obj.nsat), SNR (dB-Hz)
    %     .half   : (obj.n)x(obj.nsat), SNR (dB-Hz)
    %     .lock   : (obj.n)x(obj.nsat), SNR (dB-Hz)
    %     .outc   : (obj.n)x(obj.nsat), SNR (dB-Hz)
    %     .slipc  : (obj.n)x(obj.nsat), SNR (dB-Hz)
    %     .rejc   : (obj.n)x(obj.nsat), SNR (dB-Hz)
    %   L2        : 1x1, L2 observation struct
    %   L5        : 1x1, L5 observation struct
    %   L6        : 1x1, L6 observation struct
    %   L7        : 1x1, L7 observation struct
    %   L8        : 1x1, L8 observation struct
    %   L9        : 1x1, L9 observation struct
    % ---------------------------------------------------------------------
    % Gstat Methods:
    %   setStatFile(file):
    %   setStatStruct(statstr):
    %   help()
    %
    %     Author: Taro Suzuki

    properties
        n % Number of epochs
        nsat % Number of satellites
        sat % Satellite number defined in RTKLIB
        prn % Satellite prn/slot number
        sys % Satellite system (SYS_GPS, SYS_GLO, ...)
        satstr % Satellite id cell array ('Gnn','Rnn','Enn','Jnn','Cnn','Inn' or 'nnn')
        time % Time, gt.Gtime classGLONASS
        az % Azimath angle (deg)
        el % Elevation angle (deg)
        L1 % L1 observation struct
        L2 % L2 observation struct
        L5 % L5 observation struct
        L6 % L6 observation struct
        L7 % L7 observation struct
        L8 % L8 observation struct
        L9 % L9 observation struct
    end
    properties(Access=private)
        FTYPE = ["L1","L2","L5","L6","L7","L8","L9"];
    end
    methods
        %% constractor
        function obj = Gstat(varargin)
            if nargin==1 && (ischar(varargin{1}) || isStringScalar(varargin{1}))
                obj.setStatFile(char(varargin{1})); % file
            elseif nargin==1 && isstruct(varargin{1})
                obj.setStatStruct(varargin{1}); % stat struct
            else
                error('Wrong input arguments');
            end
        end

        %% set option data from config file
        function setStatFile(obj, file)
            % setStatFile : set option data from config file
            % -------------------------------------------------------------
            % 
            % Usage: ------------------------------------------------------
            %   obj.setStatFile(file)
            %
            % Input: ------------------------------------------------------
            %  file : 1x1, RTKLIB solution status file
            %
            arguments
                obj gt.Gstat
                file (1,:) char = ''
            end
            statstr = rtklib.readsolstat(file);
            obj.setStatStruct(statstr);
        end
        %% set status data from status struct array
        function setStatStruct(obj, statstr)
            % setStatStruct : set status data from status struct array
            % -------------------------------------------------------------
            % 
            % Usage: ------------------------------------------------------
            %   obj.setStatStruct(statstr)
            %
            % Input: ------------------------------------------------------
            %  statstr : MxN, ssat_t/stat_t struct array
            %
            arguments
                obj gt.Gstat
                statstr struct
            end
            obj.n = statstr.n;
            obj.nsat = statstr.nsat;
            [obj.sat, isat] = sort(statstr.sat);
            obj.az = statstr.az(:,isat);
            obj.el = statstr.el(:,isat);
            
            for f = obj.FTYPE
                if ~isempty(statstr.(f))
                    obj.(f).resP = statstr.(f).resp(:,isat);
                    obj.(f).resL = statstr.(f).resc(:,isat);
                    obj.(f).vsat = statstr.(f).vsat(:,isat);
                    obj.(f).snr = statstr.(f).snr(:,isat);
                    obj.(f).slip = statstr.(f).slip(:,isat);
                    obj.(f).fix = statstr.(f).fix(:,isat);
                    obj.(f).half = statstr.(f).half(:,isat);
                    obj.(f).lock = statstr.(f).lock(:,isat);
                    obj.(f).outc = statstr.(f).outc(:,isat);
                    obj.(f).slipc = statstr.(f).slipc(:,isat);
                    obj.(f).rejc = statstr.(f).rejc(:,isat);
                end
            end

            obj.time = gt.Gtime(statstr.ep);
            [sys_, obj.prn] = rtklib.satsys(obj.sat);
            obj.sys = gt.C.SYS(sys_);
            obj.satstr = rtklib.satno2id(obj.sat);
        end

        %% help
        function help(~)
            doc gt.Gstat
        end
    end
end