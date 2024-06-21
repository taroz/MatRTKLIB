/**
 * @file convgpx_.c
 * @brief Convert from solution files to GPX files 
 * @author Taro Suzuki
 * @note Wrapper for "convgpx" in convgpx.c
 * @note Input interface changed from original
 * @note Due to a conflict, file name was changed from convgpx.c to convgpx_.c
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    char file[512];
    int qflag=0, outtrk=1, outpnt=1, outalt=0, stat;
    double offset[3] = {0};
    gtime_t ts={0}, te={0};

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]);

    /* input */
    mxGetString(argin[0], file, sizeof(file)); /* input solutions file */
    if (nargin>=2) qflag  = (int)mxGetScalar(argin[1]); /* quality flag (0:all) */
    if (nargin>=3) outtrk = (int)mxGetScalar(argin[2]); /* output track    (0:off,1:on) */
    if (nargin>=4) outpnt = (int)mxGetScalar(argin[3]); /* output waypoint (0:off,1:on) */
    if (nargin>=5) outalt = (int)mxGetScalar(argin[4]); /* output altitude (0:off,1:elipsoidal,2:geodetic) */

    /* call RTKLIB function */
    if (stat = convgpx(file, "", ts, te, 0.0, qflag, offset, outtrk, outpnt, outalt, 0) < 0) {
        mexErrMsgTxt("convgpx: input file error");
    }
}
