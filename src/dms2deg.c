/**
 * @file dms2deg.c
 * @brief Convert degree-minute-second to degree
 * @author Taro Suzuki
 * @note Wrapper for "dms2deg" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, m;
    double *dmsin, dms[3], *deg;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 3); /* dms */

    /* inputs */
    dmsin = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, 1, mxREAL);
    deg = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        dms[0] = dmsin[i + m * 0];
        dms[1] = dmsin[i + m * 1];
        dms[2] = dmsin[i + m * 2];
        deg[i] = dms2deg(dms);
    }
}
