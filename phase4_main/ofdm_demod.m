function Y = ofdm_demod(rx, N, CP)
% ofdm_demod: cyclic prefix hatao, phir FFT se wapas subcarriers pe aao.
% Output: N x K matrix (har column ek OFDM symbol).
x = reshape(rx(:), N + CP, []);
x = x(CP+1:end, :);                       % CP fek diya, kaam khatam uska
Y = fft(x, N) / sqrt(N);
end
