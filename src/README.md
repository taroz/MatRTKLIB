# Porting Progress
## Satellites, Systems, and Codes functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| satno     | ✔️ | ✔️ | |
| satsys    | ✔️ | ✔️ | |
| satid2no  | ✔️ | ✔️ | |
| satno2id  | ✔️ | ✔️ | |
| obs2code  | ✔️ | ✔️ | |
| code2obs  | ✔️ | ✔️ | |
| code2freq | ✔️ | ✔️ | |
| sat2freq  | ✔️ | ✔️ | |
| code2idx  | ✔️ | ✔️ | |

## Time and String functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| tow2epoch    | ✔️ | ✔️ | Function change from gpst2time |
| epoch2tow    | ✔️ | ✔️ | time2gpst |
| gsttow2epoch | ✔️ | ✔️ | gst2time |
| epoch2gsttow | ✔️ | ✔️ | time2gst |
| bdttow2epoch | ✔️ | ✔️ | bdt2time |
| epoch2bdttow | ✔️ | ✔️ | time2bdt |
| gpst2utc     | ✔️ | ✔️ | |
| utc2gpst     | ✔️ | ✔️ | |
| gpst2bdt     | ✔️ | ✔️ | |
| bdt2gpst     | ✔️ | ✔️ | |
| epoch2doy    | ✔️ | ✔️ | time2doy |
| tow2doy      | ✔️ | ✔️ | time2doy |
| utc2gmst     | ✔️ | ✔️ | |
| adjgpsweek   | ✔️ | ✔️ | |
| reppath      |  |  | |
| reppaths     |  |  | |

## Coordinates transformation
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| xyz2llh    | ✔️ | ✔️ | ecef2pos |
| llh2xyz    | ✔️ | ✔️ | pos2ecef |
| xyz2enu    | ✔️ | ✔️ | new |
| enu2xyz    | ✔️ | ✔️ | new |
| enu2llh    | ✔️ | ✔️ | new |
| llh2enu    | ✔️ | ✔️ | new |
| ecefv2enuv    | ✔️ | ✔️ | ecef2enu |
| enuv2ecefv    | ✔️ | ✔️ | enu2ecef |
| covenu    | ✔️ | ✔️ | |
| covenusol    | ✔️ | ✔️ | new |
| covecef    | ✔️ | ✔️ | |
| covecefsol    | ✔️ | ✔️ | new |
| eci2ecef    | ✔️ | ✔️ | |
| deg2dms    | ✔️ | ✔️ | |
| dms2deg    | ✔️ | ✔️ | |

## Input and Output functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| readpos    | ✔️ | ✔️ | |
| readblq    | ✔️ | ✔️ | |
| readerp    | ✔️ | ✔️ | |
| geterp    | ✔️ | ✔️ | |

## Platform dependent functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| expath    | ✔️ | ✔️ | |

## Positioning models
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| satazel    | ✔️ | ✔️ | |
| geodist    | ✔️ | ✔️ | |
| dops    | ✔️ | ✔️ | |

## Atmosphere models
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| ionmodel    | ✔️ | ✔️ | |
| ionmapf    | ✔️ | ✔️ | |
| ionppp    | ✔️ | ✔️ | |
| tropmodel    | ✔️ | ✔️ | |
| tropmapf    | ✔️ | ✔️ | |
| iontec    | | | |
| readtec    | | | |
| ionocorr    | ✔️ | ✔️ | |
| tropcorr    | ✔️ | ✔️ | |

## Antenna models
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| readpcv    | ✔️ | ✔️ | |
| searchpcv    | ✔️ | ✔️ | |
| antmodel    | ✔️ | ✔️ | |
| antmodel_s    | ✔️ | ✔️ | |

## Earth tide models
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| sunmoonpos    | ✔️ | ✔️ | |
| tidedisp    | ✔️ | ✔️ | |

## Geiod models
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| geoidh    | ✔️ | ✔️ | |

## Datum transformation
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| tokyo2jgd    | ✔️ | ✔️ | |
| jgd2tokyo    | ✔️ | ✔️ | |

## RINEX functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| readrnxobs    | ✔️ | ✔️ | readrnx |
| readrnxnav    | ✔️ | ✔️ | readrnx |
| outrnxobs    | ✔️ | ✔️ | outrnxobsh+outrnxobsb|
| outrnxnav    | ✔️ | ✔️ | outrnx*navh+outrnx*navb|
| readrnxc    | ✔️ | ✔️ | |
| convrnx    | | | |

## Ephemeris and clock functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| eph2clk    | ✔️ | ✔️ | |
| geph2clk    | ✔️ | ✔️ | |
| seph2clk    | ✔️ | ✔️ | |
| eph2pos    | ✔️ | ✔️ | |
| geph2pos    | ✔️ | ✔️ | |
| seph2pos    | ✔️ | ✔️ | |
| peph2pos    | ✔️ | ✔️ | |
| satantoff    | ✔️ | ✔️ | |
| satpos    | ✔️ | ✔️ | |
| satposs    | ✔️ | ✔️ | |
| readsp3    | ✔️ | ✔️ | |
| readsap    | ✔️ | ✔️ | |
| readdcb    | ✔️ | ✔️ | |
| alm2pos    | ✔️ | ✔️ | |
| tle_read    | ✔️ | ✔️ | |
| tle_name_read    | ✔️ | ✔️ | |
| tle_pos    | ✔️ | ✔️ | |

## Receiver raw data functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| rtk_crc32    | | | |
| rtk_crc24q    | | | |
| rtk_crc16    | | | |

## RTCM functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| gen_rtcm2    | | | |
| gen_rtcm3    | | | |

## Solution functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| readsol    | ✔️ | ✔️ | |
| readsolstat    | ✔️ | ✔️ | |
| outsol    | ✔️ | ✔️ | |
| outnmea_rmc    |  |  | |
| outnmea_gga    |  |  | |
| outnmea_gsv    |  |  | |

## Google earth kml/gpx converter
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| convkml    |  |  | |
| convgpx    |  |  | |

## SBAS functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| tow2epoch    | ✔️ | ✔️ | |
| epoch2tow    | ✔️ | ✔️ | |

## SBAS functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| sbsreadmsg    | | | |
| sbssatcorr    | | | |
| sbsioncorr    | | | |
| sbstropcorr    | | | |

## Options functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| loadopts    | ✔️ | ✔️ | |
| saveopts    | ✔️ | ✔️ | |

## Integer ambiguity resolution
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| lambda   | ✔️ | ✔️ | |
| lambda_reduction   | |  | |
| lambda_search   | | | |

## Standard positioning
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| pntpos    | ✔️ | ✔️ | |

## Precise positioning
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| rtkinit    | ✔️ | ✔️ | |
| rtkpos    | ✔️ | ✔️ | |

## Precise point positioning
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| pppos    | | | |

## Post-processing positioning
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| postpos    | | | |