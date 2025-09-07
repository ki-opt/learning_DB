alter table t_store_weekly_sales drop partition p_000044;
alter table t_store_weekly_sales add partition p_000044 values('000044');