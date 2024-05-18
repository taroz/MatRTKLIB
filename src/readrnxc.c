/**
 * @file readrnxc.c
 * @brief Read RINEX clock files
 * @author Taro Suzuki
 * @note Wrapper for "readrnxc" in rinex.c
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    nav_t nav = {0};
    char file[512], errmsg[512];
    gtime_t t = {0};

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]);

    /* input */
    mxGetString(argin[0], file, sizeof(file)); /* rinex clock file name */
    if (nargin == 2) {
        nav = mxnav2nav(argin[1]);
        if (nav.nc > 0) {
            free(nav.pclk);
            nav.pclk = NULL;
            nav.nc = nav.ncmax = 0;
        }
    }

    /* call RTKLIB function */
    if (readrnxc(file, &nav) <= 0) {
        sprintf(errmsg, "Invalid RINEX clock file: %s", file);
        mexErrMsgTxt(errmsg);
    }

    /* output */
    argout[0] = nav2mxnav(&nav);

    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
}
