function count = razvrstiVozlisca(mesh,edges)
% 1 = zunanji kot, 2 = ravni rob, 3 = notranji kot, 4 = notranjost.
n = size(mesh.xy,1);
count = accumarray(double(mesh.cells(:)),1,[n 1]);
degree = full(sum(spones(edges),2));
assert(all(count>=1 & count<=4) && all(degree==min(count+1,4)), ...
    'Neobicajna topologija: preverite luknje, stik v eni tocki in sosede.');
boundary = false(n,1);
for g = 1:numel(mesh.bc)
    boundary(mesh.bc(g).nodes) = true;
end
assert(isequal(boundary,count<4),'Skupine pogojev se ne ujemajo z robom mreze.');
end
