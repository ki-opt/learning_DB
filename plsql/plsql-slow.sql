/* IN句が遅い原因であることは分かった

exists句の中身増やして検討？
*/

CREATE OR REPLACE PROCEDURE initialization AS
BEGIN
	EXECUTE IMMEDIATE 'TRUNCATE TABLE w_target_table';
END;
/

CREATE OR REPLACE PACKAGE constants AS
	BATCH_SIZE NUMBER := 100;
END constants;
/

CREATE OR REPLACE TYPE batch_ids_type AS TABLE OF VARCHAR2(6);
/

DECLARE
	-- 部署コード一覧取得用変数
	TYPE busho_code_type IS TABLE OF m_str.busho_code%TYPE INDEX BY PLS_INTEGER;
	busho_code_array busho_code_type;

	-- 作業用変数
	batch_num NUMBER := 1;
	start_idx NUMBER := 1;
	
	-- 時間測定用変数（TIMESTAMP差分を秒で計算する関数を使用）
	start_time TIMESTAMP := SYSTIMESTAMP;
	batch_start TIMESTAMP;
	table_func_start TIMESTAMP;
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
	-- テーブルの初期化
	initialization;

	-- 部署コード一覧取得
	SELECT busho_code
	BULK COLLECT INTO busho_code_array
	FROM m_str;
	--WHERE BUSHO_CODE BETWEEN '000000' AND '200000';

	DBMS_OUTPUT.PUT_LINE('総バッチ数: ' || CEIL(busho_code_array.COUNT / constants.BATCH_SIZE));

	WHILE start_idx <= busho_code_array.COUNT LOOP
		
		DECLARE
			-- ネストしたテーブル（INDEX BYなし）を使用
			batch_ids batch_ids_type := batch_ids_type();
			end_idx NUMBER := LEAST(start_idx + constants.BATCH_SIZE - 1, busho_code_array.COUNT);
			query VARCHAR2(32767);
			
			-- 各処理の実行時間格納用
			table_func_time NUMBER;
			sql_build_time NUMBER;
			sql_exec_time NUMBER;
			batch_total_time NUMBER;
		BEGIN
			batch_start := SYSTIMESTAMP;
			
			-- TABLE関数部分の時間測定
			table_func_start := SYSTIMESTAMP;
			batch_ids.EXTEND(end_idx - start_idx + 1);
			FOR i IN start_idx..end_idx LOOP
				batch_ids(i - start_idx + 1) := busho_code_array(i); -- 1-index
			END LOOP;
			
			table_func_time := timestamp_diff_seconds(SYSTIMESTAMP, table_func_start);
			DBMS_OUTPUT.PUT_LINE('バッチ' || batch_num || ' TABLE関数準備: ' || 
				ROUND(table_func_time, 3) || '秒');
		
			-- SQL構築時間測定
			sql_start := SYSTIMESTAMP;
			query := 'INSERT INTO w_target_table (store_cd, jan_cd) ' ||
							'SELECT /*+ INDEX(T_STORE_WEEKLY_SALES IDX_LOCAL_2) */ store_cd, jan_cd ' ||
							'FROM t_store_weekly_sales t ' ||
							--'WHERE store_cd IN (SELECT column_value FROM TABLE(:batch_ids)) ' ||
							'WHERE EXISTS (SELECT 1 FROM TABLE(:batch_ids) WHERE t.store_cd = column_value) ' || 
							'GROUP BY store_cd, jan_cd ';
			sql_build_time := timestamp_diff_seconds(SYSTIMESTAMP, sql_start);
			DBMS_OUTPUT.PUT_LINE('バッチ' || batch_num || ' SQL構築: ' || 
				ROUND(sql_build_time, 3) || '秒');
			
			-- SQL実行時間測定
			sql_start := SYSTIMESTAMP;
			EXECUTE IMMEDIATE query USING batch_ids;	--batch_idsあり
			--EXECUTE IMMEDIATE query; 						--batch_idsなし
			
			sql_exec_time := timestamp_diff_seconds(SYSTIMESTAMP, sql_start);
			batch_total_time := timestamp_diff_seconds(SYSTIMESTAMP, batch_start);
			
			DBMS_OUTPUT.PUT_LINE('バッチ' || batch_num || ' SQL実行: ' || 
				ROUND(sql_exec_time, 3) || '秒');
			DBMS_OUTPUT.PUT_LINE('バッチ' || batch_num || ' 処理件数: ' || SQL%ROWCOUNT);
			DBMS_OUTPUT.PUT_LINE('バッチ' || batch_num || ' 総所要時間: ' || 
				ROUND(batch_total_time, 3) || '秒');			
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



/*
DECLARE
	-- 部署コード一覧取得用変数
	TYPE busho_code_type IS TABLE OF m_str.busho_code%TYPE INDEX BY PLS_INTEGER;
	busho_code_array busho_code_type;

	-- 作業用変数
	batch_num NUMBER := 1;
	start_idx NUMBER := 1;

BEGIN
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
		BEGIN
			-- バッチ分IDを抽出
			batch_ids.EXTEND(end_idx - start_idx + 1);
			FOR i IN start_idx..end_idx LOOP
				batch_ids(i - start_idx + 1) := busho_code_array(i);	-- 1-index
			END LOOP;
		
			-- insert to target_table
			query := 'INSERT INTO w_target_table (store_cd, jan_cd) ' ||
							'SELECT store_cd, jan_cd ' ||
							'FROM t_store_weekly_sales ' ||
							'WHERE store_cd IN (SELECT column_value FROM TABLE(:batch_ids)) ' ||
							'GROUP BY store_cd, jan_cd ';
			EXECUTE IMMEDIATE query USING batch_ids;
		END;

		COMMIT;
		
		-- バッチ処理実行（挿入結果の確認）
		DBMS_OUTPUT.PUT_LINE('バッチ ' || batch_num || ' 完了');
		DBMS_OUTPUT.PUT_LINE('');

		batch_num := batch_num + 1;
		start_idx := start_idx + constants.BATCH_SIZE;
	END LOOP;


EXCEPTION
WHEN OTHERS THEN
	ROLLBACK;
END;
/
*/
