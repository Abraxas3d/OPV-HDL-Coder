clear all; addpath(genpath(pwd));

message = string_to_bitstream('Welcome to All Electronics Channel! I am Gregory Frizon Gusberti and you are welcome!');
message = repmat(message, 1, 10);
message = message(1:100);

message_length = numel(message);

Fb  = 9600;
Fc  = 1e6; 
Fs  = 6 * Fc; 
Fd  = Fb / 2;
Fcc = Fc - Fd/2;

Ts = 1 / Fs; 
Tc = 1 / Fc;
Tb = 1 / Fb;

_t = 0;
_i = 1; 

_timer_bit = 0;
_count_bit = 1;

rf_sw  = [];
rf_nco = [];
bitstr = [];

nco = NCO(Fs);

while(1)
  bit  = message(_count_bit);
  
  rf_sw(_i)  = cos(2 * pi * _t * (Fcc + Fd * bit));
  rf_nco(_i) = nco.update(Fcc + Fd * bit);
  bitstr(_i) = bit;
  
  _timer_bit += Ts;
  if (_timer_bit > Tb)
    _timer_bit -= Tb;
    disp(['new bit: ' num2str(_count_bit) ' from ' num2str(message_length)]);
    if (++_count_bit > message_length)
      break;
    endif
  endif
  
  _i++;
  _t += Ts;
endwhile

save -binary 'data/data_fsk' rf_sw rf_nco bitstr message;

figure(1);

subplot(2, 1, 1);
plot(rf_sw); hold on;
plot(rf_nco); grid on;
legend('Direct cos', 'NCO');
set(gca, "linewidth", 1, "fontsize", 12);

subplot(2, 1, 2);
plot_spectrum(rf_sw, Fs); hold on;
plot_spectrum(rf_nco, Fs); grid on;
legend('Direct cos', 'NCO');
set(gca, "linewidth", 1, "fontsize", 12);