function Y = ofdm_demod(rx, N, CP)
% CP hatao, FFT karo. Output N x K (har column ek OFDM symbol)
x = reshape(rx(:), N + CP, []);
x = x(CP+1:end, :);
Y = fft(x, N) / sqrt(N);
end
