% Phase 2: Rayleigh fading + channel estimation
% frame = 1 pilot OFDM symbol + 19 data symbols, channel frame ke andar same (block fading)
% compare: ideal CSI, LS, LS + denoise
clear; close all; clc;
rand('state', 2); randn('state', 2);
if ~exist('results', 'dir'), mkdir('results'); end

N = 64; CP = 16; Kd = 19;
L = 6; decay = 2;
F = 1000;                                 % frames, kam karoge toh jaldi chalega par plot noisy
EbN0_dB = 0:2:20;  nS = numel(EbN0_dB);

Xp = qam_mod(randi([0 1], 2*N, 1), 4);    % pilot
errs = zeros(3, nS);  mse = zeros(2, nS);  nbits = 0;
for f = 1:F
    h  = rayleigh_chan(L, decay);
    H  = fft(h(:), N);
    bits = randi([0 1], 2*N*Kd, 1);
    tx = ofdm_mod([Xp; qam_mod(bits, 4)], N, CP);
    rc = filter(h, 1, tx);
    nbits = nbits + numel(bits);
    for i = 1:nS
        N0 = 0.5 / 10^(EbN0_dB(i)/10);
        n  = sqrt(N0/2) * (randn(size(rc)) + 1j*randn(size(rc)));
        Y  = ofdm_demod(rc + n, N, CP);
        Yd = Y(:, 2:end);
        Hls = ls_chan_est(Y(:,1), Xp, CP, 0);
        Hdn = ls_chan_est(Y(:,1), Xp, CP, 1);
        Hs  = {H, Hls, Hdn};
        for r = 1:3
            errs(r,i) = errs(r,i) + sum(qam_demod(Yd ./ Hs{r}, 4) ~= bits);   % zero-forcing
        end
        mse(1,i) = mse(1,i) + mean(abs(Hls - H).^2);
        mse(2,i) = mse(2,i) + mean(abs(Hdn - H).^2);
    end
end
ber = errs / nbits;  mse = mse / F;
g = 10.^(EbN0_dB/10);
th_ray  = 0.5*(1 - sqrt(g./(1+g)));       % QPSK Rayleigh theory
th_awgn = 0.5*erfc(sqrt(g));

fprintf('Eb/N0   Ideal       LS          LS+denoise  Theory(Rayleigh)   MSE_LS     MSE_DN\n');
for i = 1:nS
    fprintf('%4d   %.3e   %.3e   %.3e   %.3e         %.2e   %.2e\n', EbN0_dB(i), ...
        ber(1,i), ber(2,i), ber(3,i), th_ray(i), mse(1,i), mse(2,i));
end

figure('Position', [100 100 1100 450]);
subplot(1,2,1);
semilogy(EbN0_dB, th_awgn, 'k:', EbN0_dB, th_ray, 'k-', EbN0_dB, ber(1,:), 'bo', ...
    EbN0_dB, ber(2,:), 'rs', EbN0_dB, ber(3,:), 'g^'); grid on;
axis([0 20 1e-4 1]);
legend('Theory AWGN', 'Theory Rayleigh', 'Sim ideal CSI', 'Sim LS', 'Sim LS + denoise', 'Location', 'southwest');
xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate'); title('OFDM-QPSK over Rayleigh fading');
subplot(1,2,2);
semilogy(EbN0_dB, mse(1,:), 'rs-', EbN0_dB, mse(2,:), 'g^-'); grid on;
legend('LS', 'LS + denoise', 'Location', 'southwest');
xlabel('E_b/N_0 (dB)'); ylabel('Channel estimation MSE'); title('Channel estimation error');
print('-dpng', 'results/phase2_rayleigh.png');
