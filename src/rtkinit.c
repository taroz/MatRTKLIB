/**
 * @file rtkinit.c
 * @brief Initialize RTK control struct
 * @author Taro Suzuki
 * @note Wrapper for "rtkinit" in rtkpos.c
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */

/* mex_readrinexnav ----------------------------------------------------------*/
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    rtk_t rtk;
    prcopt_t popt = prcopt_default;
    solopt_t sopt = solopt_default;
    int i;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);

    /* input option struct */
    mxopt2opt(argin[0], &popt, &sopt);

    /* call RTKLIB function */
    rtkinit(&rtk, &popt);
    
    /* set base station position */
    for (i = 0; i < 3; i++) rtk.rb[i] = popt.rb[i];

    /* output */
    argout[0] = rtk2mxrtk(&rtk, 1);

    rtkfree(&rtk);
}