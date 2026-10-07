function h = rayleigh_chan(L, decay)
% L-tap Rayleigh channel, exponential power profile, total power = 1
p = exp(-(0:L-1) / decay);
p = p / sum(p);
h = sqrt(p/2) .* (randn(1, L) + 1j*randn(1, L));
end
