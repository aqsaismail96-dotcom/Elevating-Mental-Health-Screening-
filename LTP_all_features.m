% Reads the files in FOLDER and calls the LBP_speech function
% saves the file in the file name specified


% specify the path to read files
path='D:\Research\sound 16 Oct Start\DS\FemaleScream'; 
folder = path; 
% p=zeros(60,700);
j=zeros(60,600);

dirListing = dir(folder);
k=1;
%for o = 1:20 % num of fields 
for d = 3:length(dirListing) 
%loop through the files and open. Note that dir also lists the directories, so you have to check for them. 
 fileName = fullfile(folder,dirListing(d).name); % use full path because the folder may not be the active path 
 [x,Fs]=audioread(fileName);
%  p(i,:)=LBP_speech(x);
 
 hist_features=LBP_speech(x)
end

% % p(k,:)=j(1,1:74);
% m(k)=length(j);
%  
%  k=k+1;
% end
% % end
% % specify the file name to save data
% filename = 'LBP_features_MaleScream.xlsx';   % save the matrix D1 (having instances and class labels) in excel file
% xlswrite(filename,p);









