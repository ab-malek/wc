clc;   clear;   close all;

% Parameters
Fs = 1000; % Sampling frequency
fc = 100; % Carrier frequency
t = 0:1/Fs:1; % Time vector
m = 0.8; % Modulation index

% Message signal
msg = sin(2*pi*10*t); % Example message signal

% Carrier signal
c = cos(2*pi*fc*t);

% AM modulated signal
s_am = (1 + m*msg).*c;

% Noise power
%noise_power = 1;       % Adjust as needed
% Generate Gaussian noise
%noise = sqrt(noise_power/2) * randn(size(t)); 

% Define SNR (in dB)
snr_db = 1;         % Example SNR

% Calculate noise power
signal_power = mean(s_am.^2); 
noise_power = signal_power / (10^(snr_db/10)); 

% Generate Gaussian noise
noise = sqrt(noise_power/2) * randn(size(s_am)); 

% Add noise to the signal
s_am_noisy = s_am + noise;

% AM modulated Signal with AWGN noise

figure(1)
plot(t, s_am_noisy);
title('AM Modulated Signal with AWGN');
xlabel('Time (s)');
ylabel('Amplitude');


% Demodulation
demodulated_msg = 2*s_am_noisy.*c;    % Multiply by carrier
demodulated_msg = lowpass(demodulated_msg, 10, Fs); % Filter out high-frequency components

% Plot results
figure(2);
subplot(3,1,1);
plot(t, msg);
title('Message Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,2);
plot(t, s_am);
title('AM Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,3);
plot(t, demodulated_msg);
title('Demodulated Message Signal');
xlabel('Time (s)');
ylabel('Amplitude');

