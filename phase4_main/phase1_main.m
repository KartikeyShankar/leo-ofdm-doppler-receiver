% PHASE 1 - Modulation + AWGN + OFDM ki basics, aur theory se milaan.
% Octave/MATLAB mein is folder se chalao:  phase1_main
% Kya check hota hai:
%  (1) mapper/demapper loopback
%  (2) BPSK, QPSK, 16-QAM ka BER vs Eb/N0 theory se match karta hai ya nahi
%  (3) OFDM over AWGN, QPSK theory se match kare
%  (4) cyclic prefix multipath ka ISI kaise saaf karta hai (CP ke saath aur bina)
clear; close all; clc;
rand('state', 1); randn('state', 1);      % seed fix, taaki har baar same result aaye
if ~exist('results', 'dir'), mkdir('results'); end

%% 1. Loopback test (noise nahi): bits -> symbols -> bits bilkul same aane chahiye
for M = [2 4 16]
    b = randi([0 1], 4000, 1);
    assert(isequal(qam_demod(qam_mod(b, M), M), b), 'Loopback fail ho gaya M=%d ke liye', M);
    s = qam_mod(b, M);
    printf('M=%2d  loopback OK, average symbol energy = %.3f (1 hona chahiye)\n', M, mean(abs(s).^2));
end

%% 2. AWGN pe BER vs Eb/N0: simulation vs theory
EbN0_dB = 0:1:10;
Nbits   = 4e6;                            % 2 aur 4 dono ka multiple
Ms      = [2 4 16];
ber     = zeros(numel(Ms), numel(EbN0_dB));
for m = 1:numel(Ms)
    M = Ms(m);  k = log2(M);
    bits = randi([0 1], Nbits, 1);
    s = qam_mod(bits, M);                 % Es = 1, toh Eb = 1/k
    for i = 1:numel(EbN0_dB)
        EbN0 = 10^(EbN0_dB(i)/10);
        N0   = (1/k) / EbN0;              % noise power spectral density
        n    = sqrt(N0/2) * (randn(size(s)) + 1j*randn(size(s)));  % complex AWGN, I aur Q mein N0/2 each
        rb   = qam_demod(s + n, M);
        ber(m,i) = mean(rb ~= bits);
    end
end
g = 10.^(EbN0_dB/10);
th = [0.5*erfc(sqrt(g)); 0.5*erfc(sqrt(g)); (3/8)*erfc(sqrt(0.4*g))];  % BPSK, QPSK, 16QAM (Gray, approx.)

%% 3. OFDM over AWGN (N=64 subcarriers, CP=16), QPSK: QPSK theory ke barabar aana chahiye
N = 64; CP = 16;
bits = randi([0 1], 2*N*20000, 1);        % 20000 OFDM symbols
s    = qam_mod(bits, 4);
tx   = ofdm_mod(s, N, CP);
ber_ofdm = zeros(1, numel(EbN0_dB));
for i = 1:numel(EbN0_dB)
    N0 = 0.5 / 10^(EbN0_dB(i)/10);        % QPSK mein Eb = 1/2 (CP ka overhead ignore, Eb sirf data bits ka)
    n  = sqrt(N0/2) * (randn(size(tx)) + 1j*randn(size(tx)));
    Y  = ofdm_demod(tx + n, N, CP);
    ber_ofdm(i) = mean(qam_demod(Y(:), 4) ~= bits);
end

%% 4. Cyclic prefix kyun chahiye: multipath channel, noise nahi, one-tap equalizer
h = [1 0.8 0.6 0.4];                      % 4-path channel (delay spread = 3 samples)
H = fft(h(:), N);                         % har subcarrier pe channel ka gain
s2 = qam_mod(randi([0 1], 2*N*200, 1), 4);
b2 = qam_demod(s2, 4);
for cp = [0 16]
    t  = ofdm_mod(s2, N, cp);
    r  = filter(h, 1, t);                 % multipath se guzaara
    Y  = ofdm_demod(r, N, cp) ./ H;       % one-tap equalizer: channel gain se divide
    evm = sqrt(mean(abs(Y(:) - s2).^2));  % equalise hue symbols ideal se kitni door hain
    printf('CP = %2d  ->  BER = %.4f, EVM = %.4f  (multipath, no noise)\n', cp, mean(qam_demod(Y(:), 4) ~= b2), evm);
end

%% Results table + plot
printf('\nEb/N0   BPSK sim/theory      QPSK sim/theory      16QAM sim/theory     OFDM-QPSK sim\n');
for i = 1:numel(EbN0_dB)
    printf('%4d   %.2e/%.2e   %.2e/%.2e   %.2e/%.2e   %.2e\n', EbN0_dB(i), ...
        ber(1,i), th(1,i), ber(2,i), th(2,i), ber(3,i), th(3,i), ber_ofdm(i));
end
ber(ber==0) = NaN; ber_ofdm(ber_ofdm==0) = NaN;   % log axis pe zero draw nahi hota
figure; semilogy(EbN0_dB, th(1,:), 'k-', EbN0_dB, th(3,:), 'k--', ...
    EbN0_dB, ber(1,:), 'bo', EbN0_dB, ber(2,:), 'g+', EbN0_dB, ber(3,:), 'rs', ...
    EbN0_dB, ber_ofdm, 'm^'); grid on;
legend('Theory BPSK/QPSK', 'Theory 16-QAM', 'Sim BPSK', 'Sim QPSK', 'Sim 16-QAM', 'Sim OFDM-QPSK', 'Location', 'southwest');
xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate'); title('Phase 1: BER over AWGN, simulation vs theory');
axis([0 10 1e-6 1]);
print('-dpng', 'results/phase1_ber.png');
disp('Saved results/phase1_ber.png');
