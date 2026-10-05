# Doppler-Robust OFDM Receiver for LEO Satellite Links

**Problem:** A fast-moving LEO satellite shifts the carrier frequency by tens of kHz, which breaks OFDM subcarrier orthogonality. This project studies which frequency-offset estimator recovers the link best, and what it costs in 16-bit fixed-point hardware.

**Status:** Phase 1 complete (validated). Phases 2-4 in progress.

## Phase 1 – Modulation, AWGN, OFDM basics
- From-scratch Gray-coded BPSK/QPSK/16-QAM mapper and OFDM transceiver (N=64, CP=16), no toolboxes.
- Simulated BER matches closed-form theory over AWGN; OFDM-QPSK matches QPSK theory.
- Cyclic prefix verified: multipath error (EVM) 0.23 without CP, 0 with CP.

![BER vs Eb/N0](results/phase1_ber.png)

## Run
Octave or MATLAB: `phase1_main`

## Roadmap
2. Rayleigh fading + channel estimation  3. LEO Doppler model + frequency-offset estimators  4. Q15 fixed-point study
