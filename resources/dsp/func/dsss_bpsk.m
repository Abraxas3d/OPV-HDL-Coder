% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

function signal = dsss_bpsk(bitstream, PRBSgen, Fcarrier, bitrate, shirprate)
  oversample = 4;
  
  Tcarrier = 1 / Fcarrier; 
  Tshirp   = 1 / shirprate;
  Tbit     = 1 / bitrate;

  Ts       = Tcarrier / oversample; 
  
  signal = [];
  
  _bit_timer     = 0; 
  _shirp_timer   = 0;
  _bit_counter   = 1;
  _shirp_counter = 1;
  
  _current_shirp = PRBSgen.output();; 
  _current_bit   = bitstream(1);
  _current_phase = (2 * xor(_current_bit, _current_shirp) + -1);

  _t = 0; 
  
  _i = 1; 
  
  while(1)
    if (_bit_timer >= Tbit)
      _bit_counter += 1;
      _bit_timer -= Tbit; 
   
      if (_bit_counter == numel(bitstream) + 1)
        break;
      endif
      
      disp(['new bit: ' num2str(_bit_counter)]);
      
      _current_bit   = bitstream(_bit_counter);
      _current_phase = (2 * xor(_current_bit, _current_shirp) + -1);
    endif
    
    if (_shirp_timer >= Tshirp)
      _shirp_counter += 1;
      _shirp_timer -= Tshirp;
      
      _current_shirp = PRBSgen.update();
      _current_phase = (2 * xor(_current_bit, _current_shirp) + -1);
    endif    
    
    signal(_i) = _current_phase * cos(2 * pi * _t * Fcarrier); 
  
    _bit_timer   += Ts; 
    _shirp_timer += Ts;
    _t           += Ts; 
    _i           += 1;
  endwhile
endfunction