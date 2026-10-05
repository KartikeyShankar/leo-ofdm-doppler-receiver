function Y = ofdm_demod(rx, N, CP)
% OFDM_DEMOD  Remove cyclic prefix, FFT back to subcarriers. Output: N x K matrix.
x = reshape(rx(:), N + CP, []);
x = x(CP+1:end, :);                       % discard the cyclic prefix
Y = fft(x, N) / sqrt(N);
end
