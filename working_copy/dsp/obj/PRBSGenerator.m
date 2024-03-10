% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

classdef PRBSGenerator < handle
  properties
    register = [];
    taps     = [];
    N        = 0;
  endproperties
  
  methods 
    function this = PRBSGenerator(N, taps)
      if (numel(taps) < N)
        this.taps = [zeros(1, N - numel(taps)) taps];
      else
        this.taps = taps;
      endif
            
      this.N        = N;
      this.register = ones(1, N);
    endfunction
    
    function output_bit = update(this)
      feedback = sum(this.register .* this.taps); 
      feedback = mod(feedback, 2) != 0;      
      
      this.register = [feedback this.register(1:end-1)];
      output_bit    = this.register(end);
    endfunction
    
    function output_bit = output(this)
      output_bit = this.register(end);
    endfunction
    
    function sequence = __full_sequence(this)
      prbs = PRBSGenerator(this.N, this.taps);
      
      for i = 1:(2^this.N-1)
        sequence(i) = prbs.update();
      endfor
    endfunction
  endmethods
endclassdef