function tx = ofdm_mod(sym, N, CP)
% ofdm_mod: N symbols ko N subcarriers pe IFFT se daalo, phir har block ke last CP
% samples ko uske aage chipka do (cyclic prefix, yahi OFDM ki jaan hai).
% sym ki length N ka multiple honi chahiye. sqrt(N) scaling se power same rehti hai.
sym = sym(:);
X  = reshape(sym, N, []);                 % har column = ek OFDM symbol (frequency domain)
x  = ifft(X, N) * sqrt(N);                % time domain mein aa gaye
x  = [x(N-CP+1:N, :); x];                 % cyclic prefix aage laga diya
tx = x(:);
end
