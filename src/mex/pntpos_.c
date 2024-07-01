/**
 * @file pntpos_.c
 * @brief Compute receiver position, velocity, clock bias by single-point
 * positioning
 * @author Taro Suzuki
 * @note Wrapper for "pntpos" in pntpos.c
 * @note Due to a conflict, file name was changed from pntpos.c to pntpos_.c
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    obsd_t *obss, *obs;
    nav_t nav = {0};
    prcopt_t popt = prcopt_default;
    solopt_t sopt = solopt_default;
    solbuf_t solbuf = {0};
    sol_t sol = {0};
    ssat_t *ssats;
    gtime_t *times;
    int i, j, n, nobs = 0, iobs = 0, *nobslist = NULL;
    char msg[128] = "";
    char tracefile[] = "pntpos.trace";

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);

    /* options */
    popt.ionoopt = IONOOPT_BRDC;
    popt.tropopt = TROPOPT_SAAS;
    if (nargin == 3) {
        mxopt2opt(argin[2], &popt, &sopt);
    }
    if (sopt.trace > 0) {
        mexPrintf("trace level=%d\n", sopt.trace);
        traceopen(tracefile);
        tracelevel(sopt.trace);
    }

    /* inputs */
    obss = mxobs2obs(argin[0], 1, &n, &nobslist);
    nav = mxnav2nav(argin[1]);
    
    initsolbuf(&solbuf, 0, n);
    
    /* ssats */
    if (!(ssats = (ssat_t *)calloc(MAXSAT*n, sizeof(ssat_t)))) {
        mexErrMsgTxt("pntpos: memory allocation error");
    }
    /* times */
    if (!(times = (gtime_t *)calloc(n, sizeof(gtime_t)))) {
        mexErrMsgTxt("pntpos: memory allocation error");
    }

    /* call RTKLIB function */
    for (i = 0; i < n; i++) {
        obs = &obss[iobs];

        /* exclude satellites */
        for (j = 0; j < nobslist[i]; j++) {
            if ((satsys(obs[j].sat, NULL) & popt.navsys) &&
                popt.exsats[obs[j].sat - 1] != 1) {
                obs[nobs++] = obs[j];
            }
        }
        //mexPrintf("nobslist=%d nobs=%d\n", nobslist[i], nobs);
        if (!pntpos(obs, nobs, &nav, &popt, &sol, NULL, &ssats[i*MAXSAT], msg)) {
            mexPrintf("pntpos: no solution: %s %s\n", time_str(obs->time, 3), msg);
        }
        memcpy(&times[i], &obs[0].time, sizeof(gtime_t));

        //mexPrintf("sol.stat=%d\n", sol.stat);
        //mexPrintf("msg=%s\n", msg);
        addsol(&solbuf, &sol);

        iobs += nobslist[i];
        nobs = 0;
    }
    /* outputs */
    argout[0] = sol2mxsol(solbuf.data, solbuf.n);
    argout[1] = ssat2mxssat(ssats, times, n);

    free(obss);
    free(nobslist);
    freesolbuf(&solbuf);
    free(ssats); free(times);
    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
    if (nav.erp.n > 0) free(nav.erp.data);
    
    if (sopt.trace > 0) traceclose();
}