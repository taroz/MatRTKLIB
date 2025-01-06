/**
 * @file rtkpos_.c
 * @brief Compute rover position by precise positioning
 * @author Taro Suzuki
 * @note Wrapper for "rtkpos" in rtkpos.c
 * @note Due to a conflict, file name was changed from rtkpos.c to rtkpos_.c
 */

#include "mex_utility.h"

#define NIN 4

/* number of parameters (pos,ionos,tropos,hw-bias,phase-bias,real,estimated) */
#define NF(opt) ((opt)->ionoopt == IONOOPT_IFLC ? 1 : (opt)->nf)
#define NP(opt) ((opt)->dynamics == 0 ? 3 : 9)
#define NI(opt) ((opt)->ionoopt != IONOOPT_EST ? 0 : MAXSAT)
#define NT(opt) ((opt)->tropopt < TROPOPT_EST ? 0 : ((opt)->tropopt < TROPOPT_ESTG ? 2 : 6))
#define NL(opt) ((opt)->glomodear != 2 ? 0 : NFREQGLO)
#define NB(opt) ((opt)->mode <= PMODE_DGPS ? 0 : MAXSAT * NF(opt))
#define NR(opt) (NP(opt) + NI(opt) + NT(opt) + NL(opt))
#define NX(opt) (NR(opt) + NB(opt))

/* copy rtk_t */
void rtkcopy(rtk_t *dist, const rtk_t *src) {
    memcpy(&(dist->sol), &(src->sol), sizeof(src->sol));
    memcpy(dist->rb, src->rb, sizeof(src->rb));
    dist->nx = src->nx;
    dist->na = src->na;
    dist->tt = src->tt;
    memcpy(dist->x, src->x, sizeof(double)*src->nx);
    memcpy(dist->P, src->P, sizeof(double)*src->nx*src->nx);
    memcpy(dist->xa, src->xa, sizeof(double)*src->na);
    memcpy(dist->Pa, src->Pa, sizeof(double)*src->na*src->na);
    dist->nfix = src->nfix;
    memcpy(dist->errbuf, src->errbuf, sizeof(src->errbuf));
}

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    obsd_t obsrb[MAXOBS * 2], *obsr, *obsb;
    nav_t nav = {0};
    prcopt_t popt = prcopt_default;
    solopt_t sopt = solopt_default;
    rtk_t rtk, *rtks;
    ssat_t *ssats;
    gtime_t *times;
    solbuf_t solbuf = {0};
    int i, j, nx, nr, nb;
    int iobsr = 0, iobsb = 0, nobsrb = 0, nobsr = 0, nobsb = 0;
    int *nobsrlist = NULL, *nobsblist = NULL;
    char tracefile[] = "rtkpos.trace";

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);

    /* input opt struct */
    mxopt2opt(argin[3], &popt, &sopt);

    /* trace file */
    if (sopt.trace > 0) {
        mexPrintf("trace level=%d\n", sopt.trace);
        traceopen(tracefile);
        tracelevel(sopt.trace);
    }
    /* check opt struct */
    nx = (int)mxGetScalar(mxGetField(argin[0], 0, "nx"));
    if (nx != NX(&popt)) {
        mexPrintf("nx%d NX\n", nx, NX(&popt));
        mexErrMsgTxt("rtkpos: common opt struct must be used in rtkinit");
    }
    /* check rtk struct */
    if ((int)mxGetM(argin[0]) != 1) {
        mexErrMsgTxt("rtkpos: input rtk struct must not be struct array");
    }
    /* input rtk struct */
    rtk = mxrtk2rtk(argin[0], &popt, NULL);

    /* input obs struct */
    obsr = mxobs2obs(argin[1], 1, &nr, &nobsrlist);
    if (nargin == 5) {
        obsb = mxobs2obs(argin[4], 2, &nb, &nobsblist);
        if (nr != nb) {
            rtkfree(&rtk);
            free(obsr); free(nobsrlist);
            free(obsb); free(nobsblist);
            mexErrMsgTxt("rtkpos: size of rover and base observations must be same");
        }
    }

    /* input nav struct */
    nav = mxnav2nav(argin[2]);

    /* outputs */
    /* ssats */
    if (!(ssats = (ssat_t *)calloc(MAXSAT*nr, sizeof(ssat_t)))) {
        mexErrMsgTxt("rtkpos: memory allocation error");
    }
    /* times */
    if (!(times = (gtime_t *)calloc(nr, sizeof(gtime_t)))) {
        mexErrMsgTxt("rtkpos: memory allocation error");
    }
    /* rtk */
    if (!(rtks = (rtk_t *)calloc(nr, sizeof(rtk_t)))) {
        mexErrMsgTxt("rtkpos: memory allocation error");
    }
    for (i=0; i<nr; i++) {
        rtkinit(&rtks[i], &popt);
    }

    /* rtk processing */
    for (i = 0; i < nr; i++) {
        /* reset variables */
        nobsr = 0;
        rtk.neb = 0;
        memset(rtk.errbuf, 0, MAXERRMSG);

        /* exclude satellites */
        for (j = 0; j < nobsrlist[i]; j++) {
            if ((satsys(obsr[iobsr+j].sat, NULL) & popt.navsys) &&
                popt.exsats[obsr[iobsr+j].sat - 1] != 1) {
                memcpy(&obsrb[nobsr++], &obsr[iobsr+j], sizeof(obsd_t));
            }
        }
        iobsr += nobsrlist[i];

        /* call rtkpos */
        if (nargin == 5) {
            nobsb = nobsblist[i];
            memcpy(&obsrb[nobsr], &obsb[iobsb], nobsb * sizeof(obsd_t));
            iobsb += nobsb;
        }
        if (!rtkpos(&rtk, obsrb, nobsr+nobsb, &nav)) {
            mexPrintf("rtkpos: no solution %s", rtk.errbuf);
        }
        /* copy to output */
        memcpy(&ssats[i*MAXSAT], rtk.ssat, sizeof(rtk.ssat));
        rtkcopy(&rtks[i], &rtk); 
        addsol(&solbuf, &rtk.sol);
    }

    /* output */
    argout[0] = rtk2mxrtk(rtks, nr);
    argout[1] = sol2mxsol(solbuf.data, solbuf.n);
    argout[2] = ssat2mxssat(ssats, times, nr);

    /* free memory */
    free(obsr); free(nobsrlist);
    if (nargin == 5) {
        free(obsb); free(nobsblist);
    }
    rtkfree(&rtk);
    free(rtks);
    free(ssats); free(times);
    freesolbuf(&solbuf);
    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
    
    /* trace file */
    if (sopt.trace > 0) traceclose();
}
