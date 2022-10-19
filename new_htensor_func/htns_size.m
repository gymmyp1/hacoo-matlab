%Returns the modes HaCOO sparse tensor X.

function size = htns_size(varargin)
    X = varargin{1};
    switch nargin
        case 1 %<-- if we specify just the tensor, return its modes
            size = X.modes;
        case 2 %<-- if tensor mode is specified, return just that mode
            n = varargin{2};
            size = X.modes(n);
    end
end