function [A,b] = uvoziSistem(path)
fid = fopen(path,'rb','ieee-le');
assert(fid>=0,'Datoteke ni mogoce odpreti: %s',path);
cleanup = onCleanup(@() fclose(fid));
head = fread(fid,2,'uint64');
assert(numel(head)==2,'Manjka glava CSR.');
n = head(1);
nz = head(2);
info = dir(path);
assert(n>0 && n<=double(intmax('uint32')) && info.bytes==24+16*n+12*nz,'Napacna dolzina CSR.');
ptr = fread(fid,n+1,'uint64');
col = fread(fid,nz,'uint32')+1;
val = fread(fid,nz,'double');
b = fread(fid,n,'double');
assert(numel(b)==n && ptr(1)==0 && ptr(end)==nz && all(diff(ptr)>=0));
row = repelem((1:n)',diff(ptr));
assert(all(col<=n) && all(diff(row)>0 | diff(col)>0),'Neurejeni indeksi CSR.');
assert(all(isfinite(val) & val~=0) && all(isfinite(b)));
A = sparse(row,col,val,n,n);
end
