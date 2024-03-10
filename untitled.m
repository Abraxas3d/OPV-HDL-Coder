%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creative Commons
% Attribution-Noncommercial 2.5 India
% You are free:
% to Share — to copy, distribute and transmit the work
% to Remix — to adapt the work
% Under the following conditions:
% Attribution. You must attribute the work in the manner 
% specified by the author or licensor (but not in any way 
% that suggests that they endorse you or your use of the work). 
% Noncommercial. You may not use this work for commercial purposes. 
% For any reuse or distribution, you must make clear to others the 
% license terms of this work. The best way to do this is with a 
% link to this web page.
% Any of the above conditions can be waived if you get permission 
% from the copyright holder.
% Nothing in this license impairs or restricts the author's moral rights.
% http://creativecommons.org/licenses/by-nc/2.5/in/

% Author	: Krishna
% Email		: krishna@dsplog.com
% Version	: 1.0
% Date		: 18 January 2008
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% script for generting transmit waveforms in a minimum shift 
% keying, a form of continuous phase frequency shift keying

clear all
close all

rand('seed',777); % initializing the random state
N = 7; % number of bits
ipBin = rand(1,N) > 0.5; % binary 0's and 1's

fs = 100;
fc = 1;
T = 1;

ts = [0:1/fs:T]; % generting the sampling instants
ts = ts(1:end-1);
tsR = kron(ones(1,N),ts);

ip =  2*ipBin-1; % converting 0's to -1, 1's to 1

% generating two frequencies corresponding to 0 and 1
% 0 --> fc - 1/4T
% 1 --> fc + 1/4T
fm = ip/(4*T); 
fmR = kron(fm,ones(1,fs)); % repeating

% genertaing the phase
theta = pi/2*filter([0 1],[1 -1],ip);
thetaR = kron(theta,ones(1,fs)); % repeating

xt = cos(2*pi*(fc+fmR).*tsR + thetaR );

% plotting
subplot(3,1,1),plot(kron(ip,ones(1,fs)));
axis([0 N*fs -1.25 1.25]);grid on
subplot(3,1,2), plot(xt);
axis([0 N*fs -1 1]);grid on
subplot(3,1,3),plot(kron(mod(theta*180/pi,360),ones(1,fs)))
axis([0 N*fs -360 360]);grid on





