/**
 * @file convkml_.c
 * @brief Convert from solution files to Google Earth KML files 
 * @author Taro Suzuki
 * @note Wrapper for "convkml" in convkml.c
 * @note Input interface changed from original
 * @note Due to a conflict, file name was changed from convkml.c to convkml_.c
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    char file[512];
    int qflag=0, tcolor=1, pcolor=5, outalt=0, stat;
    double offset[3] = {0};
    gtime_t ts={0}, te={0};

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]);

    /* input */
    mxGetString(argin[0], file, sizeof(file)); /* input solutions file */
    if (nargin>=2) qflag  = (int)mxGetScalar(argin[1]); /* quality flag (0:all) */
    if (nargin>=3) tcolor = (int)mxGetScalar(argin[2]); /* track color (0:none,1:white,2:green,3:orange,4:red,5:yellow) */
    if (nargin>=4) pcolor = (int)mxGetScalar(argin[3]); /* point color (0:none,1:white,2:green,3:orange,4:red,5:by qflag) */
    if (nargin>=5) outalt = (int)mxGetScalar(argin[4]); /* output altitude (0:off,1:elipsoidal,2:geodetic) */

    /* call RTKLIB function */
    if (stat = convkml(file, "", ts, te, 0.0, qflag, offset, tcolor, pcolor, outalt, 0) < 0) {
        mexErrMsgTxt("convkml: input file error");
    }
}
