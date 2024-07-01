/**
 * @file xyz2llh.c
 * @brief Transform ECEF coordinate to (lat,lon,ellipsoidal height)
 * @author Taro Suzuki
 * @note Wrapper for "ecef2pos" in rtkcmn.c
 * @note Change the function name from the original function
 * @note Change output unit from radian to degree
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, m;
    double x[3], l[3], *xyz, *llh;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 3);

    /* input */
    xyz = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, 3, mxREAL);
    llh = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        x[0] = xyz[i + m * 0];
        x[1] = xyz[i + m * 1];
        x[2] = xyz[i + m * 2];
        if (mxIsNaN(x[0]) || mxIsNaN(x[1]) || mxIsNaN(x[2])) {
            llh[i + m * 0] = llh[i + m * 1] = llh[i + m * 2] = mxGetNaN();
            continue;
        }
        ecef2pos(x, l);
        llh[i + m * 0] = l[0] * R2D;
        llh[i + m * 1] = l[1] * R2D;
        llh[i + m * 2] = l[2];
    }
}
