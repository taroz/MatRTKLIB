/**
 * @file tropcorr.c
 * @brief Compute tropospheric delay by standard atmosphere and saastamoinen
 * model
 * @author Taro Suzuki
 * @note Wrapper for "tropcorr" in pntpos.c
 * @note Change input unit from radian to degree
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 4

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    nav_t nav = {0};
    gtime_t time;
    int i, j, m, nsat, nllhs, tropopt;
    double ep[6], llh[3], azel[2];
    double *eps, *llhs, *azs, *els, *trps, *vars;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6);   /* epoch */
    mxCheckSizeOfColumns(argin[2], 3);   /* llh */
    mxCheckSameRows(argin[0], argin[3]); /* epoch,az */
    mxCheckSameSize(argin[3], argin[4]); /* az,el */
    mxCheckScalar(argin[5]);             /* tropopt */

    /* inputs */
    eps = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    nav = mxnav2nav(argin[1]);
    llhs = (double *)mxGetPr(argin[2]);
    nllhs = (int)mxGetM(argin[2]);
    azs = (double *)mxGetPr(argin[3]);
    nsat = (int)mxGetN(argin[3]);
    els = (double *)mxGetPr(argin[4]);
    tropopt = (int)mxGetScalar(argin[5]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    trps = mxGetPr(argout[0]);
    mxSetNaN(trps, m * nsat);
    argout[1] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    vars = mxGetPr(argout[1]);
    mxSetNaN(vars, m * nsat);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        ep[0] = eps[i + m * 0];
        ep[1] = eps[i + m * 1];
        ep[2] = eps[i + m * 2];
        ep[3] = eps[i + m * 3];
        ep[4] = eps[i + m * 4];
        ep[5] = eps[i + m * 5];
        time = epoch2time(ep);

        if (nllhs == 1) {
            llh[0] = llhs[0] * D2R;
            llh[1] = llhs[1] * D2R;
            llh[2] = llhs[2];
        } else {
            llh[0] = llhs[i + m * 0] * D2R;
            llh[1] = llhs[i + m * 1] * D2R;
            llh[2] = llhs[i + m * 2];
        }

        for (j = 0; j < nsat; j++) {
            azel[0] = azs[i + m * j] * D2R;
            azel[1] = els[i + m * j] * D2R;
            tropcorr(time, &nav, llh, azel, tropopt, &trps[i + m * j],
                     &vars[i + m * j]);
        }
    }
}
