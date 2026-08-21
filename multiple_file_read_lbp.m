% Reads the files in FOLDER and calls the LBP_function function
% saves the file in the file name specified


% specify the path to read files
path='Breathing'; 
folder = path; 
dirListing = dir(folder);
k=1;
%for o = 1:20 % num of fields 
for d = 3:length(dirListing) 
%loop through the files and open. Note that dir also lists the directories, so you have to check for them. 
 fileName = fullfile(folder,dirListing(d).name); % use full path because the folder may not be the active path 
 [x,Fs]=audioread(fileName);
%  p(i,:)=LBP_speech_new(x);
 
 hist_features(k,:)=LBP_function(x);
 k=k+1;
end

% specify the file name to save data
filename = 'Hello_LBP_features_Breathing.xlsx';   % save the matrix D1 (having instances and class labels) in excel file
xlswrite(filename,hist_features);









