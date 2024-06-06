/**
 * @file obs2code.c
 * @brief Convert obs code type string to obs code
 * @author Taro Suzuki
 * @note Wrapper for "obs2code" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, m, n;
    double *code;
    char *obs;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckCell(argin[0]);

    /* input */
    m = (int)mxGetM(argin[0]);
    n = (int)mxGetN(argin[0]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, n, mxREAL);
    code = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m * n; i++) {
        obs = mxArrayToString(mxGetCell(argin[0], i));
        code[i] = (double)obs2code(obs);
    }
}
