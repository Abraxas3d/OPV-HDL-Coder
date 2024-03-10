classdef class_yin_yang_hilbert < handle
  properties
    x1 = 0;
    y1 = 0;
    x2 = 0;
    y2 = 0;
    a  = 0.9;
  endproperties

  methods
    function this = class_yin_yang_hilbert(a)
      this.a = a;
    endfunction
    
    function y = update(this, new_x)
      y = this.a * ( new_x + this.y2 ) - this.x2;
     
      this.x2 = this.x1;
      this.x1 = new_x;
      this.y2 = this.y1;
      this.y1 = y;
           
    endfunction
    
    function reset(this)
      this.x2 = 0;   
      this.x1 = 0;
      this.y2 = 0;
      this.y1 = 0;
    endfunction
  endmethods
endclassdef