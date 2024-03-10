% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

function s = delay_samples(signal, samples)
  s = [zeros(1, samples) signal(1:end-samples)]; 
endfunction