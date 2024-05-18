%% compile option
trace_option = true;    % enable/disable debug trace
obs100Hz_option = true; % whether 100Hz observation data can be handled

%% setting
path = fileparts(mfilename('fullpath'));
srcpath = '..\src';
cd(srcpath);

option = ' -DENAGLO -DENAGAL -DENAQZS -DENACMP -DENAIRN -DNFREQ=7 -v';
if ispc % windows
    option = [option ' -DWIN32 -lwinmm'];
end

if trace_option
    option = [option ' -DTRACE'];
end
if obs100Hz_option
    option = [option ' -DOBS_100HZ'];
end

%%
% eval(['mex pntpos_.c -output pntpos obs2obs.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c opt2opt.c sol2sol.c ssat2ssat.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c ./RTKLIB/src/pntpos.c  ./RTKLIB/src/ephemeris.c  ./RTKLIB/src/sbas.c  ./RTKLIB/src/preceph.c ./RTKLIB/src/ionex.c ./RTKLIB/src/geoid.c ./RTKLIB/src/solution.c -outdir ../+rtklib' option]);
% eval(['mex xyz2llh.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c -outdir ../+rtklib' option]);
% eval(['mex enu2llh.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c -outdir ../+rtklib' option]);
% eval(['mex satazel.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c -outdir ../+rtklib' option]);
% eval(['mex geodist.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c -outdir ../+rtklib' option]);
% eval(['mex dops.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c -outdir ../+rtklib' option]);
% eval(['mex readrnxnav.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I./RTKLIB/src ./RTKLIB/src/rinex.c ./RTKLIB/src/rtkcmn.c -outdir ../+rtklib' option]);
% eval(['mex readrnxc.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I./RTKLIB/src ./RTKLIB/src/rinex.c ./RTKLIB/src/rtkcmn.c -outdir ../+rtklib' option]);
% eval(['mex readsap.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I./RTKLIB/src ./RTKLIB/src/preceph.c ./RTKLIB/src/rtkcmn.c -outdir ../+rtklib' option]);
% eval(['mex readsol.c sol2sol.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c ./RTKLIB/src/solution.c ./RTKLIB/src/geoid.c -outdir ../+rtklib' option]);
% eval(['mex outsol.c sol2sol.c opt2opt.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c ./RTKLIB/src/solution.c ./RTKLIB/src/geoid.c -outdir ../+rtklib' option]);% outsolex
% eval(['mex satpos.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c ./RTKLIB/src/ephemeris.c ./RTKLIB/src/preceph.c ./RTKLIB/src/sbas.c -outdir ../+rtklib' option]);
% eval(['mex satposs.c obs2obs.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c ./RTKLIB/src/ephemeris.c ./RTKLIB/src/preceph.c ./RTKLIB/src/sbas.c -outdir ../+rtklib' option]);
% eval(['mex loadopts.c opt2opt.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c ./RTKLIB/src/options.c -outdir ../+rtklib' option]);
% eval(['mex saveopts.c opt2opt.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c ./RTKLIB/src/options.c -outdir ../+rtklib' option]);
% eval(['mex rtkinit.c opt2opt.c rtk2rtk.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c ./RTKLIB/src/rtkpos.c ./RTKLIB/src/pntpos.c  ./RTKLIB/src/ephemeris.c  ./RTKLIB/src/sbas.c  ./RTKLIB/src/preceph.c ./RTKLIB/src/ionex.c ./RTKLIB/src/tides.c ./RTKLIB/src/lambda.c ./RTKLIB/src/ppp.c ./RTKLIB/src/ppp_ar.c -outdir ../+rtklib' option]);
% eval(['mex rtkpos_.c -output rtkpos obs2obs.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c opt2opt.c rtk2rtk.c sol2sol.c ssat2ssat.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c ./RTKLIB/src/rtkpos.c ./RTKLIB/src/pntpos.c ./RTKLIB/src/ephemeris.c ./RTKLIB/src/sbas.c ./RTKLIB/src/preceph.c ./RTKLIB/src/ionex.c ./RTKLIB/src/tides.c ./RTKLIB/src/lambda.c ./RTKLIB/src/ppp.c ./RTKLIB/src/ppp_ar.c ./RTKLIB/src/geoid.c ./RTKLIB/src/solution.c -outdir ../+rtklib' option]);
% eval(['mex readsolstat.c solstat2solstat.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c ./RTKLIB/src/solution.c ./RTKLIB/src/geoid.c -outdir ../+rtklib' option]);
% eval(['mex outrnxobs.c obs2obs.c -I./RTKLIB/src ./RTKLIB/src/rinex.c ./RTKLIB/src/rtkcmn.c -outdir ../+rtklib' option]);
% eval(['mex readpcv.c pcv2pcv.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c -outdir ../+rtklib' option]);
eval(['mex searchpcv.c pcv2pcv.c -I./RTKLIB/src ./RTKLIB/src/rtkcmn.c -outdir ../+rtklib' option]);

%%
cd(path);