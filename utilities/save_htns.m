%Save a .txt COO tensor a HaCOO .mat file.

function save_htns(varargin)

files = varargin{1};

for i=1:length(files)
    fprintf("Saving tensor %s to file...\n", file(i));

    t = read_htns(file(i));

    newStr = erase(file,".txt");
    matfile = strcat(newStr,'_hacoo.mat');

    write_htns(t,matfile);
end
end

