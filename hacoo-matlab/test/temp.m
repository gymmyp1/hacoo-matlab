%Just messing around to try to get a hang of MATLAB

%item = struct
%item.idx = 3
%item.val = 1

%table = {}

%trying non-scalar structure
%field: [morton, value]
X(2).field = {293, 5};
X(3).field = {567,1};

%Curved parentheses retireve a subset cell array
X(2).field{1} %<-- curly brackets to access element in cell array
X(2).field{2} %<-- curly brackets to access element in cell array