%Class definition for a linked list node.

classdef node
   properties
      morton;
      value;
      next;
      last;
      flag;
   end
   methods
       function obj = node(varargin)
         if nargin == 0
            obj.morton = 0;
            obj.value = 0;
            obj.flag = -1;
         else
             obj.morton = varargin{1};
             obj.value = varargin{2};
             obj.flag = 1;

         end
         obj.next = -1;
         obj.last = obj;
       end

       function obj = set_morton(obj,m)
           obj.morton = m;
       end

       function obj = set_value(obj,v)
           obj.value = v;
       end

       function obj = set_next(obj,n)
           obj.next = n;
       end

       function obj = set_last(obj,l)
           obj.last = l;
       end

       function clear(obj)
           obj.morton = 0;
           obj.value = 0;
           obj.flag = -1;
           obj.next = node();
           obj.last = obj;
       end


   end
end