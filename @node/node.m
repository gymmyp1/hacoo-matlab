%Class definition for a linked list node.

classdef node
   properties
      morton;
      value;
   end
   methods
       function obj = node(varargin)
         if nargin == 0
            obj.morton = -1;
            obj.value = -1;
         else
             obj.morton = varargin{1};
             obj.value = varargin{2};
         end
       end

       function obj = set_morton(obj,m)
           obj.morton = m;
       end

       function obj = set_value(obj,v)
           obj.value = v;
       end

       function clear(obj)
           obj.morton = -1;
           obj.value = -1;
       end
   end
end