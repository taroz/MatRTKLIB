/**
 * @file opt2opt.c
 * @brief Convert mxArray mxopt to prcopt_t,solopt_t, and vice versa
 * @author Taro Suzuki
 */

#include "mex_utility.h"

/* opt2mxopt ----------------------------------------------------------*/
extern mxArray *opt2mxopt(const prcopt_t *popt, const solopt_t *sopt) {
    mxArray *mxopt, *mxpos1, *mxpos2, *mxout, *mxstats, *mxant, *mxmisc;
    mxArray *mxexsat, *snrmask_L1, *snrmask_L2, *snrmask_L5;
    mxArray *rovpos, *refpos, *rovdenu, *refdenu;
    double rovpos_[3]={0},refpos_[3]={0};
    int i, j, nexsat, postype;
    char satstr[64];

    /* output struct */
    const char *optf[] = {"pos1", "pos2", "out", "stats", "ant", "misc"};
    const char *pos1f[] = {
        "posmode",   "navsys",     "frequency",  "elmask",     "snrmask_r",
        "snrmask_b", "snrmask_L1", "snrmask_L2", "snrmask_L5", "tidecorr",
        "ionoopt",   "tropopt",    "ephopt",     "raim_fde",   "exclsats"};
    const char *pos2f[] = {"armode",    "gloarmode", "bdsarmode",  "arthres",
                           "arlockcnt", "aroutcnt", "armaxiter", "filteriter", "maxinno"};
    const char *outf[] = {"solformat", "timeformat","trace"};
    const char *statsf[] = {"eratio1", "eratio2", "errphase", "errphaseel"};
    const char *antf[] = {"rovtype", "rovpos", "rovant", "rovdenu",
                          "reftype", "refpos", "refant", "refdenu"};
    const char *miscf[] = {"timeinterp"};
    mxopt = mxCreateStructMatrix(1, 1, 6, optf);
    mxpos1 = mxCreateStructMatrix(1, 1, 15, pos1f);
    mxpos2 = mxCreateStructMatrix(1, 1, 9, pos2f);
    mxout = mxCreateStructMatrix(1, 1, 3, outf);
    mxstats = mxCreateStructMatrix(1, 1, 4, statsf);
    mxant = mxCreateStructMatrix(1, 1, 8, antf);
    mxmisc = mxCreateStructMatrix(1, 1, 1, miscf);

    /* pos1 */
    mxSetField(mxpos1, 0, "posmode", mxCreateDoubleScalar((double)popt->mode));
    mxSetField(mxpos1, 0, "navsys", mxCreateDoubleScalar((double)popt->navsys));
    mxSetField(mxpos1, 0, "frequency", mxCreateDoubleScalar((double)popt->nf));
    mxSetField(mxpos1, 0, "elmask",
               mxCreateDoubleScalar(R2D * (double)popt->elmin));
    mxSetField(mxpos1, 0, "snrmask_r",
               mxCreateDoubleScalar((double)popt->snrmask.ena[0]));
    mxSetField(mxpos1, 0, "snrmask_b",
               mxCreateDoubleScalar((double)popt->snrmask.ena[1]));
    /* snrmask */
    snrmask_L1 = mxCreateDoubleMatrix(1, 9, mxREAL);
    memcpy(mxGetPr(snrmask_L1), popt->snrmask.mask[0], 9 * sizeof(double));
    mxSetField(mxpos1, 0, "snrmask_L1", snrmask_L1);
    snrmask_L2 = mxCreateDoubleMatrix(1, 9, mxREAL);
    memcpy(mxGetPr(snrmask_L2), popt->snrmask.mask[1], 9 * sizeof(double));
    mxSetField(mxpos1, 0, "snrmask_L2", snrmask_L2);
    snrmask_L5 = mxCreateDoubleMatrix(1, 9, mxREAL);
    memcpy(mxGetPr(snrmask_L5), popt->snrmask.mask[2], 9 * sizeof(double));
    mxSetField(mxpos1, 0, "snrmask_L5", snrmask_L5);
    mxSetField(mxpos1, 0, "tidecorr",
               mxCreateDoubleScalar((double)popt->tidecorr));
    mxSetField(mxpos1, 0, "ionoopt",
               mxCreateDoubleScalar((double)popt->ionoopt));
    mxSetField(mxpos1, 0, "tropopt",
               mxCreateDoubleScalar((double)popt->tropopt));
    mxSetField(mxpos1, 0, "ephopt", 
               mxCreateDoubleScalar((double)popt->sateph));
    mxSetField(mxpos1, 0, "raim_fde",
               mxCreateDoubleScalar((double)popt->posopt[4]));
    /* exsat */
    for (i = 0, nexsat = 0; i < MAXSAT; i++) {
        if (popt->exsats[i]) nexsat++;
    }
    mxexsat = mxCreateCellMatrix(1, nexsat);
    for (i = 0, j = 0; i < MAXSAT; i++) {
        if (popt->exsats[i]) {
            satno2id(i + 1, satstr);
            mxSetCell(mxexsat, j, mxCreateString(satstr));
            j++;
        }
    }
    mxSetField(mxpos1, 0, "exclsats", mxexsat);
    mxSetField(mxopt, 0, "pos1", mxpos1);

    /* pos2 */
    mxSetField(mxpos2, 0, "armode", mxCreateDoubleScalar((double)popt->modear));
    mxSetField(mxpos2, 0, "gloarmode",
               mxCreateDoubleScalar((double)popt->glomodear));
    mxSetField(mxpos2, 0, "bdsarmode",
               mxCreateDoubleScalar((double)popt->bdsmodear));
    mxSetField(mxpos2, 0, "arthres",
               mxCreateDoubleScalar((double)popt->thresar[0]));
    mxSetField(mxpos2, 0, "arlockcnt",
               mxCreateDoubleScalar((double)popt->minlock));
    mxSetField(mxpos2, 0, "aroutcnt",
               mxCreateDoubleScalar((double)popt->maxout));
    mxSetField(mxpos2, 0, "armaxiter",
               mxCreateDoubleScalar((double)popt->armaxiter));
    mxSetField(mxpos2, 0, "filteriter",
               mxCreateDoubleScalar((double)popt->niter));
    mxSetField(mxpos2, 0, "maxinno",
               mxCreateDoubleScalar((double)popt->maxinno));
    mxSetField(mxopt, 0, "pos2", mxpos2);
    
    /* out */
    mxSetField(mxout, 0, "solformat", mxCreateDoubleScalar((double)sopt->posf));
    mxSetField(mxout, 0, "timeformat", mxCreateDoubleScalar((double)sopt->timef));
    mxSetField(mxout, 0, "trace", mxCreateDoubleScalar((double)sopt->trace));
    mxSetField(mxopt, 0, "out", mxout);

    /* stats */
    mxSetField(mxstats, 0, "eratio1",
               mxCreateDoubleScalar((double)popt->eratio[0]));
    mxSetField(mxstats, 0, "eratio2",
               mxCreateDoubleScalar((double)popt->eratio[1]));
    mxSetField(mxstats, 0, "errphase",
               mxCreateDoubleScalar((double)popt->err[1]));
    mxSetField(mxstats, 0, "errphaseel",
               mxCreateDoubleScalar((double)popt->err[2]));
    mxSetField(mxopt, 0, "stats", mxstats);

    /* ant */
    /* rover */
    postype = popt->rovpos;
    if (postype == 0) {
        ecef2pos(popt->ru, rovpos_); 
        rovpos_[0] *= R2D;
        rovpos_[1] *= R2D;
    } else {
        postype += 1;
    }
    rovpos = mxCreateDoubleMatrix(1, 3, mxREAL);
    memcpy(mxGetPr(rovpos), rovpos_, 3 * sizeof(double));
    mxSetField(mxant, 0, "rovpos", rovpos);

    mxSetField(mxant, 0, "rovtype", mxCreateDoubleScalar((double)postype));
    mxSetField(mxant, 0, "rovant", mxCreateString(popt->anttype[0]));
    rovdenu = mxCreateDoubleMatrix(1, 3, mxREAL);
    memcpy(mxGetPr(rovdenu), popt->antdel[0], 3 * sizeof(double));
    mxSetField(mxant, 0, "rovdenu", rovdenu);
    
    /* base */
    postype = popt->refpos;
    if (postype == 0) {
        ecef2pos(popt->rb, refpos_); 
        refpos_[0] *= R2D;
        refpos_[1] *= R2D;
    } else {
        postype += 1;
    }
    refpos = mxCreateDoubleMatrix(1, 3, mxREAL);
    memcpy(mxGetPr(refpos), refpos_, 3 * sizeof(double));
    mxSetField(mxant, 0, "refpos", refpos);
    
    mxSetField(mxant, 0, "reftype", mxCreateDoubleScalar((double)postype));
    mxSetField(mxant, 0, "refant", mxCreateString(popt->anttype[1]));
    refdenu = mxCreateDoubleMatrix(1, 3, mxREAL);
    memcpy(mxGetPr(refdenu), popt->antdel[1], 3 * sizeof(double));
    mxSetField(mxant, 0, "refdenu", refdenu);

    mxSetField(mxopt, 0, "ant", mxant);

    /* misc */
    mxSetField(mxmisc, 0, "timeinterp",
               mxCreateDoubleScalar((double)popt->intpref));
    mxSetField(mxopt, 0, "misc", mxmisc);

    return mxopt;
}

/* mxopt2opt ----------------------------------------------------------*/
extern void mxopt2opt(const mxArray *mxopt, prcopt_t *popt, solopt_t *sopt) {
    int i, sat, nexsat;
    double antpos[3];
    char id[4];
    mxArray *mxpos1, *mxpos2, *mxout, *mxstats, *mxant, *mxmisc, *mxexsat;

    const char *optf[] = {"pos1", "pos2", "out", "stats", "ant", "misc"};
    const char *pos1f[] = {
        "posmode",   "navsys",     "frequency",  "elmask",     "snrmask_r",
        "snrmask_b", "snrmask_L1", "snrmask_L2", "snrmask_L5", "tidecorr",
        "ionoopt",   "tropopt",    "ephopt",     "raim_fde",   "exclsats"};
    const char *pos2f[] = {"armode",    "gloarmode", "bdsarmode",  "arthres",
                           "arlockcnt", "aroutcnt", "armaxiter", "filteriter", "maxinno"};
    const char *outf[] = {"solformat", "timeformat","trace"};
    const char *statsf[] = {"eratio1", "eratio2", "errphase", "errphaseel"};
    const char *antf[] = {"rovtype", "rovpos", "rovant", "rovdenu",
                          "reftype", "refpos", "refant", "refdenu"};
    const char *miscf[] = {"timeinterp"};

    /* check opt struct */
    mxCheckStruct(mxopt, optf, 6);

    /* input struct */
    mxpos1 = mxGetField(mxopt, 0, "pos1");
    mxpos2 = mxGetField(mxopt, 0, "pos2");
    mxout = mxGetField(mxopt, 0, "out");
    mxstats = mxGetField(mxopt, 0, "stats");
    mxant = mxGetField(mxopt, 0, "ant");
    mxmisc = mxGetField(mxopt, 0, "misc");

    /* check each struct */
    mxCheckStruct(mxpos1, pos1f, 15);
    mxCheckStruct(mxpos2, pos2f, 9);
    mxCheckStruct(mxout, outf, 3);
    mxCheckStruct(mxstats, statsf, 4);
    mxCheckStruct(mxant, antf, 8);
    mxCheckStruct(mxmisc, miscf, 1);

    /* pos1 */
    popt->mode = (int)mxGetScalar(mxGetField(mxpos1, 0, "posmode"));
    popt->navsys = (int)mxGetScalar(mxGetField(mxpos1, 0, "navsys"));
    popt->nf = (int)mxGetScalar(mxGetField(mxpos1, 0, "frequency"));
    popt->elmin = D2R * (double)mxGetScalar(mxGetField(mxpos1, 0, "elmask"));
    popt->snrmask.ena[0] = (int)mxGetScalar(mxGetField(mxpos1, 0, "snrmask_r"));
    popt->snrmask.ena[1] = (int)mxGetScalar(mxGetField(mxpos1, 0, "snrmask_b"));
    memcpy(popt->snrmask.mask[0],
           (double *)mxGetPr(mxGetField(mxpos1, 0, "snrmask_L1")),
           9 * sizeof(double));
    memcpy(popt->snrmask.mask[1],
           (double *)mxGetPr(mxGetField(mxpos1, 0, "snrmask_L2")),
           9 * sizeof(double));
    memcpy(popt->snrmask.mask[2],
           (double *)mxGetPr(mxGetField(mxpos1, 0, "snrmask_L5")),
           9 * sizeof(double));
    popt->tidecorr = (int)mxGetScalar(mxGetField(mxpos1, 0, "tidecorr"));
    popt->ionoopt = (int)mxGetScalar(mxGetField(mxpos1, 0, "ionoopt"));
    popt->tropopt = (int)mxGetScalar(mxGetField(mxpos1, 0, "tropopt"));
    popt->sateph = (int)mxGetScalar(mxGetField(mxpos1, 0, "ephopt"));
    popt->posopt[4] = (int)mxGetScalar(mxGetField(mxpos1, 0, "raim_fde"));

    /* exsat */
    mxexsat = mxGetField(mxpos1, 0, "exclsats");
    nexsat = (int)mxGetN(mxexsat);
    for (i = 0; i < nexsat; i++) {
        mxGetString(mxGetCell(mxexsat, i), id, 4);
        if (!(sat = satid2no(id))) continue;
        popt->exsats[sat - 1] = 1;
    }

    /* pos2 */
    popt->modear = (int)mxGetScalar(mxGetField(mxpos2, 0, "armode"));
    popt->glomodear = (int)mxGetScalar(mxGetField(mxpos2, 0, "gloarmode"));
    popt->bdsmodear = (int)mxGetScalar(mxGetField(mxpos2, 0, "bdsarmode"));
    popt->thresar[0] = mxGetScalar(mxGetField(mxpos2, 0, "arthres"));
    popt->minlock = (int)mxGetScalar(mxGetField(mxpos2, 0, "arlockcnt"));
    popt->maxout = (int)mxGetScalar(mxGetField(mxpos2, 0, "aroutcnt"));
    popt->armaxiter = (int)mxGetScalar(mxGetField(mxpos2, 0, "armaxiter"));
    popt->niter = (int)mxGetScalar(mxGetField(mxpos2, 0, "filteriter"));
    popt->maxinno = mxGetScalar(mxGetField(mxpos2, 0, "maxinno"));

    /* out */
    sopt->posf = (int)mxGetScalar(mxGetField(mxout, 0, "solformat"));
    sopt->timef = (int)mxGetScalar(mxGetField(mxout, 0, "timeformat"));
    sopt->trace = (int)mxGetScalar(mxGetField(mxout, 0, "trace"));

    /* stats */
    popt->eratio[0] = mxGetScalar(mxGetField(mxstats, 0, "eratio1"));
    popt->eratio[1] = mxGetScalar(mxGetField(mxstats, 0, "eratio2"));
    popt->err[1] = mxGetScalar(mxGetField(mxstats, 0, "errphase"));
    popt->err[2] = mxGetScalar(mxGetField(mxstats, 0, "errphaseel"));

    /* ant */
    /* rover */
    popt->rovpos = (int)mxGetScalar(mxGetField(mxant, 0, "rovtype"));
    memcpy(antpos, (double *)mxGetPr(mxGetField(mxant, 0, "rovpos")), 3 * sizeof(double));
    if (popt->rovpos == 0) { /* lat/lon/hgt */
        antpos[0] *= D2R;
        antpos[1] *= D2R;
        pos2ecef(antpos, popt->ru);
    } else if (popt->rovpos == 1) { /* xyz-ecef */
        popt->rovpos = 0;
        popt->ru[0] = antpos[0];
        popt->ru[1] = antpos[1];
        popt->ru[2] = antpos[2];
    } else {
        popt->rovpos -= 1;
    }
    memcpy(popt->antdel[0], (double *)mxGetPr(mxGetField(mxant, 0, "rovdenu")), 3 * sizeof(double));
    mxGetString(mxGetField(mxant, 0, "rovant"), popt->anttype[0], sizeof(popt->anttype[0]));
    
     /* base */
    popt->refpos = (int)mxGetScalar(mxGetField(mxant, 0, "reftype"));
    memcpy(antpos, (double *)mxGetPr(mxGetField(mxant, 0, "refpos")), 3 * sizeof(double));
    if (popt->refpos == 0) { /* lat/lon/hgt */
        antpos[0] *= D2R;
        antpos[1] *= D2R;
        pos2ecef(antpos, popt->rb);
    } else if (popt->refpos == 1) { /* xyz-ecef */
        popt->refpos = 0;
        popt->rb[0] = antpos[0];
        popt->rb[1] = antpos[1];
        popt->rb[2] = antpos[2];
    } else {
        popt->refpos -= 1;
    }
    memcpy(popt->antdel[1], (double *)mxGetPr(mxGetField(mxant, 0, "refdenu")), 3 * sizeof(double));
    mxGetString(mxGetField(mxant, 0, "refant"), popt->anttype[1], sizeof(popt->anttype[1]));

    /* misc */
    popt->intpref = (int)mxGetScalar(mxGetField(mxmisc, 0, "timeinterp"));
}
