clear all; addpath(genpath(pwd));
pkg load communications; % needed for awgn function

load './data/data_fsk';

Fb  = 9600;
Fc  = 1e6; 
Fs  = 6 * Fc; 
Fd  = Fb / 2;
Fcc = Fc - Fd/2;

Ts = 1 / Fs; 
Tc = 1 / Fc;
Tb = 1 / Fb;

_t = 0; % linspace(0, numel(rf_sw) * Ts - Ts, numel(rf_sw));

##lpfilt = fir1(20, 5 * Fb / Fs);

_c = cos(2 * pi * _t * Fc);
_s = sin(2 * pi * _t * Fc);

rf = awgn(rf_nco, 0, 'measured');

_i = 1; 

nco_f1 = NCO(Fs);
nco_f2 = NCO(Fs);

fsize  = floor(1 * Fs / Fb);

avg_f1_i = AVGFilter(fsize);
avg_f1_q = AVGFilter(fsize);

avg_f2_i = AVGFilter(fsize);
avg_f2_q = AVGFilter(fsize);

_bitstream = [];

while(_i < numel(rf))
  _rf = rf(_i); 
  
  [f1_i, f1_q] = nco_f1.update(Fcc);
  [f2_i, f2_q] = nco_f2.update(Fcc + Fd);
  
  bin_f1_i = avg_f1_i.update(_rf * f1_i);
  bin_f1_q = avg_f1_q.update(_rf * f1_q);
  
  bin_f2_i = avg_f2_i.update(_rf * f2_i);
  bin_f2_q = avg_f2_q.update(_rf * f2_q);
  
  _bitstream(_i) = (bin_f1_i**2 + bin_f1_q**2) - (bin_f2_i**2 + bin_f2_q**2);
  
  _i++;
endwhile

figure(1); 
ax1 = subplot(2, 1, 1);
stairs(2 * bitstr - 1); grid on; hold on;
stairs(_bitstream);
set(gca, "linewidth", 1, "fontsize", 12);

ax2 = subplot(2, 1, 2);
stairs(_bitstream); grid on;
set(gca, "linewidth", 1, "fontsize", 12);

linkaxes([ax1, ax2], 'x');

% save -binary 'data/data_fsk_demod_bitstream' _bitstream;

##_i = _c .* rf;
##_q = _s .* rf;
##
##_i = filtfilt(lpfilt, [1], _i);
##_q = filtfilt(lpfilt, [1], _q);
##
##_d_i = diff(_i) / Ts;
##_d_q = diff(_q) / Ts;
##
##_s = _i + i * _q;
##
##figure(1); 
##
##ax1 = subplot(2, 1, 1);
##stairs(bitstr);
##
##ax2 = subplot(2, 1, 2);
##plot(_i); hold on;
##plot(_q); grid on;
##legend('I', 'Q');
##
##linkaxes([ax1, ax2], 'x');
##
##figure(2); 
##plot(bitstr); hold on;
##plot(100 * arg(_s(2:end) .* conj(_s(1:end-1))));