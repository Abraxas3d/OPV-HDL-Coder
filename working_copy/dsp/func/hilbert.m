% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

function o = hilbert(signal, n)
  h = hilbert_coeff(n) .* hanning(n)'; 

  o = conv(signal, h); 

  o = o(n/2:end-n/2);
endfunction