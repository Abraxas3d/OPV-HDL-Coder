clear all; 

Fs = 10e6; 
Ts = 1 / Fs; 

carrier_F = Fs / 3;
base_F    = 200e3;
N         = 10e3; 

t = linspace(0, N * Ts - Ts, N); 

% base_i = cos(2 * pi *  base_F * t);
% base_q = sin(2 * pi *  base_F * t);

[base_i, base_q] = baseband_tones(base_F, 100e3, Fs, N);

carrier_0  = cos(2 * pi * t * carrier_F);
carrier_90 = sin(2 * pi * t * carrier_F);

usb = base_i .* carrier_0 - base_q .* carrier_90;
lsb = base_i .* carrier_0 + base_q .* carrier_90;

usb2 = base_i .* carrier_0 - [0 (base_q .* carrier_0)(1:end-1)];
lsb2 = base_i .* carrier_0 + [0 (base_q .* carrier_0)(1:end-1)];

usb3 = base_i .* carrier_0 - hilbert(base_q .* carrier_0, 13);
lsb3 = base_i .* carrier_0 + hilbert(base_q .* carrier_0, 13);

figure(1);  clf; 
subplot(3, 1, 1);
plot_spectrum(usb, Fs); hold on; 
plot_spectrum(lsb, Fs);
legend('USB', 'LSB');
title('SSB with quadrature baseband and carrier'); 

subplot(3, 1, 2);
plot_spectrum(usb2, Fs); hold on; 
plot_spectrum(lsb2, Fs);
legend('USB', 'LSB');
title('SSB with ouput combiner as sample delay'); 

subplot(3, 1, 3);
plot_spectrum(usb3, Fs); hold on; 
plot_spectrum(lsb3, Fs);
legend('USB', 'LSB');
title('SSB with ouput combiner using hilbert transform'); 
