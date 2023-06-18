%{ Load HaCOO tensor from a .mat file.
%}
function t = load_htns(file)

    %call case 1 in HaCOO htensor constructor
    t = htensor(file);

end

