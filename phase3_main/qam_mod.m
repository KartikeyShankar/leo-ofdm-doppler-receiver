function s = qam_mod(bits, M)
% qam_mod: bits ko constellation symbols mein badalta hai (BPSK / QPSK / 16-QAM)
% M = 2, 4 ya 16. Gray coding use ki hai, matlab padosi points mein sirf 1 bit ka
% farak hota hai -> galti se padosi point pakda gaya toh bhi 1 hi bit galat hoga.
% Average symbol energy Es = 1 rakhi hai, isliye Eb = 1/log2(M).
k = log2(M);
bits = bits(:);
if M == 2
    s = 2*bits - 1;                       % 0 -> -1, 1 -> +1, simple hai bhai
    return
end
b = reshape(bits, k, []);                 % har column = ek symbol ke bits
if k == 2                                 % QPSK: ek bit I axis pe, ek Q axis pe
    I = 2*b(1,:) - 1;  Q = 2*b(2,:) - 1;  sc = 1/sqrt(2);
else                                      % 16-QAM: har axis pe 2 bits, levels -3,-1,+1,+3
    I = (2*b(1,:) - 1) .* (3 - 2*b(2,:));  % Gray: 00->-3  01->-1  11->+1  10->+3
    Q = (2*b(3,:) - 1) .* (3 - 2*b(4,:));
    sc = 1/sqrt(10);                      % 16-QAM ki avg energy 10 aati hai, usse divide
end
s = ((I + 1j*Q) * sc).';
end
