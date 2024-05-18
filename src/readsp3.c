/**
 * @file readsp3.c
 * @brief Read SP3 file
 * @author Taro Suzuki
 * @note Wrapper for "readsp3" in preceph.c
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    nav_t nav = {{0}};
    char file[512];
    gtime_t t = {0};

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]); /* SP3 file name */

    /* input */
    mxGetString(argin[0], file, sizeof(file)); /* SP3 file name */
    if (nargin == 2) {
        nav = mxnav2nav(argin[1]);

        if (nav.ne > 0) {
            free(nav.peph);
            nav.peph = NULL;
            nav.ne = nav.nemax = 0;
        }
    }

    /* call RTKLIB function */
    readsp3(file, &nav, 0);

    /* output */
    argout[0] = nav2mxnav(&nav);

    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
}
