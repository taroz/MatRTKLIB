/**
 * @file deg2dms.c
 * @brief Convert degree to degree-minute-second
 * @author Taro Suzuki
 * @note Wrapper for "deg2dms" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, m, ndec = 9;
    double *deg, dms[3], *dmsout;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 1); /* deg */
    if (nargin == 2) {
        mxCheckScalar(argin[1]); /* ndec */
    }

    /* inputs */
    deg = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    if (nargin == 2) ndec = (int)mxGetScalar(argin[1]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, 3, mxREAL);
    dmsout = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        deg2dms(deg[i], dms, ndec);
        dmsout[i + m * 0] = dms[0];
        dmsout[i + m * 1] = dms[1];
        dmsout[i + m * 2] = dms[2];
    }
}
