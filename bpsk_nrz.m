% BPSK Modulation and Demodulation
clc;
clear all;
close all;

binary_sequence = [1 0 1 1 0 0 1 0 0 1];
number_bits = length(binary_sequence);

% Define Parameters
Eb = 2;
Tb = 1;
Ac = 1;
nc = 4;
fc = nc/Tb;
tf = 99;
t = 0:1/tf:1;
tn = 0:1/(tf+1):number_bits;
tt = tn(1,2:end);

% Carrier Signal
wc = 2*pi*fc;
xc = Ac*cos(wc*t);

% Polar NRZ signal generation
NRZ = [];
for m = 1:number_bits
    if binary_sequence(m) == 1
        NRZ = [NRZ ones(1,length(t))];
    else
        NRZ = [NRZ -ones(1,length(t))];
    end
end

% BPSK Signal Generation
TX = [];
for n = 1:number_bits
    if binary_sequence(n) == 1
        TX = [TX sqrt(2*Eb/Tb)*cos(2*pi*fc*t)];
    else
        TX = [TX -sqrt(2*Eb/Tb)*cos(2*pi*fc*t)];
    end
end

% Manually AWGN noise add
SNR = -50;
Ps = mean(abs(TX).^2);
Pn = Ps/(10^(SNR/10));
noise = sqrt(Pn) * randn(1,length(TX));
RX = TX + noise;

% Coherent Demodulation
LO = sqrt(2/Tb)*cos(2*pi*fc*t);
BINSEQDET = [];
CS = [];
for n = 1:number_bits
    temp = RX([(n-1)*(tf+1)+1:n*(tf+1)]);
    S = sum(temp.*LO);
    CS = [CS S];
    if (S>0)
        BINSEQDET = [BINSEQDET 1];
    else
        BINSEQDET = [BINSEQDET 0];
    end
end

bit_errors = sum(abs(BINSEQDET - binary_sequence));
disp(['Total Bit Errors: ', num2str(bit_errors)]);

figure(1)
plot(t,xc)
title('Carrier Signal')
xlabel('Time(s)');
ylabel('Amplitude');

figure(2)
subplot(2,1,1)
plot(tt,NRZ)
title('Polar NRZ input binary sequence')
xlabel('Time(s)');
ylabel('Amplitude');

subplot(2,1,2)
plot(tt,TX(1,1:length(tt)));
title('BPSK modulated signal')
xlabel('Time(s)');
ylabel('Amplitude');

figure(3)
subplot(2,1,1)
plot(tt,RX(1,1:length(tt)));
title('Received BPSK Signal')
xlabel('Time(s)');
ylabel('Amplitude');

subplot(2,1,2)
stem(CS);
title('Output of the Coherent Correlation receiver');

figure(4)
subplot(2,1,1)
stem(binary_sequence,'Linewidth',2)
title('Input binary sequence');

subplot(2,1,2)
stem(BINSEQDET,'Linewidth',2)
title('Detected binary sequence');
