% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

classdef PIController < handle
  properties
    reference   = 0;
    last_error  = 0;
    integrator  = 0; 
    last_output = 0;
    Kp = 0;
    Ki = 0;
    Fs = 0;
  endproperties

  methods
    function this = PIController(Kp, Ki, Fs)
      this.Fs = Fs;
      this.Ki = Ki / Fs; 
      this.Kp = Kp;
    endfunction
    
    function set_reference(this, reference)
      this.reference = reference;
    endfunction
    
    function out = update(this, input)
      error = this.reference - input; 
      
      this.integrator += error; 
      
      out = this.Kp * error + this.Ki * this.integrator; 
      this.last_output = out;
      this.last_error = error; 
    endfunction
    
    function out = output(this)
      out = this.last_output;
    endfunction
  endmethods
endclassdef
