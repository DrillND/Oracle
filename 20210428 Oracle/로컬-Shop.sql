select * from tab;

create table tmpTBL ( name varchar2(10)); -- CRUD,¡÷ºÆ

insert into tmpTBL values( 'Hello SQL' );

connect hr/1234;
select * from tmpTBL;

update tmpTBL set name = 'Hello ora';

DELETE FROM tmpTBL;

drop table tmpTBL;

show user
