/*+ NO_USE_HASH_AGGREGATION */ 
/*+ NO_INDEX(T_STORE_WEEKLY_SALES IDX_LOCAL) */
/*+ INDEX(T_STORE_WEEKLY_SALES IDX_LOCAL) */
/*+ NO_USE_HASH_AGGREGATION INDEX(T_STORE_WEEKLY_SALES IDX_LOCAL) */ 

set timing off;
set autotrace off;

-- group by
select store_cd, jan_cd, sum(sales)
from t_store_weekly_sales
where 1 = 1
  and store_cd LIKE '67%'
group by store_cd, jan_cd;

-- group by index
set timing on;
set autotrace traceonly;
select /*+ INDEX(T_STORE_WEEKLY_SALES IDX_LOCAL_2) */  store_cd, jan_cd, sum(sales)
from t_store_weekly_sales
where 1 = 1
  and store_cd LIKE '67%'
group by store_cd, jan_cd;

-- group by no index
select /*+ NO_INDEX(T_STORE_WEEKLY_SALES) */  store_cd, jan_cd, sum(sales)
from t_store_weekly_sales
where 1 = 1
  and store_cd LIKE '67%' --= '676584'
group by store_cd, jan_cd;

/* select */
-- select
select *
from t_store_weekly_sales
where 1 = 1
  and store_cd = '676584'
  --and jan_cd = '010668'
;

-- select with index
select /*+ INDEX(T_STORE_WEEKLY_SALES IDX_LOCAL) */ *
from t_store_weekly_sales
where 1 = 1
  and store_cd = '676584'
  --and jan_cd = '010668'
;

-- select no index
select /*+ NO_INDEX(T_STORE_WEEKLY_SALES IDX_LOCAL) */ *
from t_store_weekly_sales
where 1 = 1
  and store_cd = '676584'
  --and jan_cd = '010668'
;

select *
from m_str_all;

select COUNT(*)
from m_str
where BUSHO_CODE BETWEEN '000000' AND '200000';