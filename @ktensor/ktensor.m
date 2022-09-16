%KTENSOR Class for Kruskal tensors (decomposed).

classdef ktensor
    properties
         lambda
         u

    end
    methods

        function t = ktensor(varargin)
            %K = KTENSOR(lambda,U1,U2,...,UD) creates a Kruskal tensor from its
            %   constituent parts. Here lambda is a k-vector and each Uk is a
            %   matrix with k columns. (from Tensor Toolbox)
            %   lambda = [];
            %   U = {};

        if (nargin == 2)
            t.lambda = varargin{1};
            t.u = varargin{2};
        end

        end
    end
end