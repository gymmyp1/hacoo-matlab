%Class definition for a linked list node.

classdef node
   properties
      idx_id; %<-- this is just concatenated index values
      value;
   end
   methods
       function obj = node(varargin)
         if nargin == 0
            obj.idx_id = -1;
            obj.value = -1;
         else
             obj.idx_id = varargin{1};
             obj.value = varargin{2};
         end
       end

       function obj = set_morton(obj,m)
           obj.idx_id = m;
       end

       function obj = set_value(obj,v)
           obj.value = v;
       end

       function clear(obj)
           obj.idx_id = -1;
           obj.value = -1;
       end
   end
end