function s = qam_mod(bits, M)
% QAM_MOD  Map a bit vector to unit-average-energy constellation symbols.
%   M = 2 (BPSK), 4 (QPSK), 16 (16-QAM). Gray-coded, so neighbouring
%   symbols differ by only 1 bit (one symbol error -> usually one bit error).
%   Output has Es = 1 (average symbol energy), so Eb = 1/log2(M).
k = log2(M);
bits = bits(:);
if M == 2
    s = 2*bits - 1;                       % 0 -> -1, 1 -> +1
    return
end
b = reshape(bits, k, []);                 % each column = bits of one symbol
if k == 2                                 % QPSK: 1 bit on I axis, 1 on Q axis
    I = 2*b(1,:) - 1;  Q = 2*b(2,:) - 1;  sc = 1/sqrt(2);
else                                      % 16-QAM: 2 bits per axis, levels -3,-1,+1,+3
    I = (2*b(1,:) - 1) .* (3 - 2*b(2,:));  % Gray: 00->-3 01->-1 11->+1 10->+3
    Q = (2*b(3,:) - 1) .* (3 - 2*b(4,:));
    sc = 1/sqrt(10);                      % average energy of 16-QAM levels is 10
end
s = ((I + 1j*Q) * sc).';
end
