clear all;

rand('seed', 2);

Fs       = 10e6; 
baudrate = 250e3; 

Cfreq    = 2e6;
Cphse    = 45;
Cppm     = 500 / 1e6;

Ts = 1 / Fs;

N = 2e3;

_baud_timer     = 0;
_time           = 0;
_current_symbol = 0;

signal_modulated = zeros(1, N);
signal_baseband  = zeros(1, N);

for i = 1:N
  _baud_timer += Ts; 
  _time       += Ts;
  
  if (_baud_timer >= 1/baudrate)
   
    _current_symbol = (randi(8) - 1) / 8;
    _baud_timer -= 1/baudrate;
  endif
  
  carrier = cos((2 * pi * _current_symbol) + 2 * pi * _time * (1 + Cppm) * Cfreq + deg2rad(Cphse)); 
  
  signal_baseband(i)  = _current_symbol;
  signal_modulated(i) = carrier + randn(1) / 100;
endfor;

figure(1); clf;
subplot(2, 1, 1); stairs(signal_baseband);
subplot(2, 1, 2); stairs(signal_modulated);

%% costas loop 
function [i, q] = rotate(I, Q, ang)
  ang = deg2rad(ang); 
  i   = I * cos(ang) - Q * sin(ang);
  q   = I * sin(ang) + Q * cos(ang);
endfunction

filter_I    = AVGFilter(8); 
filter_Q    = AVGFilter(8); 
filter_loop = PIController(2, 1, Fs);
nco         = NCO(Fs);
control     = 0;

costas_I = []; 
costas_Q = [];
costas_c = [];
for i = 1:N
  [nco_i, nco_q] = nco.update(Cfreq + 10e3 * control);
  branch_I = nco_i * signal_modulated(i); 
  branch_Q = nco_q * signal_modulated(i);
  
  branch_I = filter_I.update(branch_I);
  branch_Q = filter_Q.update(branch_Q);
  
  e_I = branch_I;
  e_Q = branch_Q;
  
  error = sign(e_I) * branch_Q - sign(e_Q) * branch_I;
  
  [ri, rq] = rotate(e_I, e_Q, 45); 
  error += sign(ri) * rq - sign(rq) * ri;
  
  control = filter_loop.update(error);
  
  costas_I(i) = branch_I;
  costas_Q(i) = branch_Q;
  costas_c(i) = control;
endfor

figure(2); clf;

subplot(2, 1, 1); 
stairs(costas_I); hold on; 
stairs(costas_Q);

subplot(2, 1, 2); 
stairs(costas_c);

figure(3); 
_plot_last = 1000;
plot(costas_I(end-_plot_last:end), costas_Q(end-_plot_last:end), 'o');
xlim([-1, 1]); ylim([-1, 1]);



