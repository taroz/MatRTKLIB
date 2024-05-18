clear; clc; close all;
addpath ..\
basepath = '.\data\';

%% read RTKLIB solution file
gsol = gt.Gsol([basepath 'rover_rtk.pos']);
gsol.plotAll();

gsol.solStatCount([gt.C.SOLQ_FIX gt.C.SOLQ_FLOAT])
gsol.solStatRate([gt.C.SOLQ_FIX gt.C.SOLQ_FLOAT])

gsol2 = gsol.fixedInterval(gsol.dt);
gsol2.plotAll();
gsol2.solStatCount([gt.C.SOLQ_FIX gt.C.SOLQ_FLOAT])
gsol2.solStatRate([gt.C.SOLQ_FIX gt.C.SOLQ_FLOAT])
