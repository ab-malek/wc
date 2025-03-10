clc
clear all
close all

%% Custom Functions
function result = de2bi(varargin)
    % Custom de2bi function
    if nargin == 2
        num = varargin{1};
        bits = varargin{2};
        result = zeros(length(num), bits);
        for i = 1:length(num)
            for j = 1:bits
                result(i, bits - j + 1) = mod(num(i), 2);
                num(i) = floor(num(i) / 2);
            end
        end
    else
        error('Custom de2bi function requires 2 inputs.');
    end
end

function result = bi2de(varargin)
    % Custom bi2de function
    if nargin == 2
        bits = varargin{1};
        result = zeros(size(bits, 1), 1);
        for i = 1:size(bits, 1)
            for j = 1:size(bits, 2)
                result(i) = result(i) + bits(i, j) * 2^(size(bits, 2) - j);
            end
        end
    else
        error('Custom bi2de function requires 2 inputs.');
    end
end

function result = pskmod(data, M)
    % Custom pskmod function
    phase = 2 * pi * data / M;
    result = cos(phase) + 1i * sin(phase);
end

function result = pskdemod(data, M)
    % Custom pskdemod function
    phase = angle(data);
    result = round(mod(phase * M / (2 * pi), M));
end

function result = awgn(data, snr, ~)
    % Custom awgn function
    signal_power = mean(abs(data).^2);
    noise_power = signal_power / (10^(snr / 10));
    noise = sqrt(noise_power / 2) * (randn(size(data)) + 1i * randn(size(data)));
    result = data + noise;
end

function [noe, ber] = biterr(data1, data2)
    % Custom biterr function
    noe = sum(data1 ~= data2);
    ber = noe / length(data1);
end

%% Main Program
%% bps
M = 8;
bps = log2(M);

%% input + reshape
txt1 = 'Information and communication engineering';
symbols = double(txt1);
symbolToBitMapping = de2bi(symbols, 8);

totNoBits = numel(symbolToBitMapping);
inputReshapedBits = reshape(symbolToBitMapping, 1, totNoBits);

%% padding
remainder = rem(totNoBits, bps);
if(remainder == 0)
    userPaddedData = inputReshapedBits;
else
    paddingBits = zeros(1, bps - remainder);
    userPaddedData = [inputReshapedBits paddingBits];
end

%% modulation
reshapedUserPaddedData = reshape(userPaddedData, numel(userPaddedData)/bps, bps);
bitToSymbolMapping = bi2de(reshapedUserPaddedData, 'left-msb');
modulatedSymbol = pskmod(bitToSymbolMapping, M);

%% channel
SNR = [];
BER = [];

for snr = 0:15
    SNR = [SNR snr];
    noisySymbols = awgn(modulatedSymbol, snr, 'measured');
    demodulatedSymbol = pskdemod(noisySymbols, M);

    % original data
    demodulatedSymbolToBitMapping = de2bi(demodulatedSymbol, bps);
    reshapedDemodulatedBits = reshape(demodulatedSymbolToBitMapping, 1, numel(demodulatedSymbolToBitMapping));

    % remove padding
    demodulatedBitsWithoutPadding = reshapedDemodulatedBits(1:totNoBits);

    [noe, ber] = biterr(inputReshapedBits, demodulatedBitsWithoutPadding);
    BER = [BER ber];

    % Original Text
    txtBits = reshape(demodulatedBitsWithoutPadding, numel(demodulatedBitsWithoutPadding)/8, 8);
    txtBitsDecimal = bi2de(txtBits, 'left-msb');
    msg = char(txtBitsDecimal);
end

figure(1)
semilogy(SNR, BER, '--');
xlabel('SNR');
ylabel('BER');
title('SNR vs BER');
