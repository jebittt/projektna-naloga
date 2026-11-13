function izvediPreverjanja(mesh,A,b,dx)
% Neodvisen prepis enacbe (9), indeksi v spodnji tabeli so iz PDF (od 0).
ref = eye(16);
rows = [5 1 4 6 9;6 2 5 7 10;9 5 8 10 13;10 6 9 11 14];
for r = rows.'
    ref(r(1)+1,r(1)+1) = -4;
    ref(r(1)+1,r(2:5)+1) = 1;
end
ref(8,[4 7 8 12]) = [1 2 -2004 1];
ref(12,[8 11 12 16]) = [1 2 -2004 1];
rhs = [50 100 100 100 50 0 0 -400000 50 0 0 -400000 50 300 300 300]';
tref = [50 100 100 100 50 118.7445 156.2274 199.9064 ...
    50 168.7508 206.2586 200.0561 50 300 300 300]';
assert(isequal(size(mesh.cells),[9 4]) && abs(dx-1)<1e-12);
assert(isequal(full(A),ref) && isequal(b,rhs),'A ali b odstopa od enacbe (9).');
err = norm(A\b-tref,inf);
assert(err<=5.0001e-5,'Temperatura odstopa od zaokrozene reference.');
fprintf('Zgled: 256/256 koeficientov A in 16/16 vrednosti b tocnih. max |T-Tref| = %.9g K.\n',err);
% Preveri tudi tok na fizicnem levem robu in zunanjem kotu iste mreze.
mesh.bc(1).type = 'toplotni tok';
mesh.bc(1).value = 3;
[Q,rhsQ] = sestaviSistem(mesh,1);
assert(isequal(full(Q(1,[1 2 5])),[-2 1 1]) && rhsQ(1)==-6);
assert(isequal(full(Q(5,[1 5 6 9])),[1 -4 2 1]) && rhsQ(5)==-6);
end
