/**
 * @file ionmapf.c
 * @brief Compute ionospheric delay mapping function by single layer model
 * @author Taro Suzuki
 * @note Wrapper for "ionmapf" in rtkcmn.c
 * @note Change input unit from radian to degree
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 3

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, j, m, nsat, nllhs;
    double llh[3], azel[2];
    double *ionmap, *llhs, *azs, *els;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 3);   /* llh */
    mxCheckSameSize(argin[1], argin[2]); /* az,el */

    /* inputs */
    llhs = (double *)mxGetPr(argin[0]);
    nllhs = (int)mxGetM(argin[0]);
    azs = (double *)mxGetPr(argin[1]);
    nsat = (int)mxGetN(argin[1]);
    m = (int)mxGetM(argin[1]);
    els = (double *)mxGetPr(argin[2]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    ionmap = mxGetPr(argout[0]);
    mxSetNaN(ionmap, m * nsat);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
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
            ionmap[i] = ionmapf(llh, azel);
        }
    }
}
