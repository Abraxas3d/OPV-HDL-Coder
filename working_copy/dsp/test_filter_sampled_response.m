imp = [1 zeros(1, 50)]; 

fh  = [1 3 6];
fil = filter_sampled_response(numel(fh) * fh/sum(fh));

figure(1); 
stem(fil);

basen = 2; 
base  = ones(1, basen)/basen;

figure(2); clf;
[H, W] = freqz(base); 
%freqz_plot(W, H);  hold on;
plot(W/pi, 20 * log10(abs(H))); hold on;


[H, W] = freqz(conv(base, fil)); 
%freqz_plot(W, H); 
plot(W/pi, 20 * log10(abs(H))); hold on;

xlim([0, 0.5]); 
ylim([-15, 5]);