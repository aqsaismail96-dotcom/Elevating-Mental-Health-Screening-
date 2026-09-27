



clc;
clear;
close all;

%% =========================================================
% LPC + MFCC FEATURE FUSION
% TOTAL = 75 FEATURES
% LPC = 10
% MFCC = 65
% ==========================================================


%% LOAD PREPROCESSED 3-SECOND AUDIO

[file,path] = uigetfile('*.wav', ...
    'Select a preprocessed 3-second WAV segment');

if isequal(file,0)
    error('No audio file selected.');
end

[audio,fs] = audioread(fullfile(path,file));


%% =========================================================
% MONO CONVERSION
% ==========================================================

if size(audio,2) > 1
    audio = mean(audio,2);
end


%% =========================================================
% RESAMPLE TO 16 kHz
% ==========================================================

targetFs = 16000;

if fs ~= targetFs

    audio = resample(audio,targetFs,fs);

    fs = targetFs;

end


%% =========================================================
% HAMMING WINDOW
% ==========================================================

hammingWindow = ...
    @(N) (0.54 - 0.46*cos(2*pi*(0:N-1)'/(N-1)));


%% =========================================================
% =========================================================
% PART A: LPC EXTRACTION
% =========================================================
% =========================================================

p = 10;

frameDurationLPC = 40;
frameShiftLPC = 10;

frameLengthLPC = ...
    round(frameDurationLPC * fs / 1000);

frameShiftSamplesLPC = ...
    round(frameShiftLPC * fs / 1000);


%% FRAME AUDIO FOR LPC

LPCFrames = vec2frames( ...
    audio, ...
    frameLengthLPC, ...
    frameShiftSamplesLPC, ...
    'cols', ...
    hammingWindow, ...
    false);


%% NUMBER OF LPC FRAMES

numLPCFrames = size(LPCFrames,2);


%% PRE-ALLOCATE

LPC = zeros(p,numLPCFrames);


%% EXTRACT LPC

for i = 1:numLPCFrames

    currentFrame = LPCFrames(:,i);

    [A,G,a,r] = autolpc( ...
        currentFrame,p);

    LPC(:,i) = a(1:p);

end


%% =========================================================
% LPC STATISTICS
% ==========================================================

LPC_Mean = mean(LPC,2);

LPC_Std = std(LPC,0,2);


%% =========================================================
% =========================================================
% PART B: MFCC EXTRACTION
% =========================================================
% ==========================================================

Tw = 25;
Ts = 10;

alpha = 0.97;

R = [300 3700];

M = 20;

N = 13;

L = 22;


%% EXTRACT MFCC

[MFCC,FBE,frames] = mfcc( ...
    audio, ...
    fs, ...
    Tw, ...
    Ts, ...
    alpha, ...
    hammingWindow, ...
    R, ...
    M, ...
    N, ...
    L);


%% =========================================================
% DELTA MFCC
% ==========================================================

DeltaMFCC = zeros(size(MFCC));

for c = 1:N

    DeltaMFCC(c,:) = ...
        gradient(MFCC(c,:));

end


%% =========================================================
% DELTA-DELTA MFCC
% ==========================================================

DeltaDeltaMFCC = ...
    zeros(size(MFCC));

for c = 1:N

    DeltaDeltaMFCC(c,:) = ...
        gradient(DeltaMFCC(c,:));

end


%% =========================================================
% MFCC STATISTICS
% ==========================================================

MFCC_Mean = mean(MFCC,2);

MFCC_Std = std(MFCC,0,2);


%% =========================================================
% DELTA STATISTICS
% ==========================================================

Delta_Mean = mean(DeltaMFCC,2);


%% =========================================================
% DELTA-DELTA STATISTICS
% ==========================================================

DeltaDelta_Mean = ...
    mean(DeltaDeltaMFCC,2);


%% =========================================================
% 65-DIMENSIONAL MFCC VECTOR
% ==========================================================

MFCC65 = [

    MFCC_Mean;
    Delta_Mean;
    DeltaDelta_Mean;
    MFCC_Mean;
    MFCC_Std

];


%% =========================================================
% 75-DIMENSIONAL LPC + MFCC VECTOR
% ==========================================================

FusedFeatures = [

    LPC_Mean;
    LPC_Std;
    MFCC65

];


%% =========================================================
% DISPLAY DIMENSIONS
% ==========================================================

fprintf('\n========================================\n');
fprintf('FEATURE EXTRACTION RESULTS\n');
fprintf('========================================\n');

fprintf('LPC mean       = %d\n',length(LPC_Mean));
fprintf('LPC std        = %d\n',length(LPC_Std));

fprintf('MFCC features  = %d\n',length(MFCC65));

fprintf('Fused features = %d\n', ...
    length(FusedFeatures));

fprintf('========================================\n');


%% =========================================================
% SAVE
% ==========================================================

save('LPC_MFCC_Fused_Features.mat', ...
    'FusedFeatures', ...
    'LPC', ...
    'MFCC', ...
    'DeltaMFCC', ...
    'DeltaDeltaMFCC', ...
    'MFCC65');


writematrix( ...
    FusedFeatures', ...
    'LPC_MFCC_Fused_Features.csv');


fprintf('\nFeatures saved successfully.\n');
