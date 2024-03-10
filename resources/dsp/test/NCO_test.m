addpath(genpath(pwd));

clear all; 

Fs = 1e3;
F  = 179;

I = [];
Q = []; 
E = [];

nco  = NCO(Fs);
ncoe = NCOEnable(Fs);

for N = 1:10000
  [i, q] = nco.update(F);
  e      = ncoe.update(F);
  
  I = [i I];
  Q = [q Q];
  E = [e E];
endfor

figure(1); clf;
plot(I); hold on; 
plot(Q); hold on; 
stem(E);

figure(2);
plot_spectrum(I, Fs); hold on;
plot_spectrum(E, Fs);