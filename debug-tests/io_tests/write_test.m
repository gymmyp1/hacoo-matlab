%Save a .txt COO tensor a HaCOO .mat file.

tic

writeTns("uber.txt")

toc

function writeTns(file)
    fprintf("Saving tensor %s to file...\n", file);
    t = read_htns(file);

    newStr = erase(file,".txt");
    matfile = strcat(newStr,'_hacoo.mat');

    write_htns(t,matfile);
end