SELECT 
    owner,
    tablespace_name,
    ROUND(SUM(bytes) / 1024 / 1024, 2) AS used_mb,
    COUNT(*) AS segment_count
FROM dba_segments
WHERE owner = ''  -- ここにユーザー名を指定
GROUP BY owner, tablespace_name
ORDER BY used_mb DESC;

select
    username,
    account_status,
    created,
    default_tablespace
FROM dba_users
WHERE username = 'RTKDM708';

-- 3. 指定ユーザーがオブジェクトを持っているかを確認
SELECT 
    owner,
    object_type,
    COUNT(*) AS object_count
FROM dba_objects
WHERE owner = 'RTKDM708'  -- ここにユーザー名を指定
GROUP BY owner, object_type
ORDER BY object_count DESC;


alter database datafile 'C:\Users\rtkdm\Desktop\oracledb\oradata\ORCL\orclpdb\USERS01.DBF' RESIZE 35000M