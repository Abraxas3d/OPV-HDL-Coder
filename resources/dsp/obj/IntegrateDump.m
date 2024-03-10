% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

classdef IntegrateDump < handle
  properties 
    integrator = 0;
  endproperties
  
  methods
    function this = IntegratorDump()
      % nada?
    endfunction
    
    function out = update(this, input)
      this.integrator += input;
      out = this.integrator;
    endfunction
    
    function out = dump(this, input)
      out = this.integrator;
      this.integrator = 0;
    endfunction
  endmethods
endclassdef
