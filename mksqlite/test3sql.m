mksqlite( 'open', 'test.sqlite' ); % "in-memory"-database

%          |First name |Last name    |City         |Random data
mydata = { ...
           'Gunther',  'Meyer',      'Munich',     []; ...
           'Holger',   'Michelmann', 'Garbsen',    rand( 1, 10 ); ...
           'Knuth',    'Almeroth',   'Wehnsen',    'coworker' ...
         }; 

% create table
mksqlite( 'CREATE TABLE demo (Col_1, Col_2, Col_3, Data)' );

% create records
% uses "cell expansion" for command shortening!
for i = 1:size( mydata, 1 )
    mksqlite( 'INSERT INTO demo VALUES (?,?,?,?)', mydata{i,:} );
end

mksqlite( 'close' );