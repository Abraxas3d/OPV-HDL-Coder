% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

function plot_spectrum(signal, Fs)
  signal = signal + randn(1, numel(signal)) / 1e2;
  signal = signal .* blackman(numel(signal))';
   
  _fft_d = fft(signal) / numel(signal); 

  _fft_d = _fft_d(1:end/2);
  
  _fft_x = linspace(0, Fs/2, numel(2 * _fft_d));

  plot(_fft_x / 1e6, 20 * log10(abs(_fft_d))); grid on;
  ylabel('Amplitude [dB]');
  xlabel('Frequency MHz');
  grid on;  
  ylim([-90, 0]);
endfunction