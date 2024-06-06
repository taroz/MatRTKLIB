/**
 * @file llh2xyz.c
 * @brief Transform (lat,lon,ellipsoidal height) to ECEF coordinate
 * @author Taro Suzuki
 * @note Wrapper for "pos2ecef" in rtkcmn.c
 * @note Change the function name from the original function
 * @note Change input unit from radian to degree
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, m;
    double l[3], x[3], *llh, *xyz;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 3);

    /* input */
    llh = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, 3, mxREAL);
    xyz = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        l[0] = llh[i + m * 0] * D2R;
        l[1] = llh[i + m * 1] * D2R;
        l[2] = llh[i + m * 2];
        pos2ecef(l, x);
        xyz[i + m * 0] = x[0];
        xyz[i + m * 1] = x[1];
        xyz[i + m * 2] = x[2];
    }
}
