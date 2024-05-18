/**
 * @file outrnxnav.c
 * @brief Output RINEX navigation file
 * @author Taro Suzuki
 * @note Wrapper for "outrnxnavb, outrnxgnavb" in rinex.c
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, rnxver = 303;
    FILE *fp;
    char file[512], errmsg[512];
    nav_t nav = {0};
    rnxopt_t opt = {0};

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]);                    /* file name */
    if (nargin == 3) mxCheckScalar(argin[2]); /* rnxver */

    /* input */
    mxGetString(argin[0], file, sizeof(file));
    nav = mxnav2nav(argin[1]);
    if (nargin == 3) rnxver = (int)mxGetScalar(argin[2]);

    /* rinex setting */
    opt.rnxver = rnxver;
    opt.navsys = SYS_ALL;

    /* write to rinex file */
    if ((fp = fopen(file, "w")) == NULL) {
        sprintf(errmsg, "file open error: %s", file);
        mexErrMsgTxt(errmsg);
    }
    outrnxnavh(fp, &opt, &nav);
    for (i = 0; i < nav.n; i++) {
        outrnxnavb(fp, &opt, &nav.eph[i]);
    }
    for (i = 0; i < nav.ng; i++) {
        outrnxgnavb(fp, &opt, &nav.geph[i]);
    }

    fclose(fp);
    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
}
