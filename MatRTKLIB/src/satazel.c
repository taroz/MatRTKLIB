/**
 * @file satazel.c
 * @brief Satellite azimuth/elevation angle
 * @author Taro Suzuki
 * @note Wrapper for "satazel" in rtkcmn.c
 * @note Change input/output unit from radian to degree
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 4

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, j, m, nsat, nllhs;
    double llh[3], e[3], azel[2], *llhs, *exs, *eys, *ezs, *azs, *els;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 3);   /* llh */
    mxCheckSameSize(argin[1], argin[2]); /* exs,eys */
    mxCheckSameSize(argin[2], argin[3]); /* eys,ezs */

    /* inputs */
    llhs = (double *)mxGetPr(argin[0]);
    nllhs = (int)mxGetM(argin[0]);
    exs = (double *)mxGetPr(argin[1]);
    m = (int)mxGetM(argin[1]);
    nsat = (int)mxGetN(argin[1]);
    eys = (double *)mxGetPr(argin[2]);
    ezs = (double *)mxGetPr(argin[3]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    azs = mxGetPr(argout[0]);
    argout[1] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    els = mxGetPr(argout[1]);

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
            if (mxIsNaN(llh[0]) || mxIsNaN(llh[1]) || mxIsNaN(llh[2])) {
                azs[i + m * j] = els[i + m * j] = mxGetNaN();
                continue;
            }
            e[0] = exs[i + m * j];
            e[1] = eys[i + m * j];
            e[2] = ezs[i + m * j];
            satazel(llh, e, azel);
            azs[i + m * j] = azel[0] * R2D;
            els[i + m * j] = azel[1] * R2D;
        }
    }
}
