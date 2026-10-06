# Doppler-Robust OFDM Receiver for LEO Satellite Links

**Problem:** A fast-moving LEO satellite shifts the carrier frequency by tens of kHz, which breaks OFDM subcarrier orthogonality. This project studies how to estimate and correct that offset, and w[...]

**Status:** Phases 1-3 done and validated. Phase 4 (estimator improvement + Q15 fixed-point) in progress.

Everything is written from scratch in plain Octave/MATLAB (no toolboxes). Run `phase1_main`, `phase2_main`, `phase3_main` from this folder.

## Phase 1 - Modulation, AWGN, OFDM basics
- Gray-coded BPSK/QPSK/16-QAM and an OFDM transceiver (N=64, CP=16).
- Simulated BER matches closed-form theory; OFDM-QPSK matches QPSK theory.
- Cyclic prefix check: multipath EVM 0.23 without CP, 0 with CP.

![BER vs Eb/N0](results/phase1_ber.png)

## Phase 2 - Rayleigh fading + channel estimation
- 6-tap Rayleigh channel, block fading (1 pilot + 19 data symbols per frame), zero-forcing equalizer.
- Ideal-CSI BER sits on the Rayleigh theory curve. LS estimation loses about 3 dB; time-domain denoising (zeroing taps beyond the CP) recovers most of it and cuts channel-estimation MSE about 4x.

![Rayleigh + channel estimation](results/phase2_rayleigh.png)

## Phase 3 - LEO Doppler and CFO estimation
- Overhead pass model: 520 km circular orbit, 2 GHz carrier (assumed values). Max Doppler about 46 kHz (3 subcarriers at 15 kHz spacing), max Doppler rate about 690 Hz/s.
- Moose estimator (two identical pilot symbols) only works up to +-0.4 subcarrier = +-6 kHz, so the raw Doppler must be pre-compensated by at least 87% (in practice from GNSS + ephemeris) and the [...]
- Link modelled as AWGN + CFO (LOS-dominant). Without correction the link is dead for any CFO > 0; with the true CFO known it matches AWGN theory; with the Moose estimate it works up to +-0.3 but [...]

![LEO pass](results/phase3_pass.png)
![CFO results](results/phase3_cfo.png)

## Next
Phase 4: reduce the Moose penalty (more pilots, phase tracking) and quantize the receiver to Q15 fixed-point to measure BER loss vs word length.
