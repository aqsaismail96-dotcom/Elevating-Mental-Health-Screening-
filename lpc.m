
clc;
clear;
close all;

%% =========================================================
% LPC FEATURE EXTRACTION
% 10 LPC COEFFICIENTS PER FRAME
% ==========================================================

%% LOAD PREPROCESSED 3-SECOND AUDIO SEGMENT

[file, path] = uigetfile('*.wav', ...
    'Select a preprocessed 3-second WAV segment');

if isequal(file,0)
    error('No audio file selected.');
end

[audio, fs] = audioread(fullfile(path,file));


%% =========================================================
% CONVERT TO MONO
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
% LPC PARAMETERS
% ==========================================================

p = 10;                         % LPC order = 10

frameDuration = 40;             % 40 ms
frameShiftDuration = 10;        % 10 ms

frameLength = round( ...
    frameDuration * fs / 1000);

frameShift = round( ...
    frameShiftDuration * fs / 1000);


%% =========================================================
% HAMMING WINDOW
% ==========================================================

hammingWindow = ...
    @(N) (0.54 - 0.46*cos(2*pi*(0:N-1)'/(N-1)));


%% =========================================================
% FRAME THE SIGNAL
% ==========================================================

LPCFrames = vec2frames( ...
    audio, ...
    frameLength, ...
    frameShift, ...
    'cols', ...
    hammingWindow, ...
    false);


%% =========================================================
% NUMBER OF FRAMES
% ==========================================================

numFrames = size(LPCFrames,2);


%% =========================================================
% PRE-ALLOCATE LPC MATRIX
% ==========================================================

LPC = zeros(p,numFrames);


%% =========================================================
% LPC EXTRACTION
% ==========================================================

for i = 1:numFrames

    currentFrame = LPCFrames(:,i);

    % LPC analysis
    [A,G,a,r] = autolpc(currentFrame,p);

    % Store 10 LPC coefficients
    LPC(:,i) = a(1:p);

end


%% =========================================================
% DISPLAY RESULTS
% ==========================================================

fprintf('\nLPC Feature Extraction Results\n');
fprintf('Sampling frequency: %d Hz\n',fs);
fprintf('Frame duration: %d ms\n',frameDuration);
fprintf('Frame shift: %d ms\n',frameShiftDuration);
fprintf('LPC order: %d\n',p);
fprintf('Number of frames: %d\n',numFrames);

fprintf('\nLPC feature matrix size:\n');
disp(size(LPC));


%% =========================================================
% SAVE LPC FEATURES
% ==========================================================

save('LPC_Features.mat','LPC');

writematrix( ...
    LPC', ...
    'LPC_Features.csv');

fprintf('\nLPC features saved successfully.\n');
