% PHASE 1 - Modulation + AWGN + OFDM basics, validated against theory.
% Run in Octave or MATLAB from this folder:  phase1_main
% Checks: (1) mapper/demapper loopback, (2) BER vs Eb/N0 matches closed-form
% theory for BPSK, QPSK, 16-QAM, (3) OFDM over AWGN matches QPSK theory,
% (4) cyclic prefix removes multipath interference (with vs without CP).
clear; close all; clc;
rand('state', 1); randn('state', 1);      % fixed seed -> reproducible results
if ~exist('results', 'dir'), mkdir('results'); end

%% 1. Loopback sanity test (no noise): bits -> symbols -> bits must be identical
for M = [2 4 16]
    b = randi([0 1], 4000, 1);
    assert(isequal(qam_demod(qam_mod(b, M), M), b), 'Loopback failed for M=%d', M);
    s = qam_mod(b, M);
    printf('M=%2d  loopback OK, average symbol energy = %.3f (should be 1)\n', M, mean(abs(s).^2));
end

%% 2. BER vs Eb/N0 over AWGN: simulation vs theory
EbN0_dB = 0:1:10;
Nbits   = 4e6;                            % multiple of 2 and 4
Ms      = [2 4 16];
ber     = zeros(numel(Ms), numel(EbN0_dB));
for m = 1:numel(Ms)
    M = Ms(m);  k = log2(M);
    bits = randi([0 1], Nbits, 1);
    s = qam_mod(bits, M);                 % Es = 1, so Eb = 1/k
    for i = 1:numel(EbN0_dB)
        EbN0 = 10^(EbN0_dB(i)/10);
        N0   = (1/k) / EbN0;              % noise power spectral density
        n    = sqrt(N0/2) * (randn(size(s)) + 1j*randn(size(s)));  % complex AWGN
        rb   = qam_demod(s + n, M);
        ber(m,i) = mean(rb ~= bits);
    end
end
g = 10.^(EbN0_dB/10);
th = [0.5*erfc(sqrt(g)); 0.5*erfc(sqrt(g)); (3/8)*erfc(sqrt(0.4*g))];  % BPSK, QPSK, 16QAM (Gray, approx.)

%% 3. OFDM over AWGN (N=64 subcarriers, CP=16) with QPSK: should equal QPSK theory
N = 64; CP = 16;
bits = randi([0 1], 2*N*20000, 1);        % 20000 OFDM symbols
s    = qam_mod(bits, 4);
tx   = ofdm_mod(s, N, CP);
ber_ofdm = zeros(1, numel(EbN0_dB));
for i = 1:numel(EbN0_dB)
    N0 = 0.5 / 10^(EbN0_dB(i)/10);        % Eb = 1/2 for QPSK (CP overhead ignored: Eb counts data bits)
    n  = sqrt(N0/2) * (randn(size(tx)) + 1j*randn(size(tx)));
    Y  = ofdm_demod(tx + n, N, CP);
    ber_ofdm(i) = mean(qam_demod(Y(:), 4) ~= bits);
end

%% 4. Why the cyclic prefix exists: multipath channel, no noise, one-tap equalizer
h = [1 0.8 0.6 0.4];                      % 4-path channel (delay spread = 3 samples)
H = fft(h(:), N);                         % channel gain on each subcarrier
s2 = qam_mod(randi([0 1], 2*N*200, 1), 4);
b2 = qam_demod(s2, 4);
for cp = [0 16]
    t  = ofdm_mod(s2, N, cp);
    r  = filter(h, 1, t);                 % pass through multipath channel
    Y  = ofdm_demod(r, N, cp) ./ H;       % one-tap equalizer: divide by channel gain
    evm = sqrt(mean(abs(Y(:) - s2).^2));  % RMS distance of equalised symbols from ideal
    printf('CP = %2d  ->  BER = %.4f, EVM = %.4f  (multipath, no noise)\n', cp, mean(qam_demod(Y(:), 4) ~= b2), evm);
end

%% Results table + plot
printf('\nEb/N0   BPSK sim/theory      QPSK sim/theory      16QAM sim/theory     OFDM-QPSK sim\n');
for i = 1:numel(EbN0_dB)
    printf('%4d   %.2e/%.2e   %.2e/%.2e   %.2e/%.2e   %.2e\n', EbN0_dB(i), ...
        ber(1,i), th(1,i), ber(2,i), th(2,i), ber(3,i), th(3,i), ber_ofdm(i));
end
ber(ber==0) = NaN; ber_ofdm(ber_ofdm==0) = NaN;   % zeros cannot be drawn on a log axis
figure; semilogy(EbN0_dB, th(1,:), 'k-', EbN0_dB, th(3,:), 'k--', ...
    EbN0_dB, ber(1,:), 'bo', EbN0_dB, ber(2,:), 'g+', EbN0_dB, ber(3,:), 'rs', ...
    EbN0_dB, ber_ofdm, 'm^'); grid on;
legend('Theory BPSK/QPSK', 'Theory 16-QAM', 'Sim BPSK', 'Sim QPSK', 'Sim 16-QAM', 'Sim OFDM-QPSK', 'Location', 'southwest');
xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate'); title('Phase 1: BER over AWGN, simulation vs theory');
axis([0 10 1e-6 1]);
print('-dpng', 'results/phase1_ber.png');
disp('Saved results/phase1_ber.png');
