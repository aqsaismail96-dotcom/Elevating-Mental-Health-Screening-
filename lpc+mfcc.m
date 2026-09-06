clc;
clear;
close all;

%% =========================================================
%  LOAD AUDIO
% ==========================================================

[audio, fs] = audioread('2937-1-0-0.wav');

% Convert stereo to mono
if size(audio,2) > 1
    audio = mean(audio,2);
end

% Resample to 16 kHz
targetFs = 16000;

if fs ~= targetFs
    audio = resample(audio, targetFs, fs);
    fs = targetFs;
end


%% =========================================================
%  LPC PARAMETERS
% ==========================================================

p = 10;                 % 10 LPC coefficients
frameDuration = 40;    % 40 ms frame
frameLength = round(frameDuration * fs / 1000);

% Frame shift
frameShift = round(10 * fs / 1000);


%% =========================================================
%  MFCC PARAMETERS
% ==========================================================

Tw = 25;                % Frame duration = 25 ms
Ts = 10;                % Frame shift = 10 ms
alpha = 0.97;           % Pre-emphasis coefficient

% Hamming window
hammingWindow = @(N) ...
    (0.54 - 0.46*cos(2*pi*(0:N-1)'/(N-1)));

R = [300 3700];         % Frequency range
M = 20;                 % Number of Mel filters

N = 13;                 % 13 MFCC coefficients
L = 22;                 % Cepstral lifter parameter


%% =========================================================
%  MFCC EXTRACTION
% ==========================================================

[MFCC, FBE, frames] = mfcc( ...
    audio, fs, Tw, Ts, alpha, ...
    hammingWindow, R, M, N, L);


%% =========================================================
%  LPC EXTRACTION
% ==========================================================

% Pre-emphasis
audio_pre = filter([1 -alpha], 1, audio);

% Frame the audio
lpcFrames = vec2frames( ...
    audio_pre, ...
    frameLength, ...
    frameShift, ...
    'cols', ...
    hammingWindow, ...
    false);


% Number of LPC frames
numLPCFrames = size(lpcFrames,2);

% Pre-allocate LPC feature matrix
LPC = zeros(p, numLPCFrames);


%% =========================================================
%  EXTRACT 10 LPC COEFFICIENTS
% ==========================================================

for i = 1:numLPCFrames

    currentFrame = lpcFrames(:,i);

    % LPC analysis
    [A,G,a,r] = autolpc(currentFrame,p);

    % Store 10 LPC coefficients
    LPC(:,i) = a(1:p);

end


%% =========================================================
%  MATCH NUMBER OF FRAMES
% ==========================================================

% MFCC and LPC may produce slightly different
% numbers of frames because their frame lengths differ.

numFrames = min( ...
    size(LPC,2), ...
    size(MFCC,2));


LPC = LPC(:,1:numFrames);
MFCC = MFCC(:,1:numFrames);


%% =========================================================
%  LPC + MFCC FEATURE FUSION
% ==========================================================

FusedFeatures = [
    LPC;
    MFCC
];


%% =========================================================
%  DISPLAY RESULTS
% ==========================================================

disp('LPC feature size:');
disp(size(LPC));

disp('MFCC feature size:');
disp(size(MFCC));

disp('Fused LPC + MFCC feature size:');
disp(size(FusedFeatures));


%% =========================================================
%  SAVE FUSED FEATURES
% ==========================================================

save('LPC_MFCC_Fused_Features.mat', ...
     'FusedFeatures');

writematrix( ...
    FusedFeatures', ...
    'LPC_MFCC_Fused_Features.csv');