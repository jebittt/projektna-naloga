function izvoziGeometrijo(path,mesh)
n = size(mesh.xy,1);
m = size(mesh.cells,1);
fid = fopen(path,'wb','ieee-le');
assert(fid>=0,'Napaka pri odpiranju: %s',path);
cleanup = onCleanup(@() fclose(fid));
assert(fwrite(fid,[n m],'uint64')==2);
assert(fwrite(fid,mesh.xy.','double')==2*n);
assert(fwrite(fid,mesh.cells.'-uint32(1),'uint32')==4*m);
clear cleanup
fid = fopen(path,'rb','ieee-le');
assert(fid>=0);
cleanup = onCleanup(@() fclose(fid));
assert(isequal(fread(fid,2,'uint64'),[n;m]));
assert(isequal(fread(fid,[2 n],'double').',mesh.xy));
assert(isequal(fread(fid,[4 m],'*uint32').'+uint32(1),mesh.cells));
assert(isempty(fread(fid,1,'uint8')));
end
