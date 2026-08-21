clear all
clc

varMFCC=xlsread('D:\Research\sound 16 Oct Start\DS\features\mfcc play\hello.xlsx');
varMFCC2=varMFCC';


% varMFCC3=[varMFCC2 varMFCC2];

% signals=varMFCC3';


% for i=1:1:10
     i=1;
    
 varLTP(:,i)=LTP_speech(varMFCC2(:,i),0);

% end
