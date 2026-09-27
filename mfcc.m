
 clc;
clear;
close all;

%% =========================================================
% MFCC FEATURE EXTRACTION
% 65-DIMENSIONAL MFCC REPRESENTATION
% ==========================================================

%% LOAD PREPROCESSED 3-SECOND AUDIO SEGMENT

[file,path] = uigetfile('*.wav', ...
    'Select a preprocessed 3-second WAV segment');

if isequal(file,0)
    error('No audio file selected.');
end

[audio,fs] = audioread(fullfile(path,file));


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
% MFCC PARAMETERS
% ==========================================================

Tw = 25;                    % Frame duration = 25 ms
Ts = 10;                    % Frame shift = 10 ms

alpha = 0.97;               % Pre-emphasis coefficient

R = [300 3700];             % Frequency range

M = 20;                     % Number of Mel filters

N = 13;                     % Number of MFCC coefficients

L = 22;                     % Cepstral lifter


%% =========================================================
% HAMMING WINDOW
% ==========================================================

hammingWindow = ...
    @(N) (0.54 - 0.46*cos(2*pi*(0:N-1)'/(N-1)));


%% =========================================================
% BASIC MFCC EXTRACTION
% ==========================================================

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
% CHECK BASIC MFCC SIZE
% ==========================================================

fprintf('\nBasic MFCC size:\n');
disp(size(MFCC));


%% =========================================================
% DELTA MFCC
% ==========================================================

DeltaMFCC = zeros(size(MFCC));

for c = 1:N

    DeltaMFCC(c,:) = gradient(MFCC(c,:));

end


%% =========================================================
% DELTA-DELTA MFCC
% ==========================================================

DeltaDeltaMFCC = zeros(size(MFCC));

for c = 1:N

    DeltaDeltaMFCC(c,:) = ...
        gradient(DeltaMFCC(c,:));

end


%% =========================================================
% MEAN OF MFCC COEFFICIENTS
% ==========================================================

MeanMFCC = mean(MFCC,2);


%% =========================================================
% STANDARD DEVIATION OF MFCC COEFFICIENTS
% ==========================================================

StdMFCC = std(MFCC,0,2);


%% =========================================================
% CREATE 65-DIMENSIONAL FEATURE VECTOR
% ==========================================================

MFCC65 = [

    mean(MFCC,2);             % 13
    mean(DeltaMFCC,2);        % 13
    mean(DeltaDeltaMFCC,2);   % 13
    MeanMFCC;                 % 13
    StdMFCC                   % 13

];


%% =========================================================
% VERIFY DIMENSION
% ==========================================================

fprintf('\nMFCC feature dimensions:\n');

fprintf('Static MFCC       = %d\n',size(MFCC,1));
fprintf('Delta MFCC        = %d\n',size(DeltaMFCC,1));
fprintf('Delta-Delta MFCC  = %d\n',size(DeltaDeltaMFCC,1));
fprintf('Mean              = %d\n',size(MeanMFCC,1));
fprintf('Standard deviation= %d\n',size(StdMFCC,1));

fprintf('\nTotal MFCC features = %d\n', ...
    length(MFCC65));


%% =========================================================
% SAVE RESULTS
% ==========================================================

save('MFCC_65_Features.mat', ...
    'MFCC65', ...
    'MFCC', ...
    'DeltaMFCC', ...
    'DeltaDeltaMFCC', ...
    'MeanMFCC', ...
    'StdMFCC');

writematrix( ...
    MFCC65', ...
    'MFCC_65_Features.csv');


fprintf('\n65-dimensional MFCC features saved successfully.\n');
