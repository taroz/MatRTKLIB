classdef Gtime < handle
    % Gtime: GPS time class
    %
    % Gtime Declaration:
    % obj = Gtime(epoch, [utcflag])
    %   epoch    : Nx6, calendar time vector
    %                [year, month, day, hour, minutes, second]
    %   [utcflag]: 1x1, UTC flag 0:GPST, 1:UTC
    %
    % obj = Gtime(tow, week)
    %   tow      : Nx1, time of week in GPST (s)
    %   week     : Nx1 or 1x1, GPS week
    %
    % obj = Gtime(sod, ymd, [utcflag])
    %   sod      : Nx1, Seconds of day (s)
    %   ymd      : Nx3 or 1x3, [year, month, day]
    %   [utcflag]: 1x1, UTC flag 0:GPST, 1:UTC
    %
    % obj = Gtime(t)
    %   t        : Mx1, datetime vector in MATLAB
    %
    % Gtime Properties:
    %   n        : 1x1, Number of epochs
    %   ep       : (obj.n)x3, calendar time vector
    %                [year, month, day, hour, minutes, second]
    %   tow      : (obj.n)x1, Nx1, time of week in GPST (s)
    %   week     : (obj.n)x3, GPS week
    %   t        : (obj.n)x1, datetime vector in MATLAB
    %
    % Gtime Methods:
    %   setEpoch(epoch, [utcflag]):
    %   setGPST(tow, week):
    %   setSod(sod, ymd, [utcflag]):
    %   setDatetime(t):
    %   append(gtime)
    %   addOffset(offset)
    %   round([ndec]):
    %   gtime = select(idx):
    %   gtime = selectTimeSpan(ts, te):
    %   dt = estInterval([ndec])
    %   doy = doy([idx]):
    %   dow = dow([idx]):
    %   sod = sod([idx]):
    %   ymd = ymd([idx]):
    %   hms = hms([idx]):
    %   plot([idx]):
    %   plotDiff([idx]):
    %   help()
    %
    % Author: Taro Suzuki

    properties
        n, ep, tow, week, t;
    end

    methods
        %% constractor
        function obj = Gtime(varargin)
            if nargin==1
                if isdatetime(varargin{1})
                    obj.setDatetime(varargin{1}); % datetime
                else
                    obj.setEpoch(varargin{1}); % epoch
                end
            elseif nargin==2
                if size(varargin{1}, 2) == 6
                    obj.setEpoch(varargin{1}, varargin{2}); % epoch+utcflag
                elseif size(varargin{1}, 2) == 1 && size(varargin{2}, 2) == 3
                    obj.setSod(varargin{1}, varargin{2}); % sod+ymd
                elseif size(varargin{1}, 2) == 1 && size(varargin{2}, 2) == 1
                    obj.setGPST(varargin{1}, varargin{2}); % tow+week
                else
                    error('Wrong input arguments');
                end
            elseif nargin==3
                obj.setSod(varargin{1}, varargin{2}, varargin{3}); % sod+ymd+utcflag
            else
                error('Wrong input arguments');
            end
        end

        %% set epoch
        function setEpoch(obj, epoch, utcflag)
            arguments
                obj gt.Gtime
                epoch (:,6) double
                utcflag (1,1) {mustBeInteger} = 0
            end
            if utcflag
                obj.ep = rtklib.utc2gpst(epoch);
            else
                obj.ep = epoch;
            end
            [obj.tow, obj.week] = rtklib.epoch2tow(obj.ep);
            obj.t = obj.ep2datetime(obj.ep);
            obj.n = size(obj.ep,1);
        end

        %% set GPST
        function setGPST(obj, tow, week)
            arguments
                obj gt.Gtime
                tow (:,1) double
                week double {mustBeInteger, mustBeVector}
            end
            if isscalar(week); week = repmat(week,size(tow)); end
            obj.tow = tow;
            obj.week = week;
            obj.ep = rtklib.tow2epoch(obj.tow, obj.week);
            obj.t = obj.ep2datetime(obj.ep);
            obj.n = size(obj.ep, 1);
        end

        %% set sod
        function setSod(obj, sod, ymd, utcflag)
            arguments
                obj gt.Gtime
                sod (:,1) double
                ymd (:,3) double
                utcflag (1,1) {mustBeInteger} = 0
            end
            if size(ymd, 1) == 1; ymd = repmat(ymd, [size(sod,1) 1]); end
            if utcflag
                obj.ep = rtklib.utc2gpst([ymd obj.sod2hms(sod)]);
            else
                obj.ep = [ymd obj.sod2hms(sod)];
            end
            [obj.tow, obj.week] = rtklib.epoch2tow(obj.ep);
            obj.t = obj.ep2datetime(obj.ep);
            obj.n = size(obj.ep,1);
        end

        %% set datatime
        function setDatetime(obj, t)
            arguments
                obj gt.Gtime
                t (:,1) datetime
            end
            obj.t = t;
            obj.ep = [t.Year, t.Month, t.Day, t.Hour, t.Minute, t.Second];
            [obj.tow, obj.week] = rtklib.epoch2tow(obj.ep);
            obj.n = size(obj.ep,1);
        end

        %% append
        function append(obj, gtime)
            arguments
                obj gt.Gtime
                gtime gt.Gtime
            end
            obj.setDatetime([obj.t; gtime.t]);
        end
        
        %% addOffset
        function addOffset(obj, offset)
            arguments
                obj gt.Gtime
                offset (1,1)
            end
            switch class(offset)
                case 'double'
                    obj.setDatetime(obj.t+seconds(offset));
                case 'duration'
                    obj.setDatetime(obj.t+offset);
            end
        end

        %% round
        function round(obj, ndec)
            arguments
                obj gt.Gtime
                ndec (1,1) {mustBeInteger} = 2
            end
            t_ = obj.roundDateTime(obj.t, ndec);
            obj.setDatetime(t_);
        end

        %% copy
        function gtime = copy(obj)
            arguments
                obj gt.Gtime
            end
            gtime = obj.select(1:obj.n);
        end

        %% select
        % select from index
        function gtime = select(obj, idx)
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector}
            end
            if ~any(idx)
                error('Selected index is empty');
            end
            gtime = gt.Gtime(obj.ep(idx, :));
        end
        % select from time span
        function [gtime, idx] = selectTimeSpan(obj, ts, te)
            arguments
                obj gt.Gtime
                ts (1,1) gt.Gtime
                te (1,1) gt.Gtime
            end
            idx = obj.t>=ts.t & obj.t<=te.t;
            gtime = obj.select(idx);
        end

        %% estimate time interval
        function dt = estInterval(obj, ndec)
            arguments
                obj gt.Gtime
                ndec (1,1) {mustBeInteger} = 2
            end

            if obj.n > 1
                dt = round(median(seconds(diff(obj.t))),ndec);
            else
                dt = 0;
            end
        end

        %% access
        % day of year
        function doy = doy(obj, idx)
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            doy = fix(rtklib.epoch2doy(obj.ep(idx,:)));
        end
        % day of week
        function dow = dow(obj, idx)
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            dow = weekday(obj.t.t(idx));
        end
        % seconds of day
        function sod = sod(obj, idx)
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            sod = obj.hms2sod(obj.ep(idx, 4:6));
        end
        % year,month,date
        function ymd = ymd(obj, idx)
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            ymd = obj.ep(idx, 1:3);
        end
        % hour,minute,second
        function hms = hms(obj, idx)
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            hms = obj.ep(idx, 4:6);
        end
        % Two-digit year
        function yy = yy(obj, idx)
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            yy = obj.ep(idx, 1)-2000;
        end
        % year
        function year = year(obj, idx)
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            year = obj.ep(idx, 1);
        end
        % month
        function month = month(obj, idx)
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            month = obj.ep(idx, 2);
        end
        % day
        function day = day(obj, idx)
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            day = obj.ep(idx, 3);
        end
        % hour
        function hour = hour(obj, idx)
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            hour = obj.ep(idx, 4);
        end
        % minute
        function minute = minute(obj, idx)
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            minute = obj.ep(idx, 5);
        end
        % second
        function second = second(obj, idx)
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            second = obj.ep(idx, 6);
        end

        %% plot
        function plot(obj)
            arguments
                obj gt.Gtime
            end
            figure;
            plot(obj.t, '.-');
            ylabel('Time');
            grid on;
        end
        function plotDiff(obj)
            arguments
                obj gt.Gtime
            end
            if obj.n > 1
                figure;
                plot(seconds(diff(obj.t)), '.-');
                ylabel('Time difference (s)');
                grid on;
            end
        end

        %% help
        function help(~)
            doc gt.Gtime
        end
    end

    %% private functions
    methods (Access = private)
        % round datetime
        function dtr = roundDateTime(~, dt, dec)
            dtr = dateshift(dt,'start','minute') + seconds(round(second(dt),dec));
        end
        % convert
        function sod = hms2sod(~, hms)
            arguments
                ~
                hms (:,3) double
            end
            sod = 3600*hms(:,1)+60*hms(:,2)+hms(:,3);
        end
        function hms = sod2hms(~,sod)
            arguments
                ~
                sod (:,1) double
            end
            h = fix(sod/3600);
            m = fix((sod-3600*h)/60);
            s = sod-3600*h-60*m;
            hms = [h m s];
        end
        function t = ep2datetime(~, ep)
            arguments
                ~
                ep (:,6) double
            end
            t = datetime(ep(:,1),ep(:,2),ep(:,3),ep(:,4),ep(:,5),fix(ep(:,6)),...
                round(1000*(ep(:,6)-fix(ep(:,6)))));
        end
    end
end