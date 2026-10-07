function [nerr, nb, eps_hat] = cfo_rx(eps, EbN0_dB, Xp, N, CP, Kd, nP, track, fxb, fs)
% nP = pilot symbols (2 ya 4), 0 matlab true eps pata hai
% track = 1: decision-directed phase tracking
% fxb = fixed-point bits (0 = floating), fs = full scale
np = max(nP, 2);
L  = N + CP;
bits = randi([0 1], 2*N*Kd, 1);
tx = ofdm_mod([repmat(Xp, np, 1); qam_mod(bits, 4)], N, CP);
n  = (0:numel(tx)-1).';
rx = tx .* exp(1j*2*pi*eps*n/N);
N0 = 0.5 / 10^(EbN0_dB/10);
rx = rx + sqrt(N0/2) * (randn(size(rx)) + 1j*randn(size(rx)));
if fxb > 0, rx = quant_fx(rx, fxb, fs); end

if nP == 0
    eps_hat = eps;
else
    c = 0;
    for p = 1:nP-1
        c = c + sum(conj(rx((p-1)*L+1:p*L)) .* rx(p*L+1:(p+1)*L));
    end
    eps_hat = angle(c) * N / (2*pi*L);
end

ph = exp(-1j*2*pi*eps_hat*n/N);
if fxb > 0
    rx = quant_fx(rx .* quant_fx(ph, fxb, 1), fxb, fs);
else
    rx = rx .* ph;
end
Y  = ofdm_demod(rx, N, CP);
Yd = Y(:, np+1:end);

if track
    phi = 0;
    for k = 1:Kd
        y = Yd(:,k) * exp(-1j*phi);
        d = qam_mod(qam_demod(y, 4), 4);
        phi = phi + angle(sum(y .* conj(d)));
        Yd(:,k) = Yd(:,k) * exp(-1j*phi);
    end
end
nerr = sum(qam_demod(Yd, 4) ~= bits);
nb = numel(bits);
end
