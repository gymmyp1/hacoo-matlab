%Save a .txt COO tensor a COO .mat file.

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/


%Just change these file names to what you need.
%-------
%files = ["uber.txt" "chicago.txt" "nips.txt" "lbnl.txt"];
%files = ["uber.txt" "chicago.txt" "nips.txt" "lbnl.txt" "nell-2.txt" "enron.txt"];
files = ["nell-2.txt" "enron.txt"];
%--------

for i=1:length(files)
    tic
    fprintf("Saving tensor %s to file...\n", files(i));

    %read .txt file to COO sptensor
    t = read_coo(files(i));

    %If you have indexes already concatenated...
    %t = read_htns(file,concatIdxFile);

    newStr = erase(files(i),".txt");
    matfile = strcat(newStr,'_coo.mat');

    save(matfile,'t','-v7.3'); %adding version to save large files
    toc
end


