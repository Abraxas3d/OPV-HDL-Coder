clear all; addpath(genpath(pwd));

load './data/data_fsk';

figure(1);

ax1 = subplot(2, 1, 1); 
stairs(bitstr); 
title('Tx Bitstream');
xlabel('samples');
set(gca, "linewidth", 1, "fontsize", 12);

ax2 = subplot(2, 1, 2); 
plot(rf_nco);
title('FSK IF at 1MHz');
xlabel('samples');
set(gca, "linewidth", 1, "fontsize", 12);

linkaxes([ax1 ax2], 'x');