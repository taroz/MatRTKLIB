/**
 * @file mex_readrnxobs.c
 * @brief Read RINEX observation file
 * @author Taro Suzuki
 * @note Wrapper for "readrnxt" in rinex.c
 */

#include "mex_utility.h"

#define NIN 1

/* search next observation data index */
static int nextobsf(const obs_t *obs, int *i, int rcv) {
    double tt;
    int n;

    for (; *i < obs->n; (*i)++)
        if (obs->data[*i].rcv == rcv) break;
    for (n = 0; *i + n < obs->n; n++) {
        tt = timediff(obs->data[*i + n].time, obs->data[*i].time);
        if (obs->data[*i + n].rcv != rcv || tt > DTTOL) break;
    }
    return n;
}

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    obs_t obs = {0};
    nav_t nav = {0};
    sta_t sta = {0};
    gtime_t t = {0};
    char file[512], errmsg[512];
    int i, n, m, iobs, *nobslist;
    double *xyz, *glo_fcn;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]); /* rinex file name */

    /* input */
    mxGetString(argin[0], file, sizeof(file)); /* rinex file name */

    /* call RTKLIB function */
    if (readrnxt(file, 1, t, t, 0, "", &obs, &nav, &sta) <= 0) {
		sprintf(errmsg, "Invalid RINEX observation file: %s", file);
        mexErrMsgTxt(errmsg);
    }
    // mexPrintf("%f,%f,%f\n",sta.pos[0],sta.pos[1],sta.pos[2]);

    /* count epochs */
    for (iobs = 0, n = 0; (m = nextobsf(&obs, &iobs, 1)) > 0; iobs += m) {
        n++;
    }

    /* count each number of observations */
    if (!(nobslist = (int *)calloc(n, sizeof(int)))) {
        mexErrMsgTxt("readrnxobs: memory allocation error");
    }
    for (iobs = 0, i = 0; (m = nextobsf(&obs, &iobs, 1)) > 0; iobs += m, i++) {
        nobslist[i] = m;
    }

    /* outputs */
    argout[0] = obs2mxobs(obs.data, n, nobslist);

    /* station position in ECEF */
    argout[1] = mxCreateDoubleMatrix(1, 3, mxREAL);
    xyz = mxGetPr(argout[1]);
    memcpy(xyz, sta.pos, 3 * sizeof(double));

    /* glo_fcn */
    argout[2] = mxCreateDoubleMatrix(1, 32, mxREAL);
    glo_fcn = mxGetPr(argout[2]);
    int2double(nav.glo_fcn, 32, glo_fcn);

    free(nobslist);
    freeobs(&obs);
}