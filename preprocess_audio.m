function [audio, Fs] = preprocess_audio(file_path)

    % 1. Read audio
    [audio, Fs] = audioread(file_path);

    % 2. Channel Standardization
    % Convert stereo/multi-channel audio to mono
    if size(audio, 2) > 1
        audio = mean(audio, 2);
    end

    % 3. Resampling
    % Convert sampling frequency to 16 kHz
    targetFs = 16000;

    if Fs ~= targetFs
        audio = resample(audio, targetFs, Fs);
        Fs = targetFs;
    end

    % 4. Noise Removal / Speech Band Filtering
    % Band-pass filter: 300-3400 Hz
    lowFreq = 300;
    highFreq = 3400;

    audio = bandpass(audio, ...
        [lowFreq highFreq], Fs);

    % 5. Silence Removal
    % Detect and remove low-energy/silent regions
    threshold = 0.02;

    frameLength = round(0.025 * Fs);
    hopLength = round(0.010 * Fs);

    energy = [];

    for i = 1:hopLength:(length(audio)-frameLength)

        frame = audio(i:i+frameLength-1);

        energy(end+1) = rms(frame);

    end

    % Find frames above threshold
    activeFrames = energy > threshold;

    % Convert active frames into samples
    activeAudio = [];

    for i = 1:length(activeFrames)

        if activeFrames(i)

            startSample = (i-1)*hopLength + 1;
            endSample = min( ...
                startSample + frameLength - 1, ...
                length(audio));

            activeAudio = [ ...
                activeAudio; ...
                audio(startSample:endSample)];

        end

    end

    audio = activeAudio;

    % 6. Amplitude Normalization
    maxAmplitude = max(abs(audio));

    if maxAmplitude > 0
        audio = audio / maxAmplitude;
    end

end
