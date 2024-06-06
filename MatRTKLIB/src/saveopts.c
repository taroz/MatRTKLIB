/**
 * @file saveopts.c
 * @brief Save options to file
 * @author Taro Suzuki
 * @note Wrapper for "saveopts" in option.c
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    prcopt_t popt = prcopt_default;
    solopt_t sopt = solopt_default;
    char file[512], errmsg[512], comment[512] = "";

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]); /* option file */
    if (nargin == 3) {
        mxCheckChar(argin[2]); /* comment */
    }

    /* input */
    mxGetString(argin[0], file, sizeof(file));
    mxopt2opt(argin[1], &popt, &sopt);
    if (nargin == 3) {
        mxGetString(argin[2], comment, sizeof(comment));
    }

    /* call RTKLIB function */
    setsysopts(&popt, &sopt, NULL);

    /* Save option to file */
    if (!saveopts(file, "w", comment, sysopts)) {
        sprintf(errmsg, "Invalid option file: %s", file);
        mexErrMsgTxt(errmsg);
    }
}