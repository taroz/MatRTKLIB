/**
 * @file bdttow2epoch.c
 * @brief Convert week and tow in BeiDou time to calendar day/time
 * @author Taro Suzuki
 * @note Wrapper for "gst2time" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, nepoch;
    double *epoch, *tow, *week, ep[6];
    gtime_t time;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSameSize(argin[0], argin[1]);      /* tow,week */
    mxCheckSizeOfColumns(argin[0], 1);        /* tow */
    mxCheckSizeOfColumns(argin[1], 1);        /* week */

    /* inputs */
    tow = (double *)mxGetPr(argin[0]);
    week = (double *)mxGetPr(argin[1]);
    nepoch = mxGetSize(argin[0]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(nepoch, 6, mxREAL);
    epoch = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < nepoch; i++) {
        time = bdt2time((int)week[i], tow[i]);

        time2epoch(time, ep);
        epoch[i + nepoch * 0] = ep[0];
        epoch[i + nepoch * 1] = ep[1];
        epoch[i + nepoch * 2] = ep[2];
        epoch[i + nepoch * 3] = ep[3];
        epoch[i + nepoch * 4] = ep[4];
        epoch[i + nepoch * 5] = ep[5];
    }
}
