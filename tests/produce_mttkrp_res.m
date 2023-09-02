%script to reproduce results in Table xXX (Time elapsed/CPU time required
%to calculate MTTKRP for both COO sptensor and HaCOO htensor)


%list of FROSTT tensors in the "frostt_tensors" directory
files = ["uber.txt" "chicago.txt" "nips.txt" "lbnl.txt" "nell-2.txt" "enron.txt"];
R = 50;
numTrials = 1;

for f=1:length(files)

%get a file
file = files(f);

%Create name of file to write results to (filename_mttkrp.txt)
outFile = erase(file, ".txt");
outFile = strcat(outFile,"_mttkrp.txt");

%Time MTTKRP and write the average time to calculate over each mode to outFile
time_mttkrp(file, R, outFile, numTrials)

end