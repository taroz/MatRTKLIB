/**
 * @file solstat2solstat.c
 * @brief Convert mxArray solstat_t to mxssolstat
 * @author Taro Suzuki
 */

#include "mex_utility.h"

/* solstat2mxsolstat
 * ----------------------------------------------------------*/
extern mxArray *solstat2mxsolstat(const solstat_t *stat, const int nstat) {
    mxArray *mxstat, *mxL;
    int i, j, k = 0, sat, frq, isat, ifrq, idx, vss[MAXSAT] = {0}, n = 0,
              nsat = 0, nfrq = 0, vfrq[MAXFREQ] = {0}, *timecnt;
    double *resp, *resc, *vsat, *snr, *fix, *slip, *half, *lock, *outc, *slipc,
        *rejc, *eps, ep[6], *azs, *els, satlist[MAXSAT] = {0};
    gtime_t t_prev;
    mxArray *mxsat, *mxep, *mxaz, *mxel, *mxresp, *mxresc, *mxvsat, *mxsnr,
        *mxfix, *mxslip, *mxhalf, *mxlock, *mxoutc, *mxslipc, *mxrejc;

    /* output struct */
    const char *freqstr[] = {"L1", "L2", "L5", "L6", "L7", "L8", "L9"};
    const char *statf[] = {"n",  "nsat", "sat", "ep", "az", "el", "L1",
                           "L2", "L5",   "L6",  "L7", "L8", "L9"};
    const char *freqf[] = {"resp", "resc", "vsat", "snr",   "fix", "slip",
                           "half", "lock", "outc", "slipc", "rejc"};

    if (!(timecnt = (int *)calloc(nstat, sizeof(int)))) {
        mexErrMsgTxt("solstat2mxsolstat: memory allocation error");
    }
    /* count satellites, frequencies, and times */
    for (i = 0; i < nstat; i++) {
        /* count satellites */
        sat = stat[i].sat;
        if (vss[sat - 1] == 0) {
            vss[sat - 1] = nsat + 1;
            satlist[nsat++] = (double)sat;
        }
        /* count frequency*/
        frq = stat[i].frq;
        if (vfrq[frq - 1] == 0) {
            vfrq[frq - 1] = nfrq + 1;
            nfrq++;
        }
        /* count times */
        if (i == 0) t_prev = stat[i].time;
        if (timediff(stat[i].time, t_prev) > 0) n++;
        timecnt[n]++;
        t_prev = stat[i].time;
    }
    //mexPrintf("solstat2mxsolstat: nsat=%d n=%d  nfrq=%d\n", nsat, n, nfrq);

    mxstat = mxCreateStructMatrix(1, 1, 13, statf);
    mxSetField(mxstat, 0, "n", mxCreateDoubleScalar(n));
    mxSetField(mxstat, 0, "nsat", mxCreateDoubleScalar(nsat));
    mxsat = mxCreateDoubleMatrix(1, nsat, mxREAL);
    memcpy(mxGetPr(mxsat), satlist, nsat * sizeof(double));
    mxSetField(mxstat, 0, "sat", mxsat);

    mxep = mxCreateDoubleMatrix(n, 6, mxREAL);
    eps = mxGetPr(mxep);
    mxaz = mxCreateDoubleMatrix(n, nsat, mxREAL);
    azs = mxGetPr(mxaz);
    mxSetNaN(azs, n * nsat);
    mxel = mxCreateDoubleMatrix(n, nsat, mxREAL);
    els = mxGetPr(mxel);
    mxSetNaN(els, n * nsat);

    if (!(resp = (double *)malloc(nfrq * nsat * n * sizeof(double))) ||
        !(resc = (double *)malloc(nfrq * nsat * n * sizeof(double))) ||
        !(vsat = (double *)malloc(nfrq * nsat * n * sizeof(double))) ||
        !(snr = (double *)malloc(nfrq * nsat * n * sizeof(double))) ||
        !(fix = (double *)malloc(nfrq * nsat * n * sizeof(double))) ||
        !(slip = (double *)malloc(nfrq * nsat * n * sizeof(double))) ||
        !(half = (double *)malloc(nfrq * nsat * n * sizeof(double))) ||
        !(lock = (double *)malloc(nfrq * nsat * n * sizeof(double))) ||
        !(outc = (double *)malloc(nfrq * nsat * n * sizeof(double))) ||
        !(slipc = (double *)malloc(nfrq * nsat * n * sizeof(double))) ||
        !(rejc = (double *)malloc(nfrq * nsat * n * sizeof(double)))) {
        mexErrMsgTxt("solstat2mxsolstat: memory allocation error");
    }
    mxSetNaN(resp, nfrq * n * nsat);
    mxSetNaN(resc, nfrq * n * nsat);
    mxSetNaN(vsat, nfrq * n * nsat);
    mxSetNaN(snr, nfrq * n * nsat);
    mxSetNaN(fix, nfrq * n * nsat);
    mxSetNaN(slip, nfrq * n * nsat);
    mxSetNaN(half, nfrq * n * nsat);
    mxSetNaN(lock, nfrq * n * nsat);
    mxSetNaN(outc, nfrq * n * nsat);
    mxSetNaN(slipc, nfrq * n * nsat);
    mxSetNaN(rejc, nfrq * n * nsat);

    for (i = 0; i < n; i++) {
        /* ep */
        time2epoch(stat[k].time, ep);
        eps[i + n * 0] = ep[0];
        eps[i + n * 1] = ep[1];
        eps[i + n * 2] = ep[2];
        eps[i + n * 3] = ep[3];
        eps[i + n * 4] = ep[4];
        eps[i + n * 5] = ep[5];
        
        for (j = 0; j < timecnt[i]; j++, k++) {
            isat = vss[stat[k].sat - 1] - 1;
            /* az, el */
            if (stat[k].frq == 1) {
                azs[i + n * isat] = stat[k].el * R2D;
                els[i + n * isat] = stat[k].el * R2D;
            }
            /* frquency struct */
            ifrq = vfrq[stat[k].frq - 1] - 1;
            idx = i + n * isat + n * nsat * ifrq;
            resp[idx] = stat[k].resp;
            resc[idx] = stat[k].resc;
            vsat[idx] = stat[k].flag >> 5;
            slip[idx] = (stat[k].flag >>3) & 0x3;;
            fix[idx] = stat[k].flag & 0x7;
            snr[idx] = stat[k].snr * SNR_UNIT;
            lock[idx] = stat[k].lock;
            outc[idx] = stat[k].outc;
            slipc[idx] = stat[k].slipc;
            rejc[idx] = stat[k].rejc;
        }
    }
    mxSetField(mxstat, 0, "ep", mxep);
    mxSetField(mxstat, 0, "az", mxaz);
    mxSetField(mxstat, 0, "el", mxel);

    for (i = 0; i < NFREQ; i++) {
        if (vfrq[i] > 0) {
            ifrq = vfrq[i]-1;
            mxL = mxCreateStructMatrix(1, 1, 11, freqf);

            mxresp = mxCreateDoubleMatrix(n, nsat, mxREAL);
            memcpy(mxGetPr(mxresp), &resp[ifrq * n * nsat], n * nsat * sizeof(double));
            mxSetField(mxL, 0, "resp", mxresp);

            mxresc = mxCreateDoubleMatrix(n, nsat, mxREAL);
            memcpy(mxGetPr(mxresc), &resc[ifrq * n * nsat], n * nsat * sizeof(double));
            mxSetField(mxL, 0, "resc", mxresc);
            
            mxvsat = mxCreateDoubleMatrix(n, nsat, mxREAL);
            memcpy(mxGetPr(mxvsat), &vsat[ifrq * n * nsat], n * nsat * sizeof(double));
            mxSetField(mxL, 0, "vsat", mxvsat);
            
            mxsnr = mxCreateDoubleMatrix(n, nsat, mxREAL);
            memcpy(mxGetPr(mxsnr), &snr[ifrq * n * nsat], n * nsat * sizeof(double));
            mxSetField(mxL, 0, "snr", mxsnr);

            mxfix = mxCreateDoubleMatrix(n, nsat, mxREAL);
            memcpy(mxGetPr(mxfix), &fix[ifrq * n * nsat], n * nsat * sizeof(double));
            mxSetField(mxL, 0, "fix", mxfix);

            mxslip = mxCreateDoubleMatrix(n, nsat, mxREAL);
            memcpy(mxGetPr(mxslip), &slip[ifrq * n * nsat], n * nsat * sizeof(double));
            mxSetField(mxL, 0, "slip", mxslip);

            mxhalf = mxCreateDoubleMatrix(n, nsat, mxREAL);
            memcpy(mxGetPr(mxhalf), &half[ifrq * n * nsat], n * nsat * sizeof(double));
            mxSetField(mxL, 0, "half", mxhalf);

            mxlock = mxCreateDoubleMatrix(n, nsat, mxREAL);
            memcpy(mxGetPr(mxlock), &lock[ifrq * n * nsat], n * nsat * sizeof(double));
            mxSetField(mxL, 0, "lock", mxlock);

            mxoutc = mxCreateDoubleMatrix(n, nsat, mxREAL);
            memcpy(mxGetPr(mxoutc), &outc[ifrq * n * nsat], n * nsat * sizeof(double));
            mxSetField(mxL, 0, "outc", mxoutc);

            mxslipc = mxCreateDoubleMatrix(n, nsat, mxREAL);
            memcpy(mxGetPr(mxslipc), &slipc[ifrq * n * nsat], n * nsat * sizeof(double));
            mxSetField(mxL, 0, "slipc", mxslipc);

            mxrejc = mxCreateDoubleMatrix(n, nsat, mxREAL);
            memcpy(mxGetPr(mxrejc), &rejc[ifrq * n * nsat], n * nsat * sizeof(double));
            mxSetField(mxL, 0, "rejc", mxrejc);

            mxSetField(mxstat, 0, freqstr[i], mxL);
        }
    }

    free(timecnt);
    free(resp);
    free(resc);
    free(vsat);
    free(snr);
    free(fix);
    free(slip);
    free(half);
    free(lock);
    free(outc);
    free(slipc);
    free(rejc);
    return mxstat;
}
