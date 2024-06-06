/**
 * @file loadopts.c
 * @brief Load options from file (.conf)
 * @author Taro Suzuki
 * @note Wrapper for "loadopts" in option.c
 */

#include "mex_utility.h"

#define NIN 0

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    prcopt_t popt = prcopt_default;
    solopt_t sopt = solopt_default;
    char file[512], errmsg[512];

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);

    popt.ionoopt = IONOOPT_BRDC;
    popt.tropopt = TROPOPT_SAAS;
    
    if (nargin == 1) {
        mxCheckChar(argin[0]);                     /* option file */
        mxGetString(argin[0], file, sizeof(file)); /* input */

        /* load option from file */
        if (!loadopts(file, sysopts)) {
            sprintf(errmsg, "Invalid option file: %s", file);
            mexErrMsgTxt(errmsg);
        }
        getsysopts(&popt, &sopt, NULL);
    }

    /* outputs */
    argout[0] = opt2mxopt(&popt, &sopt);
}