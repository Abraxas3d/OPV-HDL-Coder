% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

classdef NCO < handle
  properties
    phase = 0;
    k     = 0;
  endproperties
  
  methods
    function this = NCO(Fs)
      this.k = 2 * pi / Fs;
    endfunction
    
    function [out_I, out_Q] = update(this, frequency_input)
      this.phase = this.phase + this.k * frequency_input;
      
      while (this.phase > 2 * pi)
        this.phase = this.phase - 2 * pi; 
      endwhile
      while (this.phase < 0)
        this.phase = this.phase + 2 * pi;
      endwhile
      
      out_I = cos(this.phase);
      out_Q = sin(this.phase);
    endfunction
  endmethods
endclassdef