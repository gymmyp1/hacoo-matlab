%{
 File: build_vocab.m
 Purpose: Build vocabulary and index it for building document tensors.

Parameters:
    vocabFile - save vocabulary file
    freqFile - save frequency file
    constraint - limit vocabulary to the n most frequent words

Returns:
    N - number of documents
    words - array of unique words in entire corpus
    wordToIndex - indexed vocabulary for entire corpus
    newFileNames - file names for saving document tensors as .mat files
%}

function [N,words,wordToIndex,newFileNames] = build_vocab(varargin)
%% Set up params
params = inputParser;
params.addParameter('vocabFile','vocabulary',@isstring);
params.addParameter('freqFile','@',@isstring);
params.addParameter('constraint',10e4,@isscalar);
params.parse(varargin{:});

%% Copy from params object
vocabFile = params.Results.vocabFile;
freqFile = params.Results.freqFile;
constraint = params.Results.constraint;
%%

files = dir('*.TXT');
N = numel(files);
newFileNames = cell(N,1);
words = cell(N, 1);

for i = 1:length(files)
    fid1 = files(i).name;
    newFileNames{i} = replace(fid1,'.txt','_coo.txt');
    fidI = fopen(files(i).name,'r');
    temp = textscan(fidI, '%s');
    temp{1} = erasePunctuation(temp{1}); %requires MATLAB Text Analytics Toolbox
    docWords = {};
    for j=1:length(temp{1})
        lowerCase = lower(temp{1});
        if all(isstrprop(lowerCase{j},'alpha'))
            docWords{end+1} = lowerCase{j};
        end
    end
    words{i} = transpose(docWords);
end

% Build raw vocabulary dictionary
vocab = containers.Map;
for doc=1:N  %for every doc
    for i=1:length(words{doc})  %for every word in a doc
        word = words{doc}{i};
        if ~isKey(vocab,word) %if word is not in voacb, add it
            vocab(word) = 1;
        else
            vocab(word) = vocab(word) + 1;
        end
    end
end

%vocab.keys;
%vocab.values;

%Sort by frequency in descending order
keys = vocab.keys;
mvals = cell2mat(vocab.values);
[vocabVals, sortIdx] = sort(mvals,'descend');
vocabKeys = keys(sortIdx);

if constraint > 0 && constraint < length(keys)
    % count the other
    other = 0;
    for word=constraint+1:size(vocab,1)
        other = other + vocabVals(word);
    end

    % trim the list
    vocabKeys = vocabKeys(1:constraint);
    vocabVals = vocabVals(1:constraint);
    vocabKeys{end+1} = '<other>';
    vocabVals(end+1) = other;
end

% index the vocabulary
vocabIndex = 1:length(vocabKeys);

%Save the vocabulary
fileID = fopen(vocabFile,'w');
for i=1:length(vocabKeys)
    fprintf(fileID,'%s %d\n',vocabKeys{i},vocabIndex(i));
end
fclose(fileID);

% optionally save the frequency file
if freqFile ~= '@'
    fileID = fopen(freqFile,'w');
    for i=1:length(vocabKeys)
        fprintf(fileID,'%s %d\n',vocabKeys{i},vocabVals(i));
    end
    fclose(fileID);
end

% construct the word lookup
wordToIndex = containers.Map(vocabKeys,vocabIndex);

