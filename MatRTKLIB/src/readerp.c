/**
 * @file readerp.c
 * @brief Read earth rotation parameters
 * @author Taro Suzuki
 * @note Wrapper for "readerp" in rtkcmn.c
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    erp_t erp = {0};
    char file[512], errmsg[512];

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]); /* ERP file name */

    /* input */
    mxGetString(argin[0], file, sizeof(file)); /* ERP file name */

    /* call RTKLIB function */
    if (!readerp(file, &erp)) {
        sprintf(errmsg, "readerp: invalid ERP file: %s", file);
        mexErrMsgTxt(errmsg);
    }

    /* output */
    argout[0] = erp2mxerp(&erp);

    if (erp.n > 0) free(erp.data);
}
