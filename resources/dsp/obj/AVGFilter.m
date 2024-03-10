% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

classdef AVGFilter < handle
  properties
    register = []
    N        = 0;
    c        = 1;
  endproperties
  
  methods
    function this = AVGFilter(N)
       this.register = zeros(1, N);
       this.N        = N;       
    endfunction
    
    function output = update(this, new_sample)
      this.register(this.c) = new_sample;
      
      %this.c = this.c + 1; 
      if (++this.c > this.N)
         this.c = 1;
      endif
            
      output = sum(this.register) / this.N;
    endfunction
  endmethods
endclassdef