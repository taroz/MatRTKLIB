classdef Grtk < handle
    % Grtk: RTKLIB rtk control struct class
    %
    % Grtk Declaration:
    % obj = Grtk(file)
    %   file   : 1x1, RTKLIB configration file (???.conf)
    %
    % obj = Grtk(optstr)
    %   optstr : 1x1, RTKLIB option struct
    %
    % obj = Grtk(rtkstr)
    %   optstr : 1x1, RTKLIB rtk control struct
    %
    % Grtk Properties:
    %   n      : 1x1, Number of epochs
    %   time   : 1x1, Time, gt.Gtime class
    %   nx     : 1x1, number of float states
    %   na     : 1x1, number of fixed states
    %   x      : (obj.n)x(obj.nx), float states
    %   P      : (obj.nx)x(obj.nx)x((obj.n)), float covariance
    %   xa     : (obj.n)x(obj.na),  fixed states
    %   Pa     : (obj.na)x(obj.na)x(obj.n), fixed covariance
    %   nfix   : (obj.n)x1, number of continuous fixes of ambiguity
    %   tt     : (obj.n)x1, time difference between current and previous (s)
    %   rb     : (obj.n)x6, base position/velocity (ecef) (m|m/s)
    %   errmsg : (obj.n)x1, error message
    %
    % Grtk Methods:
    %   setRtkFile(file):
    %   setRtkStruct(rtkstr):
    %   rtkstr = struct():
    %   help()
    %
    %     Author: Taro Suzuki

    properties
        n, time, nx, na, x, P, xa, Pa, nfix, tt, rb, errmsg;
    end
    methods
        %% constractor
        function obj = Grtk(varargin)
            if nargin==1 && ischar(varargin{1})
                obj.setRtkFile(varargin{1}); % file
            elseif nargin==1 && isstruct(varargin{1})
                obj.setRtkStruct(varargin{1}); % opt struct
            else
                error('Wrong input arguments');
            end
        end

        %% set option data from config file
        function setRtkFile(obj, file)
            arguments
                obj gt.Grtk
                file (1,:) char
            end
            optstr = rtklib.loadopts(file);
            rtkstr = rtklib.rtkinit(optstr);
            obj.setRtkStruct(rtkstr);
        end
        %% set option data from option struct
        function setRtkStruct(obj, rtkstr)
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

        %% convert to struct
        function rtkstr = struct(obj)
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
            doc gt.Grtk
        end
    end
end