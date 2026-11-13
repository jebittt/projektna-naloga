function izvoziSistem(path,A,b)
% find na transponirani matriki prehodi vrstice A po vrsti.
n = size(A,1);
assert(n<=double(intmax('uint32')) && isequal(size(A),[n n]) && isequal(size(b),[n 1]));
[col,row,val] = find(A.');
ptr = [0; cumsum(accumarray(row,1,[n 1]))];
fid = fopen(path,'wb','ieee-le');
assert(fid>=0,'Datoteke ni mogoce ustvariti: %s',path);
cleanup = onCleanup(@() fclose(fid));
put([n nnz(A)],'uint64');
put(ptr,'uint64');
put(col-1,'uint32');
put(val,'double');
put(b,'double');
    function put(x,type)
        assert(fwrite(fid,x,type)==numel(x),'Nepopoln zapis: %s',path);
    end
end
