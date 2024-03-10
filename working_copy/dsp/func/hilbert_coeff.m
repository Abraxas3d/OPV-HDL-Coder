% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

function h = hilbert_coeff(n)
  nn = floor(n/2);
  
  h = 2 ./ ((1:nn) * pi);
  h(2:2:end) = 0;
  h = [-flip(h) 0 h];
endfunction