%Driver code for testing building a HaCOO tensor from scratch and if
%updates to the "next" array are correct.

%addpath  C:\Users\MeiLi\OneDrive\Documents\MATLAB\hacoo-matlab
addpath /Users/meilicharles/Documents/MATLAB/hacoo-matlab/

idx =  [75 6 640 646;
        118 13 671 670;
        81 5 662 696;
        30 16 664 725;
        26 1 650 699;
        157 10 657 694;
        160 19 655 694;
        91 12 650 698;
        117 18 692 709];

vals = ones(size(idx,1),1);

tic
t = htensor(); %create a blank tensor
%t.next;
for i=1:size(idx,1)
    t = t.set(idx(i,:),vals(i));
end

t.display_htns()

%removing will also affect the next array!

%t = t.remove([1 1 1]);
%t = t.remove([2 1 1]);
%t = t.remove([1 2 1]);

%t.display_htns()

toc