function [A,b,dx] = sestaviSistem(mesh,k)
assert(isscalar(k) && isfinite(k) && k>0,'Neveljavna prevodnost.');
[edges,dx] = najdiSosede(mesh);
count = razvrstiVozlisca(mesh,edges);
n = numel(count);
% Na robu uporabimo stevilo celic ob stranici. V notranjosti imata
% vse stranice dve celici, zato delimo celotno vrstico z 2 (enacba 6).
scale = ones(n,1);
scale(count==4) = 0.5;
b = zeros(n,1);
diagonal = -2*count.*scale;
for g = 1:numel(mesh.bc)
    bc = mesh.bc(g);
    i = bc.nodes;
    switch bc.type
        case 'temperatura'
            scale(i) = 0;
            diagonal(i) = 1;
            b(i) = bc.value;
        case 'toplotni tok'
            b(i) = -2*bc.value*dx/k;
        case 'prestop'
            bi = bc.h*dx/k;
            diagonal(i) = diagonal(i)-2*bi;
            b(i) = -2*bi*bc.value;
        otherwise
            error('Neznan robni pogoj.');
    end
end
A = spdiags(scale,0,n,n)*edges + spdiags(diagonal,0,n,n);
expected = n + sum(full(sum(spones(edges),2)).*(scale~=0));
assert(issparse(A) && isequal(size(A),[n n]) && isequal(size(b),[n 1]));
assert(nnz(A)==expected && all(diag(A)==diagonal) && all(diagonal~=0));
assert(all(isfinite(nonzeros(A))) && all(isfinite(b)));
end
