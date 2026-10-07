function y = quant_fx(x, bits, fs)
% signed fixed-point quantizer: round + saturate. complex input ok.
% bits = 16 aur fs = 1 matlab Q15
q = 2^(bits-1);
f = @(v) max(min(round(v/fs*q), q-1), -q) / q * fs;
y = f(real(x)) + 1j*f(imag(x));
end
