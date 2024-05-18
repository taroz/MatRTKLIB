/**
 * @file gpst2doy.c
 * @brief Convert GPS time (tow, week) to day of year
 * @author Taro Suzuki
 * @note Wrapper for "time2doy" in rtkcmn.c
 * @note Support vector inputs
 */
#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    bool utcflag = false;
    int i, nepoch;
    double *doy, *tow, *week;
    gtime_t time;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSameSize(argin[0], argin[1]);      /* tow,week */
    mxCheckSizeOfColumns(argin[0], 1);        /* tow */
    mxCheckSizeOfColumns(argin[1], 1);        /* week */
    if (nargin == 3) mxCheckScalar(argin[2]); /* utc flag */

    /* inputs */
    tow = (double *)mxGetPr(argin[0]);
    week = (double *)mxGetPr(argin[1]);
    nepoch = mxGetSize(argin[0]);
    if (nargin == 3) utcflag = (bool)mxGetScalar(argin[2]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(nepoch, 6, mxREAL);
    doy = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < nepoch; i++) {
        time = gpst2time((int)week[i], tow[i]);

        if (utcflag) time = utc2gpst(time);
        doy[i] = time2doy(time);
    }
}
