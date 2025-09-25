/* 

*/

CREATE OR REPLACE PROCEDURE initialization AS

	v_count NUMBER;

BEGIN
	EXECUTE IMMEDIATE 'TRUNCATE TABLE w_target_table';

	SELECT COUNT(*) INTO v_count FROM USER_TABLES WHERE TABLE_NAME = 'temp_str';
	DBMS_OUTPUT.PUT_LINE(v_count);
	--IF v_count = 0 THEN
	--	EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE temp_str (store_cd VARCHAR2(6)) on commit preserve rows';
	--END IF;
END;
/

CREATE OR REPLACE PACKAGE constants AS
	BATCH_SIZE NUMBER := 50;
END;
/

DECLARE
	-- 部署コード一覧取得用変数
	TYPE busho_code_type IS TABLE OF m_str.busho_code%TYPE INDEX BY PLS_INTEGER;
	busho_code_array busho_code_type;

	-- 作業用変数
	batch_num NUMBER := 1;
	start_idx NUMBER := 1;
	
	-- 時間測定用変数（TIMESTAMP差分を秒で計算する関数を使用）
	start_time TIMESTAMP;
	sql_start TIMESTAMP;
	cumulative_time NUMBER;
	
	-- 時間計算用関数（ローカル関数として定義）
	FUNCTION timestamp_diff_seconds(ts_end TIMESTAMP, ts_start TIMESTAMP) RETURN NUMBER IS
	BEGIN
		RETURN EXTRACT(DAY FROM (ts_end - ts_start)) * 24 * 60 * 60 +
				EXTRACT(HOUR FROM (ts_end - ts_start)) * 60 * 60 +
				EXTRACT(MINUTE FROM (ts_end - ts_start)) * 60 +
				EXTRACT(SECOND FROM (ts_end - ts_start));
	END timestamp_diff_seconds;

BEGIN
	start_time := SYSTIMESTAMP;

	-- テーブルの初期化
	initialization;

	-- 部署コード一覧取得
	SELECT busho_code
	BULK COLLECT INTO busho_code_array
	FROM m_str;

	WHILE start_idx <= busho_code_array.COUNT LOOP
		
		DECLARE
			-- ネストしたテーブル（INDEX BYなし）を使用
			batch_ids batch_ids_type := batch_ids_type();
			end_idx NUMBER := LEAST(start_idx + constants.BATCH_SIZE - 1, busho_code_array.COUNT);
			query VARCHAR2(32767);
			
			-- 各処理の実行時間格納用
			sql_exec_time NUMBER;
			batch_total_time NUMBER;
		BEGIN
			-- TABLE関数
			batch_ids.EXTEND(end_idx - start_idx + 1);
			FOR i IN start_idx..end_idx LOOP
				batch_ids(i - start_idx + 1) := busho_code_array(i); -- 1-index
			END LOOP;
			
			-- insert
			sql_start := SYSTIMESTAMP;
			EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_str';
			query := 'INSERT INTO temp_str SELECT * FROM TABLE(:batch_ids)';
			EXECUTE IMMEDIATE query USING batch_ids;
			
			-- insert select
			sql_start := SYSTIMESTAMP;
			INSERT INTO w_target_table
				-- /*+ LEADING(m t) USE_NL(t) */
				SELECT /*+ LEADING(m t) USE_NL(t) INDEX(t IDX_LOCAL_2) */ store_cd, jan_cd
				--SELECT /*+ LEADING(m t) USE_HASH(t) PARALLEL(4) */ store_cd, jan_cd
				FROM t_store_weekly_sales t
				INNER JOIN temp_str m ON t.store_cd = m.busho_code
				GROUP BY store_cd, jan_cd;
			sql_exec_time := timestamp_diff_seconds(SYSTIMESTAMP, sql_start);

			DBMS_OUTPUT.PUT_LINE('バッチ' || batch_num || ' SQL実行: ' || ROUND(sql_exec_time, 3) || '秒');
			DBMS_OUTPUT.PUT_LINE('バッチ' || batch_num || ' 処理件数: ' || SQL%ROWCOUNT);
		END;

		COMMIT;
		
		-- バッチ処理実行（挿入結果の確認）
		cumulative_time := timestamp_diff_seconds(SYSTIMESTAMP, start_time);
		
		DBMS_OUTPUT.PUT_LINE('バッチ ' || batch_num || ' 完了');
		DBMS_OUTPUT.PUT_LINE('累積時間: ' || 
			FLOOR(cumulative_time / 60) || '分 ' || 
			ROUND(MOD(cumulative_time, 60), 3) || '秒');
		DBMS_OUTPUT.PUT_LINE('-----------------------------------');

		batch_num := batch_num + 1;
		start_idx := start_idx + constants.BATCH_SIZE;
	END LOOP;

	cumulative_time := timestamp_diff_seconds(SYSTIMESTAMP, start_time);
	DBMS_OUTPUT.PUT_LINE('全体処理完了時間: ' || 
		FLOOR(cumulative_time / 60) || '分 ' || 
		ROUND(MOD(cumulative_time, 60), 3) || '秒');

END;
/
