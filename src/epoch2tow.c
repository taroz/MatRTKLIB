/**
 * @file epoch2tow.c
 * @brief Convert calendar day/time to GPS time of week
 * @author Taro Suzuki
 * @note Wrapper for "time2gpst" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    bool utcflag = false;
    int i, iweek, nepoch;
    double ep[6], *epoch, *tow, *week;
    gtime_t time;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6);        /* epochs */
    if (nargin == 2) mxCheckScalar(argin[1]); /* utcflag */

    /* inputs */
    epoch = (double *)mxGetPr(argin[0]);
    nepoch = (int)mxGetM(argin[0]);
    if (nargin == 2) utcflag = (bool)mxGetScalar(argin[1]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(nepoch, 1, mxREAL);
    tow = mxGetPr(argout[0]);
    argout[1] = mxCreateDoubleMatrix(nepoch, 1, mxREAL);
    week = mxGetPr(argout[1]);

    /* call RTKLIB function */
    for (i = 0; i < nepoch; i++) {
        ep[0] = epoch[i + nepoch * 0];
        ep[1] = epoch[i + nepoch * 1];
        ep[2] = epoch[i + nepoch * 2];
        ep[3] = epoch[i + nepoch * 3];
        ep[4] = epoch[i + nepoch * 4];
        ep[5] = epoch[i + nepoch * 5];
        time = epoch2time(ep);
        if (utcflag) time = utc2gpst(time);
        tow[i] = time2gpst(time, &iweek);
        week[i] = (double)iweek;
    }
}
