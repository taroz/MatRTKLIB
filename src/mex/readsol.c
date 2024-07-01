/**
 * @file readsol.c
 * @brief Read RTKLIB solution file
 * @author Taro Suzuki
 * @note Wrapper for "readsolt" in solution.c
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    solbuf_t solbuf = {0};
    gtime_t t = {0};
    char errmsg[512];
    char **file = (char **)malloc(sizeof(char *));
    file[0] = (char *)malloc(512 * sizeof(char));

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]); /* solution file name */

    /* input */
    mxGetString(argin[0], file[0], 512); /* solution file name */
    // mexPrintf("%s\n",file[0]);

    /* call RTKLIB function */
    if (readsolt(file, 1, t, t, 0, 0, &solbuf) <= 0) {
        sprintf(errmsg, "Invalid RTKLIB solution file: %s", file[0]);
        mexErrMsgTxt(errmsg);
    }

    /* outputs */
    argout[0] = sol2mxsol(solbuf.data, solbuf.n);
    argout[1] = mxCreateDoubleMatrix(1, 3, mxREAL);
    memcpy(mxGetPr(argout[1]), solbuf.rb, 3 * sizeof(double));

    free(file);
    freesolbuf(&solbuf);
}