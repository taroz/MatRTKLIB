classdef Gpos < handle
    % Gpos: GNSS position class
    % ---------------------------------------------------------------------
    % Gpos Declaration:
    % gpos = Gpos();  Create empty gt.Gpos object
    %
    % gpos = Gpos(pos, 'type', [orgpos], ['orgtype']);
    %                            Create gt.Gpos object from position vector
    %   pos      : Mx3, Position vector
    %                [latitude(deg), longitude(deg), ellipsoidal height(m)] or
    %                [ECEF x(m), ECEF y(m), ECEF z(m)] or
    %                [east(m), north(m), up(m)]
    %   type     : 1x1, Coordinate type: 'llh' or 'xyz' or 'enu' or 'nmeallh'
    %  [orgpos]  : 1x3, Coordinate origin 1x3 position vector
    %  [orgtype] : 1x1, Coordinate type: 'llh' or 'xyz'
    % ---------------------------------------------------------------------
    % Gpos Properties:
    %   n       : 1x1, Number of epochs
    %   llh     :(obj.n)x3, Geodetic position (deg, deg, m)
    %   xyz     :(obj.n)x3, ECEF position (m, m, m)
    %   enu     :(obj.n)x3, Local ENU position (m, m, m)
    %   orgllh  : 1x3, Coordinate origin (deg, deg, m)
    %   orgxyz  : 1x3, Coordinate origin in ECEF (m, m, m)
    % ---------------------------------------------------------------------
    % Gpos Methods:
    %   setPos(pos, type);              Set position
    %   setOrg(pos, type);              Set coordinate origin
    %   setOrgGpos(gpos);               Set coordinate origin by gt.Gpos
    %   insert(idx, gpos);              Insert gt.Gpos object
    %   append(gpos);                   Append gt.Gpos object
    %   addOffset(offset, [coordtype]); Add position offset
    %   outPos(file, type, [idx]);      Output position to file
    %   outKML(file, [open], [lw], [lc], [ps], [pc], [idx], [alt]); Output Google Earth KML file
    %   gerr = difference(gpos);        Compute difference between two gt.Gpos objects
    %   gvel = gradient(dt, [idx]);     Compute velocity based on position gradient
    %   gpos = copy();                  Copy object
    %   gpos = select(idx);             Select position from index
    %   gpos = interp(x, xi, [method]); Interpolating position
    %   [gpos, gcov] = mean([idx]);     Compute mean position and covariance
    %   [mllh, sdenu] = meanLLH([idx]); Compute mean geodetic position and standard deviation
    %   [mxyz, sdxyz] = meanXYZ([idx]); Compute mean ECEF position and standard deviation
    %   [menu, sdenu] = meanENU([idx]); Compute mean ENU position and standard deviation
    %   llhrad = llhRad([idx]);         Convert latitude and longitude units to radian
    %   latrad = latRad([idx]);         Convert latitude units to radian
    %   lonrad = lonRad([idx]);         Convert longitude units to radian
    %   llhdms = llhDMS([idx]);         Convert latitude and longitude to degree,minute,second format
    %   latdms = latDMS([idx]);         Convert latitude to degree,minute,second format
    %   londms = lonDMS([idx]);         Convert longitude to degree,minute,second format
    %   gh = geoid([idx]);              Compute geoid height
    %   oh = orthometric([idx]);        Compute orthometric height
    %   lat = lat([idx]);               Get latitude
    %   lon = lon([idx]);               Get longitude
    %   h = h([idx]);                   Get ellipsoidal height
    %   x = x([idx]);                   Get ECEF x position
    %   y = y([idx]);                   Get ECEF y position
    %   z = z([idx]);                   Get ECEF z position
    %   east = east([idx]);             Get local east position
    %   north = north([idx]);           Get local north position
    %   up = up([idx]);                 Get local up position
    %   plot([idx]);                    Plot position
    %   plotMap([idx]);                 Plot position to map
    %   plotSatMap([idx]);              Plot position to satellite map
    %   help();                         Show help
    % ---------------------------------------------------------------------
    % Gpos Overloads:
    %   gerr = obj - gpos;              Compute difference between two gt.Gpos objects
    % ---------------------------------------------------------------------
    % Author: Taro Suzuki
    %
    properties
        n      % Number of epochs
        llh    % Geodetic position (deg, deg, m)
        xyz    % ECEF position (m, m, m)
        enu    % Local ENU position (m, m, m)
        orgllh % Coordinate origin (deg, deg, m)
        orgxyz % Coordinate origin in ECEF (m, m, m)
    end
    methods
        %% constructor
        function obj = Gpos(varargin)
            if nargin==0; obj.n = 0; end % generate empty object
            if nargin>=2; obj.setPos(varargin{1}, varargin{2}); end
            if nargin==4; obj.setOrg(varargin{3}, varargin{4}); end
        end
        %% setPos
        function setPos(obj, pos, postype)
            % setPos: Set position
            % -------------------------------------------------------------
            % Geodetic, ECEF, or Local ENU position can be set.
            %
            % Usage: ------------------------------------------------------
            %   obj.setPos(pos, postype)
            %
            % Input: ------------------------------------------------------
            %   pos    : Mx3, Position data
            %   postype: 1x1, Position type 'llh' or 'xyz' or 'enu' or 'nmeallh'
            %
            arguments
                obj gt.Gpos
                pos (:,3) double
                postype (1,:) char {mustBeMember(postype,{'llh','xyz','enu','nmeallh'})}
            end
            obj.n = size(pos,1);
            switch postype
                case 'llh'
                    obj.llh = pos;
                    obj.xyz = rtklib.llh2xyz(obj.llh);
                    if ~isempty(obj.orgllh); obj.enu = rtklib.llh2enu(obj.llh, obj.orgllh); end
                case 'xyz'
                    obj.xyz = pos;
                    obj.llh = rtklib.xyz2llh(obj.xyz);
                    if ~isempty(obj.orgllh); obj.enu = rtklib.xyz2enu(obj.xyz, obj.orgllh); end
                case 'enu'
                    obj.enu = pos;
                    if ~isempty(obj.orgllh)
                        obj.llh = rtklib.enu2llh(obj.enu, obj.orgllh);
                        obj.xyz = rtklib.enu2xyz(obj.enu, obj.orgllh);
                    end
                case 'nmeallh'
                    latdeg = obj.ddmm2deg(pos(:,1));
                    londeg = obj.ddmm2deg(pos(:,2));
                    obj.llh = [latdeg londeg pos(:,3)];
                    obj.xyz = rtklib.llh2xyz(obj.llh);
                    if ~isempty(obj.orgllh); obj.enu = rtklib.llh2enu(obj.llh, obj.orgllh); end
            end
        end
        %% setOrg
        function setOrg(obj, org, orgtype)
            % setOrg: Set coordinate origin
            % -------------------------------------------------------------
            % Geodetic and ECEF position can be set as the origin.
            %
            % Usage: ------------------------------------------------------
            %   obj.setOrg(pos, postype)
            %
            % Input: ------------------------------------------------------
            %   org    : 1x3, Coordinate origin position
            %   orgtype: 1x1, Position type 'llh' or 'xyz'
            %
            arguments
                obj gt.Gpos
                org (1,3) double
                orgtype (1,:) char {mustBeMember(orgtype,{'llh','xyz'})}
            end
            switch orgtype
                case 'llh'
                    obj.orgllh = org;
                    obj.orgxyz = rtklib.llh2xyz(org);
                case 'xyz'
                    obj.orgxyz = org;
                    obj.orgllh = rtklib.xyz2llh(org);
            end
            if ~isempty(obj.llh)
                obj.enu = rtklib.llh2enu(obj.llh, obj.orgllh);
            elseif ~isempty(obj.xyz)
                obj.enu = rtklib.xyz2enu(obj.xyz, obj.orgllh);
            elseif ~isempty(obj.enu)
                obj.llh = rtklib.enu2llh(obj.enu, obj.orgllh);
                obj.xyz = rtklib.enu2xyz(obj.enu, obj.orgllh);
            end
        end
        %% setOrgGpos
        function setOrgGpos(obj, gpos)
            % setOrgGpos: Set coordinate origin by gt.Gpos
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setOrgGpos(gpos)
            %
            % Input: ------------------------------------------------------
            %   gpos : 1x1, gt.Gpos, Coordinate origin position
            %
            arguments
                obj gt.Gpos
                gpos gt.Gpos
            end
            if isempty(gpos.llh)
                error("gpos.llh is empty");
            end
            obj.setOrg(gpos.llh(1,:),"llh");
        end
        %% insert
        function insert(obj, idx, gpos)
            % insert: Insert gt.Gpos object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.insert(idx, gpos)
            %
            % Input: ------------------------------------------------------
            %   idx : 1x1, Integer index to insert
            %   gpos: 1x1, gt.Gpos object
            %
            arguments
                obj gt.Gpos
                idx (1,1) {mustBeInteger}
                gpos gt.Gpos
            end
            if idx<=0 || idx>obj.n
                error('Index is out of range');
            end
            if ~isempty(obj.llh) && ~isempty(gpos.llh)
                obj.setPos(obj.insertdata(obj.llh, idx, gpos.llh), 'llh');
            else
                obj.setPos(obj.insertdata(obj.enu, idx, gpos.enu), 'enu');
            end
        end
        %% append
        function append(obj, gpos)
            % append: Append gt.Gpos object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.append(gpos)
            %
            % Input: ------------------------------------------------------
            %   gpos: 1x1, gt.Gpos object
            %
            arguments
                obj gt.Gpos
                gpos gt.Gpos
            end
            if ~isempty(obj.llh) && ~isempty(gpos.llh)
                obj.setPos([obj.llh; gpos.llh], 'llh');
            else
                obj.setPos([obj.enu; gpos.enu], 'enu');
            end
        end
        %% addOffset
        function addOffset(obj, offset, coordtype)
            % addOffset: Add position offset
            % -------------------------------------------------------------
            % Add a position offset to obj. The offset must be a scalar
            % or of the same size as obj.
            %
            % Usage: ------------------------------------------------------
            %   obj.addOffset(offset, coordtype)
            %
            % Input: ------------------------------------------------------
            %   offset    : Mx3 or 1x3, Position offset
            %  [coordtype]: 1x1, Coordinate type 'enu' or 'xyz' (optional)
            %               Default 'enu'
            %
            arguments
                obj gt.Gpos
                offset (:,3) double
                coordtype (1,:) char {mustBeMember(coordtype,{'enu','xyz'})} = 'enu'
            end
            if size(offset,1)~=obj.n && size(offset,1)~=1
                error("Size of offset must be obj.n or 1");
            end
            switch coordtype
                case 'enu'
                    if ~isempty(obj.enu)
                        obj.setPos(obj.enu+offset, 'enu');
                    else
                        % first position is origin
                        enu_ = rtklib.llh2enu(obj.llh, obj.llh(1,:));
                        llh_ = rtklib.enu2llh(enu_+offset, obj.llh(1,:));
                        obj.setPos(llh_, 'llh');
                    end
                case 'xyz'
                    if isempty(obj.xyz)
                        error('xyz must be set to a value');
                    end
                    obj.setPos(obj.xyz+offset, 'xyz');
            end
        end
        %% outPos
        function outPos(obj, file, type, idx)
            % outPos: Output position to file
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.outPos(file, type, [idx])
            %
            % Input: ------------------------------------------------------
            %   file: Output file name
            %   type: 1x1, Position type 'llh' or 'llhdms' or 'xyz' or 'enu'
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gpos
                file (1,:) char
                type (1,:) char {mustBeMember(type,{'llh','llhdms','xyz','enu'})}
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            gpos = obj.select(idx);
            llhdms = gpos.llhDMS();
            fid = fopen(file,'w');
            for i=1:gpos.n
                switch type
                    case 'llh'
                        fprintf(fid, '%.8f %.8f %.4f\n', gpos.llh(i,1), gpos.llh(i,2), gpos.llh(i,3));
                    case 'llhdms'
                        fprintf(fid, '%.0f %.0f  %.6f ', llhdms{1}(i,1), llhdms{1}(i,2), llhdms{1}(i,3));
                        fprintf(fid, '%.0f %.0f  %.6f ', llhdms{2}(i,1), llhdms{2}(i,2), llhdms{2}(i,3));
                        fprintf(fid, '%.4f\n', llhdms{3}(i));
                    case 'xyz'
                        fprintf(fid, '%.4f %.4f %.4f\n', gpos.xyz(i,1), gpos.xyz(i,2), gpos.xyz(i,3));
                    case 'enu'
                        fprintf(fid, '%.4f %.4f %.4f\n', gpos.enu(i,1), gpos.enu(i,2), gpos.enu(i,3));
                end
            end
            fclose(fid);
        end
        %% outKML
        function outKML(obj, file, open, lw, lc, ps, pc, idx, alt)
            % outKML: Output Google Earth KML file
            % -------------------------------------------------------------
            % Output Google Earth KML file. If Google Earth is installed,
            % it will automatically open the KML file by default.
            %
            % Usage: ------------------------------------------------------
            %   obj.outKML(file, [open], [lw], [lc], [ps], [pc], [idx], [alt])
            %
            % Input: ------------------------------------------------------
            %   file:  Output KML file name (???.kml)
            %  [open]: 1x1, Open KML file (optional) (0:off,1:on)
            %          Default: off
            %  [lw]:   1x1, Line width, 0: No line (optional) Default: 3.0
            %  [lc]:   Line Color, MATLAB Style, e.g. "r" or [1 0 0]
            %          (optional) Default: "r"
            %  [ps]:   1x1, Point size, 0: No point (optional) Default: 0
            %  [pc]:   Point Color, MATLAB Style, e.g. "r" or [1 0 0]
            %          (optional) Default: "r"
            %  [idx]:  Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %  [alt]:  1x1, Output altitude (optional)
            %          (0:off,1:elipsoidal,2:geodetic) Default: off
            %
            arguments
                obj gt.Gpos
                file (1,:) char
                open (1,1) = 0
                lw (1,1) = 3.0
                lc = "r"
                ps (1,1) = 0
                pc = "r"
                idx {mustBeInteger, mustBeVector} = 1:obj.n
                alt (1,1) = 0
            end
            if obj.n==0
                error('No data to output');
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end
            gpos = obj.select(idx);
            gpos = gpos.select(~isnan(gpos.llh(:,1)));
            kmlstr = "";
            kmlstr = kmlstr+"<?xml version=\""1.0\"" encoding=\""UTF-8\""?>\n";
            kmlstr = kmlstr+"<kml xmlns=\""http://earth.google.com/kml/2.1\"">\n";
            kmlstr = kmlstr+"<Document>\n";

            if lw ~= 0
                kmlstr = kmlstr+gpos.kmltrack(lc, lw, alt);
            end
            if ps ~= 0
                kmlstr = kmlstr+gpos.kmlpoint(pc, ps, alt);
            end
            kmlstr = kmlstr+"</Document>\n";
            kmlstr = kmlstr+"</kml>\n";

            fid = fopen(file,"wt");
            fprintf(fid, kmlstr);
            fclose(fid);

            if open
                system(file);
            end
        end
        %% difference
        function gerr = difference(obj, gpos)
            % difference: Compute difference between two gt.Gpos objects
            % -------------------------------------------------------------
            % Size of the two gt.Gpos must be same.
            %
            % Usage: ------------------------------------------------------
            %   gerr = obj.difference(gpos)
            %
            % Input: ------------------------------------------------------
            %   gpos: 1x1, gt.Gpos object
            %
            % Output: -----------------------------------------------------
            %   gerr: 1x1, gt.Gerr object
            %
            arguments
                obj gt.Gpos
                gpos gt.Gpos
            end
            if obj.n ~= gpos.n && gpos.n ~= 1
                error('Size of gpos must be obj.n or 1')
            end
            if ~isempty(obj.xyz) && ~isempty(gpos.xyz)
                gerr = gt.Gerr('position', obj.xyz - gpos.xyz, 'xyz');
            elseif ~isempty(obj.enu) && ~isempty(gpos.enu)
                gerr = gt.Gerr('position', obj.enu - gpos.enu, 'enu');
            else
                error('Two gt.Gpos must have both xyz or enu')
            end
            if ~isempty(gpos.orgllh)
                gerr.setOrg(gpos.orgllh, 'llh')
            elseif ~isempty(obj.orgllh)
                gerr.setOrg(obj.orgllh, 'llh')
            end
        end
        %% gradient
        function gvel = gradient(obj, dt, idx)
            % gradient: Compute velocity based on position gradient
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   gvel = gradient(dt, [idx])
            %
            % Input: ------------------------------------------------------
            %   dt :  1x1, Time delta between epochs (s)
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   gvel: 1x1, gt.Gvel object containing calculated velocity
            %
            arguments
                obj gt.Gpos
                dt (1,1) double
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if ~isempty(obj.xyz)
                vxyz = [gradient(obj.xyz(idx,1)),...
                    gradient(obj.xyz(idx,2)),...
                    gradient(obj.xyz(idx,3))]/dt;
                gvel = gt.Gvel(vxyz, 'xyz');
            else
                venu = [gradient(obj.enu(idx,1)),...
                    gradient(obj.enu(idx,2)),...
                    gradient(obj.enu(idx,3))]/dt;
                gvel = gt.Gvel(venu, 'enu');
            end
            if ~isempty(obj.orgllh); gvel.setOrg(obj.orgllh, 'llh'); end
        end
        %% copy
        function gpos = copy(obj)
            % copy: Copy position
            % -------------------------------------------------------------
            % MATLAB handle class is used, so if you want to create a
            % different object, you need to use the copy method.
            %
            % Usage: ------------------------------------------------------
            %   gpos = obj.copy()
            %
            % Output: -----------------------------------------------------
            %   gobs: 1x1, Copied gt.Gpos object
            %
            arguments
                obj gt.Gpos
            end
            gpos = obj.select(1:obj.n);
        end
        %% select
        function gpos = select(obj, idx)
            % select: Select position from index
            % -------------------------------------------------------------
            % Select position data from the index and return a new object.
            % The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %   gpos = obj.select(idx)
            %
            % Input: ------------------------------------------------------
            %   idx: Logical or numeric index to select
            %
            % Output: -----------------------------------------------------
            %   gpos: 1x1, gt.Gpos object
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector}
            end
            if ~any(idx)
                error('Selected index is empty');
            end
            if ~isempty(obj.llh)
                gpos = gt.Gpos(obj.llh(idx,:), 'llh');
            else
                gpos = gt.Gpos(obj.enu(idx,:), 'enu');
            end
            if ~isempty(obj.orgllh); gpos.setOrg(obj.orgllh, 'llh'); end
        end
        %% interp
        function gpos = interp(obj, x, xi, method)
            % interp: Interpolating position
            % -------------------------------------------------------------
            % Interpolate the position data at the query point and return a
            % new object.
            %
            % Usage: ------------------------------------------------------
            %   gpos = obj.interp(x, xi, [method])
            %
            % Input: ------------------------------------------------------
            %   x     : Sample points
            %   xi    : Query points
            %   method: Interpolation method (optional)
            %           Default: method = "linear"
            %
            % Output: -----------------------------------------------------
            %   gpos: 1x1, Interpolated gt.Gpos object
            %
            arguments
                obj gt.Gpos
                x {mustBeVector}
                xi {mustBeVector}
                method (1,:) char {mustBeMember(method,{'linear','spline','makima'})} = 'linear'
            end
            if length(x)~=obj.n
                error('Size of x must be obj.n');
            end
            if min(x)>min(xi) || max(x)<max(xi)
                error("Query point is out of range (extrapolation)")
            end
            if ~isempty(obj.xyz)
                gpos = gt.Gpos(interp1(x, obj.xyz, xi, method), "xyz");
            else
                gpos = gt.Gpos(interp1(x, obj.enu, xi, method), "enu");
            end
            if ~isempty(obj.orgllh); gpos.setOrg(obj.orgllh, 'llh'); end
        end
        %% mean
        function [gpos, gcov] = mean(obj, idx)
            % mean: Compute mean position and covariance
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [gpos, gcov] = obj.mean([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   gpos: 1x1, gt.Gpos object with mean position
            %   gcov: 1x1, gt.Gcov object
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if ~isempty(obj.enu)
                menu = obj.meanENU(idx);
                gpos = gt.Gpos(menu, 'enu');
            else
                mxyz = obj.meanXYZ(idx);
                gpos = gt.Gpos(mxyz, 'xyz');
            end
            if ~isempty(obj.orgllh)
                gpos.setOrg(obj.orgllh,'llh');
            end
            gcov = gt.Gcov(obj);
        end
        %% meanLLH
        function [mllh, sdenu] = meanLLH(obj, idx)
            % meanLLH: Compute mean geodetic position and standard deviation
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [mllh, sdenu] = obj.meanLLH([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   mllh : 1x3, Mean geodetic position
            %   sdenu: 1x3, Standard deviation of enu position
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end
            mllh = mean(obj.llh(idx,:), 1, 'omitnan');
            enu_ = rtklib.llh2enu(obj.llh, obj.llh(1,:));
            sdenu = std(enu_, 0, 1, 'omitnan');
        end
        %% meanXYZ
        function [mxyz, sdxyz] = meanXYZ(obj, idx)
            % meanXYZ: Compute mean ECEF position and standard deviation
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [mxyz, sdxyz] = obj.meanXYZ([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   mxyz : 1x3, Mean ECEF position
            %   sdxyz: 1x3, Standard deviation of ECEF position
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            mxyz = mean(obj.xyz(idx,:), 1, 'omitnan');
            sdxyz = std(obj.xyz(idx,:), 0, 1, 'omitnan');
        end
        %% meanENU
        function [menu, sdenu] = meanENU(obj, idx)
            % meanENU: Compute mean ENU position and standard deviation
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [menu, sdenu] = obj.meanENU([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   menu : 1x3, Mean ENU position
            %   sdenu: 1x3, Standard deviation of ENU position
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            menu = mean(obj.enu(idx,:), 1, 'omitnan');
            sdenu = std(obj.enu(idx,:), 0, 1, 'omitnan');
        end
        %% llhRad
        function llhrad = llhRad(obj, idx)
            % llhRad: Convert latitude and longitude units to radian
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   llhrad = obj.llhRad([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   llhrad : Mx3, llh position in radian
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end
            llhrad = [obj.llh(idx,1)/180*pi, obj.llh(idx,2)/180*pi, obj.llh(idx,3)];
        end
        %% latRad
        function latrad = latRad(obj, idx)
            % latRad: Convert latitude units to radian
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   latrad = obj.latRad([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   latrad : Mx1, latitude in radian
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end
            latrad = obj.llh(idx,1)/180*pi;
        end
        %% lonRad
        function lonrad = lonRad(obj, idx)
            % lonRad: Convert longitude units to radian
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   lonrad = obj.lonRad([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   lonrad : Mx1, longitude in radian
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end
            lonrad = obj.llh(idx,2)/180*pi;
        end
        %% llhDMS
        function llhdms = llhDMS(obj, idx)
            % llhDMS: Convert latitude and longitude to degree,minute,second format
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   llhdms = obj.llhDMS([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   llhdms : Mx3, llh position in DMS format (cell)
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end
            latdms = rtklib.deg2dms(obj.lat(idx));
            londms = rtklib.deg2dms(obj.lon(idx));
            llhdms = {latdms, londms, obj.h(idx)};
        end
        %% latDMS
        function latdms = latDMS(obj, idx)
            % latDMS: Convert latitude to degree,minutu,second format
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   latdms = obj.latDMS([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   latdms : Mx3, latitude in degree,minutu,second format
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end
            latdms = rtklib.deg2dms(obj.lat(idx));
        end
        %% lonDMS
        function londms = lonDMS(obj, idx)
            % lonDMS: Convert longitude to degree,minutu,second format
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   londms = obj.lonDMS([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   londms : Mx3, longitude in degree,minutu,second format
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end
            londms = rtklib.deg2dms(obj.lon(idx));
        end
        %% geoid
        function gh = geoid(obj, idx)
            % geoid: Compute geoid height
            % -------------------------------------------------------------
            % RTKLIB internal Geoid model (EGM96 1°x1°) is used to compute
            % geoid height.
            %
            % Usage: ------------------------------------------------------
            %   gh = obj.geoid([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   gh : Mx1, Geoid height (m)
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end
            gpos = obj.select(idx);
            gh = NaN(gpos.n, 1);
            idx = ~any(isnan(gpos.llh(:,1:2)),2);
            gh_ = rtklib.geoidh(gpos.llh(idx,1), gpos.llh(idx,2));
            gh(idx) = gh_;
        end
        %% orthometric
        function oh = orthometric(obj, idx)
            % orthometric: Compute orthometric height
            % -------------------------------------------------------------
            % RTKLIB internal Geoid model (EGM96 1°x1°) is used to compute
            % geoid height.
            %
            % Usage: ------------------------------------------------------
            %   oh = obj.orthometric([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   oh : Mx1, Orthometric height (m)
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end
            oh = obj.llh(idx,3) - obj.geoid(idx);
        end
        %% lat
        function lat = lat(obj, idx)
            % lat: Get latitude
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   lat = obj.lat([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   lat : Mx1, Latitude (degree)
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end
            lat = obj.llh(idx,1);
        end
        %% lon
        function lon = lon(obj, idx)
            % lon: Get logitude
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   lon = obj.lon([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   lon : Mx1, Longitude (degree)
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end
            lon = obj.llh(idx,2);
        end
        %% h
        function h = h(obj, idx)
            % h: Get ellipsoidal height
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   h = obj.h([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   h : Mx1, Ellipsoidal height (m)
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end
            h = obj.llh(idx,3);
        end
        %% x
        function x = x(obj, idx)
            % x: Get ECEF x position
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   x = obj.x([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   x : Mx1, ECEF x position (m)
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            x = obj.xyz(idx,1);
        end
        %% y
        function y = y(obj, idx)
            % y: Get ECEF y position
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   y = obj.y([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   y : Mx1, ECEF y position (m)
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            y = obj.xyz(idx,2);
        end
        %% z
        function z = z(obj, idx)
            % z: Get ECEF z position
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   z = obj.z([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   z : Mx1, ECEF z position (m)
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            z = obj.xyz(idx,3);
        end
        %% east
        function east = east(obj, idx)
            % east: Get Local east position
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   east = obj.east([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   east : Mx1, Local east position (m)
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            east = obj.enu(idx,1);
        end
        %% north
        function north = north(obj, idx)
            % north: Get Local north position
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   north = obj.north([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   north : Mx1, Local north position (m)
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            north = obj.enu(idx,2);
        end
        %% up
        function up = up(obj, idx)
            % up: Get Local up position
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   up = obj.up([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   up : Mx1, Local up position (m)
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            up = obj.enu(idx,3);
        end
        %% plot
        function plot(obj, idx)
            % plot: Plot position
            % -------------------------------------------------------------
            % Positions are converted to ENU coordinate and plotted.
            %
            % Usage: ------------------------------------------------------
            %   obj.plot([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if ~isempty(obj.enu)
                enu_ = obj.enu(idx,:);
            else
                % first position is origin
                llh_ = obj.llh(idx,:);
                enu_ = rtklib.llh2enu(llh_, llh_(1,:));
            end

            figure;
            tiledlayout(3,1,'TileSpacing','Compact');
            nexttile(1, [2 1]);
            plot(enu_(:,1), enu_(:,2), '.-');
            xlabel('East (m)');
            ylabel('North (m)');
            grid on; axis equal;
            nexttile;
            plot(enu_(:,3),'.-');
            grid on;
            ylabel('Up (m)');
            drawnow
        end
        %% plotMap
        function plotMap(obj, idx)
            % plotMap: Plot position to map
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotMap([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.llh)
                error('llh must be set to a value');
            end

            figure;
            geoplot(obj.lat(idx),obj.lon(idx),"r.-");
            drawnow
        end
        %% plotSatMap
        function plotSatMap(obj, idx)
            % plotSatMap: Plot position to satellite map
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotSatMap([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gpos
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            obj.plotMap(idx);
            geobasemap("satellite");
        end
        %% help
        function help(~)
            % help: Show help
            doc gt.Gpos
        end
        %% overload
        function gerr = minus(obj, gpos)
            % minus: Compute position difference
            % -------------------------------------------------------------
            % You can calculate position difference only running obj - gpos.
            % Obj and gpos must be same size.
            %
            % Usage: ------------------------------------------------------
            %   gerr = obj - gpos
            %
            % Input: ------------------------------------------------------
            %   gpos : 1x1, gt.Gpos object
            %
            % Output: -----------------------------------------------------
            %   gerr: 1x1, gt.Gerr object
            %
            arguments
                obj gt.Gpos
                gpos gt.Gpos
            end
            gerr = obj.difference(gpos);
        end
    end
    %% Private functions
    methods(Access=private)
        %% Insert data
        function c = insertdata(~, a, idx, b)
            c = [a(1:size(a,1)<idx,:); b; a(1:size(a,1)>=idx,:)];
        end
        %% Output KML track
        function kmlstr = kmltrack(obj, linecol, linewidth, outalt)
            linecol = validatecolor(linecol);
            kmlstr = "";
            kmlstr = kmlstr+"<Placemark>\n";
            kmlstr = kmlstr+"<name>Rover Track</name>\n";
            kmlstr = kmlstr+"<Style>\n";
            kmlstr = kmlstr+"<LineStyle>\n";
            kmlstr = kmlstr+sprintf("<color>%s</color>\n",obj.col2hex(linecol));
            kmlstr = kmlstr+sprintf("<width>%d</width>\n",linewidth);
            kmlstr = kmlstr+"</LineStyle>\n";
            kmlstr = kmlstr+"</Style>\n";
            kmlstr = kmlstr+"<LineString>\n";
            if outalt>0; kmlstr = kmlstr+"<altitudeMode>absolute</altitudeMode>\n"; end
            kmlstr = kmlstr+"<coordinates>\n";
            for i=1:obj.n
                if outalt==0
                    alt = 0.0;
                elseif outalt==1
                    alt = obj.h(i);
                elseif outalt==2
                    alt =obj.orthometric(i);
                end
                kmlstr = kmlstr+sprintf("%13.9f,%12.9f,%5.3f\n",obj.lon(i),obj.lat(i),alt);
            end
            kmlstr = kmlstr+"</coordinates>\n";
            kmlstr = kmlstr+"</LineString>\n";
            kmlstr = kmlstr+"</Placemark>\n";
        end
        %% Output KML point
        function kmlstr = kmlpoint(obj, pointcol, pointsize, outalt)
            pointcol = validatecolor(pointcol);
            icon = "http://maps.google.com/mapfiles/kml/pal2/icon18.png";
            kmlstr = "";

            kmlstr = kmlstr+"<Style id=""P1"">\n";
            kmlstr = kmlstr+"<IconStyle>\n";
            kmlstr = kmlstr+sprintf("<color>%s</color>\n",obj.col2hex(pointcol));
            kmlstr = kmlstr+sprintf("<scale>%.1f</scale>\n",pointsize);
            kmlstr = kmlstr+sprintf("<Icon><href>%s</href></Icon>\n",icon);
            kmlstr = kmlstr+"</IconStyle>\n";
            kmlstr = kmlstr+"</Style>\n";

            kmlstr = kmlstr+"<Folder>\n";
            kmlstr = kmlstr+"<name>Position</name>\n";
            for i=1:obj.n
                kmlstr = kmlstr+"<Placemark>\n";
                kmlstr = kmlstr+"<styleUrl>#P1</styleUrl>\n";
                kmlstr = kmlstr+"<Point>\n";
                if outalt>0
                    kmlstr = kmlstr+"<extrude>1</extrude>\n";
                    kmlstr = kmlstr+"<altitudeMode>absolute</altitudeMode>\n";
                end
                if outalt==0
                    alt = 0.0;
                elseif outalt==1
                    alt = obj.h(i);
                elseif outalt==2
                    alt =obj.orthometric(i);
                end
                kmlstr = kmlstr+sprintf("<coordinates>%13.9f,%12.9f,%5.3f</coordinates>\n",obj.lon(i),obj.lat(i),alt);
                kmlstr = kmlstr+"</Point>\n";
                kmlstr = kmlstr+"</Placemark>\n";
            end

            kmlstr = kmlstr+"</Folder>\n";
        end
        %% Convert color vector to KML color string
        function chex = col2hex(~,c)
            arguments
                ~
                c (:,3)
            end
            nc = size(c,1);
            ckml = round(255*fliplr(c)); % order is BGR
            hs = reshape(string(dec2hex(ckml,2)),nc,3);
            chex = char("FF"+hs(:,1)+hs(:,2)+hs(:,3));
        end
        %% Convert ddmm.mm to degree
        function deg = ddmm2deg(~,ddmm)
            arguments
                ~
                ddmm (:,1) double
            end
            d = fix(ddmm/100);
            df = (ddmm-d*100)/60;
            deg = d+df;
        end
    end
end