# Doppler-Robust OFDM Receiver for LEO Satellite Links

**Problem:** A fast-moving LEO satellite shifts the carrier frequency by tens of kHz, which breaks OFDM subcarrier orthogonality. This project studies how to estimate and correct that offset, and what happens to BER under realistic satellite motion and channel conditions.

**Status:** Phases 1-4 done and validated.

Everything is written from scratch in plain Octave/MATLAB (no toolboxes). Run `phase1_main`, `phase2_main`, `phase3_main` from this folder.

## Phase 1 - Modulation, AWGN, OFDM basics
- Gray-coded BPSK/QPSK/16-QAM and an OFDM transceiver (N=64, CP=16).
- Simulated BER matches closed-form theory; OFDM-QPSK matches QPSK theory.
- Cyclic prefix check: multipath EVM 0.23 without CP, 0 with CP.

![BER vs Eb/N0](../phase4_main/results/phase1_ber.png)

## Phase 2 - Rayleigh fading + channel estimation
- 6-tap Rayleigh channel, block fading (1 pilot + 19 data symbols per frame), zero-forcing equalizer.
- Ideal-CSI BER sits on the Rayleigh theory curve. LS estimation loses about 3 dB; time-domain denoising (zeroing taps beyond the CP) recovers most of it and cuts channel-estimation MSE about 4x.

![Rayleigh + channel estimation](../phase4_main/results/phase2_rayleigh.png)

## Phase 3 - LEO Doppler and CFO estimation
- Overhead pass model: 520 km circular orbit, 2 GHz carrier (assumed values). Max Doppler about 46 kHz (3 subcarriers at 15 kHz spacing), max Doppler rate about 690 Hz/s.
- Moose estimator (two identical pilot symbols) only works up to +-0.4 subcarrier = +-6 kHz, so the raw Doppler must be pre-compensated by at least 87% (in practice from GNSS + ephemeris) and the receiver still needs a final phase correction loop.
- Link modelled as AWGN + CFO (LOS-dominant). Without correction the link is dead for any CFO > 0; with the true CFO known it matches AWGN theory; with the Moose estimate it works up to +-0.3 but sits noticeably above the ideal curve.

![LEO pass](../phase4_main/results/phase3_pass.png)
![CFO results](../phase4_main/results/phase3_cfo.png)

## Phase 4 - Better estimator + fixed-point study
- Moose with 2 pilots sits about 10x above ideal BER at 6 dB (phase drift builds up over the frame). 4 pilots helps but costs overhead. 2 pilots plus decision-directed phase tracking lands within a few dB of the ideal curve.

![Estimators](../phase4_main/results/phase4_estimators.png)

- Fixed-point: receiver samples and the derotation phasor are quantized to b bits (round + saturate). At Eb/N0 = 8 dB, 6 bits or more is indistinguishable from floating point within simulation noise.
- Limitation: only the input samples and derotator are quantized. The FFT, tracking loop and demapper still run in floating point, so this is a first-order word-length study, not a full fixed-point implementation.

![Fixed point](../phase4_main/results/phase4_fixedpoint.png)

## Possible extensions
Learned CFO estimator vs Moose, full fixed-point FFT, Doppler-rate tracking for longer frames.
