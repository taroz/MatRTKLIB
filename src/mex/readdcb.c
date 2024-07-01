/**
 * @file readdcb.c
 * @brief Read differential code bias (DCB) parameters
 * @author Taro Suzuki
 * @note Wrapper for "readdcb" in preceph.c
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    nav_t nav = {0};
    char file[512], errmsg[512];

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]); /* DCB file name */

    /* input */
    mxGetString(argin[0], file, sizeof(file)); /* DCB file name */
    if (nargin == 2) {
        nav = mxnav2nav(argin[1]);
    }

    /* call RTKLIB function */
    if (!readdcb(file, &nav, NULL)) {
        sprintf(errmsg, "readdcb: invalid DCB file: %s", file);
        mexErrMsgTxt(errmsg);
    }
    //mexPrintf("%f\n", nav.cbias[0][1]);
    
    /* output */
    argout[0] = nav2mxnav(&nav);

    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
    if (nav.erp.n > 0) free(nav.erp.data);
}
