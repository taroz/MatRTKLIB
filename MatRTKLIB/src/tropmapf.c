/**
 * @file tropmapf.c
 * @brief Compute tropospheric mapping function by NMF
 * @author Taro Suzuki
 * @note Wrapper for "tropmapf" in rtkcmn.c
 * @note Change input unit from radian to degree
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 4

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    gtime_t time;
    int i, j, m, nsat, nllhs;
    double ep[6], llh[3], azel[2], *eps, *llhs, *azs, *els, *mapfd, *mapfw;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6);   /* epoch */
    mxCheckSizeOfColumns(argin[1], 3);   /* llh */
    mxCheckSameRows(argin[0], argin[2]); /* epoch,az */
    mxCheckSameSize(argin[2], argin[3]); /* az,el */

    /* inputs */
    eps = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    llhs = (double *)mxGetPr(argin[1]);
    nllhs = (int)mxGetM(argin[1]);
    azs = (double *)mxGetPr(argin[2]);
    nsat = (int)mxGetN(argin[2]);
    els = (double *)mxGetPr(argin[3]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    mapfd = mxGetPr(argout[0]);
    mxSetNaN(mapfd, m * nsat);
    argout[1] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    mapfw = mxGetPr(argout[1]);
    mxSetNaN(mapfw, m * nsat);

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
            mapfd[i + m * j] = tropmapf(time, llh, azel, &mapfw[i + m * j]);
        }
    }
}
