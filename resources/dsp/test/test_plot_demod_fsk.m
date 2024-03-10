clear all; addpath(genpath(pwd));

load 'data/data_fsk';
load 'data/data_fsk_demod_bitstream';

figure(2);

ax1 = subplot(2, 1, 1); 
stairs(bitstr); 
title('Tx Bitstream');
xlabel('samples');
set(gca, "linewidth", 1, "fontsize", 12);

ax2 = subplot(2, 1, 2); 
plot(_bitstream);
title('Rx Bitstream (SNR = 0dB)');
xlabel('samples');
set(gca, "linewidth", 1, "fontsize", 12);

linkaxes([ax1 ax2], 'x');