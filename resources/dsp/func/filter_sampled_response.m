% Developed by Gregory F. Gusberti 
% All Electronics Channel - youtube.com/allelectronicschannel

function h = filter_sampled_response(H)
  N = 2 * numel(H) - 1;
  n = numel(H);
  
  nn = 0:n-1;

  h = zeros(1, n); 
  
  for n_i = 0:n-1
    h(n_i+1) = H(1);
    
    for h_i = 1:n-1
      h(n_i+1) = h(n_i+1) + 2 * H(h_i+1) * cos(h_i * n_i * 2 * pi / N);
    endfor
  endfor
  
  h = h / N;
  h = [flip(h(2:end)) h(1) h(2:end)];
  h = h .* hanning(N)';
endfunction

% https://www.allaboutcircuits.com/technical-articles/design-of-fir-filters-using-frequency-sampling-method/