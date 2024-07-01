/**
 * @file readblq.c
 * @brief Read blq ocean tide loading parameters
 * @author Taro Suzuki
 * @note Wrapper for "readblq" in rtkcmn.c
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    const mwSize dims[3] = {11, 6, 0};
    double *odisp, odispt[6 * 11];
    char file[512], sta[256], errmsg[512];

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]); /* BLQ file path */
    mxCheckChar(argin[1]); /* station name */

    /* input */
    mxGetString(argin[0], file, sizeof(file)); /* BLQ file path */
    mxGetString(argin[1], sta, sizeof(sta));   /* station name */

    /* output */
    argout[0] = mxCreateDoubleMatrix(6, 11, mxREAL);
    odisp = mxGetPr(argout[0]);

    /* call RTKLIB function */
    if (!readblq(file, sta, odispt)) {
        sprintf(errmsg, "readblq: invalid BLQ file: file:%s station:%s", file, sta);
        mexErrMsgTxt(errmsg);
    }
    transpose_mw(odispt, dims, odisp);
}
