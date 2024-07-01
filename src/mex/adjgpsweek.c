/**
 * @file adjgpsweek.c
 * @brief Adjust gps week number using cpu time
 * @author Taro Suzuki
 * @note Wrapper for "adjgpsweek" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, m, n, iadjweek;
    double *week, *adjweek;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckDouble(argin[0]); /* week */

    /* input */
    week = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    n = (int)mxGetN(argin[0]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, n, mxREAL);
    adjweek = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m * n; i++) {
        iadjweek = adjgpsweek((int)week[i]);
        adjweek[i] = (double)iadjweek;
    }
}
