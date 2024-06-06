/**
 * @file lambda_.c
 * @brief integer least-square estimation. reduction is performed by lambda
 * @author Taro Suzuki
 * @note Wrapper for "lambda" in lambda.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 3

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int m, n;
    double *a, *Q, *F, *Ft, *s;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckScalar(argin[0]);           /* m */
    mxCheckSameColumns(argin[1], argin[2]); /* a , Q */
    mxCheckSquareMatrix(argin[2]);     /* Q */

    /* inputs */
    m = (int)mxGetScalar(argin[0]);
    a = (double *)mxGetPr(argin[1]);
    n = (int)mxGetN(argin[1]);
    Q = (double *)mxGetPr(argin[2]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, n, mxREAL);
    argout[1] = mxCreateDoubleMatrix(m, 1, mxREAL);

    F = mxGetPr(argout[0]);
    s = mxGetPr(argout[1]);

    Ft = (double *)malloc(m * n * sizeof(double));

    /* call RTKLIB function */
    lambda(n, m, a, Q, Ft, s);

    transpose(Ft, n, m, 1, F);

    free(Ft);
}
