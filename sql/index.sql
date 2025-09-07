/* インデックスがlocalかglobalかの確認.
partitioned=Yesの場合local, noの場合global
*/
select table_name||','||index_name||','||tablespace_name||','||partitioned from user_indexes;