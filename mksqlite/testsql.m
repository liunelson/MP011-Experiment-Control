ooo = mksqlite('open', 'Chinook_Sqlite_AutoIncrementPKs.sqlite');
mksqlite( 'result_type', 0 )
ttt = mksqlite('show tables');
fields = {zeros(numel(ttt),1)};

for i = 1:numel(ttt)
    fields(i) = {ttt(i).tablename};
end

snames = zeros(numel(ttt),1);
squery = zeros(numel(ttt),1);

query = mksqlite(['select * from ' char(fields(11))]);
fnames = fieldnames(query);

% bbb = cell(3503,9);
% 
% for i = 1:3503;
%     for j = 1:9
%         bbb{i,j} = getfield(query(i), char(fnames(j)));
%     end
% end

% for i = 1:numel(ttt)
%     query = mksqlite(['select * from ' char(fields(i))]);
%     fnames = fieldnames(query);
%     snames(i) = numel(fnames);
%     squery(i) = numel(query);
% end
% 
% 
% table = cell(max(squery),max(snames),numel(ttt));
%  
% stable = size(table);
% 
% for i = 1:stable(3)
%     query = mksqlite(['select * from ' char(fields(i))]);
%     aaa = fieldnames(query);
%     for j = 1:numel(aaa)
%         for m = 1:numel(query)
%             table{m,j,i} = getfield(query(m), char(aaa(j)));
%         end
%     end
% end

mksqlite('close')