function bits = qam_demod(r, M)
% hard decision demapper, qam_mod ka ulta
k = log2(M);
r = r(:);
if M == 2
    bits = double(real(r) > 0);
    return
end
if k == 2
    b = [real(r).' > 0; imag(r).' > 0];
else
    x = real(r).' * sqrt(10);  y = imag(r).' * sqrt(10);
    b = [x > 0; abs(x) < 2; y > 0; abs(y) < 2];
end
bits = double(b(:));
end
