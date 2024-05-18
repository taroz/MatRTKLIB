classdef Gopt < handle
    % Gopt: RTKLIB process option class
    %
    % Gopt Declaration:
    % obj = Gopt()
    % 
    % obj = Gopt(file)
    %   file      : 1x1, RTKLIB configration file (???.conf)
    %
    % obj = Gnav(optstr)
    %   optstr    : 1x1, RTKLIB option struct
    %
    % Gopt Properties:
    %   pos1      : 1x1, positioning setting 1 struct:
    %   pos2      : 1x1, positioning setting 2 struct:
    %   out       : 1x1, output setting struct:
    %   stats     : 1x1, statistics setting struct:
    %   ant       : 1x1, antenna setting struct:
    %   misc      : 1x1, misc setting struct:
    %
    % Gopt Methods:
    %   setOptFile(file):
    %   setOptStruct(optstr):
    %   saveOpt(file):
    %   optstr = struct():
    %   show()
    %   help()
    %
    %     Author: Taro Suzuki

    properties
        pos1, pos2, out, stats, ant, misc;
    end
    methods
        %% constractor
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

        %% set option data from config file
        function setOptFile(obj, file)
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
        %% set option data from option struct
        function setOptStruct(obj, optstr)
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

        %% save option file
        function saveOpt(obj, file)
            arguments
                obj gt.Gopt
                file (1,:) char
            end
            optstr = obj.struct();
            rtklib.saveopts(file, optstr);
        end

        %% convert to struct
        function optstr = struct(obj)
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

        %% show current options
        function show(obj)
            disp(obj.pos1)
            disp(obj.pos2)
            disp(obj.out)
            disp(obj.stats)
            disp(obj.ant)
            disp(obj.misc)
        end
        %% help
        function help(~)
            doc gt.Gopt
        end
    end
end