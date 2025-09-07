/* sqlplus sys/sys@p as sysdba */

select
  tablespace_name,
  nvl(TOTAL_BYTES / 1024 / 1024 ,0) as "SIZE[MB]",
  nvl((TOTAL_BYTES - FREE_BYTES) / 1024 / 1024,0) as "USED[MB]",
  nvl(FREE_BYTES / 1024 / 1024,0) as "FREE[MB]",
  round(nvl((TOTAL_BYTES - FREE_BYTES) / TOTAL_BYTES * 100,100),2) as "RATE[%]"
from
  ( select
      tablespace_name,
      sum(bytes) TOTAL_BYTES
    from
      dba_data_files
    group by
      tablespace_name
  ),
  ( select
      tablespace_name free_tbs_name,
      sum(bytes) FREE_BYTES
    from
      dba_free_space
    group by tablespace_name
  )
where
  tablespace_name = free_tbs_name(+)
order by tablespace_name;

select
    username,
    account_status,
    created,
    default_tablespace
FROM dba_users
WHERE username = 'RTKDM708';

-- 表領域拡張
alter database datafile 'C:\Users\rtkdm\Desktop\oracledb\oradata\ORCL\orclpdb\USERS01.DBF' RESIZE 35000M
-- エラーが出る⇒https://claude.ai/public/artifacts/31b08312-cfbc-4c29-ad4d-3495fbd0a10a