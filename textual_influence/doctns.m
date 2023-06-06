%{
 File: htns_doctns.m
 Purpose: Report time required to update all document tensors (times
    index insertion only).

Parameters:
    N - number of documents
    words - array of unique words in entire corpus
    wordToIndex - indexed vocabulary for entire corpus
    newFileNames - file names for saving document tensors as .mat files
    tns_format - which tensor format to use (sptensor or htensor)
    ngram - set the number of consecutive words when building tensor
    mat_save - write HaCOO document tensors as .mat files
    coo_save - write document tensors as COO files

Returns:
    tns - built HaCOO or COO tensor
    walltime - accumulated elapsed time required to build all document
    tensors
    cputime - accumulated cpu time required to build all document
    tensors
%}

function [walltime,cpu_time] = doctns(N,words,wordToIndex,newFileNames,varargin)
params = inputParser;
params.addParameter('format','default',@isstring);
params.addParameter('ngram',3,@isscalar);
params.addParameter('hacoo_save',0,@isscalar);
params.addParameter('coo_save',0,@isscalar);
params.parse(varargin{:});

%% Copy from params object
format = params.Results.format;
ngram = params.Results.ngram;
mat_save = params.Results.mat_save;
%%

%Check if tensor format is valid
if strcmp(format,"sptensor") || strcmp(format,"coo")
    fmtNum = 1;
elseif strcmp(format,"htensor") || strcmp(format,"hacoo")
    fmtNum = 2;
else 
    fprintf("Tensor format invalid.\n");
    return
end

walltime = 0;
cpu_time = 0;

% construct the document tensors
for doc=1:N %for every doc
    %If using HaCOO format
    if fmtNum == 2
        tns = htensor();
    elseif fmtNum == 1 %else use COO format
        tns = sptensor(ones(1,ngram));
    end
    
    curr_doc = words{doc}; %word list for current doc
    i = 1;
    limit = length(curr_doc) - ngram;
    % count the ngrams
    while i < limit+2
        gram = curr_doc(i:i+ngram-1);
        idx = zeros(1,ngram);

        % build the index
        for w=1:length(gram)
            word = gram{w};
            if ~isKey(wordToIndex,word)
                word = '<other>';
            end
            idx(w) = wordToIndex(word);
        end

        tic
        tStart = cputime;

        %If using HaCOO format
        if fmtNum == 2
            % build using HaCOO format
            tns = tns.set(idx,1,'update',1);

        %If using COO format
        elseif fmtNum == 1
            %Check if this index is larger than the sptensor size
            updateModes = idx > size(tns);

            if any(updateModes) %if any index modes are larger, just insert
                tns(idx) = 1;
            else
                %update the entry's val
                tns(idx) = tns(idx) + 1;
            end
        end

        walltime = walltime + toc;
        tEnd = cputime - tStart;
        cpu_time = cpu_time + tEnd;
        
        % next word
        i = i+1;
    end

    if hacoo_save
        %fprintf("Writing file: ");
        %newFileNames{doc}
        
        % write the file
        fileID = newFileNames{doc};
        write_htns(tns,fileID,'-v7.3');
    end

    if coo_save
        fileID = newFileNames{doc};
        write_coo(tns,fileID);
    end
    
end

end %<-- end function

