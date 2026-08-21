

[r,c]=size(MFCCs);

 for i=1:r
S(i,1) = sum(MFCCs(i,:))
 av(i,1)=(S(i,1))/c;
 end
av=av';

 filename='my_data_file.xlsx';
 xlswrite(filename,av);