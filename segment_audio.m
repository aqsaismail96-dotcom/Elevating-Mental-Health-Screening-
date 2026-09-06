function segments = segment_audio(audio, Fs)

    % ---------------------------------------------------------
    % Audio Segmentation
    % Segment duration = 3 seconds (3000 ms)
    % Segment overlap = 10%
    % Frame duration = 25 ms
    % A 3-second segment corresponds to 120 x 25-ms frames
    % ---------------------------------------------------------

    % 1. Segment duration
    segmentDuration = 3;          % seconds

    % 2. Segment overlap
    overlap = 0.10;               % 10% overlap

    % 3. Number of samples in one 3-second segment
    segmentLength = round(segmentDuration * Fs);

    % 4. Number of overlapping samples between segments
    overlapLength = round(segmentLength * overlap);

    % 5. Step size between consecutive segments
    hopLength = segmentLength - overlapLength;

    % 6. Calculate number of complete segments
    if length(audio) < segmentLength
        segments = {};
        return;
    end

    numSegments = floor((length(audio) - segmentLength) / hopLength) + 1;

    % 7. Preallocate segment cell array
    segments = cell(numSegments, 1);

    % 8. Extract 3-second overlapping segments
    for i = 1:numSegments

        % Starting sample
        startIndex = (i - 1) * hopLength + 1;

        % Ending sample
        endIndex = startIndex + segmentLength - 1;

        % Extract segment
        segments{i} = audio(startIndex:endIndex);

    end

end