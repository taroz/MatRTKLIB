classdef Gopt < handle
    % Gopt: RTKLIB process option class
    % ---------------------------------------------------------------------
    % Gopt Declaration:
    % gopt = gt.Gopt();  Create gt.Gopt object using default option struct
    %
    % gopt = gt.Gopt(file);  Create gt.Gopt object from configration file
    %   file         : 1x1, RTKLIB configration file (???.conf)
    %
    % gopt = gt.Gopt(optstr);  Create gt.Gopt object from option struct
    %   optstr       : 1x1, RTKLIB option struct
    % ---------------------------------------------------------------------
    % Gopt Properties:
    % pos1 : 1x1, Positioning setting 1 struct
    %     .posmode   : 1x1, Positioning mode (PMODE_???)
    %     .navsys    : 1x1, Navigation systems (NAVSYS_G, ... , NAVSYS_GREQC)
    %     .frequency : 1x1, Number of frequencies (FREQOPT_L1, ..., FREQOPT_L12345)
    %     .elmask    : 1x1, Elevation mask (deg)
    %     .snrmask_r : 1x1, SNR mask for rover (ON/OFF)
    %     .snrmask_b : 1x1, SNR mask for base (ON/OFF)
    %     .snrmask_L1: 1x9, Elevation vs mask L1 SNR (dB-Hz)
    %     .snrmask_L2: 1x1, Elevation vs mask L2 SNR (dB-Hz)
    %     .snrmask_L5: 1x1, Elevation vs mask L5 SNR (dB-Hz)
    %     .tidecorr  : 1x1, Earth tide correction (0:off,1:solid,2:solid+otl+pole)
    %     .ionoopt   : 1x1, Ionosphere option (IONOOPT_???)
    %     .tropopt   : 1x1, Troposphere option (TROPOPT_???)
    %     .ephopt    : 1x1, Satellite ephemeris/clock (EPHOPT_???)
    %     .raim_fde  : 1x1, RAIM FDE (ON/OFF)
    %     .exclsats  : cell array, Excluded satellites e.g. {'G01','C02'}
    % pos2 : 1x1, Positioning setting 2 struct
    %     .armode    : 1x1, AR mode (0:off,1:continuous,2:instantaneous,3:fix and hold,4:ppp-ar)
    %     .gloarmode : 1x1, GLONASS AR mode (0:off,1:on,2:auto cal,3:ext cal)
    %     .bdsarmode : 1x1, BeiDou AR mode (0:off,1:on)
    %     .arthres   : 1x1, AR validation threshold
    %     .arlockcnt : 1x1, Min lock count to fix ambiguity
    %     .aroutcnt  : 1x1, Outage count to reset bias
    %     .armaxiter : 1x1, Max iteration to resolve ambiguity
    %     .filteriter: 1x1, Number of filter iteration
    %     .maxinno   : 1x1, Reject threshold of innovation (m)
    % out : 1x1, Output setting struct
    %     .solformat  : 1x1, Solution format (SOLF_???)
    %     .timeformat : 1x1, Time format (0:sssss.s,1:yyyy/mm/dd hh:mm:ss.s)
    %     .trace      : 1x1, Debug trace level (0:off,1-5:debug)
    % stats : 1x1, Statistics setting struct
    %     .eratio1    : 1x1, L1 code/phase error ratio
    %     .eratio2    : 1x1, L2 code/phase error ratio
    %     .errphase   : 1x1, Phase error factor (m)
    %     .errphaseel : 1x1, Phase error factor (m)
    % ant : 1x1, Antenna setting struct
    %     .rovtype    : 1x1, Position type (0:llh,1:xyz,2:single,3:posfile,4:rinexhead,5:rtcm,6:raw)
    %     .rovpos     : 1x3, Rover position for fixed mode
    %     .rovant     : char, Rover antenna name
    %     .rovdenu    : 1x3, Rovere antenna delta position (m)
    %     .reftype    : 1x1, Position type (0:llh,1:xyz,2:single,3:posfile,4:rinexhead,5:rtcm,6:raw)
    %     .refpos     : 1x3, Base position
    %     .refant     : char, Base antenna name
    %     .refdenu    : 1x3, Base antenna delta position (m)
    % misc : 1x1, Misc setting struct
    %     .timeinterp : 1x1, Interpolate reference observation (ON/OFF)
    % ---------------------------------------------------------------------
    % Gopt Methods;
    %   setOptFile(file);     Set option data from config file
    %   setOptStruct(optstr); Set option data from option struct
    %   saveOpt(file);        Save option file
    %   gopt = copy();        Copy object
    %   optstr = struct();    Convert from gt.Gopt object to struct
    %   show();               Show current options
    %   help();               Show help
    % ---------------------------------------------------------------------
    % Author: Taro Suzuki
    %
    properties
        pos1  % Positioning setting 1 struct
        pos2  % Positioning setting 2 struct
        out   % Output setting struct
        stats % Statistics setting struct
        ant   % Antenna setting struct
        misc  % Misc setting struct
    end
    methods
        %% constructor
        function obj = Gopt(varargin)
            if nargin == 0
                obj.setOptFile()
            elseif nargin==1 && (ischar(varargin{1}) || isStringScalar(varargin{1}))
                obj.setOptFile(char(varargin{1})); % file
            elseif nargin==1 && isstruct(varargin{1})
                obj.setOptStruct(varargin{1}); % opt struct
            else
                error('Wrong input arguments');
            end
        end
        %% setOptFile
        function setOptFile(obj, file)
            % setOptFile: Set option data from config file
            % -------------------------------------------------------------
            % Read the config file of RTKLIB.
            %
            % Usage: ------------------------------------------------------
            %   obj.setOptFile(file)
            %
            % Input: ------------------------------------------------------
            %   file  : RTKLIB config file (???.conf)
            %
            arguments
                obj gt.Gopt
                file (1,:) char = ''
            end
            if isempty(file)
                optstr = rtklib.loadopts();
            else
                optstr = rtklib.loadopts(obj.absPath(file));
            end
            obj.setOptStruct(optstr);
        end
        %% setOptStruct
        function setOptStruct(obj, optstr)
            % setOptStruct: Set option data from option struct
            % -------------------------------------------------------------
            % Set objects from RTKLIB's option structure.
            %
            % Usage: ------------------------------------------------------
            %   obj.setOptStruct(optstr)
            %
            % Input: ------------------------------------------------------
            %   optstr  : RTKLIB option struct
            %
            arguments
                obj gt.Gopt
                optstr (1,1) struct
            end
            % pos1
            obj.pos1 = optstr.pos1;
            obj.pos1.posmode = gt.C.PMODE(optstr.pos1.posmode);
            obj.pos1.navsys = gt.C.NAVSYS(optstr.pos1.navsys);
            obj.pos1.frequency = gt.C.FREQOPT(optstr.pos1.frequency);
            obj.pos1.snrmask_r = gt.C.SWITCH(optstr.pos1.snrmask_r);
            obj.pos1.snrmask_b = gt.C.SWITCH(optstr.pos1.snrmask_b);
            obj.pos1.tidecorr = gt.C.TIDE(optstr.pos1.tidecorr);
            obj.pos1.ionoopt = gt.C.IONOOPT(optstr.pos1.ionoopt);
            obj.pos1.tropopt = gt.C.TROPOPT(optstr.pos1.tropopt);
            obj.pos1.ephopt = gt.C.EPHOPT(optstr.pos1.ephopt);
            obj.pos1.raim_fde = gt.C.SWITCH(optstr.pos1.raim_fde);
            % pos2
            obj.pos2 = optstr.pos2;
            obj.pos2.armode = gt.C.ARMODE(optstr.pos2.armode);
            obj.pos2.gloarmode = gt.C.SWITCH(optstr.pos2.gloarmode);
            obj.pos2.bdsarmode = gt.C.SWITCH(optstr.pos2.bdsarmode);
            % out
            obj.out = optstr.out;
            obj.out.solformat = gt.C.SOLF(optstr.out.solformat);
            obj.out.timeformat = gt.C.TIMEF(optstr.out.timeformat);
            obj.out.trace = gt.C.TRACE(optstr.out.trace);

            % stats
            obj.stats = optstr.stats;
            % ant
            obj.ant = optstr.ant;
            obj.ant.rovtype = gt.C.POSOPT(optstr.ant.rovtype);
            obj.ant.reftype = gt.C.POSOPT(optstr.ant.reftype);
            % misc
            obj.misc = optstr.misc;
            obj.misc.timeinterp = gt.C.SWITCH(optstr.misc.timeinterp);
        end
        %% saveOpt
        function saveOpt(obj, file)
            % saveOpt: Output option file
            % -------------------------------------------------------------
            % Output RTKLIB option file (???.conf).
            %
            % Usage: ------------------------------------------------------
            %   obj.saveOpt(file)
            %
            % Input: ------------------------------------------------------
            %   file : Output option file name (???.conf)
            %
            arguments
                obj gt.Gopt
                file (1,:) char
            end
            optstr = obj.struct();
            rtklib.saveopts(obj.absPath(file), optstr);
        end
        %% copy
        function gopt = copy(obj)
            % copy: Copy object
            % -------------------------------------------------------------
            % MATLAB handle class is used, so if you want to create a
            % different instance, you need to use the copy method.
            %
            % Usage: ------------------------------------------------------
            %   gopt = obj.copy()
            %
            % Output: -----------------------------------------------------
            %   gopt : 1x1, Copied gt.Gopt object
            %
            arguments
                obj gt.Gopt
            end
            gopt = gt.Gopt(obj.struct());
        end
        %% struct
        function optstr = struct(obj)
            % struct: Convert from gt.Gopt object to struct
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.struct()
            %
            % Output: -----------------------------------------------------
            %   solstr :  RTKLIB solution struct
            %
            arguments
                obj gt.Gopt
            end
            % pos1
            pos1_ = obj.pos1;
            pos1_ = rmfield(pos1_,'exclsats');
            optstr.pos1 = structfun(@double,pos1_,'UniformOutput',false);
            optstr.pos1.exclsats = obj.pos1.exclsats;
            % pos2
            optstr.pos2 = structfun(@double,obj.pos2,'UniformOutput',false);
            % out
            optstr.out = structfun(@double,obj.out,'UniformOutput',false);
            % stats
            optstr.stats = structfun(@double,obj.stats,'UniformOutput',false);
            % ant
            ant_ = obj.ant;
            ant_ = rmfield(ant_,'rovant');
            ant_ = rmfield(ant_,'refant');
            optstr.ant = structfun(@double,ant_,'UniformOutput',false);
            optstr.ant.rovant = obj.ant.rovant;
            optstr.ant.refant = obj.ant.refant;
            % misc
            optstr.misc = structfun(@double,obj.misc,'UniformOutput',false);
        end
        %% show
        function show(obj)
            % show: Show current options
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.show()
            %
            disp(obj.pos1)
            disp(obj.pos2)
            disp(obj.out)
            disp(obj.stats)
            disp(obj.ant)
            disp(obj.misc)
        end
        %% help
        function help(~)
            % help: Show help
            doc gt.Gopt
        end
    end
    %% Private functions
    methods(Access=private)
        %% Convert from relative path to absolute path
        function apath = absPath(~, rpath)
            if isstring(rpath)
                rpath = char(rpath);
            end
            [dirname, filename, ext] = fileparts(rpath);
            [status, pathinfo] = fileattrib(dirname);
            if status==1
                apath = fullfile(pathinfo.Name, strcat([filename, ext]));
            else
                error('Directory does not exist: %s',dirname);
            end
        end
    end
end