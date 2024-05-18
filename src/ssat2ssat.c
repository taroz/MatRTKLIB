/**
 * @file ssat2ssat.c
 * @brief Convert mxArray ssat_t to mxssat
 * @author Taro Suzuki
 */

#include "mex_utility.h"

/* ssat2mxssat ----------------------------------------------------------*/
extern mxArray *ssat2mxssat(const ssat_t *ssat, const gtime_t *time, const int n) {
    mxArray *mxssat, *mxL;
    int i, j, k, isat, ifrq, idx1, idx2, frqs[MAXFREQ]={0},nsat = 0,nfrq = 0;
    double *resp, *resc, *vsat, *snr, *fix, *slip, *half, *lock, *outc, *slipc,
        *rejc, *eps, *azs, *els, ep[6], nan, sats[MAXSAT] = {0};
    mxArray *mxaz, *mxel, *mxsat, *mxep, *mxresp, *mxresc, *mxvsat, *mxsnr, *mxfix, *mxslip, *mxhalf,
        *mxlock, *mxoutc, *mxslipc, *mxrejc;

    /* output struct */
    const char *freqstr[] = {"L1", "L2", "L5", "L6", "L7", "L8", "L9"};
    const char *statf[] = {"n",  "nsat", "sat", "ep", "az", "el", "L1",
                           "L2", "L5",   "L6",  "L7", "L8", "L9"};
    const char *freqf[] = {"resp", "resc", "vsat", "snr",   "fix", "slip",
                           "half", "lock", "outc", "slipc", "rejc"};
    
    /* count valid satellites */
    for (i = 0; i < MAXSAT; i++) {
        for (k = 0; k < n; k++) {
            if (ssat[i + MAXSAT * k].vs) {
                sats[nsat++] = i+1;
                break;
            }
        }
        /* count frequencies */
        for (k = 0; k < NFREQ; k++) {
            if (ssat[i].resp[k] != 0.0 && frqs[k]==0) {
                frqs[nfrq++] = k+1;
            }
        }
    }
    //mexPrintf("ssat2mxssat: n=%d nsat=%d nfrq=%d\n",n, nsat,nfrq);

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
        mexErrMsgTxt("ssat2mxssat: memory allocation error");
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

    mxssat = mxCreateStructMatrix(1, 1, 13, statf);
    mxSetField(mxssat, 0, "n", mxCreateDoubleScalar(n));
    mxSetField(mxssat, 0, "nsat", mxCreateDoubleScalar(nsat));
    mxsat = mxCreateDoubleMatrix(1, nsat, mxREAL);
    memcpy(mxGetPr(mxsat), sats, nsat * sizeof(double));
    mxSetField(mxssat, 0, "sat", mxsat);

    mxep = mxCreateDoubleMatrix(n, 6, mxREAL);
    eps = mxGetPr(mxep);
    mxaz = mxCreateDoubleMatrix(n, nsat, mxREAL);
    azs = mxGetPr(mxaz);
    mxSetNaN(azs, n * nsat);
    mxel = mxCreateDoubleMatrix(n, nsat, mxREAL);
    els = mxGetPr(mxel);
    mxSetNaN(els, n * nsat);

    nan = mxGetNaN();
    for (i=0; i<n; i++) {
        /* ep */
        time2epoch(time[i], ep);
        eps[i + n * 0] = ep[0];
        eps[i + n * 1] = ep[1];
        eps[i + n * 2] = ep[2];
        eps[i + n * 3] = ep[3];
        eps[i + n * 4] = ep[4];
        eps[i + n * 5] = ep[5];
        for (j = 0; j < nsat; j++) {
            isat = (int)sats[j] - 1;
            azs[i + n * j] = ssat[isat + i * MAXSAT].azel[0]*R2D;
            els[i + n * j] = ssat[isat + i * MAXSAT].azel[1]*R2D;
            for (k=0; k<nfrq; k++) {
                ifrq = frqs[k] - 1;
                idx1 = i + j*n + k* n * nsat;
                idx2 = isat + i * MAXSAT;
                resp[idx1] = (ssat[idx2].resp[ifrq]) == 0 ? nan : ssat[idx2].resp[ifrq];
                resc[idx1] = (ssat[idx2].resc[ifrq]) == 0 ? nan : ssat[idx2].resc[ifrq];
                vsat[idx1] = (ssat[idx2].vsat[ifrq]) == 0 ? nan : (double) ssat[idx2].vsat[ifrq];
                slip[idx1] = (ssat[idx2].slip[ifrq]) == 0 ? nan : (double) ssat[idx2].slip[ifrq];
                fix[idx1] = (ssat[idx2].fix[ifrq]) == 0 ? nan : (double) ssat[idx2].fix[ifrq];
                snr[idx1] = (ssat[idx2].snr[ifrq]) == 0 ? nan : (double) ssat[idx2].snr[ifrq] * SNR_UNIT;
                half[idx1] = (ssat[idx2].half[ifrq]) == 0 ? nan : (double) ssat[idx2].half[ifrq];
                lock[idx1] = (ssat[idx2].lock[ifrq]) == 0 ? nan : (double) ssat[idx2].lock[ifrq];
                outc[idx1] = (ssat[idx2].outc[ifrq]) == 0 ? nan : (double) ssat[idx2].outc[ifrq];
                slipc[idx1] = (ssat[idx2].slipc[ifrq]) == 0 ? nan : (double) ssat[idx2].slipc[ifrq];
                rejc[idx1] = (ssat[idx2].rejc[ifrq]) == 0 ? nan : (double) ssat[idx2].rejc[ifrq];
            }
        }
    }
    
    mxSetField(mxssat, 0, "ep", mxep);
    mxSetField(mxssat, 0, "az", mxaz);
    mxSetField(mxssat, 0, "el", mxel);

    for (i = 0; i < nfrq; i++) {
        ifrq = frqs[i] - 1;
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
        
        mxslip = mxCreateDoubleMatrix(n, nsat, mxREAL);
        memcpy(mxGetPr(mxslip), &slip[ifrq * n * nsat], n * nsat * sizeof(double));
        mxSetField(mxL, 0, "slip", mxslip);
        
        mxfix = mxCreateDoubleMatrix(n, nsat, mxREAL);
        memcpy(mxGetPr(mxfix), &fix[ifrq * n * nsat], n * nsat * sizeof(double));
        mxSetField(mxL, 0, "fix", mxfix);
        
        mxsnr = mxCreateDoubleMatrix(n, nsat, mxREAL);
        memcpy(mxGetPr(mxsnr), &snr[ifrq * n * nsat], n * nsat * sizeof(double));
        mxSetField(mxL, 0, "snr", mxsnr);
        
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

        mxSetField(mxssat, 0, freqstr[ifrq], mxL);
    }
    
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
    return mxssat;
}