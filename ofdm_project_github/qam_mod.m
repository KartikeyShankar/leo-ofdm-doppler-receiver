function s = qam_mod(bits, M)
% bits -> BPSK/QPSK/16-QAM symbols (Gray coded, Es = 1)
k = log2(M);
bits = bits(:);
if M == 2
    s = 2*bits - 1;
    return
end
b = reshape(bits, k, []);
if k == 2
    I = 2*b(1,:) - 1;  Q = 2*b(2,:) - 1;  sc = 1/sqrt(2);
else
    I = (2*b(1,:) - 1) .* (3 - 2*b(2,:));   % 00->-3 01->-1 11->+1 10->+3
    Q = (2*b(3,:) - 1) .* (3 - 2*b(4,:));
    sc = 1/sqrt(10);                         % avg energy 10 -> normalise
end
s = ((I + 1j*Q) * sc).';
end
