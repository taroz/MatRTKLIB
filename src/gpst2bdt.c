/**
 * @file gpst2bdt.c
 * @brief Convert GPST epoch to BDT epoch
 * @author Taro Suzuki
 * @note Wrapper for "gpst2bdt" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, nepoch;
    double ep[6], *epoch, *bdtepoch;
    gtime_t time;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN); /* epochs */
    mxCheckSizeOfColumns(argin[0], 6);

    /* inputs */
    epoch = (double *)mxGetPr(argin[0]);
    nepoch = (int)mxGetM(argin[0]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(nepoch, 6, mxREAL);
    bdtepoch = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < nepoch; i++) {
        ep[0] = epoch[i + nepoch * 0];
        ep[1] = epoch[i + nepoch * 1];
        ep[2] = epoch[i + nepoch * 2];
        ep[3] = epoch[i + nepoch * 3];
        ep[4] = epoch[i + nepoch * 4];
        ep[5] = epoch[i + nepoch * 5];
        time = epoch2time(ep);
        time = gpst2bdt(time);
        time2epoch(time, ep);
        bdtepoch[i + nepoch * 0] = ep[0];
        bdtepoch[i + nepoch * 1] = ep[1];
        bdtepoch[i + nepoch * 2] = ep[2];
        bdtepoch[i + nepoch * 3] = ep[3];
        bdtepoch[i + nepoch * 4] = ep[4];
        bdtepoch[i + nepoch * 5] = ep[5];
    }
}
