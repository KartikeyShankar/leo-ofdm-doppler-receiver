% Phase 1: modulation + AWGN + OFDM basics, theory se match karna hai
clear; close all; clc;
rand('state', 1); randn('state', 1);
if ~exist('results', 'dir'), mkdir('results'); end

% loopback test
for M = [2 4 16]
    b = randi([0 1], 4000, 1);
    assert(isequal(qam_demod(qam_mod(b, M), M), b), 'loopback fail M=%d', M);
    s = qam_mod(b, M);
    fprintf('M=%2d  loopback OK, avg energy = %.3f\n', M, mean(abs(s).^2));
end

% BER vs Eb/N0 (AWGN)
EbN0_dB = 0:1:10;
Nbits   = 4e6;
Ms      = [2 4 16];
ber     = zeros(numel(Ms), numel(EbN0_dB));
for m = 1:numel(Ms)
    M = Ms(m);  k = log2(M);
    bits = randi([0 1], Nbits, 1);
    s = qam_mod(bits, M);
    for i = 1:numel(EbN0_dB)
        N0 = (1/k) / 10^(EbN0_dB(i)/10);
        n  = sqrt(N0/2) * (randn(size(s)) + 1j*randn(size(s)));
        ber(m,i) = mean(qam_demod(s + n, M) ~= bits);
    end
end
g = 10.^(EbN0_dB/10);
th = [0.5*erfc(sqrt(g)); 0.5*erfc(sqrt(g)); (3/8)*erfc(sqrt(0.4*g))];

% OFDM over AWGN, QPSK (N=64, CP=16)
N = 64; CP = 16;
bits = randi([0 1], 2*N*20000, 1);
tx   = ofdm_mod(qam_mod(bits, 4), N, CP);
ber_ofdm = zeros(1, numel(EbN0_dB));
for i = 1:numel(EbN0_dB)
    N0 = 0.5 / 10^(EbN0_dB(i)/10);
    n  = sqrt(N0/2) * (randn(size(tx)) + 1j*randn(size(tx)));
    Y  = ofdm_demod(tx + n, N, CP);
    ber_ofdm(i) = mean(qam_demod(Y(:), 4) ~= bits);
end

% multipath pe CP ka effect (noise nahi)
h = [1 0.8 0.6 0.4];
H = fft(h(:), N);
s2 = qam_mod(randi([0 1], 2*N*200, 1), 4);
b2 = qam_demod(s2, 4);
for cp = [0 16]
    r   = filter(h, 1, ofdm_mod(s2, N, cp));
    Y   = ofdm_demod(r, N, cp) ./ H;
    evm = sqrt(mean(abs(Y(:) - s2).^2));
    fprintf('CP = %2d -> BER = %.4f, EVM = %.4f\n', cp, mean(qam_demod(Y(:), 4) ~= b2), evm);
end

fprintf('\nEb/N0   BPSK sim/theory      QPSK sim/theory      16QAM sim/theory     OFDM-QPSK sim\n');
for i = 1:numel(EbN0_dB)
    fprintf('%4d   %.2e/%.2e   %.2e/%.2e   %.2e/%.2e   %.2e\n', EbN0_dB(i), ...
        ber(1,i), th(1,i), ber(2,i), th(2,i), ber(3,i), th(3,i), ber_ofdm(i));
end
ber(ber==0) = NaN; ber_ofdm(ber_ofdm==0) = NaN;
figure; semilogy(EbN0_dB, th(1,:), 'k-', EbN0_dB, th(3,:), 'k--', ...
    EbN0_dB, ber(1,:), 'bo', EbN0_dB, ber(2,:), 'g+', EbN0_dB, ber(3,:), 'rs', ...
    EbN0_dB, ber_ofdm, 'm^'); grid on;
legend('Theory BPSK/QPSK', 'Theory 16-QAM', 'Sim BPSK', 'Sim QPSK', 'Sim 16-QAM', 'Sim OFDM-QPSK', 'Location', 'southwest');
xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate'); title('Phase 1: BER over AWGN, simulation vs theory');
axis([0 10 1e-6 1]);
print('-dpng', 'results/phase1_ber.png');
