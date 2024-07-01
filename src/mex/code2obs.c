/**
 * @file code2obs.c
 * @brief Convert obs code to obs code string
 * @author Taro Suzuki
 * @note Wrapper for "code2obs" in rtkcmn.c
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
    mxCheckDouble(argin[0]); /* code */

    /* input */
    code = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    n = (int)mxGetN(argin[0]);

    /* output */
    argout[0] = mxCreateCellMatrix(m, n);

    /* call RTKLIB function */
    for (i = 0; i < m * n; i++) {
        obs = code2obs((uint8_t)code[i]);
        mxSetCell(argout[0], i, mxCreateString(obs));
    }
}
