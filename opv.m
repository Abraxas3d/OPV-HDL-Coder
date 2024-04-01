%% System Data
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
device_clock = 245.76e6; % ADRV9009 receiver IQ rate
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

f1 = channel_center_frequency - outer_deviation;   % carrier frequency for information as 11 (-3)
f2 = channel_center_frequency - inner_deviation;   % carrier frequency for information as 10 (-1)
f3 = channel_center_frequency + inner_deviation;   % carrier frequency for information as 00 (1)
f4 = channel_center_frequency + outer_deviation;   % carrier frequency for information as 01 (3)

%% Preamble Construction
% stay in deviation land
preamble = repmat([3; -3], symbols_per_frame/2, 1);

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

PTT_1 = repmat(0, samples_per_frame, 1);
PTT_2 = repmat(1, samples_per_frame*5, 1);
PTT_3 = repmat(0, samples_per_frame, 1);
PTT = cat(1, PTT_1, PTT_2, PTT_3);
PTT = logical(PTT);
%PTT = timetable(PTT,'SampleRate',Fs)
PTT = timeseries(PTT, 1/sample_rate);

%% Numerically Controlled Oscillator worksheet
phase_increment_f1 = int32((f1*2^32)/device_clock);
phase_increment_f2 = int32((f2*2^32)/device_clock);
phase_increment_f3 = int32((f3*2^32)/device_clock);
phase_increment_f4 = int32((f4*2^32)/device_clock);

phase_increment_bo_be = int32((orthogonal_frequency*2^32)/device_clock);
phase_increment_carrier = int32((carrier_frequency*2^32)/device_clock);

phase_increment_lower = int32(((carrier_frequency-orthogonal_frequency)*2^32)/device_clock);
phase_increment_higher = int32(((carrier_frequency+orthogonal_frequency)*2^32)/device_clock);


%% CIC Worksheet

% Sampling rate of DDC input is device_clock

FsIn = device_clock;    % Sampling rate of DDC input
FsOutTarget = 2*msk_bandwidth;     % Sampling rate of DDC is 2*msk_bandwidth

% Round to ensure an integer. 
FsOutMultiple = round(FsIn/FsOutTarget);

% Find closest power of 2 to this multiple. This will give the closest
% power of 2 above the multiple. We subtract 1 from the multiple in order
% to have a FsOut that is defnitely high enough for sampling our signal. 
% If we keep the exponent as produced by the function, then we may end up 
% with not enough sampling rate for the target signal. 

exponent_for_M = nextpow2(FsOutMultiple);
M = 2^(exponent_for_M - 1);
FsOut = FsIn/M;

Fc = carrier_frequency;     % Carrier frequency
Fpass = msk_bandwidth;      % Passband frequency
                            % sounds double-sided to me, but need to check
                            % this carefully. msk_bandwidth is
                            % null-to-null.
Fstop = FsOut/2 - Fpass;    % Stopband frequency is half the output rate 
                            % minus the passband upper frequency. This
                            % caused the Fstop to be less than Fpass. This
                            % was flagged as an error by the filter
                            % functions.

Fstop = 1.3*Fpass;    % Fstop needs to be higher than the passband.
                      % Followed the example and added a margin above the
                      % Fpass.

Ap = 0.1;           % Passband ripple
Ast = 60;           % Stopband attenuation

% These parameters go into the CIC filter block configuration
cicParams.DecimationFactor = 32;
cicParams.DifferentialDelay = 1;
cicParams.NumSections = 5;
cicParams.FsOut = FsIn/cicParams.DecimationFactor;

cicFilt = dsp.CICDecimator(cicParams.DecimationFactor, ...
    cicParams.DifferentialDelay,cicParams.NumSections)
cicGain = gain(cicFilt)

%%
% Because the CIC gain is a power of two, a hardware implementation can easily 
% correct for the gain factor by using a shift operation.
% For analysis purposes, the example represents the gain correction in MATLAB 
% with a one-tap |dsp.FIRFilter| System object(TM). 

cicGainCorr = dsp.FIRFilter('Numerator',1/cicGain)

%%
% Display the magnitude response of the CIC filter with and without
% gain correction by using |fvtool|. For analysis, 
% combine the CIC filter and the gain 
% correction filter into a |dsp.FilterCascade| System object. CIC filters
% use fixed-point arithmetic internally, 
% so |fvtool| plots both the quantized and unquantized responses. 

ddcPlots.cicDecim = fvtool(...
    cicFilt, ...
    dsp.FilterCascade(cicFilt,cicGainCorr), ...
    'Fs',[FsIn,FsIn]);
legend(ddcPlots.cicDecim, ...
    'CIC No Correction', ...
    'CIC With Gain Correction');

%%
% *CIC Droop Compensation Filter*
%
% Because the magnitude response of the CIC filter has a significant _droop_ within
% the passband region, the example uses a FIR-based droop compensation filter
% to flatten the passband response. The droop compensator has the same properties as the
% CIC decimator. This filter implements decimation by a factor of two, 
% so you must also specify bandlimiting characteristics for the filter. Use 
% the |design| function to return a filter System object with the specified
% characteristics. 

compParams.R = 2;                                % CIC compensation decimation factor
compParams.Fpass = Fstop;                        % CIC compensation passband frequency
compParams.FsOut = cicParams.FsOut/compParams.R; % New sampling rate
compParams.Fstop = compParams.FsOut - Fstop;     % CIC compensation stopband frequency
compParams.Ap = Ap;                              % Same passband ripple as overall filter
compParams.Ast = Ast;                            % Same stopband attenuation as overall filter

compSpec = fdesign.decimator(compParams.R,'ciccomp', ...
    cicParams.DifferentialDelay, ...
    cicParams.NumSections, ...
    cicParams.DecimationFactor, ...
    'Fp,Fst,Ap,Ast', ...
    compParams.Fpass,compParams.Fstop,compParams.Ap,compParams.Ast, ...
    cicParams.FsOut);
compFilt = design(compSpec,'SystemObject',true)

%%
% Plot the combined response of the CIC filter 
% (with gain correction) and droop compensation.

ddcPlots.cicComp = fvtool(...
    dsp.FilterCascade(cicFilt,cicGainCorr,compFilt), ...
    'Fs',FsIn,'Legend','off');

%%
% *Halfband Decimator* (replaced by regular FIR but it's got 3dB gain loss)
%
% The halfband filter provides efficient decimation by two.
% Halfband filters are efficient because approximately half of their
% coefficients are equal to zero, and those multipliers are excluded from
% the hardware implementation.

intermediateSpec = fdesign.decimator(4,'lowpass', ...
    'Fp,Fst,Ap,Ast',Fpass,Fstop,Ap,Ast,compParams.FsOut);
intermediateFilt = design(intermediateSpec,'equiripple','SystemObject',true)

%%
% Plot the response of the DDC up to the halfband filter output.

ddcPlots.intermediateFilt = fvtool(...
    dsp.FilterCascade(cicFilt,cicGainCorr,compFilt,intermediateFilt), ...
    'Fs',FsIn,'Legend','off');

%%
% *Final FIR Decimator*
%
% The final FIR implements the detailed passband and stopband
% characteristics of the DDC. This filter has more coefficients than the
% earlier FIR filters, but because it operates at a lower sampling rate it
% can use resource sharing for an efficient hardware implementation.
%
% Add 3 dB of headroom to the stopband attenuation so that the DDC still 
% meets the specification after fixed-point quantization. This value was 
% found empirically by using |fvtool|.
finalSpec = fdesign.decimator(4,'lowpass', ...
    'Fp,Fst,Ap,Ast',Fpass,Fstop,Ap,Ast+3,intermediateSpec.Fs_out);
finalFilt = design(finalSpec,'equiripple','SystemObject',true)

%%
% Visualize the overall magnitude response of the DDC.

ddcFilterChain           = dsp.FilterCascade(cicFilt,cicGainCorr,compFilt,intermediateFilt,finalFilt);
ddcPlots.overallResponse = fvtool(ddcFilterChain,'Fs',FsIn,'Legend','off');

%% Fixed-Point Conversion
% The frequency response of the floating-point DDC filter chain now meets the
% specification. Next, quantize each filter stage to use fixed-point types 
% and analyze them to confirm that the filter chain still meets the specification.
%
% *Filter Quantization*
%
% This example uses 16-bit coefficients, which are sufficient to meet the 
% specification. Using fewer than 18 bits for the coefficients minimizes 
% the number of DSP blocks that are required for an FPGA implementation. 
% The input to the DDC filter chain is 16-bit data with
% 15 fractional bits. The filter outputs are 18-bit values, which provide
% extra headroom and precision in the intermediate signals.
%
% For the CIC decimator, choosing the |'Minimum section word lengths'|
% fixed-point data type option automatically optimizes the
% internal wordlengths based on the output wordlength
% and other CIC parameters.

cicFilt.FixedPointDataType = 'Minimum section word lengths';
cicFilt.OutputWordLength = 18;

%%
% Configure the fixed-point properties of the gain correction and FIR-based System objects.
% The object uses the default |RoundingMethod| and |OverflowAction|
% property values (|'Floor'| and |'Wrap'| respectively). 
%

% CIC Gain Correction
cicGainCorr.FullPrecisionOverride = false;
cicGainCorr.CoefficientsDataType = 'Custom';
cicGainCorr.CustomCoefficientsDataType = numerictype(fi(cicGainCorr.Numerator,1,16));
cicGainCorr.OutputDataType = 'Custom';
cicGainCorr.CustomOutputDataType = numerictype(1,18,16);

% CIC Droop Compensation
compFilt.FullPrecisionOverride = false;
compFilt.CoefficientsDataType = 'Custom';
compFilt.CustomCoefficientsDataType = numerictype([],16,15);
compFilt.ProductDataType = 'Full precision';
compFilt.AccumulatorDataType = 'Full precision';
compFilt.OutputDataType = 'Custom';
compFilt.CustomOutputDataType = numerictype([],18,16);

% Intermediate
intermediateFilt.FullPrecisionOverride = false;
intermediateFilt.CoefficientsDataType = 'Custom';
intermediateFilt.CustomCoefficientsDataType = numerictype([],16,15);
intermediateFilt.ProductDataType = 'Full precision';
intermediateFilt.AccumulatorDataType = 'Full precision';
intermediateFilt.OutputDataType = 'Custom';
intermediateFilt.CustomOutputDataType = numerictype([],18,16);

% FIR
finalFilt.FullPrecisionOverride = false;
finalFilt.CoefficientsDataType = 'Custom';
finalFilt.CustomCoefficientsDataType = numerictype([],16,15);
finalFilt.ProductDataType = 'Full precision';
finalFilt.AccumulatorDataType = 'Full precision';
finalFilt.OutputDataType = 'Custom';
finalFilt.CustomOutputDataType = numerictype([],18,16);

%%
% *Fixed-Point Analysis*
%
% Inspect the quantization effects with |fvtool|. You can analyze the filters 
% individually or in a cascade. |fvtool| shows the quantized and unquantized (reference)
% responses overlayed. For example, this figure shows the effect of quantizing
% the final FIR filter stage.

ddcPlots.quantizedFIR = fvtool(finalFilt, ...
    'Fs',finalSpec.Fs_Out,'arithmetic','fixed');

%%
% Redefine the |ddcFilterChain| cascade object to include the fixed-point 
% properties of the individual filters. Then, use |fvtool| to analyze the 
% entire filter chain and confirm that the quantized DDC still meets the specification.

ddcFilterChain = dsp.FilterCascade(cicFilt, ...
    cicGainCorr,compFilt,intermediateFilt,finalFilt);
ddcPlots.quantizedDDCResponse = fvtool(ddcFilterChain, ...
    'Fs',FsIn,'Arithmetic','fixed');

legend(ddcPlots.quantizedDDCResponse, ...
    'DDC filter chain');
%% Save Workspace


% Save entire workspace as opv_workspace.mat
save('opv_workspace.mat')


%% Load OPV Workspace and open Simulink Models

% load the workspace created by this script
load('opv_workspace.mat')

% open the simulink model under development
open_system("opv_receiver_HDL_coder_input_Hodgart_Massey")