/**
 * @file geterp.c
 * @brief Get earth rotation parameter values
 * @author Taro Suzuki
 * @note Wrapper for "geterp" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    erp_t erp = {0};
    gtime_t time;
    double ep[6], *eps, erpv[4], *erpvs;
    int i, m;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[1], 6); /* epochs */

    /* input */
    mxerp2erp(argin[0], &erp);
    eps = (double *)mxGetPr(argin[1]);
    m = (int)mxGetM(argin[1]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, 4, mxREAL);
    erpvs = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        ep[0] = eps[i + m * 0];
        ep[1] = eps[i + m * 1];
        ep[2] = eps[i + m * 2];
        ep[3] = eps[i + m * 3];
        ep[4] = eps[i + m * 4];
        ep[5] = eps[i + m * 5];
        time = epoch2time(ep);

        geterp(&erp, time, erpv);

        erpvs[0 + m * i] = erpv[0];
        erpvs[1 + m * i] = erpv[1];
        erpvs[2 + m * i] = erpv[2];
        erpvs[3 + m * i] = erpv[3];
    }
    free(erp.data);
}
