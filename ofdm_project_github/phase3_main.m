% Phase 3: LEO Doppler + CFO estimation (Moose)
% Link LOS-dominant hai, isliye yaha AWGN + frequency offset use kiya hai
clear; close all; clc;
rand('state', 3); randn('state', 3);
if ~exist('results', 'dir'), mkdir('results'); end

% LEO pass: 520 km orbit, 2 GHz carrier (assumptions), 15 kHz subcarrier spacing
h_km = 520;  fc = 2e9;  scs = 15e3;
N = 64;  CP = 16;  Kd = 10;
[t, el, fd, fdr] = leo_pass(h_km, fc, 10);
eps_max = N / (2*(N+CP));                 % Moose ki range (subcarrier spacing mein)
lim = eps_max * scs;
fprintf('Pass: %.0f s, max Doppler = %.1f kHz, max rate = %.0f Hz/s\n', t(end)-t(1), max(abs(fd))/1e3, max(abs(fdr)));
fprintf('Moose range = +-%.2f subcarrier = +-%.1f kHz\n', eps_max, lim/1e3);
fprintf('Pre-compensation se Doppler ka kam se kam %.0f%% hatna padega\n', 100*(1 - lim/max(abs(fd))));

figure('Position', [100 100 1000 700]);
subplot(3,1,1); plot(t, el); grid on; ylabel('Elevation (deg)'); title('LEO pass, 520 km, f_c = 2 GHz');
subplot(3,1,2); plot(t, fd/1e3, 'b', t, lim/1e3*ones(size(t)), 'r--', t, -lim/1e3*ones(size(t)), 'r--'); grid on;
ylabel('Doppler (kHz)'); legend('Doppler', 'Moose range', 'Location', 'east');
subplot(3,1,3); plot(t, fdr); grid on; ylabel('Doppler rate (Hz/s)'); xlabel('Time (s)');
print('-dpng', 'results/phase3_pass.png');

% BER vs CFO at fixed Eb/N0
Xp = qam_mod(randi([0 1], 2*N, 1), 4);
EbN0 = 6;  F = 200;
eps_v = -0.6:0.1:0.6;
ber = zeros(3, numel(eps_v));
for k = 1:numel(eps_v)
    for m = 0:2
        e = 0; b = 0;
        for f = 1:F
            [ne, nb] = cfo_link(eps_v(k), EbN0, Xp, N, CP, Kd, m);
            e = e + ne;  b = b + nb;
        end
        ber(m+1, k) = e / b;
    end
end
th = 0.5 * erfc(sqrt(10^(EbN0/10)));

% estimator RMSE vs Eb/N0, eps = 0.3
snr = 0:3:21;  eps0 = 0.3;  F2 = 500;
rmse = zeros(size(snr));
for i = 1:numel(snr)
    se = 0;
    for f = 1:F2
        [~, ~, eh] = cfo_link(eps0, snr(i), Xp, N, CP, Kd, 1);
        se = se + (eh - eps0)^2;
    end
    rmse(i) = sqrt(se / F2);
end

fprintf('\n eps    none      Moose     genie\n');
for k = 1:numel(eps_v)
    fprintf('%5.1f   %.4f    %.4f    %.4f\n', eps_v(k), ber(1,k), ber(2,k), ber(3,k));
end
fprintf('\nEb/N0   RMSE(eps)\n');
for i = 1:numel(snr), fprintf('%4d    %.4f\n', snr(i), rmse(i)); end

ber(ber==0) = NaN;
figure('Position', [100 100 1100 450]);
subplot(1,2,1);
semilogy(eps_v, ber(1,:), 'rs-', eps_v, ber(2,:), 'g^-', eps_v, ber(3,:), 'bo-', eps_v, th*ones(size(eps_v)), 'k--'); grid on;
legend('No correction', 'Moose estimate', 'True CFO known', 'AWGN theory', 'Location', 'south');
xlabel('CFO (subcarrier spacings)'); ylabel('Bit error rate'); title('BER vs CFO at E_b/N_0 = 6 dB');
subplot(1,2,2);
semilogy(snr, rmse, 'mo-'); grid on;
xlabel('E_b/N_0 (dB)'); ylabel('RMSE of CFO estimate'); title('Moose estimator, true CFO = 0.3');
print('-dpng', 'results/phase3_cfo.png');
