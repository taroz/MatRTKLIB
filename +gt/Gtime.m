classdef Gtime < handle
    % Gtime: GPS time class
    % ---------------------------------------------------------------------
    % Gtime Declaration:
    % gtime = Gtime();  Create empty gt.Gtime object
    %
    % gtime = Gtime(epoch, [utcflag]);  Create gt.Gtime object from calendar
    %                                   time vector
    %   epoch   : Mx6, calendar time vector
    %               [year, month, day, hour, minutes, second]
    %  [utcflag]: 1x1, UTC flag 0:GPST, 1:UTC
    %
    % gtime = Gtime(tow, week);  Create gt.Gtime object from GPS time of week
    %                                  and GPS week
    %   tow     : Mx1, time of week in GPST (s)
    %   week    : Mx1 or 1x1, GPS week
    %
    % gtime = Gtime(sod, ymd, [utcflag]);  Create gt.Gtime object from
    %                                      seconds of day
    %   sod     : Mx1, Seconds of day (s)
    %   ymd     : Mx3 or 1x3, [year, month, day]
    %  [utcflag]: 1x1, UTC flag 0:GPST, 1:UTC
    %
    % gtime = Gtime(hhmmss, ymd, [utcflag]);  Create gt.Gtime object from
    %                                      NMEA style
    %   hhmmss  : Mx1, String, hour,minute,second in NMEA style
    %   ymd     : Mx3 or 1x3, [year, month, day]
    %  [utcflag]: 1x1, UTC flag 0:GPST, 1:UTC
    %
    % gtime = Gtime(t, [utcflag]);  Create gt.Gtime object from MATLAB datetime
    %   t       : Mx1, MATLAB datetime vector
    %  [utcflag]: 1x1, UTC flag 0:GPST, 1:UTC
    % ---------------------------------------------------------------------
    % Gtime Properties:
    %   n       : 1x1, Number of epochs
    %   ep      :(obj.n)x6, Calendar time vector
    %               [year, month, day, hour, minutes, second]
    %   tow     :(obj.n)x1, Time of week in GPST (s)
    %   week    :(obj.n)x3, GPS week
    %   t       :(obj.n)x1, MATLAB Datetime vector
    % ---------------------------------------------------------------------
    % Gtime Methods:
    %   setEpoch(epoch, [utcflag]); Set calendar time vector
    %   setGPST(tow, week);         Set GPS time of week and GPS week
    %   setSod(sod, ymd, [utcflag]);Set seconds of day
    %   setNMEA(hhmmss, ymd, [utcflag]);Set NEMA time sytle
    %   setDatetime(t, [utcflag]);  Set MATLAB datetime
    %   insert(idx, gtime);         Insert gt.Gtime object
    %   append(gtime);              Append gt.Gtime object
    %   addOffset(offset);          Add offset to time
    %   round([ndigit]);            Round time to the nearest arbitrary digit
    %   roundInterval([dt]);        Round time to the arbitrary interval
    %   gtime = copy();             Copy object
    %   gtime = select(idx);        Select time from index
    %   gtime = selectTimeSpan(ts, te); Select time from time span
    %   gtime = interp(x, xi, [method]); Interpolating time
    %   dt = estInterval([ndigit]); Estimate time interval
    %   doy = doy([idx]);           Get day of year
    %   dow = dow([idx]);           Get day of week
    %   sod = sod([idx]);           Get seconds of day
    %   ymd = ymd([idx]);           Get year, month, day
    %   hms = hms([idx]);           Get hour, minute, second
    %   yy = yy([idx]);             Get two-digit year
    %   year = year([idx]);         Get year
    %   month = month([idx]);       Get month
    %   day = day([idx]);           Get day
    %   hour = hour([idx]);         Get hour
    %   minute = minute([idx]);     Get minute
    %   second = second([idx]);     Get second
    %   plot([idx]);                Plot time
    %   plotDiff([idx]);            Plot time difference
    %   help();                     Show help
    % ---------------------------------------------------------------------
    % Author: Taro Suzuki
    %
    properties
        n    % Number of epochs
        ep   % Calendar time vector [year, month, day, hour, minutes, second]
        tow  % Time of week in GPST (s)
        week % GPS week
        t    % MATLAB Datetime vector
    end
    methods
        %% constructor
        function obj = Gtime(varargin)
            if nargin==0 % generate empty object
                obj.n = 0;
            elseif nargin==1
                if isdatetime(varargin{1})
                    obj.setDatetime(varargin{1}); % datetime
                else
                    obj.setEpoch(varargin{1}); % epoch
                end
            elseif nargin==2
                if isdatetime(varargin{1})
                    obj.setDatetime(varargin{1}, varargin{2}); % datetime+utcflag
                elseif size(varargin{1}, 2) == 6
                    obj.setEpoch(varargin{1}, varargin{2}); % epoch+utcflag
                elseif size(varargin{1}, 2) == 1 && isstring(varargin{1}) && size(varargin{2}, 2) == 3
                    obj.setNMEA(varargin{1}, varargin{2}); % hhmmss+ymd
                elseif size(varargin{1}, 2) == 1 && size(varargin{2}, 2) == 3
                    obj.setSod(varargin{1}, varargin{2}); % sod+ymd
                elseif size(varargin{1}, 2) == 1 && size(varargin{2}, 2) == 1
                    obj.setGPST(varargin{1}, varargin{2}); % tow+week
                else
                    error('Wrong input arguments');
                end
            elseif nargin==3
                if isstring(varargin{1})
                    obj.setNMEA(varargin{1}, varargin{2}, varargin{3}); % hhmmss+ymd+utcflag
                else
                    obj.setSod(varargin{1}, varargin{2}, varargin{3}); % sod+ymd+utcflag
                end
            else
                error('Wrong input arguments');
            end
        end
        %% setEpoch
        function setEpoch(obj, epoch, utcflag)
            % setEpoch: Set calendar time vector
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setEpoch(epoch, [utcflag])
            %
            % Input: ------------------------------------------------------
            %   epoch   : Mx6, Calendar time vector
            %               [year, month, day, hour, minutes, second]
            %  [utcflag]: 1x1, UTC flag 0:GPST, 1:UTC (optional)
            %               Default: utcflag = 0
            %
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
        %% setGPST
        function setGPST(obj, tow, week)
            % setGPST: Set GPS time of week and GPS week
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setEpoch(tow, week)
            %
            % Input: ------------------------------------------------------
            %   tow : Mx1, Time of week in GPST (s)
            %   week: Mx1 or 1x1, GPS week
            %
            arguments
                obj gt.Gtime
                tow (:,1) double
                week double {mustBeInteger, mustBeVector}
            end
            if isscalar(week); week = repmat(week, size(tow)); end
            obj.tow = tow;
            obj.week = week;
            obj.ep = rtklib.tow2epoch(obj.tow, obj.week);
            obj.t = obj.ep2datetime(obj.ep);
            obj.n = size(obj.ep,1);
        end
        %% setSod
        function setSod(obj, sod, ymd, utcflag)
            % setSod: Set seconds of day
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setSod(sod, ymd, [utcflag])
            %
            % Input: ------------------------------------------------------
            %   sod     : Mx1, Seconds of day (s)
            %   ymd     : Mx3 or 1x3, [year, month, day]
            %  [utcflag]: 1x1, UTC flag 0:GPST, 1:UTC (optional)
            %               Default: utcflag = 0
            %
            arguments
                obj gt.Gtime
                sod (:,1) double
                ymd (:,3) double
                utcflag (1,1) {mustBeInteger} = 0
            end
            if size(ymd,1) == 1; ymd = repmat(ymd, [size(sod,1), 1]); end
            if utcflag
                obj.ep = rtklib.utc2gpst([ymd, obj.sod2hms(sod)]);
            else
                obj.ep = [ymd, obj.sod2hms(sod)];
            end
            [obj.tow, obj.week] = rtklib.epoch2tow(obj.ep);
            obj.t = obj.ep2datetime(obj.ep);
            obj.n = size(obj.ep,1);
        end

        %% setNMEA
        function setNMEA(obj, hhmmss, ymd, utcflag)
            % setNMEA: Set NEMA time sytle
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setNMEA(hhmmss, ymd, [utcflag])
            %
            % Input: ------------------------------------------------------
            %   hhmmss  : Mx1, hour,minute,second in NMEA style
            %   ymd     : Mx3 or 1x3, [year, month, day]
            %  [utcflag]: 1x1, UTC flag 0:GPST, 1:UTC (optional)
            %               Default: utcflag = 0
            %
            arguments
                obj gt.Gtime
                hhmmss (:,1) string
                ymd (:,3) double
                utcflag (1,1) {mustBeInteger} = 0
            end
            if size(ymd,1) == 1; ymd = repmat(ymd, [size(hhmmss,1), 1]); end
            sod = obj.hhmmss2sod(hhmmss);
            if utcflag
                obj.ep = rtklib.utc2gpst([ymd, obj.sod2hms(sod)]);
            else
                obj.ep = [ymd, obj.sod2hms(sod)];
            end
            [obj.tow, obj.week] = rtklib.epoch2tow(obj.ep);
            obj.t = obj.ep2datetime(obj.ep);
            obj.n = size(obj.ep,1);
        end
        %% setDatetime
        function setDatetime(obj, t, utcflag)
            % setDatetime: Set MATLAB datetime
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setDatetime(t, [utcflag])
            %
            % Input: ------------------------------------------------------
            %   t : Mx1, MATLAB datetime vector in GPST
            %  [utcflag]: 1x1, UTC flag 0:GPST, 1:UTC (optional)
            %               Default: utcflag = 0
            %
            arguments
                obj gt.Gtime
                t (:,1) datetime
                utcflag (1,1) {mustBeInteger} = 0
            end
            ep_ = [t.Year, t.Month, t.Day, t.Hour, t.Minute, t.Second];
            if utcflag
                ep_ = rtklib.utc2gpst(ep_);
            end
            obj.ep = ep_;
            obj.t = obj.ep2datetime(obj.ep);
            [obj.tow, obj.week] = rtklib.epoch2tow(obj.ep);
            obj.n = size(obj.ep,1);
        end
        %% insert
        function insert(obj, idx, gtime)
            % insert: Insert gt.Gtime object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.insert(idx, gtime)
            %
            % Input: ------------------------------------------------------
            %   idx : 1x1, Integer index to insert
            %   gtime: 1x1, gt.Gtime object
            %
            arguments
                obj gt.Gtime
                idx (1,1) {mustBeInteger}
                gtime gt.Gtime
            end
            if idx<=0 || idx>obj.n
                error('Index is out of range');
            end
            obj.setDatetime(obj.insertdata(obj.t, idx, gtime.t));
        end
        %% append
        function append(obj, gtime)
            % append: Append gt.Gtime object
            % -------------------------------------------------------------
            % Add gt.gtime object.
            % obj.n will be obj.n+gtime.n
            %
            % Usage: ------------------------------------------------------
            %   obj.append(gtime)
            %
            % Input: ------------------------------------------------------
            %   gtime : 1x1, gt.Gtime object
            %
            arguments
                obj gt.Gtime
                gtime gt.Gtime
            end
            obj.setDatetime([obj.t; gtime.t]);
        end
        %% addOffset
        function addOffset(obj, offset)
            % addOffset: Add time offset
            % -------------------------------------------------------------
            % Add a time offset to obj. The offset must be a scalar
            % or of the same size as obj.
            % The offset must be of double or MATLAB duration.
            %
            % Usage: ------------------------------------------------------
            %   obj.addOffset(offset)
            %
            % Input: ------------------------------------------------------
            %   offset : Mx1 or 1x1, Time offset
            %              double (s) or MATLAB duration
            %
            arguments
                obj gt.Gtime
                offset (:,1)
            end
            if size(offset,1)~=obj.n && size(offset,1)~=1
                error("Size of offset must be obj.n or 1");
            end
            switch class(offset)
                case 'double'
                    obj.setDatetime(obj.t+seconds(offset));
                case 'duration'
                    obj.setDatetime(obj.t+offset);
                otherwise
                    error("offset must be double or duration");
            end
        end
        %% round
        function round(obj, ndigit)
            % round: Round time to the nearest arbitrary digit
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.round([ndigit])
            %
            % Input: ------------------------------------------------------
            %  [ndigit] : 1x1, Arbitrary digit to round (optional)
            %              Default: ndigit = 2
            %
            arguments
                obj gt.Gtime
                ndigit (1,1) {mustBeInteger} = 2
            end
            t_ = dateshift(obj.t,'start','minute') + seconds(round(second(obj.t), ndigit));
            obj.setDatetime(t_);
        end

        function roundInterval(obj, dt)
            % round: Round time to the arbitrary interval
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.roundInterval([dt])
            %
            % Input: ------------------------------------------------------
            %  [dt] : 1x1, Arbitrary time interval (s) (optional)
            %              Default: dt = 1
            %
            arguments
                obj gt.Gtime
                dt (1,1) = 1
            end
            t_ = obj.roundDateTime(obj.t,dt);
            obj.setDatetime(t_);
        end
        %% copy
        function gtime = copy(obj)
            % copy: Copy object
            % -------------------------------------------------------------
            % MATLAB handle class is used, so if you want to create a
            % different object, you need to use the copy method.
            %
            % Usage: ------------------------------------------------------
            %   gtime = obj.copy()
            %
            % Output: -----------------------------------------------------
            %   gtime : 1x1, Copied gt.Gtime object
            %
            arguments
                obj gt.Gtime
            end
            gtime = obj.select(1:obj.n);
        end
        %% interp
        function gtime = interp(obj, x, xi, method)
            % interp: Interpolating time
            % -------------------------------------------------------------
            % Interpolate the time data at the query point and return a
            % new object.
            %
            % Usage: ------------------------------------------------------
            %   gtime = obj.interp(x, xi, [method])
            %
            % Input: ------------------------------------------------------
            %   x     : Sample points
            %   xi    : Query points
            %   method: Interpolation method (optional)
            %           Default: method = "linear"
            %
            % Output: -----------------------------------------------------
            %   gtime: 1x1, Interpolated gt.Gtime object
            %
            arguments
                obj gt.Gtime
                x {mustBeVector}
                xi {mustBeVector}
                method string = "Linear"
            end
            if length(x)~=obj.n
                error('Size of x must be obj.n');
            end
            gtime = gt.Gtime(interp1(x, obj.t, xi, method));
        end
        %% select
        function gtime = select(obj, idx)
            % select: Select time from index
            % -------------------------------------------------------------
            % Select time from the index and return a new object.
            % The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %   gtime = obj.select(idx)
            %
            % Input: ------------------------------------------------------
            %   idx  : Logical or numeric index to select
            %
            % Output: -----------------------------------------------------
            %   gtime: 1x1, Selected gt.Gtime object
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector}
            end
            if ~any(idx)
                error('Selected index is empty');
            end
            gtime = gt.Gtime(obj.ep(idx,:));
        end
        %% selectTimeSpan
        function [gtime, idx] = selectTimeSpan(obj, ts, te)
            % selectTimeSpan: Select time from time span
            % -------------------------------------------------------------
            % Select time from the time span and return a new object.
            % Time span is the start and end time of gt.Gtime type.
            %
            % Usage: ------------------------------------------------------
            %   gtime = obj.selectTimeSpan(ts, te)
            %
            % Input: ------------------------------------------------------
            %   ts  : 1x1, gt.Gtime, Start time
            %   te  : 1x1, gt.Gtime, End time
            %
            % Output: -----------------------------------------------------
            %   gtime: 1x1, Selected gt.Gtime object
            %
            arguments
                obj gt.Gtime
                ts gt.Gtime
                te gt.Gtime
            end
            idx = obj.t>=ts.t & obj.t<=te.t;
            gtime = obj.select(idx);
        end
        %% estInterval
        function dt = estInterval(obj, ndigit)
            % estInterval: Estimate time interval
            % -------------------------------------------------------------
            % Estimate the time interval from the time vector.
            % If the time interval is not constant, use the median to
            % output a reasonable time interval.
            %
            % Usage: ------------------------------------------------------
            %   gtime = obj.estInterval([ndigit])
            %
            % Input: ------------------------------------------------------
            %  [ndigit] : 1x1, Arbitrary digit to estimated time interval
            %             (optional) Default: ndigit = 2
            %
            % Output: -----------------------------------------------------
            %   dt: 1x1, double, Estimated time interval (s)
            %
            arguments
                obj gt.Gtime
                ndigit (1,1) {mustBeInteger} = 2
            end
            if obj.n > 1
                dt = round(median(seconds(diff(obj.t))), ndigit);
            else
                dt = 0;
            end
        end

        %% doy
        function doy = doy(obj, idx)
            % doy: Get day of year
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   doy = obj.doy([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   doy: Mx1, Day of year (0-365)
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            doy = fix(rtklib.epoch2doy(obj.ep(idx,:)));
        end
        %% dow
        function dow = dow(obj, idx)
            % dow: Get day of week
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   dow = obj.dow([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   dow: Mx1, Day of week (0-6)
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            dow = weekday(obj.t(idx));
        end
        %% sod
        function sod = sod(obj, idx)
            % sod: Get seconds of day
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   sod = obj.sod([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   sod: Mx1, Seconds of day (0-86400)
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            sod = obj.hms2sod(obj.ep(idx, 4:6));
        end
        %% ymd
        function ymd = ymd(obj, idx)
            % ymd: Get year, month, day
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   ymd = obj.ymd([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   ymd: Mx3, Year, Month, Day [year, month, day]
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            ymd = obj.ep(idx, 1:3);
        end
        %% hms
        function hms = hms(obj, idx)
            % hms: Get hour, minute, second
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   hms = obj.hms([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   hms: Mx3, Hour, Minute, Second [hour, minute, second]
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            hms = obj.ep(idx, 4:6);
        end
        %% yy
        function yy = yy(obj, idx)
            % yy: Get two-digit year
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   yy = obj.yy([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   yy: Mx1, Hour, Two-digit year (0-99)
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            yy = obj.ep(idx, 1)-2000;
        end
        %% year
        function year = year(obj, idx)
            % year: Get year
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   year = obj.year([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   year: Mx1, Year
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            year = obj.ep(idx, 1);
        end
        %% month
        function month = month(obj, idx)
            % month: Get month
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   month = obj.month([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   month: Mx1, Month
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            month = obj.ep(idx, 2);
        end
        %% day
        function day = day(obj, idx)
            % day: Get day
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   day = obj.day([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   day: Mx1, Day
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            day = obj.ep(idx, 3);
        end
        %% hour
        function hour = hour(obj, idx)
            % hour: Get hour
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   hour = obj.hour([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   hour: Mx1, Hour
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            hour = obj.ep(idx, 4);
        end
        %% minute
        function minute = minute(obj, idx)
            % minute: Get minute
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   minute = obj.minute([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   minute: Mx1, Minute
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            minute = obj.ep(idx, 5);
        end
        %% second
        function second = second(obj, idx)
            % second: Get second
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   second = obj.second([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   second: Mx1, Second
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            second = obj.ep(idx, 6);
        end
        %% plot
        function plot(obj, idx)
            % plot: Plot time
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plot([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            figure;
            plot(obj.t(idx), '.-');
            ylabel('Time');
            grid on;
        end
        %% plotDiff
        function plotDiff(obj, idx)
            % plotDiff: Plot time difference
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotDiff([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: 1:obj.n
            %
            arguments
                obj gt.Gtime
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if obj.n > 1
                figure;
                plot(seconds(diff(obj.roundDateTime(obj.t(idx),obj.estInterval()))), '.-');
                ylabel('Time difference (s)');
                grid on;
            end
        end
        %% help
        function help(~)
            % help: Show help
            doc gt.Gtime
        end
    end
    %% Private functions
    methods (Access = private)
        %% Insert data
        function c = insertdata(~,a,idx,b)
            c = [a(1:size(a,1)<idx,:); b; a(1:size(a,1)>=idx,:)];
        end
        %% Round datetime
        function tr = roundDateTime(~, t, dt)
            pt = posixtime(t);
            pt = round(pt/dt)*dt;
            tr = datetime(pt, "ConvertFrom", "posixtime", "TimeZone", "UTC");
        end
        %% Convert hms to seconds of day
        function sod = hms2sod(~, hms)
            arguments
                ~
                hms (:,3) double
            end
            sod = 3600*hms(:,1)+60*hms(:,2)+hms(:,3);
        end
        %% Convert seconds of day to hms
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
        %% Convert hhmmss to seconds of day
        function sod = hhmmss2sod(~, hhmmss)
            arguments
                ~
                hhmmss (:,1) string
            end
            tstr = char(hhmmss);
            h = str2num(tstr(:,1:2));
            m = str2num(tstr(:,3:4));
            s = str2num(tstr(:,5:end));
            sod = 3600*h+60*m+s;
        end
        %% Convert epoch to datetime
        function t = ep2datetime(~, ep)
            arguments
                ~
                ep (:,6) double
            end
            t = datetime(ep(:,1),ep(:,2),ep(:,3),ep(:,4),ep(:,5),fix(ep(:,6)),...
                round(1000*(ep(:,6)-fix(ep(:,6)))), "TimeZone", "UTC"); % ms
        end
    end
end