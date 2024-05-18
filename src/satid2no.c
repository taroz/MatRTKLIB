/**
 * @file satid2no.c
 * @brief Convert satellite id to satellite number
 * @author Taro Suzuki
 * @note Wrapper for "satid2no" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, m, n;
    double *no;
    char *id;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckCell(argin[0]); /* id */

    /* input */
    m = (int)mxGetM(argin[0]);
    n = (int)mxGetN(argin[0]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, n, mxREAL);
    no = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m * n; i++) {
        id = mxArrayToString(mxGetCell(argin[0], i));
        no[i] = (double)satid2no(id);
    }
}
