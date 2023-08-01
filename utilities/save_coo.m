%{
Save a .txt COO tensor a COO .mat file.

Parameters:
   Input:
        files - list of .txt file tensors in COO format to save

   Output:
        nothing
%}

function save_coo(varargin)
files = varargin{1};

    for i=1:length(files)
    
        fprintf("Saving tensor %s to file...\n", files(i));
    
        %read .txt file to COO sptensor (requires Tensor Toolbox)
        t = read_coo(files(i));

        newStr = erase(files(i),".txt");
        matfile = strcat(newStr,'_coo.mat');
    
        save(matfile,'t');
        %save(matfile,'t','-v7.3'); %add version to save files over 2GB
    end
end

