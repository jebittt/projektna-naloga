function mesh = preberiMrezo(path)
% Preberi bloke in razvrsti zapise po ID, tudi ce so vrstice premesane.
fid = fopen(path,'rt');
assert(fid >= 0,'Datoteke ni mogoce odpreti: %s',path);
cleanup = onCleanup(@() fclose(fid));
n = header('tocke');
points = block(n,3,' %f;%f,%f');
mesh.xy = points(:,2:3);
m = header('celice');
cells = block(m,5,' %f;%f,%f,%f,%f');
assert(validIds(cells(:,2:5),n),'Neveljaven ID vozlisca v celici.');
mesh.cells = uint32(cells(:,2:5)+1);
ng = header('robni pogoji');
mesh.bc = repmat(struct('id',0,'type','','value',0,'h',0,'nodes',[]),ng,1);
used = false(n,1);
for g = 1:ng
    tokens = regexp(nextLine(),'^pogoj\s+(\d+):\s*(temperatura|prestop|toplotni tok)$','tokens','once');
    assert(~isempty(tokens),'Neveljavna glava robnega pogoja.');
    id = str2double(tokens{1});
    assert(~ismember(id,[mesh.bc(1:g-1).id]),'Podvojen ID skupine.');
    kind = tokens{2};
    h = 0;
    if strcmp(kind,'toplotni tok')
        value = parameter('toplotni tok');
    else
        value = parameter('temperatura');
    end
    if strcmp(kind,'prestop')
        h = parameter('koeficient prestopa');
        assert(h >= 0,'Negativna prestopnost.');
    end
    count = str2double(nextLine());
    assert(isfinite(count) && count==fix(count) && count>0 && count<=n,'Neveljavno stevilo robnih vozlisc.');
    nodes = fscanf(fid,' %f',count)+1;
    assert(numel(nodes)==count && validIds(nodes-1,n),'Neveljavni robni indeksi.');
    assert(numel(unique(nodes))==count && ~any(used(nodes)), ...
        'Podvojeno vozlisce znotraj skupine ali med skupinami pri pogoju %d.',id);
    used(nodes) = true;
    mesh.bc(g) = struct('id',id,'type',kind,'value',value,'h',h,'nodes',nodes);
end
assert(isempty(strtrim(fread(fid,Inf,'*char')')),'Odvecni podatki za zadnjim blokom.');

    function line = nextLine()
        line = '';
        while isempty(line)
            raw = fgetl(fid);
            assert(ischar(raw),'Nepricakovan konec datoteke %s.',path);
            line = strtrim(raw);
        end
    end
    function count = header(label)
        tok = regexp(nextLine(),['^' label '\s+(\d+)$'],'tokens','once');
        assert(~isempty(tok),'Manjka glava %s.',label);
        count = str2double(tok{1});
    end
    function val = parameter(label)
        tok = regexp(nextLine(),['^' label ':\s*(\S+)$'],'tokens','once');
        assert(~isempty(tok),'Manjka parameter %s.',label);
        val = str2double(tok{1});
        assert(isfinite(val),'Neveljavna vrednost za %s.',label);
    end
    function data = block(count,width,format)
        [data,num] = fscanf(fid,format,[width,count]);
        assert(count>0 && num==width*count && all(isfinite(data(:))),'Nepopoln numericni blok.');
        data = sortrows(data.',1);
        assert(isequal(data(:,1),(0:count-1)'),'Podvojeni ali manjkajoci ID-ji.');
    end
end

function ok = validIds(ids,n)
ok = all(ids(:)>=0 & ids(:)<n & ids(:)==fix(ids(:)));
end
