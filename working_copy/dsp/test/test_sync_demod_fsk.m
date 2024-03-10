clear all; addpath(genpath(pwd));

load './data/data_fsk_demod_bitstream';

% generate a time error 
_bitstream = _bitstream(236:end); 
_bitstream = _bitstream(rand(1, numel(_bitstream)) > 0.02);  

Fb  = 9600;
Fc  = 1e6; 
Fs  = 6 * Fc; 
Fd  = Fb / 2;
Fcc = Fc - Fd/2;

Ts = 1 / Fs; 
Tc = 1 / Fc;
Tb = 1 / Fb;

_t = 0;

_i = 1; 

sampler_rate = 2 * Fb; ;

nco_sampler = NCOEnable(Fs);
controller  = PIController(40e3, 100, sampler_rate / 2);

fsm         = 0;

reg0 = 0;
reg1 = 0;

gard_error = 0;

_error = [];

_sampling = [];

while(_i < numel(_bitstream))
  _bit = _bitstream(_i); 
  _sm = 0;
  
  if (nco_sampler.update(sampler_rate - controller.output()))
    
    disp(controller.output());
    
    if (fsm) % we need to compute gardner error
      
      gard_error = (_bit - reg1) * reg0;
      controller.update(gard_error);
      
      _sm = _bit; % for simulation
      
    endif
    
    fsm = !fsm;
    
    reg1 = reg0; % sampler pipeline
    reg0 = _bit;
  endif
  
  _sampling(_i) = _sm;
  _error(_i)    = gard_error;
  
  _i++;
endwhile

figure(3); 
ax1 = subplot(2, 1, 1);
plot(_bitstream); grid on; hold on;
_ss = find(_sampling != 0);
stem(_ss, _sampling(_ss), 'o');
title('Rx Bitstream and sampling points');
xlabel('samples');
set(gca, "linewidth", 1, "fontsize", 12);


ax2 = subplot(2, 1, 2);
plot(_error);
xlabel('samples');
title('Gardner Timing Error');
set(gca, "linewidth", 1, "fontsize", 12);

linkaxes([ax1, ax2], 'x');

