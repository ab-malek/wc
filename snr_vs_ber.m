clc
clear all
close all

%% Define M-PSK Parameters
M = 8; % Number of symbols in M-PSK
bps = log2(M); % Bits per symbol

%% Generate Random Symbols or Convert Text to Binary
%nosymbol = 600; 
%symbols = randi([0, 255], 1, nosymbol); % Random symbols in range 0-255
%symbolToBitMapping = de2bi(symbols, 8, 'left-msb'); % Convert to 8-bit binary

% Convert Text to Binary
txt1 = 'Information and communication engineering'; 
symbols = double(txt1); % Convert characters to ASCII values
symbolToBitMapping = de2bi(symbols, 8, 'left-msb'); % Convert ASCII to binary

%% Reshape Bits for Transmission
totNoBits = numel(symbolToBitMapping);
inputReshapedBits = reshape(symbolToBitMapping, 1, totNoBits);

%% Padding Bits (if necessary)
remainder = rem(totNoBits, bps); % Check remainder for M-PSK grouping
if remainder == 0
    userPaddedData = inputReshapedBits;
else
    paddingBits = zeros(1, bps - remainder); % Zero-padding
    userPaddedData = [inputReshapedBits paddingBits];
end

%% M-PSK Modulation
userPaddedData = reshape(userPaddedData, numel(userPaddedData)/bps, bps);
bitToSymbolMapping = bi2de(userPaddedData, 'left-msb'); % Convert to decimal symbols
modulatedSymbol = pskmod(bitToSymbolMapping, M); % PSK modulation

%% Transmission Over AWGN Channel
SNR = [];
BER = [];
for snr = 0:15
    SNR = [SNR snr];
    
    % Add AWGN noise
    noisySymbols = awgn(modulatedSymbol, snr, 'measured');
    
    % PSK Demodulation
    demodulatedSymbol = pskdemod(noisySymbols, M);
    
    % Convert Symbols to Bits
    demodulatedSymbolToBitMapping = de2bi(demodulatedSymbol, 'left-msb'); 
    reshapedDemodulatedBits = reshape(demodulatedSymbolToBitMapping, 1, numel(demodulatedSymbolToBitMapping));

    % Remove Padding
    demodulatedBitsWithoutPadding = reshapedDemodulatedBits(1: totNoBits);

    % Compute Bit Error Rate (BER)
    [noe, ber] = biterr(inputReshapedBits, demodulatedBitsWithoutPadding);
    BER = [BER ber];

    %% Recover Original Text
    txtBits = reshape(demodulatedBitsWithoutPadding, numel(demodulatedBitsWithoutPadding)/8, 8);
    txtBitsDecimal = bi2de(txtBits, 'left-msb');
    msg = char(txtBitsDecimal);
end



%% Plot BER vs. SNR
figure(1)
semilogy(SNR, BER, '-o');
xlabel('SNR');
ylabel('BER');
title('SNR vs BER');
