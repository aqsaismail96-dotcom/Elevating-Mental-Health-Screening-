
function [feature_result]=LBP_function(x)
% filename = 'D:\RESEARCH_WORK\speech recognition projects\audio dataset\dataset\Breathing\breathing-001.wav';

% Read the data back into MATLAB using audioread.
% [x,Fs] = audioread('D:\Research\sound 16 Oct Start\feature extracted\LBP_Feature\breathing-001.wav');
% x(t) is the main signal, it is digitized version of audio clip

stem(x);  % plot the digitized sampled version of audio clip
% % t=spectogram(y);
% spectrogram(y)

% if P=8, it means 8 neighbours and 1 reference sample. total frame size
% will be 9 in this case
P=8; % no of neighbours for computation 

b_right=zeros(1,4); % variables for computing differnces on sides
b_left=b_right;

[row,c]=size(x); % total number of samples is "row"
total_frames=row/9;  % number of total frames as 1 Frames=9 samples
                    % so total frames = total samples/ frame size
k=1;

 for i=5:9:total_frames  %runs for tatal number of samples in signal
    for r=0:(P/2)-1  % Sumation loop from formula
     a1=x(i + (r-(P/2)));
     a2=x(i);
    diff_left(i)=a1-a2;  % compute differences on left 
                            % side of refernce smaple
     if(diff_left(i)>0)   % assign values 0 or 1 based on comparison
         b_left(r+1)=1*2^r;
     else
         b_left(r+1)=0;
     end
     
    diff_right(i)=x(i+r+1) - x(i); % compute differences on right 
                                 % side of refernce smaple
     
     if(diff_right(i)>0)   % assign values 0 or 1 based on comparison
         b_right(r+1)=1*2^(r+P/2);
     else
         b_right(r+1)=0;
     end 
     
    end  % end sumation loop
    
   
 full_frame(:,k) = [b_left 0 b_right]; % together Right and LEFT frames
                                           % with ZERO in center (reference
                                           % sample)
 lbp_features(1,k)=sum(full_frame(:,k)); % compute LBP features vector output
 k=k+1;
      
 end  % end outer loop which runs for tatal number of samples in signal

 feature_result = hist(lbp_features,20);
 
end

