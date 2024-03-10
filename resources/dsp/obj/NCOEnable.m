% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

% This NCO class deliveries only an enable pulse on wraparound

classdef NCOEnable < handle
  properties
    phase = 0;
    k     = 0;
  endproperties
  
  methods
    function this = NCOEnable(Fs)
      this.k = 2 * pi / Fs;
    endfunction
    
    function out = update(this, frequency_input)
      this.phase = this.phase + this.k * frequency_input;
      
      out = 0;
      while (this.phase > 2 * pi)
        this.phase = this.phase - 2 * pi; 
        out = 1;
      endwhile
      while (this.phase < 0)
        this.phase = this.phase + 2 * pi;
        out = 1;
      endwhile
    endfunction
  endmethods
endclassdef