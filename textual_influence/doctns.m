%{
 File: doctns.m
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
    tnsList - cell array of built HaCOO or COO tensors for each document in
              current directory
    walltime - accumulated elapsed time required to build all document
               tensors
    cputime - accumulated cpu time required to build all document
              tensors
%}

function [tnsList,walltime,cpu_time] = doctns(N,words,wordToIndex,newFileNames,varargin)
params = inputParser;
params.addParameter('format','default',@isstring);
params.addParameter('ngram',3,@isscalar);
params.addParameter('hacoo_save',0,@isscalar);
params.addParameter('coo_save',0,@isscalar);
params.parse(varargin{:});

%% Copy from params object
format = params.Results.format;
ngram = params.Results.ngram;
hacoo_save = params.Results.hacoo_save;
coo_save = params.Results.coo_save;
%

%Check if tensor format is valid
if strcmp(format,"sptensor") || strcmp(format,"coo")
    fmtNum = 1;
elseif strcmp(format,"htensor") || strcmp(format,"hacoo")
    fmtNum = 2;
else
    fprintf("Tensor format invalid.\n");
    return
end

tnsList = cell(N,1); %blank cell array to store all built document tensors
walltime = 0;
cpu_time = 0;
nbuckets = 1048576; %specify the number of buckets HaCOO starts with 2^20

% construct the document tensors
for doc=1:N %for every doc
    %If using HaCOO format
    if fmtNum == 2
        tns = htensor(nbuckets); %create HaCOO tensor w/ specific # of buckets
    elseif fmtNum == 1 %else use COO format
        tns = sptensor(ones(1,ngram));
    end

    curr_doc = words{doc}; %word list for current doc
    i = 1;
    limit = length(curr_doc) - ngram;
    idxList = zeros(limit,ngram);
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

        %store the index
        idxList(i,:) = idx;
        % next word
        i = i+1;
    end

    %concatenate the indexes for HaCOO
    T = arrayfun(@string,idxList);

    %apply to each row

    X = strcat(T(:,1),'',T(:,2)); %To start the new array

    for i=3:size(T,2)
        %fprintf("concatenating mode %d\n",i)
        X= strcat(X(:,:),'',T(:,i));
    end

    concatIdx = arrayfun(@str2double,X);


    %insert elements
    for i=1:size(idxList,1)
        tic
        tStart = cputime;

        %If using HaCOO format
        if fmtNum == 2
            % build using HaCOO format, turn off updateNext so we're just
            % timing inserting indexes
            tns = tns.set(idxList(i,:),1,'update',1,'concatIdx',concatIdx(i));

            %If using COO format
        elseif fmtNum == 1
            %Check if this index is larger than the sptensor size
            updateModes = idxList(i,:) > size(tns);

            if any(updateModes) %if any index modes are larger, just insert
                tns(idxList(i,:)) = 1;
            else
                %update the entry's val
                tns(idxList(i,:)) = tns(idxList(i,:)) + 1;
            end
        end

        walltime = walltime + toc;
        tEnd = cputime - tStart;
        cpu_time = cpu_time + tEnd;
       
    end
    
    if fmtNum ==2
        %update the locations of occupied buckets
        tns = tns.init_nnzLoc();
    end
    %store the tensor & advance to the next document
    tnsList{doc} = tns;

    %----------
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
    %--------
end


end %<-- end function

