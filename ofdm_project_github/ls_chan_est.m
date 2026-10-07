function Hhat = ls_chan_est(Yp, Xp, Lmax, denoise)
% pilot se LS channel estimate. denoise=1 pe Lmax taps ke baad ka sab zero (wo noise hai)
Hhat = Yp ./ Xp;
if denoise
    h = ifft(Hhat);
    h(Lmax+1:end) = 0;
    Hhat = fft(h);
end
end
