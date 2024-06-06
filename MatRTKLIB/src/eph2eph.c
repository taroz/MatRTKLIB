/**
 * @file eph2eph.c
 * @brief Convert mxArray mxeph/mxgeph/mxpeph to eph_t/geph_t/peph_t, and vice
 * versa
 * @author Taro Suzuki
 */

#include "mex_utility.h"

/* eph2mxeph ----------------------------------------------------------*/
extern mxArray *eph2mxeph(const eph_t *eph, const int n) {
    int i;
    double ep[6];
    mxArray *mxeph, *tgd, *toe, *toc, *ttr;

    /* output struct */
    const char *ephf[] = {
        "sat",  "iode", "iodc", "sva", "svh", "week", "code", "flag", "toe",
        "toc",  "ttr",  "A",    "e",   "i0",  "OMG0", "omg",  "M0",   "deln",
        "OMGd", "idot", "crc",  "crs", "cuc", "cus",  "cic",  "cis",  "toes",
        "fit",  "f0",   "f1",   "f2",  "tgd", "Adot", "ndot"};

    mxeph = mxCreateStructMatrix(n, 1, 34, ephf);

    for (i = 0; i < n; i++) {
        mxSetField(mxeph, i, "sat", mxCreateDoubleScalar(eph[i].sat));
        mxSetField(mxeph, i, "iode", mxCreateDoubleScalar(eph[i].iode));
        mxSetField(mxeph, i, "iodc", mxCreateDoubleScalar(eph[i].iodc));
        mxSetField(mxeph, i, "sva", mxCreateDoubleScalar(eph[i].sva));
        mxSetField(mxeph, i, "svh", mxCreateDoubleScalar(eph[i].svh));
        mxSetField(mxeph, i, "week", mxCreateDoubleScalar(eph[i].week));
        mxSetField(mxeph, i, "code", mxCreateDoubleScalar(eph[i].code));
        mxSetField(mxeph, i, "flag", mxCreateDoubleScalar(eph[i].flag));
        mxSetField(mxeph, i, "A", mxCreateDoubleScalar(eph[i].A));
        mxSetField(mxeph, i, "e", mxCreateDoubleScalar(eph[i].e));
        mxSetField(mxeph, i, "i0", mxCreateDoubleScalar(eph[i].i0));
        mxSetField(mxeph, i, "OMG0", mxCreateDoubleScalar(eph[i].OMG0));
        mxSetField(mxeph, i, "omg", mxCreateDoubleScalar(eph[i].omg));
        mxSetField(mxeph, i, "M0", mxCreateDoubleScalar(eph[i].M0));
        mxSetField(mxeph, i, "deln", mxCreateDoubleScalar(eph[i].deln));
        mxSetField(mxeph, i, "OMGd", mxCreateDoubleScalar(eph[i].OMGd));
        mxSetField(mxeph, i, "idot", mxCreateDoubleScalar(eph[i].idot));
        mxSetField(mxeph, i, "crc", mxCreateDoubleScalar(eph[i].crc));
        mxSetField(mxeph, i, "crs", mxCreateDoubleScalar(eph[i].crs));
        mxSetField(mxeph, i, "cuc", mxCreateDoubleScalar(eph[i].cuc));
        mxSetField(mxeph, i, "cus", mxCreateDoubleScalar(eph[i].cus));
        mxSetField(mxeph, i, "cic", mxCreateDoubleScalar(eph[i].cic));
        mxSetField(mxeph, i, "cis", mxCreateDoubleScalar(eph[i].cis));
        mxSetField(mxeph, i, "toes", mxCreateDoubleScalar(eph[i].toes));
        mxSetField(mxeph, i, "fit", mxCreateDoubleScalar(eph[i].fit));
        mxSetField(mxeph, i, "f0", mxCreateDoubleScalar(eph[i].f0));
        mxSetField(mxeph, i, "f1", mxCreateDoubleScalar(eph[i].f1));
        mxSetField(mxeph, i, "f2", mxCreateDoubleScalar(eph[i].f2));
        mxSetField(mxeph, i, "Adot", mxCreateDoubleScalar(eph[i].Adot));
        mxSetField(mxeph, i, "ndot", mxCreateDoubleScalar(eph[i].ndot));

        /* set tgd */
        tgd = mxCreateDoubleMatrix(1, 4, mxREAL);
        memcpy(mxGetPr(tgd), eph[i].tgd, 4 * sizeof(double));
        mxSetField(mxeph, i, "tgd", tgd);

        /* set toe,toc,ttr */
        toe = mxCreateDoubleMatrix(1, 6, mxREAL);
        time2epoch(eph[i].toe, ep);
        memcpy(mxGetPr(toe), ep, 6 * sizeof(double));
        mxSetField(mxeph, i, "toe", toe);

        toc = mxCreateDoubleMatrix(1, 6, mxREAL);
        time2epoch(eph[i].toc, ep);
        memcpy(mxGetPr(toc), ep, 6 * sizeof(double));
        mxSetField(mxeph, i, "toc", toc);

        ttr = mxCreateDoubleMatrix(1, 6, mxREAL);
        time2epoch(eph[i].ttr, ep);
        memcpy(mxGetPr(ttr), ep, 6 * sizeof(double));
        mxSetField(mxeph, i, "ttr", ttr);
    }

    return mxeph;
}

/* geph2mxgeph ----------------------------------------------------------*/
extern mxArray *geph2mxgeph(const geph_t *geph, const int n) {
    int i;
    double ep[6];
    mxArray *mxgeph, *pos, *vel, *acc, *gtoe, *gtof;

    /* output struct */
    const char *gephf[] = {"sat", "iode", "frq",  "svh",  "sva",
                           "age", "toe",  "tof",  "pos",  "vel",
                           "acc", "taun", "gamn", "dtaun"};

    mxgeph = mxCreateStructMatrix(n, 1, 14, gephf);

    for (i = 0; i < n; i++) {
        mxSetField(mxgeph, i, "sat", mxCreateDoubleScalar(geph[i].sat));
        mxSetField(mxgeph, i, "iode", mxCreateDoubleScalar(geph[i].iode));
        mxSetField(mxgeph, i, "frq", mxCreateDoubleScalar(geph[i].frq));
        mxSetField(mxgeph, i, "svh", mxCreateDoubleScalar(geph[i].svh));
        mxSetField(mxgeph, i, "sva", mxCreateDoubleScalar(geph[i].sva));
        mxSetField(mxgeph, i, "age", mxCreateDoubleScalar(geph[i].age));
        mxSetField(mxgeph, i, "taun", mxCreateDoubleScalar(geph[i].taun));
        mxSetField(mxgeph, i, "gamn", mxCreateDoubleScalar(geph[i].gamn));
        mxSetField(mxgeph, i, "dtaun", mxCreateDoubleScalar(geph[i].dtaun));

        /* set pos,vel,acc */
        pos = mxCreateDoubleMatrix(1, 3, mxREAL);
        memcpy(mxGetPr(pos), geph[i].pos, 3 * sizeof(double));
        mxSetField(mxgeph, i, "pos", pos);
        vel = mxCreateDoubleMatrix(1, 3, mxREAL);
        memcpy(mxGetPr(vel), geph[i].vel, 3 * sizeof(double));
        mxSetField(mxgeph, i, "vel", vel);
        acc = mxCreateDoubleMatrix(1, 3, mxREAL);
        memcpy(mxGetPr(acc), geph[i].acc, 3 * sizeof(double));
        mxSetField(mxgeph, i, "acc", acc);

        /* set toe,tof */
        gtoe = mxCreateDoubleMatrix(1, 6, mxREAL);
        time2epoch(geph[i].toe, ep);
        memcpy(mxGetPr(gtoe), ep, 6 * sizeof(double));
        mxSetField(mxgeph, i, "toe", gtoe);

        gtof = mxCreateDoubleMatrix(1, 6, mxREAL);
        time2epoch(geph[i].tof, ep);
        memcpy(mxGetPr(gtof), ep, 6 * sizeof(double));
        mxSetField(mxgeph, i, "tof", gtof);
    }
    return mxgeph;
}

/* mxeph2eph ----------------------------------------------------------*/
extern void mxeph2eph(const mxArray *mxeph, const int n, eph_t *eph) {
    gtime_t t = {0};
    int i;
    const char *ephf[] = {"sat",  "iode", "iodc", "sva", "svh",  "week", "code",
                          "flag", "A",    "e",    "i0",  "OMG0", "omg",  "M0",
                          "deln", "OMGd", "idot", "crc", "crs",  "cuc",  "cus",
                          "cic",  "cis",  "toes", "fit", "f0",   "f1",   "f2",
                          "Adot", "ndot", "toe",  "toc", "ttr",  "tgd"};

    /* check eph struct */
    mxCheckStruct(mxeph, ephf, 34);

    for (i = 0; i < n; i++) {
        eph[i].sat = (int)mxGetScalar(mxGetField(mxeph, i, "sat"));
        eph[i].iode = (int)mxGetScalar(mxGetField(mxeph, i, "iode"));
        eph[i].iodc = (int)mxGetScalar(mxGetField(mxeph, i, "iodc"));
        eph[i].sva = (int)mxGetScalar(mxGetField(mxeph, i, "sva"));
        eph[i].svh = (int)mxGetScalar(mxGetField(mxeph, i, "svh"));
        eph[i].week = (int)mxGetScalar(mxGetField(mxeph, i, "week"));
        eph[i].code = (int)mxGetScalar(mxGetField(mxeph, i, "code"));
        eph[i].flag = (int)mxGetScalar(mxGetField(mxeph, i, "flag"));
        eph[i].A = (double)mxGetScalar(mxGetField(mxeph, i, "A"));
        eph[i].e = (double)mxGetScalar(mxGetField(mxeph, i, "e"));
        eph[i].i0 = (double)mxGetScalar(mxGetField(mxeph, i, "i0"));
        eph[i].OMG0 = (double)mxGetScalar(mxGetField(mxeph, i, "OMG0"));
        eph[i].omg = (double)mxGetScalar(mxGetField(mxeph, i, "omg"));
        eph[i].M0 = (double)mxGetScalar(mxGetField(mxeph, i, "M0"));
        eph[i].deln = (double)mxGetScalar(mxGetField(mxeph, i, "deln"));
        eph[i].OMGd = (double)mxGetScalar(mxGetField(mxeph, i, "OMGd"));
        eph[i].idot = (double)mxGetScalar(mxGetField(mxeph, i, "idot"));
        eph[i].crc = (double)mxGetScalar(mxGetField(mxeph, i, "crc"));
        eph[i].crs = (double)mxGetScalar(mxGetField(mxeph, i, "crs"));
        eph[i].cuc = (double)mxGetScalar(mxGetField(mxeph, i, "cuc"));
        eph[i].cus = (double)mxGetScalar(mxGetField(mxeph, i, "cus"));
        eph[i].cic = (double)mxGetScalar(mxGetField(mxeph, i, "cic"));
        eph[i].cis = (double)mxGetScalar(mxGetField(mxeph, i, "cis"));
        eph[i].toes = (double)mxGetScalar(mxGetField(mxeph, i, "toes"));
        eph[i].fit = (double)mxGetScalar(mxGetField(mxeph, i, "fit"));
        eph[i].f0 = (double)mxGetScalar(mxGetField(mxeph, i, "f0"));
        eph[i].f1 = (double)mxGetScalar(mxGetField(mxeph, i, "f1"));
        eph[i].f2 = (double)mxGetScalar(mxGetField(mxeph, i, "f2"));
        eph[i].Adot = (double)mxGetScalar(mxGetField(mxeph, i, "Adot"));
        eph[i].ndot = (double)mxGetScalar(mxGetField(mxeph, i, "ndot"));
        eph[i].toe = epoch2time((double *)mxGetPr(mxGetField(mxeph, i, "toe")));
        eph[i].toc = epoch2time((double *)mxGetPr(mxGetField(mxeph, i, "toc")));
        eph[i].ttr = epoch2time((double *)mxGetPr(mxGetField(mxeph, i, "ttr")));
        memcpy(eph[i].tgd, (double *)mxGetPr(mxGetField(mxeph, i, "tgd")),
               4 * sizeof(double));
    }
}

/* mxgeph2geph ----------------------------------------------------------*/
extern void mxgeph2geph(const mxArray *mxgeph, const int n, geph_t *geph) {
    int i;
    const char *gephf[] = {"sat",  "iode",  "frq", "svh", "sva", "age", "taun",
                           "gamn", "dtaun", "toe", "tof", "pos", "vel", "acc"};

    /* check geph struct */
    mxCheckStruct(mxgeph, gephf, 14);

    for (i = 0; i < n; i++) {
        geph[i].sat = (int)mxGetScalar(mxGetField(mxgeph, i, "sat"));
        geph[i].iode = (int)mxGetScalar(mxGetField(mxgeph, i, "iode"));
        geph[i].frq = (int)mxGetScalar(mxGetField(mxgeph, i, "frq"));
        geph[i].svh = (int)mxGetScalar(mxGetField(mxgeph, i, "svh"));
        geph[i].sva = (int)mxGetScalar(mxGetField(mxgeph, i, "sva"));
        geph[i].age = (int)mxGetScalar(mxGetField(mxgeph, i, "age"));
        geph[i].taun = (double)mxGetScalar(mxGetField(mxgeph, i, "taun"));
        geph[i].gamn = (double)mxGetScalar(mxGetField(mxgeph, i, "gamn"));
        geph[i].dtaun = (double)mxGetScalar(mxGetField(mxgeph, i, "dtaun"));
        geph[i].toe =
            epoch2time((double *)mxGetPr(mxGetField(mxgeph, i, "toe")));
        geph[i].tof =
            epoch2time((double *)mxGetPr(mxGetField(mxgeph, i, "tof")));
        memcpy(geph[i].pos, (double *)mxGetPr(mxGetField(mxgeph, i, "pos")),
               3 * sizeof(double));
        memcpy(geph[i].vel, (double *)mxGetPr(mxGetField(mxgeph, i, "vel")),
               3 * sizeof(double));
        memcpy(geph[i].acc, (double *)mxGetPr(mxGetField(mxgeph, i, "acc")),
               3 * sizeof(double));
    }
}

/* peph2mxpeph ----------------------------------------------------------*/
extern mxArray *peph2mxpeph(const peph_t *peph, const int n) {
    int i, j, k;
    double ep[6], *pos, *vel, *std, *vst, *cov, *vco;
    mxArray *mxpeph, *mxtime, *mxpos, *mxstd, *mxvel, *mxvst, *mxcov, *mxvco;

    /* output struct */
    const char *pephf[] = {"time", "index", "pos", "std",
                           "vel",  "vst",   "cov", "vco"};

    mxpeph = mxCreateStructMatrix(n, 1, 8, pephf);

    for (i = 0; i < n; i++) {
        /* set time */
        mxtime = mxCreateDoubleMatrix(1, 6, mxREAL);
        time2epoch(peph[i].time, ep);
        memcpy(mxGetPr(mxtime), ep, 6 * sizeof(double));
        mxSetField(mxpeph, i, "time", mxtime);

        /* index */
        mxSetField(mxpeph, i, "index", mxCreateDoubleScalar(peph[i].index));

        /* set pos,vel,acc */
        mxpos = mxCreateDoubleMatrix(MAXSAT, 4, mxREAL);
        mxstd = mxCreateDoubleMatrix(MAXSAT, 4, mxREAL);
        mxvel = mxCreateDoubleMatrix(MAXSAT, 4, mxREAL);
        mxvst = mxCreateDoubleMatrix(MAXSAT, 4, mxREAL);
        mxcov = mxCreateDoubleMatrix(MAXSAT, 3, mxREAL);
        mxvco = mxCreateDoubleMatrix(MAXSAT, 3, mxREAL);

        pos = (double *)mxGetPr(mxpos);
        std = (double *)mxGetPr(mxstd);
        vel = (double *)mxGetPr(mxvel);
        vst = (double *)mxGetPr(mxvst);
        cov = (double *)mxGetPr(mxcov);
        vco = (double *)mxGetPr(mxvco);

        for (j = 0; j < MAXSAT; j++) {
            for (k = 0; k < 4; k++) {
                pos[MAXSAT * k + j] = peph[i].pos[j][k];
                std[MAXSAT * k + j] = (double)peph[i].std[j][k];
                vel[MAXSAT * k + j] = peph[i].vel[j][k];
                vst[MAXSAT * k + j] = (double)peph[i].vst[j][k];
            }
            for (k = 0; k < 3; k++) {
                cov[MAXSAT * k + j] = (double)peph[i].cov[j][k];
                vco[MAXSAT * k + j] = (double)peph[i].vco[j][k];
            }
        }
        mxSetField(mxpeph, i, "pos", mxpos);
        mxSetField(mxpeph, i, "std", mxstd);
        mxSetField(mxpeph, i, "vel", mxvel);
        mxSetField(mxpeph, i, "vst", mxvst);
        mxSetField(mxpeph, i, "cov", mxcov);
        mxSetField(mxpeph, i, "vco", mxvco);
    }
    return mxpeph;
}

/* mxpeph2peph ----------------------------------------------------------*/
extern void mxpeph2peph(const mxArray *mxpeph, const int n, peph_t *peph) {
    int i, j, k;
    double *pos, *std, *vel, *vst, *cov, *vco;
    const char *pephf[] = {"time", "index", "pos", "std",
                           "vel",  "vst",   "cov", "vco"};

    /* check peph struct */
    mxCheckStruct(mxpeph, pephf, 8);

    for (i = 0; i < n; i++) {
        peph[i].time =
            epoch2time((double *)mxGetPr(mxGetField(mxpeph, i, "time")));
        peph[i].index = (int)mxGetScalar(mxGetField(mxpeph, i, "index"));

        pos = (double *)mxGetPr(mxGetField(mxpeph, i, "pos"));
        std = (double *)mxGetPr(mxGetField(mxpeph, i, "std"));
        vel = (double *)mxGetPr(mxGetField(mxpeph, i, "vel"));
        vst = (double *)mxGetPr(mxGetField(mxpeph, i, "vst"));
        cov = (double *)mxGetPr(mxGetField(mxpeph, i, "cov"));
        vco = (double *)mxGetPr(mxGetField(mxpeph, i, "vco"));

        for (j = 0; j < MAXSAT; j++) {
            for (k = 0; k < 4; k++) {
                peph[i].pos[j][k] = pos[MAXSAT * k + j];
                peph[i].std[j][k] = (float)std[MAXSAT * k + j];
                peph[i].vel[j][k] = vel[MAXSAT * k + j];
                peph[i].vst[j][k] = (float)vst[MAXSAT * k + j];
            }
            for (k = 0; k < 3; k++) {
                peph[i].cov[j][k] = (float)cov[MAXSAT * k + j];
                peph[i].vco[j][k] = (float)vco[MAXSAT * k + j];
            }
        }
    }
}

/* pclk2mxpclk ----------------------------------------------------------*/
extern mxArray *pclk2mxpclk(const pclk_t *pclk, const int n) {
    int i, j;
    double ep[6], *clk, *std;
    mxArray *mxpclk, *mxtime, *mxclk, *mxstd;

    /* output struct */
    const char *pclkf[] = {"time", "index", "clk", "std"};

    mxpclk = mxCreateStructMatrix(n, 1, 4, pclkf);

    for (i = 0; i < n; i++) {
        /* set time */
        mxtime = mxCreateDoubleMatrix(1, 6, mxREAL);
        time2epoch(pclk[i].time, ep);
        memcpy(mxGetPr(mxtime), ep, 6 * sizeof(double));
        mxSetField(mxpclk, i, "time", mxtime);

        /* index */
        mxSetField(mxpclk, i, "index", mxCreateDoubleScalar(pclk[i].index));

        /* clk std */
        mxclk = mxCreateDoubleMatrix(1, MAXSAT, mxREAL);
        mxstd = mxCreateDoubleMatrix(1, MAXSAT, mxREAL);

        clk = (double *)mxGetPr(mxclk);
        std = (double *)mxGetPr(mxstd);

        for (j = 0; j < MAXSAT; j++) {
            clk[j] = pclk[i].clk[j][0];
            std[j] = (double)pclk[i].std[j][0];
        }
        mxSetField(mxpclk, i, "clk", mxclk);
        mxSetField(mxpclk, i, "std", mxstd);
    }
    return mxpclk;
}

/* mxpclk2pclk ----------------------------------------------------------*/
extern void mxpclk2pclk(const mxArray *mxpclk, const int n, pclk_t *pclk) {
    int i, j;
    double *clk, *std;
    const char *pclkf[] = {"time", "index", "clk", "std"};

    /* check pclk struct */
    mxCheckStruct(mxpclk, pclkf, 4);

    for (i = 0; i < n; i++) {
        pclk[i].time =
            epoch2time((double *)mxGetPr(mxGetField(mxpclk, i, "time")));
        pclk[i].index = (int)mxGetScalar(mxGetField(mxpclk, i, "index"));

        clk = (double *)mxGetPr(mxGetField(mxpclk, i, "clk"));
        std = (double *)mxGetPr(mxGetField(mxpclk, i, "std"));

        for (j = 0; j < MAXSAT; j++) {
            pclk[i].clk[j][0] = clk[j];
            pclk[i].std[j][0] = (float)std[j];
        }
    }
}
