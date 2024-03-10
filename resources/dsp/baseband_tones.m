% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

function [base_i, base_q] = baseband_tones(f, bw, Fs, N)
  t = linspace(0, (N - 1) / Fs, N); 
  
  base_i = zeros(1, N);
  base_q = zeros(1, N);
    
  for tone = linspace(f - bw/2, f + bw/2, 10)
    base_i = base_i + cos(2 * pi * t * tone);
    base_q = base_q + sin(2 * pi * t * tone);
  endfor
endfunction