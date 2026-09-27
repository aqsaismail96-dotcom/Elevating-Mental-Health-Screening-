

 function [audio, Fs] = preprocess_audio(file_path)
% PREPROCESS_AUDIO
% Preprocessing pipeline used for DAIC-WOZ speech recordings.
%
% Steps:
% 1. Read audio
% 2. Channel standardization (stereo/multichannel -> mono)
% 3. Resampling to 16 kHz
% 4. Band-pass filtering from 300 to 3400 Hz
% 5. Silence removal using short-time RMS energy thresholding
% 6. Peak normalization
%
% Input:
%   file_path - path of input WAV file
%
% Output:
%   audio - preprocessed audio signal
%   Fs    - sampling frequency (16 kHz)

%% ---------------------------------------------------------
% 1. Read audio
% ----------------------------------------------------------

[audio, Fs] = audioread(file_path);


%% ---------------------------------------------------------
% 2. Channel Standardization
% ----------------------------------------------------------
% Convert stereo or multi-channel recordings to mono by
% averaging the channels.

if size(audio, 2) > 1
    audio = mean(audio, 2);
end


%% ---------------------------------------------------------
% 3. Resampling
% ----------------------------------------------------------
% Standardize all recordings to 16 kHz.
% MATLAB resample() uses anti-aliasing filtering during
% sample-rate conversion.

targetFs = 16000;

if Fs ~= targetFs
    audio = resample(audio, targetFs, Fs);
    Fs = targetFs;
end


%% ---------------------------------------------------------
% 4. Speech-Band Filtering
% ----------------------------------------------------------
% Retain the primary frequency range of human speech.
% Frequencies below 300 Hz and above 3400 Hz are attenuated.

lowFreq  = 300;
highFreq = 3400;

audio = bandpass(audio, [lowFreq highFreq], Fs);


%% ---------------------------------------------------------
% 5. Silence Removal using Short-Time Energy
% ----------------------------------------------------------
% Short-time RMS energy is calculated using:
% Frame duration = 25 ms
% Frame shift    = 10 ms
%
% Frames below the empirical energy threshold are considered
% non-speech/silent frames.

frameDuration = 0.025;   % 25 ms
frameShift    = 0.010;   % 10 ms

frameLength = round(frameDuration * Fs);
hopLength   = round(frameShift * Fs);

% Empirical RMS energy threshold
energyThreshold = 0.02;

% Number of frames
numFrames = floor((length(audio) - frameLength) / hopLength) + 1;

% Sample-level mask
speechMask = false(length(audio), 1);

for i = 1:numFrames

    % Frame starting and ending positions
    startSample = (i-1) * hopLength + 1;
    endSample   = startSample + frameLength - 1;

    % Extract frame
    frame = audio(startSample:endSample);

    % Short-time RMS energy
    frameEnergy = sqrt(mean(frame.^2));

    % Keep frame if its energy is above threshold
    if frameEnergy > energyThreshold

        speechMask(startSample:endSample) = true;

    end

end

% Remove non-speech/silent samples
audio = audio(speechMask);


%% ---------------------------------------------------------
% 6. Peak Normalization
% ----------------------------------------------------------
% Normalize the signal so that its maximum absolute amplitude
% is equal to 1.

if ~isempty(audio)

    maxAmplitude = max(abs(audio));

    if maxAmplitude > 0
        audio = audio / maxAmplitude;
    end

end


%% ---------------------------------------------------------
% Return preprocessed signal
% ----------------------------------------------------------

end
