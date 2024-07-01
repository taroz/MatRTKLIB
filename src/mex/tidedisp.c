/**
 * @file tidedisp.c
 * @brief Compute displacements by earth tides
 * @author Taro Suzuki
 * @note Wrapper for "tidedisp" in tides.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 3

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    erp_t erp;
    gtime_t tutc;
    const mwSize *dims;
    int i, m, opt;
    double ep[6], *eps, rr[3], *rrs, dr[3], *drs, *odisp, odispt[6*11];

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6);   /* epochs */
    mxCheckSizeOfColumns(argin[1], 3);   /* rrs */
    mxCheckSameRows(argin[0], argin[1]); /* rrs */
    mxCheckScalar(argin[2]);             /* opt */
    if (nargin >= 5) {
        mxCheckSizeOfArgument(argin[4], 6 ,11); /* odisp */
    }

    /* inputs */
    eps = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    rrs = (double *)mxGetPr(argin[1]);
    opt = (int)mxGetScalar(argin[2]);
    if (nargin >= 4) mxerp2erp(argin[3], &erp);
    if (nargin >= 5) {
        odisp = (double *)mxGetPr(argin[4]);
        dims = mxGetDimensions(argin[4]);
        transpose_mw(odisp, dims, odispt);
    }

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, 3, mxREAL);
    drs = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        /* gpst->utc */
        ep[0] = eps[i + m * 0];
        ep[1] = eps[i + m * 1];
        ep[2] = eps[i + m * 2];
        ep[3] = eps[i + m * 3];
        ep[4] = eps[i + m * 4];
        ep[5] = eps[i + m * 5];
        tutc = gpst2utc(epoch2time(ep));

        /* site position */
        rr[0] = rrs[i + m * 0];
        rr[0] = rrs[i + m * 1];
        rr[0] = rrs[i + m * 2];
        if (nargin == 3)
            tidedisp(tutc, rr, opt, NULL, NULL, dr);
        else if (nargin == 4)
            tidedisp(tutc, rr, opt, &erp, NULL, dr);
        else if (nargin == 5)
            tidedisp(tutc, rr, opt, &erp, odispt, dr);

        drs[i + m * 0] = dr[0];
        drs[i + m * 1] = dr[1];
        drs[i + m * 2] = dr[2];
    }
}
