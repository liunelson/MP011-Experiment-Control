mksqlite('open', 'test2.sqlite');

columnnames = {...
        'Time', 'INTEGER'; ...
        'Chiller_Temperature_external', 'REAL'; ...
        'Chiller_Temperature_internal', 'REAL'; ...
        'RF_Power', 'REAL'; ...
        'Micra_Power', 'REAL'; ...
        'Verdi_Power', 'REAL'; ...
        'High_Voltage', 'REAL' ...
        };
    
command = '';
for i = 1:numel(columnnames)/2
    command = [command char(columnnames(i,1)) ' ' char(columnnames(i,2))];
    if i ~= numel(columnnames)/2
        command = [command ', '];
    end
end
% 
mksqlite( ['CREATE TABLE newtable(' command ')'] );
% 
% mksqlite( ['INSERT INTO newtable(' addvalue ') VALUES (1, 2.3, 3.3, 3.1, 33.1, 10.0, 33.1)' ] );

data = cell(1,7);


for i = 1:numel(data)
    data{i} = rand(1,1);
end


for i = 1:1%size(columnnames, 1)
    mksqlite( 'INSERT INTO newtable VALUES (?,?,?,?,?,?,?)', data{1,:} );
end

mksqlite('close')