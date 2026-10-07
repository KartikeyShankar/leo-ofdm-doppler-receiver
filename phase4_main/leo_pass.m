function [t, el, fd, fdr] = leo_pass(h_km, fc, el_min)
% overhead LEO pass, circular orbit, spherical earth
% output: time (s), elevation (deg), Doppler (Hz), Doppler rate (Hz/s)
Re = 6371; mu = 398600.4418; c = 299792.458;     % km, km^3/s^2, km/s
Rs = Re + h_km;
w  = sqrt(mu / Rs^3);
t  = -600:1:600;
th = w * t;
dx = Rs * sin(th);
dy = Rs * cos(th) - Re;                          % user sits at (0, Re)
d  = sqrt(dx.^2 + dy.^2);                        % slant range
el = asin(dy ./ d) * 180/pi;
ok = el >= el_min;
t = t(ok);  el = el(ok);  d = d(ok);
fd  = -fc * gradient(d, t) / c;                  % approaching -> positive
fdr = gradient(fd, t);
end
