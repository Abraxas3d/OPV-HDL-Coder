% Implementa uma transformada aproximada de hilbert
% Utiliza cascatas no formato yin and yang

clear all; 

Fs       = 100e3;
Ts       = 1 / Fs;
t        = [ 0 0 0 ];
n        = 1;
T        = 1e-3;

x        = [ 1 0 0 ];
y        = [ 0 0 0 ];

f1a        = 0.2;

f1x  = 0;

f1y  = 0;
f1x1 = 0;
f1y1 = 0;
f1x2 = 0;
f1y2 = 0;

tt = 0;

h1 = class_yin_yang_hilbert(0.95);
h2 = class_yin_yang_hilbert(0.95);
h3 = class_yin_yang_hilbert(0.95);

function h = hilbert(n)
  nn = floor(n/2);
  
  h = 1 ./ ((1:nn) * pi);
  h(2:2:end) = 0;
  h = [-flip(h) 0 h];
endfunction

while(tt < T)
  xx = (n == 1);
  
  y(n) = h3.update(h2.update(h1.update(xx))); % + h2.update(xx);
  x(n) = xx;

  t(n) = tt;
  
  tt += Ts;
  
  n++; 
endwhile

figure(1); clf; hold on; grid on;
stem(t, x);
stem(t, y);

figure(2); clf; hold on; grid on; 
_fft(y, Fs);

figure(3); clf;
a = hilbert(7) .* hamming(7)';
%a = [a zeros(1, 1000)];
_fft(a, 1, 1);




