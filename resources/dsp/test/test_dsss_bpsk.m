addpath(genpath(pwd)); clear all; 

message = 'All Electronics Channel';
sync    = '@?!';

bitstream = string_to_bitstream([sync message]);
prbs      = PRBSGenerator(9, [0 1 0 1]);

% profile clear;
% profile on;

rf = dsss_bpsk(bitstream(1:end), prbs, 2.1e6, 1200, 1.5 * 511e3);

% profile off; 
% profshow(profile('info'));

save -binary './data/data_dsss_bpsk' rf;