function l = morton_decode(m, n)
    %{
    Extract integers from a morton encoding.
    Parameters:
        m - The morton encoded set
        n - The number of integers present
    Returns:
        The list of decoded integers
    %}
    % amount to shift by
    shift = 0;
    
    % construct the list
    %l = [0] * n;
    l = zeros(n,1);

    % continue until we run out of bits
    while m > 0
        for i = 1:n
            temp = bitshift(bitand(m, 1),shift); %bit shift to the left
            l(i) = bitor(l(i),temp); %bit shift to the left
            m = bitshift(m, -1); %bit shift to the right
        end
        shift = shift + 1;
    end
end
  