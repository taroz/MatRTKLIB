classdef Gopt < handle
    % Gopt: RTKLIB process option class
    % ---------------------------------------------------------------------
    % Gopt Declaration:
    % obj = Gopt()
    %
    % obj = Gopt(file)
    %   file      : 1x1, RTKLIB configration file (???.conf)
    %
    % obj = Gnav(optstr)
    %   optstr    : 1x1, RTKLIB option struct
    % ---------------------------------------------------------------------
    % Gopt Properties:
    %   pos1      : 1x1, Positioning setting 1 struct
    %   pos2      : 1x1, Positioning setting 2 struct
    %   out       : 1x1, Output setting struct
    %   stats     : 1x1, Statistics setting struct
    %   ant       : 1x1, Antenna setting struct
    %   misc      : 1x1, Misc setting struct
    % ---------------------------------------------------------------------
    % Gopt Methods;
    %   setOptFile(file);     Set option data from config file
    %   setOptStruct(optstr); Set option data from option struct
    %   saveOpt(file);        Save option file
    %   optstr = struct();    Convert from gt.Gopt to struct
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
        %% contractor
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
            % setOptFile: Set process optinon from file
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
                optstr = rtklib.loadopts(file);
            end
            obj.setOptStruct(optstr);
        end
        %% setOptStruct
        function setOptStruct(obj, optstr)
            % setOptStruct: Set process option from option struct
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
            rtklib.saveopts(file, optstr);
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
            % show: Show current process options
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
end