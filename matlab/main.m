% Prva faza: test, osnovna lopatica in tri zgostitve.
root = fileparts(fileparts(mfilename('fullpath')));
inputDir = fullfile(root,'vhodni_podatki');
out = fullfile(root,'rezultati');
for folder = ["grafi","binarne_datoteke","testi","izpisi"]
    if ~isfolder(fullfile(out,folder)), mkdir(fullfile(out,folder)); end
end
meshes = ["primer_predloga_projekt","lopatica_mreza","lopatica_mreza_r1", ...
    "lopatica_mreza_r2","lopatica_mreza_r3"];
logPath = fullfile(out,'testi','povzetek.txt');
logId = fopen(logPath,'wt'); assert(logId>=0); fclose(logId);
diary(logPath);
try
    for caseNo = 1:numel(meshes)
        name = meshes(caseNo);
        mesh = preberiMrezo(fullfile(inputDir,name+".txt"));
        n = size(mesh.xy,1);
        fprintf('\n%s: %d vozlisc, %d celic.\n',name,n,size(mesh.cells,1));
        k = 22;
        if caseNo==1, k = 1; end
        [A,b,dx] = sestaviSistem(mesh,k);
        if caseNo==1
            izvediPreverjanja(mesh,A,b,dx);
        else
            assert(abs(dx-0.00025/2^(caseNo-2))<1e-6*dx);
        end
        if caseNo==2
            narisiMrezo(mesh,fullfile(out,'grafi','lopatica_mreza.png'));
        end
        fprintf('dx = %.9g m; nnz = %d.\n',dx,nnz(A));
        base = fullfile(out,'binarne_datoteke',name);
        izvoziSistem(base+"_sistem.bin",A,b);
        [Ar,br] = uvoziSistem(base+"_sistem.bin");
        assert(isequal(A,Ar) && isequal(b,br),'Napaka pri ponovnem branju CSR.');
        clear Ar br
        izvoziGeometrijo(base+"_geom.bin",mesh);
        fprintf('CSR in geometrija: ponovno prebrani podatki so enaki izvirnim.\n');
        solve = true;
        if n>100000
            % Konzervativna rezerva za delovne tabele in zapolnitev faktorjev.
            % Prag je ocena za te 2D mreze, ne natancna napoved porabe LU.
            solve = false;
            if ispc
                [~,sys] = memory;
                reserve = 8192*n;
                solve = sys.PhysicalMemory.Available > reserve;
                fprintf('Prosti RAM %.2f GiB; zahtevana rezerva %.2f GiB.\n', ...
                    sys.PhysicalMemory.Available/2^30,reserve/2^30);
            end
        end
        if ~solve
            fprintf('Direktna resitev preskocena zaradi pomnilniske ocene.\n');
            continue
        end
        T = A\b;
        residual = norm(A*T-b,inf);
        assert(all(isfinite(T)) && residual<=1e-10*(norm(A,inf)*norm(T,inf)+norm(b,inf)));
        fprintf('Tmin %.6f, Tmax %.6f stopinj C; max |AT-b| %.3g.\n',min(T),max(T),residual);
        if caseNo>1
            heat = zeros(4,1);
            hot = [];
            for g = 1:numel(mesh.bc)
                bc = mesh.bc(g);
                % Vsako robno vozlisce ima dve polovicni izpostavljeni stranici.
                heat(bc.id) = bc.h*dx*sum(bc.value-T(bc.nodes));
                if bc.id==4
                    cold = bc.nodes;
                else
                    hot = [hot;bc.nodes]; %#ok<AGROW>
                end
            end
            assert(min(T)>=450-1e-7 && max(T)<=1200+1e-7);
            assert(mean(T(cold))<mean(T(hot)) && all(heat(1:3)>0) && heat(4)<0);
            balance = abs(sum(heat))/sum(abs(heat));
            assert(balance<1e-8,'Energijska bilanca odstopa.');
            fprintf('Povprecje zunanjega roba %.3f, kanalov %.3f stopinj C.\n',mean(T(hot)),mean(T(cold)));
            fprintf('Toplotni tokovi skupin [W/m]: %.6f %.6f %.6f %.6f; relativna bilanca %.3g.\n',heat,balance);
        end
        save(fullfile(out,'izpisi',name+"_T.mat"),'T','dx','k','residual');
    end
    fprintf('\nObdelava koncana.\n');
catch problem
    fprintf('NAPAKA: %s\n',problem.message);
    diary off
    rethrow(problem);
end
diary off
