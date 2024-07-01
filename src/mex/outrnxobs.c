/**
 * @file outrnxobs.c
 * @brief Output RINEX observation file
 * @author Taro Suzuki
 * @note Wrapper for "outrnxobs" in rinex.c
 */

#include "mex_utility.h"

#define NIN 2

/* satsys2tobssys */
int satsys2tobssys(int sys) {
    char errmsg[512];
    switch (sys) {
        case SYS_GPS:
            return 0; /* gps */
        case SYS_GLO:
            return 1; /* glo */
        case SYS_GAL:
            return 2; /* gal */
        case SYS_QZS:
            return 3; /* qzs */
        case SYS_SBS:
            return 4; /* sbs */
        case SYS_CMP:
            return 5; /* bds */
        case SYS_IRN:
            return 6; /* irn */
        default:
            sprintf(errmsg, "error: satsys2tobssys() sys=%d", sys);
            mexErrMsgTxt(errmsg);
            return -1;
    }
}

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    FILE *fp;
    char file[512], errmsg[512];
    obsd_t *obs;
    int i, j, k, n, sys, *nobslist = NULL, iobs = 0, rnxver = 303;
    uint8_t ccode[7][MAXCODE] = {{0}}, lcode[7][MAXCODE] = {{0}},
            dcode[7][MAXCODE] = {{0}}, scode[7][MAXCODE] = {{0}};
    uint8_t SYS = SYS_NONE;
    double *pos, *fcn;
    nav_t nav = {0};
    rnxopt_t opt = {0};
    geph_t geph0 = {0};

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]);                    /* file name */
    if (nargin >= 3) mxCheckSizeOfArgument(argin[2], 1, 3); /* pos */
    if (nargin >= 4) mxCheckSizeOfArgument(argin[3], 1, 32); /* glo_fcn2 */
    if (nargin == 5) mxCheckScalar(argin[4]); /* rnxver */

    /* input */
    mxGetString(argin[0], file, sizeof(file));
    obs = mxobs2obs(argin[1], 1, &n, &nobslist);
    if (nargin >= 3) pos = (double *)mxGetPr(argin[2]);
    if (nargin >= 4) fcn = (double *)mxGetPr(argin[3]);
	if (nargin == 5) rnxver = (int)mxGetScalar(argin[4]);
    // mexPrintf("n=%d\n",n);
    // mexPrintf("nobslist[n-1]=%d \n",nobslist[n-1]);

    for (i = 0; i < n; i++) {
        for (j = 0; j < nobslist[i]; j++, iobs++) {
            for (k = 0; k < NFREQ; k++) {
                sys = satsys(obs[iobs].sat, NULL);
                if (obs[iobs].P[k] != 0.0)
                    ccode[satsys2tobssys(sys)][obs[iobs].code[k] - 1] = 1;
                if (obs[iobs].L[k] != 0.0)
                    lcode[satsys2tobssys(sys)][obs[iobs].code[k] - 1] = 1;
                if (obs[iobs].D[k] != 0.0)
                    dcode[satsys2tobssys(sys)][obs[iobs].code[k] - 1] = 1;
                if (obs[iobs].SNR[k] != 0.0)
                    scode[satsys2tobssys(sys)][obs[iobs].code[k] - 1] = 1;
                SYS |= sys;
            }
        }
    }
    // mexPrintf("sys=%x\n",SYS);

    /* rinex setting */
    opt.rnxver = rnxver;
    opt.navsys = SYS;
    opt.tstart = obs[0].time;
    opt.tend = obs[iobs - 1].time;

    if (nargin >= 3) {
        memcpy(opt.apppos, pos, 3*sizeof(double));
    }
    if (nargin >= 4) {
        double2int(fcn, 32, nav.glo_fcn);
    }
    if (!(nav.geph = (geph_t *)malloc(sizeof(geph_t) * NSATGLO))) {
        mexErrMsgTxt("outrinexobs: memory allocation error");
    }
    nav.ng = NSATGLO;
    for (i = 0; i < NSATGLO; i++) nav.geph[i] = geph0;

    /* generation of tobs struct */
    for (i = 0; i < 7; i++) { /* {GPS,GLO,GAL,QZS,SBS,BDS,IRN} */
        opt.nobs[i] = 0;
        for (j = 0; j < MAXCODE; j++) {
            if (ccode[i][j])
                sprintf(opt.tobs[i][opt.nobs[i]++], "C%s", code2obs(j + 1));
            if (lcode[i][j])
                sprintf(opt.tobs[i][opt.nobs[i]++], "L%s", code2obs(j + 1));
            if (dcode[i][j])
                sprintf(opt.tobs[i][opt.nobs[i]++], "D%s", code2obs(j + 1));
            if (scode[i][j])
                sprintf(opt.tobs[i][opt.nobs[i]++], "S%s", code2obs(j + 1));
        }
        // mexPrintf("nobs=%d\n",opt.nobs[i]);
    }

    /* write to rinex file */
    if ((fp = fopen(file, "w")) == NULL) {
        sprintf(errmsg, "file open error: %s", file);
        mexErrMsgTxt(errmsg);
    }
    outrnxobsh(fp, &opt, &nav);
    for (iobs = 0, i = 0; i < n; i++) {
        // mexPrintf("i=%d nobs=%d iobs=%d\n",i,nobslist[i],iobs);
        outrnxobsb(fp, &opt, obs + iobs, nobslist[i], 0);
        iobs += nobslist[i];
    }
    fclose(fp);
    free(nobslist);
    free(obs);
    free(nav.geph);
}
