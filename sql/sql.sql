/*+ NO_USE_HASH_AGGREGATION */ 
/*+ NO_INDEX(T_STORE_WEEKLY_SALES IDX_LOCAL) */
/*+ INDEX(T_STORE_WEEKLY_SALES IDX_LOCAL) */
/*+ NO_USE_HASH_AGGREGATION INDEX(T_STORE_WEEKLY_SALES IDX_LOCAL) */ 

-- group by
select store_cd, jan_cd, sum(sales)
from t_store_weekly_sales
where 1 = 1
group by store_cd, jan_cd;

-- group by
select /*+ INDEX(T_STORE_WEEKLY_SALES IDX_LOCAL) */  store_cd, jan_cd, sum(sales)
from t_store_weekly_sales
where 1 = 1
--  and store_cd = '676584'
group by store_cd, jan_cd;


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


