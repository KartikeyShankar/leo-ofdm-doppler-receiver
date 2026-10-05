function tx = ofdm_mod(sym, N, CP)
% OFDM_MOD  Put N data symbols on N orthogonal subcarriers using an IFFT,
%   then copy the last CP samples of each block to its front (cyclic prefix).
%   sym length must be a multiple of N. Power is preserved (unitary scaling).
sym = sym(:);
X  = reshape(sym, N, []);                 % each column = one OFDM symbol (frequency domain)
x  = ifft(X, N) * sqrt(N);                % time domain
x  = [x(N-CP+1:N, :); x];                 % prepend cyclic prefix
tx = x(:);
end
