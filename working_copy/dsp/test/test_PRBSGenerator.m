addpath(genpath(pwd)); clear all; 

prbs  = PRBSGenerator(9, [0 1 0 1]);
%prbs2 = PRBSGenerator(10, [0 0 0 0 0 0 1 1]);

disp('full sequence'); 
seq  = prbs.__full_sequence();
%seq2 = prbs2.__full_sequence();
disp(['sequence length: ' num2str(numel(seq))]);

% gold = bitxor(seq, seq2);

out  = zeros(1, 10); 

for i = 1:100
  out(i) = prbs.update();
endfor

% figure(1); 
% stem(xcorr(seq, seq)); hold on;
% stem(xcorr(gold, gold));

figure(2); 
stem(xcorr(seq, seq));  hold on;
%stem(xcorr(seq, seq2)); 