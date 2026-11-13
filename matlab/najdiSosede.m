function [edges,dx] = najdiSosede(mesh)
% A(i,j) v matriki edges steje celice s skupno stranico (i,j).
xy = mesh.xy;
c = double(mesh.cells);
n = size(xy,1);
dx = median(xy(c(:,4),1)-xy(c(:,1),1));
assert(dx>0,'Neveljavna orientacija ali razmik celic.');
tol = 1e-6*dx;
offset = dx*[0 0;0 -1;1 -1;1 0];
for corner = 2:4
    delta = xy(c(:,corner),:)-xy(c(:,1),:)-offset(corner,:);
    assert(all(abs(delta(:))<=tol),'Nepravilna geometrija ali vrstni red oglisc.');
end
assert(size(unique(c(:,1)),1)==size(c,1),'Dve celici imata isto zgornje levo oglisce.');
assert(size(uniquetol(xy,tol,'ByRows',true,'DataScale',1),1)==n,'Podvojene koordinate.');
from = c(:,[1 2 3 4]);
to = c(:,[2 3 4 1]);
half = sparse(from(:),to(:),1,n,n);
edges = half+half.';
assert(all(nonzeros(edges)<=2),'Stranica pripada vec kot dvema celicama.');
end
