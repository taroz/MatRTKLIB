/**
 * @file readsolstat.c
 * @brief Read RTKLIB solution status file
 * @author Taro Suzuki
 * @note Wrapper for "readsolstatt" in solution.c
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    solstatbuf_t solstatbuf = {0};
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
    if (readsolstatt(file, 1, t, t, 0, &solstatbuf) <= 0) {
        sprintf(errmsg, "Invalid RTKLIB solution status file: %s", file[0]);
        mexErrMsgTxt(errmsg);
    }

    /* outputs */
    argout[0] = solstat2mxsolstat(solstatbuf.data, solstatbuf.n);

    freesolstatbuf(&solstatbuf);
    free(file);
}