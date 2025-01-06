%% compile.m
% Compile RTRKLIB wrappers
% Author: Taro Suzuki

clear;
close all;
clc;

%% Compile option
trace_option = true;    % enable/disable debug trace
obs100Hz_option = true; % whether 100Hz observation data can be handled

%% Setting
path = fileparts(mfilename('fullpath'));
srcpath = [path '/src/mex'];
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

%% Satellites, systems, codes functions
eval(['mex satno.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex satsys.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex satid2no.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex satno2id.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex obs2code.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex code2obs.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex code2freq.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex sat2freq.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex code2idx.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);

%% Time and string functions
eval(['mex tow2epoch.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex epoch2tow.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex gsttow2epoch.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex epoch2gsttow.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex bdttow2epoch.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex epoch2bdttow.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex gpst2utc.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex utc2gpst.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex gpst2bdt.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex bdt2gpst.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex epoch2doy.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex tow2doy.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex utc2gmst.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex adjgpsweek.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex reppath.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);

%% Coordinates transformation
eval(['mex xyz2llh.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex llh2xyz.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex xyz2enu.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex enu2xyz.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex enu2llh.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex llh2enu.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex ecef2enu.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex enu2ecef.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex covenu.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex covenusol.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex covecef.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex covecefsol.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex eci2ecef.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex deg2dms.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex dms2deg.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);

%% Input and output functions
eval(['mex readpos.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex readblq.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex readerp.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex geterp.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);

%% Platform dependent functions
eval(['mex expath.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);

%% Positioning models
eval(['mex satazel.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex geodist.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex dops.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);

%% Atmosphere models
eval(['mex ionmodel.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex ionmapf.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex ionppp.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex tropmodel.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex tropmapf.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/geoid.c -outdir ../../+rtklib' option]);
% iontec
% readtec
eval(['mex ionocorr.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/pntpos.c ../RTKLIB/src/ephemeris.c ../RTKLIB/src/sbas.c ../RTKLIB/src/preceph.c ../RTKLIB/src/ionex.c -outdir ../../+rtklib' option]);
eval(['mex tropcorr.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/pntpos.c ../RTKLIB/src/ephemeris.c ../RTKLIB/src/sbas.c ../RTKLIB/src/preceph.c ../RTKLIB/src/ionex.c -outdir ../../+rtklib' option]);

%% Antenna models
eval(['mex readpcv.c pcv2pcv.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex searchpcv.c pcv2pcv.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex antmodel.c pcv2pcv.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex antmodel_s.c pcv2pcv.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);

%% Earth tide models
eval(['mex sunmoonpos.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex tidedisp.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/tides.c ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);

%% Geiod models
eval(['mex geoidh.c -I../RTKLIB/src ../RTKLIB/src/geoid.c ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);

%% Datum transformation
eval(['mex tokyo2jgd.c -I../RTKLIB/src ../RTKLIB/src/datum.c ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex jgd2tokyo.c -I../RTKLIB/src ../RTKLIB/src/datum.c ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);

%% RINEX functions
eval(['mex readrnxobs.c obs2obs.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/rinex.c ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex readrnxnav.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/rinex.c ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex outrnxobs.c obs2obs.c -I../RTKLIB/src ../RTKLIB/src/rinex.c ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex outrnxnav.c  nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/rinex.c ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex readrnxc.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/rinex.c ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
% convrnx

%% Ephemeris and clock functions
eval(['mex eph2clk.c eph2eph.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/ephemeris.c ../RTKLIB/src/preceph.c ../RTKLIB/src/sbas.c -outdir ../../+rtklib' option]);
eval(['mex geph2clk.c eph2eph.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/ephemeris.c ../RTKLIB/src/preceph.c ../RTKLIB/src/sbas.c -outdir ../../+rtklib' option]);
% seph2clk
eval(['mex eph2pos.c eph2eph.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/ephemeris.c ../RTKLIB/src/preceph.c ../RTKLIB/src/sbas.c -outdir ../../+rtklib' option]);
eval(['mex geph2pos.c eph2eph.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/ephemeris.c ../RTKLIB/src/preceph.c ../RTKLIB/src/sbas.c -outdir ../../+rtklib' option]);
% seph2pos
eval(['mex peph2pos.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/ephemeris.c ../RTKLIB/src/preceph.c ../RTKLIB/src/sbas.c -outdir ../../+rtklib' option]);
eval(['mex satantoff.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/preceph.c ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex satpos.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/ephemeris.c ../RTKLIB/src/preceph.c ../RTKLIB/src/sbas.c -outdir ../../+rtklib' option]);
eval(['mex satposs.c obs2obs.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/ephemeris.c ../RTKLIB/src/preceph.c ../RTKLIB/src/sbas.c -outdir ../../+rtklib' option]);
eval(['mex readsp3.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/preceph.c ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex readsap.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/preceph.c ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
eval(['mex readdcb.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c -I../RTKLIB/src ../RTKLIB/src/preceph.c ../RTKLIB/src/rtkcmn.c -outdir ../../+rtklib' option]);
% alm2pos
% tle_read
% tle_name_read
% tle_pos

%% Receiver raw data functions
% rtk_crc32
% rtk_crc24q
% rtk_crc16

%% RTCM functions
% gen_rtcm2
% gen_rtcm3

%% Solution functions
eval(['mex readsol.c sol2sol.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/solution.c ../RTKLIB/src/geoid.c -outdir ../../+rtklib' option]);
eval(['mex readsolstat.c solstat2solstat.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/solution.c ../RTKLIB/src/geoid.c -outdir ../../+rtklib' option]);
eval(['mex outsol.c sol2sol.c opt2opt.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/solution.c ../RTKLIB/src/geoid.c -outdir ../../+rtklib' option]);
% outsolex
% outnmea_rmc
% outnmea_gga
% outnmea_gsv

%% Google Earth kml/gpx converter
eval(['mex convkml_.c -output convkml sol2sol.c -I../RTKLIB/src ../RTKLIB/src/convkml.c ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/solution.c ../RTKLIB/src/geoid.c -outdir ../../+rtklib' option]);
eval(['mex convgpx_.c -output convgpx sol2sol.c -I../RTKLIB/src ../RTKLIB/src/convgpx.c ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/solution.c ../RTKLIB/src/geoid.c -outdir ../../+rtklib' option]);

%% SBAS functions
% sbsreadmsg
% sbssatcorr
% sbsioncorr
% sbstropcorr

%% Options functions
eval(['mex loadopts.c opt2opt.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/options.c -outdir ../../+rtklib' option]);
eval(['mex saveopts.c opt2opt.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/options.c -outdir ../../+rtklib' option]);

%% Integer ambiguity resolution
eval(['mex lambda_.c -output lambda -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/lambda.c -outdir ../../+rtklib' option]);

%% Standard positioning
eval(['mex pntpos_.c -output pntpos obs2obs.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c opt2opt.c sol2sol.c ssat2ssat.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/pntpos.c  ../RTKLIB/src/ephemeris.c  ../RTKLIB/src/sbas.c  ../RTKLIB/src/preceph.c ../RTKLIB/src/ionex.c ../RTKLIB/src/geoid.c ../RTKLIB/src/solution.c -outdir ../../+rtklib' option]);

%% Precise positioning
eval(['mex rtkinit.c opt2opt.c rtk2rtk.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/rtkpos.c ../RTKLIB/src/pntpos.c  ../RTKLIB/src/ephemeris.c  ../RTKLIB/src/sbas.c  ../RTKLIB/src/preceph.c ../RTKLIB/src/ionex.c ../RTKLIB/src/tides.c ../RTKLIB/src/lambda.c ../RTKLIB/src/ppp.c ../RTKLIB/src/ppp_ar.c ../RTKLIB/src/ppp_corr.c ../RTKLIB/src/mdccssr.c -outdir ../../+rtklib' option]);
eval(['mex rtkpos_.c -output rtkpos obs2obs.c nav2nav.c eph2eph.c pcv2pcv.c erp2erp.c opt2opt.c rtk2rtk.c sol2sol.c ssat2ssat.c -I../RTKLIB/src ../RTKLIB/src/rtkcmn.c ../RTKLIB/src/rtkpos.c ../RTKLIB/src/pntpos.c ../RTKLIB/src/ephemeris.c ../RTKLIB/src/sbas.c ../RTKLIB/src/preceph.c ../RTKLIB/src/ionex.c ../RTKLIB/src/tides.c ../RTKLIB/src/lambda.c ../RTKLIB/src/ppp.c ../RTKLIB/src/ppp_ar.c ../RTKLIB/src/ppp_corr.c ../RTKLIB/src/mdccssr.c ../RTKLIB/src/geoid.c ../RTKLIB/src/solution.c -outdir ../../+rtklib' option]);

%% Precise point positioning
% pppos

%% Post-processing positioning
% postpos

cd(path);