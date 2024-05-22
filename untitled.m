function output   = resettable_sample_and_hold(input, reset, reset_delayed, trigger, trigger_delayed)
%#codegen

%Resettable Sample and Hold Circuit
% This was written because S&H within Resettable Subsystems in Simulink
% is not supported by HDL Coder. We needed this functionality, so this
% custom function was written. 
% Function has both negative and positive edge detection.
% Comment out what isn't needed

% To do: make this more configurable. 



initial_value = fi(0,1,16,15);
persistent sample_held;
if isempty(sample_held)
    sample_held = false;
end

persistent output_held_value;
if isempty(output_held_value);
    output_held_value = fi(0,1,16,15);
end


% positive edge detection

positive_reset_edge = and(reset, xor(reset, reset_delayed));
positive_trigger_edge = and(trigger, xor(trigger, trigger_delayed));


switch positive_reset_edge
    case false % not in reset
        switch positive_trigger_edge 
            case false % no trigger yet, continue to hold
                output = output_held_value;
            case true
                if sample_held == false
                    output_held_value = input;
                    output = output_held_value;
                    sample_held = true;
                else
                    output = output_held_value;
                end
            otherwise % we have to cover all the branches
                output = initial_value; 
        end
    case true % reset signal received - arm trigger, continue to hold
        output = output_held_value;
        sample_held = false;
    otherwise % we have to cover all the branches
        output = initial_value;
end

% negative edge detection

negative_reset_edge = and(reset_delayed, xor(reset, reset_delayed));
negative_trigger_edge = and(trigger_delayed, xor(trigger, trigger_delayed));

switch negative_reset_edge
    case false % not in reset
        switch negative_trigger_edge 
            case false % no trigger yet, continue to hold
                output = output_held_value;
            case true
                if sample_held == false
                    output_held_value = input;
                    output = output_held_value;
                    sample_held = true;
                else
                    output = output_held_value;
                end
            otherwise % we have to cover all the branches
                output = initial_value; 
        end
    case true % reset signal received - arm trigger, continue to hold
        output = output_held_value;
        sample_held = false;
    otherwise % we have to cover all the branches
        output = initial_value;

        
end