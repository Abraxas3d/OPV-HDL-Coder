%% System Data for Transmitter
samples_per_symbol = 10;
bits_per_symbol = 2;
symbols_per_frame = 1084;
symbol_rate = 27100;
bit_rate = bits_per_symbol*symbol_rate;
symbol_period = 1/symbol_rate;
bit_period = 1/bit_rate;
frame_duration = symbol_period*symbols_per_frame;
samples_per_frame = symbols_per_frame*samples_per_symbol;
sample_rate = samples_per_symbol*symbol_rate;
device_clock = 2e6; % 2 MHz to test with
%device_clock = 245.76e6; % ADRV9009 receiver IQ rate
channel_width = 10e6/64;
%Hodgart_Massey
delay = round(device_clock*(1/bit_rate));
bias = 0.00;


%% MSK Implementation
% Support section
% create a carrier frequency for the MSK signal that is a multiple
% of 1/4*bit_period, so that the total phase at bit transitions is
% exactly pi/2. Select either floor or ceiling to get close to center.
orthogonal_frequency = 1/(4*bit_period);
carrier_frequency_multiple_floor = floor((channel_width/2)/(orthogonal_frequency));
carrier_frequency_multiple_ceil = ceil((channel_width/2)/(orthogonal_frequency));
carrier_frequency = carrier_frequency_multiple_ceil*(orthogonal_frequency);
msk_bandwidth = 1.5*bit_rate;
Tb_delay = floor((bit_period)/(1/device_clock));


%% Minimum frequency shift keying attempt from books
% definition of minimum frequency shift keying
deviation = 0.5*symbol_rate;

%center_frequency = 905.05e6;
channel_center_frequency = channel_width/2;
%center_frequency = 200e3;


% refer to the 2-sided deviation clarification from Earl McCune's DSP book
%outer_deviation = 3*deviation;  % symbol rate for spacing
outer_deviation = 3*deviation/2; % MFSK 1/2 Symbol rate for spacing
%outer_deviation = 1800; %C4FM
%outer_deviation = 33.25e3;

%inner_deviation = deviation;    % symbol rate for spacing
inner_deviation = deviation/2;   % MFSK 1/2 symbol rate for spacing
%inner_deviation = 600; %C4FM
%inner_deviation = 16.62e3;

modulation_index = deviation/symbol_rate;
%modulation_index = 2*outer_deviation * symbol_period/3;

%% Preamble Construction
% stay in deviation land
% preamble = repmat([3; -3], symbols_per_frame/2, 1);
% This doesn't make sense without four tones - change to ZC
% This is a Zadoff-Chu sequence, similar to the one in 3GPP LTE
% It has essentially zero autocorrelation off of the zero lag position.
% Commonly used for synchronization in cellular protocols. 

% Sequence length for 1084 symbol frame. Largest prime number
% less than 1084 is 1069. Use this, then extend mod Nzc.
% But I think we really need bits here, 
% so it's 2168, with 2161 nearest prime.
Nzc = 2161;

% Root index
u = 69;

% Zadoff Chu sequence function
Preamble1 = zadoffChuSeq(u,Nzc);

% cyclically extend our sequence to match the number of symbols in a 
% frame. We have to do this in two chunks because matlab is 1-based
% and the cool n mod Nzc indexing trick doesn't work because of the 0.

Preamble2 = zeros(1,symbols_per_frame*2+1)';

for i = 1:Nzc
    Preamble2(i) = Preamble1(i);
end

for i = Nzc+1:symbols_per_frame*2
    Preamble2(i) = Preamble1(i-Nzc);
end

Preamble2(symbols_per_frame*2 + 1) = 0+0i;

% Visualization
figure('Name', 'OPV Zadoff-Chu Sequence I vs Q');
plot(Preamble2);
figure('Name', 'OPV Zadoff-Chu Sequence')
plot([1:symbols_per_frame*2],real(Preamble2(1:symbols_per_frame*2)));
 

% We now take the 1084*2 length discrete Fourier transform.
% A second argument to fft specifies a number of points n for 
% the transform, representing DFT length.

Preamble3 = fft(Preamble2, symbols_per_frame*2);
Preamble3 = Preamble3/sqrt(symbols_per_frame*2);

% visualization
figure('Name', 'OPV Preamble in Frequency Domain')
plot([1:symbols_per_frame*2], Preamble3)

Preamble = Preamble2;
%Preamble = fi(Preamble2,1,16,15);
a = fi(0,1,16,15);

%% Received Samples Data
% example of how to create data in the workspace so it can be brought in
% as a workspace variable in simulink.

%received_samples = zeros(samples_per_frame*20, 1);

% received_samples = repmat([0;1], samples_per_frame*10, 1);
% received_samples = received_samples*2^14;
% received_samples = complex(received_samples);
% received_samples = fi(received_samples)
% received_samples = timeseries(received_samples, 1/sample_rate);


%% Create a Push to Talk (PTT) Signal


PTT_1 = repmat(0, 100, 1);
PTT_2 = repmat(1, symbols_per_frame*3, 1);
PTT_3 = repmat(0, symbols_per_frame, 1);
PTT_4 = repmat(1, symbols_per_frame*2, 1);
PTT = cat(1, PTT_1, PTT_2, PTT_3, PTT_4);
PTT = logical(PTT);
PTTlength = length(PTT);
%PTT = timetable(PTT,'SampleRate',Fs)
PTT = timeseries(PTT, 1/(symbol_rate*2)); % at the bit rate

%% Numerically Controlled Oscillator worksheet
% (desired frequency * 2^register width) / sample or clock rate

phase_increment_bo_be = int32((orthogonal_frequency*2^32)/device_clock);
phase_increment_carrier = int32((carrier_frequency*2^32)/device_clock);

phase_increment_lower = int32(((carrier_frequency-orthogonal_frequency)*2^32)/device_clock);
phase_increment_higher = int32(((carrier_frequency+orthogonal_frequency)*2^32)/device_clock);



%% Save Workspace


% Save entire workspace as opv_workspace.mat
save('opv_workspace.mat')


%% Load OPV Workspace and open Simulink Models

% load the workspace created by this script
load('opv_workspace.mat')

% open the simulink model under development
open_system("opv_receiver_HDL_coder_input_Hodgart_Massey")