
  
 function frames = frame_segment(segment, Fs)
% FRAME_SEGMENT
% Divides a 3-second segment into 25-ms frames.
%
% Frame duration = 25 ms
% Frame shift    = 10 ms

frameDuration = 0.025;   % 25 ms
frameShift    = 0.010;   % 10 ms

frameLength = round(frameDuration * Fs);
hopLength   = round(frameShift * Fs);

numFrames = floor((length(segment) - frameLength) / hopLength) + 1;

frames = zeros(frameLength, numFrames);

for i = 1:numFrames

    startSample = (i-1) * hopLength + 1;

    endSample = startSample + frameLength - 1;

    frames(:,i) = segment(startSample:endSample);

end

end
