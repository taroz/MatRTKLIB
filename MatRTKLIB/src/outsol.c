/**
 * @file outsol.c
 * @brief Output RTKLIB solution file
 * @author Taro Suzuki
 * @note Wrapper for "outsol" in solution.c
 */

#include "mex_utility.h"

#define NIN 2

/* output reference position -------------------------------------------------*/
static void outrpos(FILE *fp, const double *r, const solopt_t *opt)
{
    double pos[3],dms1[3],dms2[3];
    const char *sep=opt->sep;
    
    trace(3,"outrpos :\n");
    
    if (opt->posf==SOLF_LLH||opt->posf==SOLF_ENU) {
        ecef2pos(r,pos);
        if (opt->degf) {
            deg2dms(pos[0]*R2D,dms1,5);
            deg2dms(pos[1]*R2D,dms2,5);
            fprintf(fp,"%3.0f%s%02.0f%s%08.5f%s%4.0f%s%02.0f%s%08.5f%s%10.4f",
                    dms1[0],sep,dms1[1],sep,dms1[2],sep,dms2[0],sep,dms2[1],
                    sep,dms2[2],sep,pos[2]);
        }
        else {
            fprintf(fp,"%13.9f%s%14.9f%s%10.4f",pos[0]*R2D,sep,pos[1]*R2D,
                    sep,pos[2]);
        }
    }
    else if (opt->posf==SOLF_XYZ) {
        fprintf(fp,"%14.4f%s%14.4f%s%14.4f",r[0],sep,r[1],sep,r[2]);
    }
}

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    FILE *fp;
    char file[512], s1[32], s2[32], errmsg[512];
    ;
    sol_t *sols;
    prcopt_t popt = prcopt_default;
    solopt_t sopt = solopt_default;
    gtime_t t = {0};
    int i, n;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]); /* file name */

    /* input */
    mxGetString(argin[0], file, sizeof(file));
    sols = mxsol2sol(argin[1]);
    n = (int)mxGetScalar(mxGetField(argin[1], 0, "n"));

    if (nargin == 3) {
        mxopt2opt(argin[2], &popt, &sopt);
    }

    /* output velocity */
    if (norm(&sols[0].rr[3], 3) != 0) {
        sopt.outvel = 1;
    }

    /* call RTKLIB function */
    if ((fp = fopen(file, "wb")) == NULL) {
        sprintf(errmsg, "file open error: %s", file);
        mexErrMsgTxt(errmsg);
    }

    /* output header */
    time2str(sols[0].time, s1, 1);
    time2str(sols[n - 1].time, s2, 1);
    fprintf(fp, "%s program   : %s\n", COMMENTH, "RTKLIB MATLAB");
    fprintf(fp, "%s sol start : %s %s\n", COMMENTH, s1, "GPST");
    fprintf(fp, "%s sol end   : %s %s\n", COMMENTH, s2, "GPST");
    if (nargin == 3) {
        outprcopt(fp, &popt);
        if (PMODE_DGPS <= popt.mode && popt.mode <= PMODE_FIXED &&
            popt.mode != PMODE_MOVEB) {
            fprintf(fp, "%s ref pos   :", COMMENTH);
            outrpos(fp, popt.rb, &sopt);
            fprintf(fp, "\n");
        }
    }
    fprintf(fp, "%s\n", COMMENTH);

    outsolhead(fp, &sopt);

    /* output solutions */
    for (i = 0; i < n; i++) {
        outsol(fp, &sols[i], popt.rb, &sopt);
    }
    fclose(fp);
    free(sols);
}