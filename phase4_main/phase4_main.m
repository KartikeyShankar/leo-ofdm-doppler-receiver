% Phase 4: (A) CFO estimator comparison, (B) fixed-point (Q-format) study
clear; close all; clc;
rand('state', 4); randn('state', 4);
if ~exist('results', 'dir'), mkdir('results'); end

N = 64;  CP = 16;  Kd = 10;  F = 400;
Xp  = qam_mod(randi([0 1], 2*N, 1), 4);
eps = 0.2;

% A: estimators, BER vs Eb/N0
snr = 0:2:10;
names = {'True CFO known', 'Moose, 2 pilots', 'Moose, 4 pilots', 'Moose 2 pilots + phase tracking'};
cfg = [0 0; 2 0; 4 0; 2 1];               % [nP track]
berA = zeros(4, numel(snr));
for m = 1:4
    for i = 1:numel(snr)
        e = 0; b = 0;
        for f = 1:F
            [ne, nb] = cfo_rx(eps, snr(i), Xp, N, CP, Kd, cfg(m,1), cfg(m,2), 0, 0);
            e = e + ne;  b = b + nb;
        end
        berA(m,i) = e / b;
    end
end
thA = 0.5 * erfc(sqrt(10.^(snr/10)));

% B: fixed point, Eb/N0 = 8 dB, receiver = Moose 2 pilots + tracking
EbN0 = 8;  fs0 = 3;
bitsV = 4:2:16;
berB = zeros(size(bitsV));
for k = 1:numel(bitsV)
    e = 0; b = 0;
    for f = 1:F
        [ne, nb] = cfo_rx(eps, EbN0, Xp, N, CP, Kd, 2, 1, bitsV(k), fs0);
        e = e + ne;  b = b + nb;
    end
    berB(k) = e / b;
end
e = 0; b = 0;
for f = 1:F
    [ne, nb] = cfo_rx(eps, EbN0, Xp, N, CP, Kd, 2, 1, 0, 0);
    e = e + ne;  b = b + nb;
end
berFloat = e / b;

fsV = 1:1:6;                              % 8 bit pe full-scale sweep (clipping vs resolution)
berC = zeros(size(fsV));
for k = 1:numel(fsV)
    e = 0; b = 0;
    for f = 1:F
        [ne, nb] = cfo_rx(eps, EbN0, Xp, N, CP, Kd, 2, 1, 8, fsV(k));
        e = e + ne;  b = b + nb;
    end
    berC(k) = e / b;
end

printf('A) Eb/N0   '); printf('%-14s', 'genie', 'moose2', 'moose4', 'moose2+track'); printf('theory\n');
for i = 1:numel(snr)
    printf('%6d     %.2e      %.2e      %.2e      %.2e      %.2e\n', snr(i), berA(1,i), berA(2,i), berA(3,i), berA(4,i), thA(i));
end
printf('\nB) float BER = %.2e\n bits   BER\n', berFloat);
for k = 1:numel(bitsV), printf('%4d    %.2e\n', bitsV(k), berB(k)); end
printf('\nC) 8 bit, full-scale sweep\n   fs   BER\n');
for k = 1:numel(fsV), printf('%4d    %.2e\n', fsV(k), berC(k)); end

berA(berA==0) = NaN;
figure;
semilogy(snr, thA, 'k--', snr, berA(1,:), 'bo-', snr, berA(2,:), 'rs-', snr, berA(3,:), 'm+-', snr, berA(4,:), 'g^-'); grid on;
legend('AWGN theory', names{:}, 'Location', 'southwest');
xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate'); title('CFO estimators, CFO = 0.2 subcarrier');
print('-dpng', 'results/phase4_estimators.png');

figure('Position', [100 100 1100 450]);
subplot(1,2,1);
semilogy(bitsV, berB, 'bo-', bitsV, berFloat*ones(size(bitsV)), 'k--'); grid on;
legend('Fixed-point', 'Floating-point', 'Location', 'northeast');
xlabel('Word length (bits)'); ylabel('Bit error rate'); title('BER vs word length (E_b/N_0 = 8 dB)');
subplot(1,2,2);
semilogy(fsV, berC, 'rs-'); grid on;
xlabel('Full scale'); ylabel('Bit error rate'); title('8-bit: clipping vs resolution');
print('-dpng', 'results/phase4_fixedpoint.png');
