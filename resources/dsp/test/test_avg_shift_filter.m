
figure(1); 
[H, W] = freqz([1 1 1 1]);

[H2, W2] = freqz([1 1 1 1 1 1 0.5 0.5]);

figure(1); clf;

plot(W, 20 * log(abs(H))); hold on;
plot(W2, 20 * log(abs(H2)));
