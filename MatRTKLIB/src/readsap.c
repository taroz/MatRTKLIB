/**
 * @file readsap.c
 * @brief Read satellite antenna parameters
 * @author Taro Suzuki
 * @note Wrapper for "readsap" in rinex.c
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    nav_t nav = {0};
    char file[512], errmsg[512];
    gtime_t time;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]);                 /* antex file name */
    mxCheckSizeOfArgument(argin[1], 1, 6); /* epoch */

    /* input */
    mxGetString(argin[0], file, sizeof(file));      /* antex file name */
    time = epoch2time((double *)mxGetPr(argin[1])); /* epoch */

    if (nargin == 3) {
        nav = mxnav2nav(argin[2]);
    }

    /* call RTKLIB function */
    if (!readsap(file, time, &nav)) {
        sprintf(errmsg, "readsap: invalid ANTEX file: %s", file);
        mexErrMsgTxt(errmsg);
    }

    /* output */
    argout[0] = nav2mxnav(&nav);

    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
}
