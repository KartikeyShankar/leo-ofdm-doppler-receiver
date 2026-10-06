function [nerr, nb, eps_hat] = cfo_link(eps, EbN0_dB, Xp, N, CP, Kd, mode)
% ek frame bhejo: 2 same pilot symbols + Kd data symbols, CFO eps (subcarrier spacing ka multiple)
% mode: 0 = koi correction nahi, 1 = Moose estimate se, 2 = true eps pata hai (genie)
bits = randi([0 1], 2*N*Kd, 1);
tx = ofdm_mod([Xp; Xp; qam_mod(bits, 4)], N, CP);
n  = (0:numel(tx)-1).';
rx = tx .* exp(1j*2*pi*eps*n/N);
N0 = 0.5 / 10^(EbN0_dB/10);
rx = rx + sqrt(N0/2) * (randn(size(rx)) + 1j*randn(size(rx)));

L = N + CP;
eps_hat = angle(sum(conj(rx(1:L)) .* rx(L+1:2*L))) * N / (2*pi*L);

if mode == 1, e = eps_hat; elseif mode == 2, e = eps; else e = 0; end
rx = rx .* exp(-1j*2*pi*e*n/N);
Y  = ofdm_demod(rx, N, CP);
nerr = sum(qam_demod(Y(:, 3:end), 4) ~= bits);
nb = numel(bits);
end
