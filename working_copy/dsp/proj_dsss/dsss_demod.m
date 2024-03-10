% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

addpath(genpath(pwd)); clear all; 

load 'data/data_dsss_bpsk';
rf = rf(50:end);
rf_i = 1;

Fs       = 4 * 2.1e6;

Fcarrier = 2.1e6;
Fshirp   = 1.5 * 511e3;
THRSH_AQUISITION = 900;
COUNT_DUMP       = floor(1/4 * 511 * Fs / Fshirp); 

nco_carrier  = NCO(Fs); nco_carrier.phase = pi/4;
nco_despread = NCOEnable(Fs);

prbs_I     = PRBSGenerator(9, [0 1 0 1]);

aquis_id_I = IntegrateDump();
aquis_id_Q = IntegrateDump();
counter_dump    = 0;

_sync_state = 'aquisition'; 

% vectors for visualization 
_vec_id_pwr = [];
_vec_I      = [];
_vec_Q      = [];
_vec_prbs_I = [];
_vec_desp_I = [];
_vec_desp_Q = [];

while(rf_i < 10e3)
  _rf = rf(rf_i);
  
  [carr_I, carr_Q] = nco_carrier.update(Fcarrier);
  
  _I = carr_I * _rf; 
  _Q = carr_Q * _rf;
  
  _prsb_I = 2 * prbs_I.output() - 1;
  
  _desp_I = _I * _prsb_I;
  _desp_Q = _Q * _prsb_I;
  
  aquis_id_I.update(_desp_I);
  aquis_id_Q.update(_desp_Q);
  
  if (++counter_dump == COUNT_DUMP)
    counter_dump = 0;
    
    _id_pw_I = abs(aquis_id_I.dump());
    _id_pw_Q = abs(aquis_id_Q.dump());
    
    _vec_id_pwr = [_vec_id_pwr (_id_pw_I + _id_pw_Q)];
    
    if (_id_pw_I + _id_pw_Q < THRSH_AQUISITION)
      nco_despread.phase += pi;
    else
      _sync_state = 'tracking';
    endif
  else
    _vec_id_pwr = [_vec_id_pwr 0];
  endif
  
  if (nco_despread.update(Fshirp))
    prbs_I.update();
  endif
  
  rf_i = rf_i + 1;
  
  _vec_I = [_vec_I _I];
  _vec_Q = [_vec_Q _Q];
  
  _vec_desp_I = [_vec_desp_I _desp_I];
  _vec_desp_Q = [_vec_desp_Q _desp_Q];
  
  _vec_prbs_I = [_vec_prbs_I _prsb_I];
endwhile

hold on;

clf;
ax1 = subplot(3, 1, 1);
plot(_vec_I); hold on;
plot(_vec_Q);
stairs(_vec_prbs_I);
legend('_I', '_Q', '_prbs_I'); 

ax2 = subplot(3, 1, 2); 
% plot(_vec_desp_I); hold on;
plot(_vec_desp_Q);

ax3 = subplot(3, 1, 3);
stem(_vec_id_pwr);

linkaxes([ax1, ax2, ax3], 'x');

