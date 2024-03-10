% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

function bitstream = string_to_bitstream(string)  
  bitstream = dec2bin(string + 0, 8); 
  bitstream = bitstream'(:)' - 48;
endfunction
