drop table temp_table;

--insert
create global temporary table temp_table (
	store_cd varchar2(6),
	jan_cd varchar2(6)
) on commit delete rows;

/*insert into temp_table (store_cd, jan_cd)
select store_cd, jan_cd
from t_store_weekly_sales
--where 1 = 1
--  and store_cd = '676584'
--  and jan_cd = '010668';
group by store_cd, jan_cd;*/

insert into temp_table (store_cd, jan_cd)
select store_cd, jan_cd
from t_store_weekly_sales
where 1 = 1
  and store_cd in ('676584','265381')
group by store_cd, jan_cd;

select count(*)
from temp_table;