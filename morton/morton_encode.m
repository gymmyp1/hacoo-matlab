function result = morton_encode(vals)
    %{
    Compute the morton encoding for the data passed into the function.

    Parameters:
        This function can take any number of values as a vector of values, and it is assumed that 
        the arguments are all non-negative integers.

    Returns:
        Returns the morton encoding of the values.
    %}
    result = 0;

    % vals is already a list
    n = length(vals);

    % we start at the left most bit
    bit = uint64(0x01);

    % keep going until we run out of 1s
    while sum(vals) ~= 0
        for i = 1:n
            %copy the bit
            if bitand(vals(i),uint64(0x1)) ~= 0
                result = bitor(result,bit);
                %result
            end

            % adjust value and the bit to toggle
            vals(i) = bitshift(vals(i), -1); %shift to the right
            bit = bitshift(bit,1); %shift to the left
        end
    end
end