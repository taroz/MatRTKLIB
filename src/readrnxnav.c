/**
 * @file readrnxnav.c
 * @brief Read RINEX navigation file
 * @author Taro Suzuki
 * @note Wrapper for "readrnxt" in rinex.c
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
    mxGetString(argin[0], file, sizeof(file)); /* rinex file name */
    if (nargin == 2) {
        nav = mxnav2nav(argin[1]);
    }

    /* call RTKLIB function */
    if (readrnxt(file, 1, t, t, 0, "", NULL, &nav, NULL) <= 0) {
		sprintf(errmsg, "Invalid RINEX navigation file: %s",file);
        mexErrMsgTxt(errmsg);
    }
    uniqnav(&nav);

    /* output */
    argout[0] = nav2mxnav(&nav);

    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
    if (nav.erp.n > 0) free(nav.erp.data);
}
