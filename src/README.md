# Porting Progress
## Satellites, Systems, and Codes functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| satno        | ✔️ | ✔️ | |
| satsys       | ✔️ | ✔️ | |
| satid2no     | ✔️ | ✔️ | |
| satno2id     | ✔️ | ✔️ | |
| obs2code     | ✔️ | ✔️ | |
| code2obs     | ✔️ | ✔️ | |
| code2freq    | ✔️ | ✔️ | |
| sat2freq     | ✔️ | ✔️ | |
| code2idx     | ✔️ | ✔️ | |

## Time and String functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| tow2epoch    | ✔️ | ✔️ | Function change from gpst2time |
| epoch2tow    | ✔️ | ✔️ | Function change from time2gpst |
| gsttow2epoch | ✔️ | ✔️ | Function change from gst2time |
| epoch2gsttow | ✔️ | ✔️ | Function change from time2gst |
| bdttow2epoch | ✔️ | ✔️ | Function change from bdt2time |
| epoch2bdttow | ✔️ | ✔️ | Function change from time2bdt |
| gpst2utc     | ✔️ | ✔️ | |
| utc2gpst     | ✔️ | ✔️ | |
| gpst2bdt     | ✔️ | ✔️ | |
| bdt2gpst     | ✔️ | ✔️ | |
| epoch2doy    | ✔️ | ✔️ | Function change from time2doy |
| tow2doy      | ✔️ | ✔️ | Function change from time2doy |
| utc2gmst     | ✔️ | ✔️ | |
| adjgpsweek   | ✔️ | ✔️ | |
| reppath      | ✔️ |  | |

## Coordinates transformation
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| xyz2llh      | ✔️ | ✔️ | Function change from ecef2pos |
| llh2xyz      | ✔️ | ✔️ | Function change from pos2ecef |
| xyz2enu      | ✔️ | ✔️ | New development function |
| enu2xyz      | ✔️ | ✔️ | New development function |
| enu2llh      | ✔️ | ✔️ | New development function |
| llh2enu      | ✔️ | ✔️ | New development function |
| ecef2enu     | ✔️ | ✔️ | Function change from ecef2enu |
| enu2ecef     | ✔️ | ✔️ | Function change from enu2ecef |
| covenu       | ✔️ | ✔️ | |
| covenusol    | ✔️ | ✔️ | New development function |
| covecef      | ✔️ | ✔️ | |
| covecefsol   | ✔️ | ✔️ | New development function |
| eci2ecef     | ✔️ | ✔️ | |
| deg2dms      | ✔️ | ✔️ | |
| dms2deg      | ✔️ | ✔️ | |

## Input and Output functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| readpos      | ✔️ | ✔️ | |
| readblq      | ✔️ | ✔️ | |
| readerp      | ✔️ | ✔️ | |
| geterp       | ✔️ | ✔️ | |

## Platform dependent functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| expath       | ✔️ |  | |

## Positioning models
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| satazel      | ✔️ | ✔️ | |
| geodist      | ✔️ | ✔️ | |
| dops         | ✔️ | ✔️ | |

## Atmosphere models
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| ionmodel     | ✔️ | ✔️ | |
| ionmapf      | ✔️ | ✔️ | |
| ionppp       | ✔️ | ✔️ | |
| tropmodel    | ✔️ | ✔️ | |
| tropmapf     | ✔️ | ✔️ | |
| iontec       | WIP | | |
| readtec      | WIP | | |
| ionocorr     | ✔️ | ✔️ | |
| tropcorr     | ✔️ | ✔️ | |

## Antenna models
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| readpcv      | ✔️ | | |
| searchpcv    | ✔️ | | |
| antmodel     | ✔️ | ✔️ | |
| antmodel_s   | ✔️ | ✔️ | |

## Earth tide models
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| sunmoonpos   | ✔️ | ✔️ | |
| tidedisp     | ✔️ | ✔️ | |

## Geiod models
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| geoidh       | ✔️ | ✔️ | |

## Datum transformation
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| tokyo2jgd    | ✔️ | ✔️ | |
| jgd2tokyo    | ✔️ | ✔️ | |

## RINEX functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| readrnxobs   | ✔️ | | Function change from readrnx |
| readrnxnav   | ✔️ | | Function change from readrnx |
| outrnxobs    | ✔️ | | outrnxobsh+outrnxobsb|
| outrnxnav    | ✔️ | | outrnxnavh+outrnxnavb|
| readrnxc     | ✔️ | | |
| convrnx      | WIP | | |

## Ephemeris and clock functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| eph2clk      | ✔️ | ✔️ | |
| geph2clk     | ✔️ | ✔️ | |
| seph2clk     | ✔️ | ✔️ | |
| eph2pos      | ✔️ | ✔️ | |
| geph2pos     | ✔️ | ✔️ | |
| seph2pos     | ✔️ | ✔️ | |
| peph2pos     | ✔️ | ✔️ | |
| satantoff    | ✔️ | ✔️ | |
| satpos       | ✔️ | ✔️ | |
| satposs      | ✔️ | ✔️ | |
| readsp3      | ✔️ | | |
| readsap      | ✔️ | | |
| readdcb      | ✔️ | | |
| alm2pos      | WIP | | |
| tle_read     | WIP | | |
| tle_name_read| WIP | | |
| tle_pos      | WIP | | |

## Receiver raw data functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| rtk_crc32    | WIP | | |
| rtk_crc24q   | WIP | | |
| rtk_crc16    | WIP | | |

## RTCM functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| gen_rtcm2    | WIP | | |
| gen_rtcm3    | WIP | | |

## Solution functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| readsol      | ✔️ | | |
| readsolstat  | ✔️ | | |
| outsol       | ✔️ | | |
| outsolex     | WIP |  | |
| outnmea_rmc  | WIP |  | |
| outnmea_gga  | WIP |  | |
| outnmea_gsv  | WIP |  | |

## Google earth kml/gpx converter
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| convkml      | ✔️ |  | |
| convgpx      | ✔️ |  | |

## SBAS functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| sbsreadmsg   | WIP | | |
| sbssatcorr   | WIP | | |
| sbsioncorr   | WIP | | |
| sbstropcorr  | WIP | | |

## Options functions
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| loadopts     | ✔️ | | |
| saveopts     | ✔️ | | |

## Integer ambiguity resolution
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| lambda       | ✔️ | WIP | |

## Standard positioning
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| pntpos       | ✔️ | ✔️ | |

## Precise positioning
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| rtkinit      | ✔️ | | |
| rtkpos       | ✔️ | ✔️ | |

## Precise point positioning
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| pppos        | WIP | | |

## Post-processing positioning
| RTKLIB function name | Ported | Vector input support| Note |
| :---: | :---: | :---: | :---: |
| postpos      | WIP | | |