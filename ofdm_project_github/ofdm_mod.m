function tx = ofdm_mod(sym, N, CP)
% N subcarriers pe IFFT + cyclic prefix. length(sym) N ka multiple ho
X = reshape(sym(:), N, []);
x = ifft(X, N) * sqrt(N);
x = [x(N-CP+1:N, :); x];
tx = x(:);
end
