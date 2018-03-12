/*
	Migration script to include lastupdated,lastupdateby and complted columns.
	It will add these three columns to existing database.
*/

alter table completedatasetregistration 
add lastupdated date, add lastupdatedby integer,add completed boolean;

alter table completedatasetregistration
add FOREIGN KEY (lastupdatedby) REFERENCES users(userid);

create or replace function migrateCompletenessTable() returns void as $$ 
declare complete RECORD;
declare usrrow integer;
begin
for complete in select * from completedatasetregistration
loop
	select usr.userid into usrrow from users usr where usr.username = complete.storedby limit 1;
	update completedatasetregistration set completed='t',lastupdated=complete.date,lastupdatedby=usrrow
			where datasetid = complete.datasetid and
			  	  periodid=complete.periodid and
			  	  sourceid=complete.sourceid and
			  	  attributeoptioncomboid=complete.attributeoptioncomboid;

end loop;
end;
$$ language plpgsql;
select migrateCompletenessTable();

alter table completedatasetregistration alter column lastupdatedby set not null;
