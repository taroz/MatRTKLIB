/**
 * @file jgd2tokyo.c
 * @brief Transform position in JGD2000 datum to Tokyo datum
 * @author Taro Suzuki
 * @note Wrapper for "jgd2tokyo" in datum.c
 * @note Change input unit from radian to degree
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    char file[512], errmsg[512];
    double *llh_tokyo, *llh_jgd, pos[3];
    int i, m;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 3); /* llh */
    mxCheckChar(argin[1]);             /* Datum file */

    /* input */
    llh_jgd = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    mxGetString(argin[1], file, sizeof(file));

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, 3, mxREAL);
    llh_tokyo = mxGetPr(argout[0]);

    /* call RTKLIB function */
    if (!loaddatump(file)) {
        sprintf(errmsg, "datum parameter file open error: %s", file);
        mexErrMsgTxt(errmsg);
    }

    for (i = 0; i < m; i++) {
        pos[0] = llh_jgd[i + m * 0] * D2R;
        pos[1] = llh_jgd[i + m * 1] * D2R;
        pos[2] = llh_jgd[i + m * 2];
        jgd2tokyo(pos);
        llh_tokyo[i + m * 0] = pos[0] * R2D;
        llh_tokyo[i + m * 1] = pos[1] * R2D;
        llh_tokyo[i + m * 2] = pos[2];
    }
}
