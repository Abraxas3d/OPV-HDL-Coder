function _fft(signal, Fs, compensate_delay = 0)
  %[H, W] = freqz(signal); 
  
  %if (compensate_delay)
  % H = H .* exp(1i * W * floor(numel(signal)/2));
  
  %endif
  %  freqz_plot(W, H); 

  %return
  _fft_d = fft(signal); 
  
  _fft_d = _fft_d(1:end/2);
  
  

  _fft_x = linspace(0, Fs/2, numel(_fft_d));

  subplot(2, 1, 1); 
  plot(_fft_x, 20 * log10(abs(_fft_d))); grid on;
  ylabel('Amplitude [dB]');
  xlabel('Hz');
  grid on;

  subplot(2, 1, 2); 
  ar = arg(_fft_d);
  n  = numel(signal);
  n2 = numel(_fft_d);
  
  % compensate delay for a response symmetric
  % and centered, for odd lengths
  % for even, change 1/2 for 1
  if (compensate_delay)
    %ar = ar + 2 * ((0:n2-1) + 1/2) * floor(n/2) * pi / (n);
    
    
  endif
  
  stem(_fft_x, rad2deg(unwrap(_fft_d))); grid on;
  ylabel('Phase [deg]');
  xlabel('Hz');
  grid on;
endfunction 

function _afft(signal, Fs)
  _fft_d = fft(signal(1:end)); 
  _fft_d = _fft_d(1:end/2);

  _fft_x = linspace(0, Fs/2, numel(_fft_d));
  
  ax = plotyy(_fft_x, 20 * log10(abs(_fft_d )), _fft_x, rad2deg(arg(_fft_d)))

  ylabel(ax(1), 'Amplitude [dB]');
  xlabel('Hz');

  subplot(2, 1, 2); 
  ylabel(ax(2), 'Phase [deg]');
  grid on;
endfunction 