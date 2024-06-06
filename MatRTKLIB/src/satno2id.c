/**
 * @file satno2id.c
 * @brief Convert satellite number to satellite id
 * @author Taro Suzuki
 * @note Wrapper for "satno2id" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, m, n;
    double *sat;
    char cid[4];

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);

    /* input */
    sat = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    n = (int)mxGetN(argin[0]);

    /* output */
    argout[0] = mxCreateCellMatrix(m, n);

    /* call RTKLIB function */
    for (i = 0; i < m * n; i++) {
        satno2id((int)sat[i], cid);
        if (strcmp(cid, "") == 0) strcpy(cid, "N/A");
        mxSetCell(argout[0], i, mxCreateString(cid));
    }
}
