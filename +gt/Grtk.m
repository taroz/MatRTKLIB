classdef Grtk < handle
    % Grtk: RTK control struct class
    % ---------------------------------------------------------------------
    % Grtk Declaration:
    % grtk = Grtk(file);  Create gt.Grtk object from config file
    %   file   : 1x1, RTKLIB configuration file (???.conf)
    %
    % grtk = Grtk(gopt);  Create gt.Grtk object from gt.Gopt object
    %   gopt   : 1x1, gt.Gopt object
    %
    % grtk = Grtk(rtkstr);  Create gt.Grtk object from RTK control struct
    %   rtkstr : 1x1, RTK control struct
    % ---------------------------------------------------------------------
    % Grtk Properties:
    %   n      : 1x1, Number of epochs
    %   time   : 1x1, Time, gt.Gtime object
    %   nx     : 1x1, Number of float states
    %   na     : 1x1, Number of fixed states
    %   x      : (obj.n)x(obj.nx), Float states
    %   P      : (obj.nx)x(obj.nx)x((obj.n)), Float covariance
    %   xa     : (obj.n)x(obj.na),  Fixed states
    %   Pa     : (obj.na)x(obj.na)x(obj.n), Fixed covariance
    %   nfix   : (obj.n)x1, Number of continuous fixes of ambiguity
    %   tt     : (obj.n)x1, Time difference between current and previous (s)
    %   rb     : (obj.n)x6, Base position/velocity (ECEF) (m|m/s)
    %   errmsg : (obj.n)x1, Error message
    % ---------------------------------------------------------------------
    % Grtk Methods:
    %   setRtkFile(file);     Set RTK data from config file
    %   setRtkStruct(rtkstr); Set RTK data from RTK control struct
    %   grtk = copy();        Copy object
    %   rtkstr = struct();    Convert from gt.Grtk object to struct
    %   help();               Show help
    % ---------------------------------------------------------------------
    % Author: Taro Suzuki
    %
    properties
        n      % Number of epochs
        time   % Time, gt.Gtime object
        nx     % Number of float states
        na     % Number of fixed states
        x      % Float states
        P      % Float covariance
        xa     % Fixed states
        Pa     % Fixed covariance
        nfix   % Number of continuous fixes of ambiguity
        tt     % Time difference between current and previous (s)
        rb     % Base position/velocity (ECEF) (m|m/s)
        errmsg % Error message
    end
    methods
        %% constructor
        function obj = Grtk(varargin)
            if nargin==1 && ischar(varargin{1})
                obj.setRtkFile(varargin{1}); % file
            elseif nargin==1 && isstruct(varargin{1})
                obj.setRtkStruct(varargin{1}); % opt struct
            elseif nargin==1 && isa(varargin{1},"gt.Gopt") % 
                obj.setRtkObject(varargin{1}); % gt.Gopt
            else
                error('Wrong input arguments');
            end
        end
        %% setRtkFile
        function setRtkFile(obj, file)
            % setRtkFile: Set RTK data from config file
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setRtkFile(file)
            %
            % Input: ------------------------------------------------------
            %   file: 1x1, RTKLIB config file (???.conf)
            %
            arguments
                obj gt.Grtk
                file (1,:) char
            end
            optstr = rtklib.loadopts(obj.absPath(file));
            rtkstr = rtklib.rtkinit(optstr);
            obj.setRtkStruct(rtkstr);
        end
        %% setRtkStruct
        function setRtkStruct(obj, rtkstr)
            % setRtkStruct: Set RTK data from RTK control struct
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setRtkStruct(rtkstr)
            %
            % Input: ------------------------------------------------------
            %   rtkstr: 1x1, RTK control struct
            %
            arguments
                obj gt.Grtk
                rtkstr (:,1) struct
            end
            trtk = struct2table(rtkstr, 'AsArray', true);
            obj.n = size(rtkstr,1);
            obj.time = gt.Gtime(trtk.ep);
            obj.nx = trtk.nx(1);
            obj.na = trtk.na(1);
            obj.x = trtk.x;
            obj.P = trtk.P;
            obj.xa = trtk.xa;
            obj.Pa = trtk.Pa;
            obj.nfix = trtk.nfix;
            obj.tt = trtk.tt;
            obj.rb = trtk.rb;
            obj.errmsg = trtk.errmsg;
        end
        %% setRtkObject
        function setRtkObject(obj, gopt)
            % setRtkObject: Set RTK data from gt.Gobj object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setRtkObject(gopt)
            %
            % Input: ------------------------------------------------------
            %   gopt: 1x1, gt.Gobj object
            %
            arguments
                obj gt.Grtk
                gopt gt.Gopt
            end
            rtkstr = rtklib.rtkinit(gopt.struct);
            obj.setRtkStruct(rtkstr);
        end
        %% copy
        function grtk = copy(obj)
            % copy: Copy object
            % -------------------------------------------------------------
            % MATLAB handle class is used, so if you want to create a
            % different instance, you need to use the copy method.
            %
            % Usage: ------------------------------------------------------
            %   grtk = obj.copy()
            %
            % Output: -----------------------------------------------------
            %   grtk : 1x1, Copied gt.Grtk object
            %
            arguments
                obj gt.Grtk
            end
            grtk = gt.Grtk(obj.struct());
        end
        %% struct
        function rtkstr = struct(obj)
            % setRtkStruct: Convert from gt.Grtk object to struct
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   rtkstr = obj.struct()
            %
            % Output: -----------------------------------------------------
            %   rtkstr: Option struct
            %
            arguments
                obj gt.Grtk
            end
            rtkstr.ep = obj.time.ep(obj.n,:);
            rtkstr.rb = obj.rb(obj.n,:);
            rtkstr.nx = obj.nx;
            rtkstr.na = obj.na;
            rtkstr.tt = obj.tt(obj.n);
            rtkstr.x = obj.x(obj.n,:);
            rtkstr.P = obj.P{obj.n};
            rtkstr.xa = obj.xa(obj.n,:);
            rtkstr.Pa = obj.Pa{obj.n};
            rtkstr.nfix = obj.nfix(obj.n);
            rtkstr.errmsg = obj.errmsg{obj.n};
        end
        %% help
        function help(~)
            % help: Show help
            doc gt.Grtk
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