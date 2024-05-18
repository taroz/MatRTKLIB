/**
 * @file readpcv.c
 * @brief Read antenna parameters
 * @author Taro Suzuki
 * @note Wrapper for "readpcb" in rtkcmn.c
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    pcvs_t pcvs = {0};
    char file[512], errmsg[512];

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]); /* PCV file name */

    /* input */
    mxGetString(argin[0], file, sizeof(file)); /* PCV file path */

    /* call RTKLIB function */
    if (!readpcv(file, &pcvs)) {
        sprintf(errmsg, "readpcv: Invalid PCV file: %s", file);
        mexErrMsgTxt(errmsg);
    }

    /* output */
    argout[0] = pcv2mxpcv(pcvs.pcv, pcvs.n);

    free(pcvs.pcv);
}
