clear all; 

global bitrate    = 1200;
global oversample = 10;
global Ts         = 1 / (oversample * bitrate);

message = 'Welcome to gusbertianalog.com. Subscribe to All Electronics!';

function [nrz, clk] = message_to_nrz(m) 
  global oversample;
  
  nrz = dec2bin(m + 0, 8); 
  nrz = nrz'(:)' - 48;
  nrz = repelem(nrz, oversample);
  
  clk = zeros(1, 2 * numel(nrz) / oversample);
  clk(1:2:end) = 1;
  clk = repelem(clk, oversample / 2);
endfunction

function plot_spectrum(signal)
  global Ts;
  
  n      = numel(signal);
  
  freq   = 2 * fft(signal .* hamming(n)') / n; 
  freq   = freq(1:end/2); 
  freq   = 20 * log10(abs(freq));
  
  fs     = linspace(0, 0.5 / Ts, numel(freq));
  
  plot(fs, freq);
  grid on;
endfunction

function nrzi = nrzi_from_nrz(signal)
  global oversample; 
  
  register = 0; 
  n        = numel(signal); 
  bits     = n / oversample;
  
  nrzi = [];  
  
  i = 1;
  
  while(i < n)
    s = signal(i);   
    
    o = xor(s, register);
    register = o;
    
    nrzi = [nrzi o];
  
    i += oversample;
  endwhile;
  
  nrzi = repelem(nrzi, oversample);
endfunction

function nrz = nrz_from_nrzi(signal)
  global oversample; 
  
  register = 0; 
  n        = numel(signal); 
  bits     = n / oversample;
  
  nrz = [];  
  
  i = 1;
  
  while(i < n)
    s = signal(i);   
    
    o = xor(s, register);
    register = s;
    
    nrz = [nrz o];
  
    i += oversample;
  endwhile;
  
  nrz = repelem(nrz, oversample);
endfunction


function plot_clocked_signal(signal, clk)
  signal = 0.6 + signal / 2;
  clk    = clk / 2;
  
  stairs(signal); hold on;
  stairs(clk);
endfunction

function edges = edge_detection(signal)
  delayed = [0 signal(1:end-1)];
  
  edges = xor(delayed, signal);
endfunction

function [clk, err, word] = pll_clock_recovery(signal)
  global Ts;
  global oversample; 
  
  nco_width = 65536;
  
  n    = numel(signal);
  clk  = [];
  err  = [];
  word = [];
  
  e  = 0;
  le = 0;
  
  nco_bias     = round(nco_width / oversample) - 140;
  nco_word     = 0;
  nco_phase    = 0; 
  phase_target = 270;
  phase_target = round(phase_target * nco_width / 360);
  
  pi  = 0;
  kp  = 1 / 2^6;
  ki  = 1 / 2^9;
  kd  = 0;
  int = 0;
  
  i = 1; 
  
  nco = 0;
  
  last_sample = 0;
  
  while(i < n)
  
    if (xor(last_sample, signal(i)))
      e = (phase_target - nco_phase); 
      int      = int + e;
      nco_word = kp * e + ki * int;
    endif
        
    last_sample = signal(i); 
 
    nco_phase = nco_phase + nco_bias + nco_word;    
    
    while (nco_phase >= nco_width)
      nco_phase = nco_phase - nco_width;
    endwhile
    while (nco_phase < 0)
      nco_phase = nco_phase + nco_width;
    endwhile
    
    nco = nco_phase >= (nco_width / 2);

            
    clk  = [clk nco];
    err  = [err e];
    word = [word nco_word];
  
    i++;
  endwhile
  
endfunction

function plot_message(message)
  global oversample;
  
  Y = 1.1;
  H = 0.08;
  W = oversample * 8;
  
  hold on; 

  i = 1; 
  
  x = 1; 
  
  while(i <= numel(message))
    line([x + W, x + W], [Y - H, Y + H/3]);
    line([x + 0, x + 0], [Y - H, Y + H/3]);

    line([x, x + W], [Y + H/4, Y + H/4], 'linestyle', '-.');

    text(x + W/2 - 9, Y + H/1.15, message(i), 'fontsize', 15);
    
    x = x + W;
    i = i + 1;
  endwhile
  
  hold off;
endfunction


clf;

[nrz, clk] = message_to_nrz(message);
nrzi       = nrzi_from_nrz(nrz);
decod      = nrz_from_nrzi(nrzi);
edges      = edge_detection(nrz);
decod2     = nrz_from_nrzi(not(nrzi));

[recovery, recovery_error, word] = pll_clock_recovery(nrz);

figure(1);
sub1 = subplot(2, 1, 1);
stairs(nrz);
plot_message(message); grid on;
title('NRZ data'); xlabel('counts');
set(gca, "linewidth", 1, "fontsize", 12);

sub2 = subplot(2, 1, 2); 
plot_spectrum(nrz); grid on; 
title('Spectrum of the NRZ stream'); xlabel('Hz');
set(gca, "linewidth", 1, "fontsize", 12);


figure(2);
sub1 = subplot(2, 1, 1); 
plot_clocked_signal(nrz, edges); grid on;
title('NRZ data and detected edges');
legend('NRZ data', 'Data edges');
set(gca, "linewidth", 1, "fontsize", 12);


sub2 = subplot(2, 1, 2);
plot_spectrum(edges); grid on; 
title('Spectrum of the NRZ edges'); xlabel('Hz');
set(gca, "linewidth", 1, "fontsize", 12);


figure(3); 
seg = 1000;
sub1 = subplot(3, 1, 1);
%stairs(clk); hold on;
%stairs(recovery);
plot_clocked_signal(nrz, clk);
grid on; 
title('NRZ data and tx clock');
legend('NRZ Datastream', 'Tx internal clock'); 

xlim([1, seg]);
set(gca, "linewidth", 1, "fontsize", 12)


sub2 = subplot(3, 1, 2);
%plot_clocked_signal(nrz, recovery);
%stairs(clk + 0); hold on;
%stairs(recovery);
plot_clocked_signal(clk, edges);
stairs(-0.6 + recovery/2);

grid on; 
title('Edges and recovered clock'); 
legend('Tx internal clock', 'Data edges', 'Recovered clock');
set(gca, "linewidth", 1, "fontsize", 12)

sub3 = subplot(3, 1, 3);

stairs(recovery_error); hold on;
grid on; 
title('PLL phase-error'); 
%stairs(word); hold on;
legend('Error [counts]');
xlim([1, seg]);

linkaxes([sub1, sub2, sub3], 'x');

set(gca, "linewidth", 1, "fontsize", 12)

figure(4); 
seg = 1000;
sub1 = subplot(2, 1, 1);
plot_clocked_signal(nrz, recovery);
plot_message(message);
set(gca, "linewidth", 1, "fontsize", 12)
title('Received data and recovered clock'); 
legend('Received data', 'Recovered clock');


