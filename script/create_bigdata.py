import pandas as pd
import numpy as np

ALREADY_CREATED_WEEK = 100

N_WEEKS = 100
N_STORES = 600
N_JANS_PER_STORE = 18000
N_TOTAL_JANS = int(18000 * 1.5)

def sales_data():
	"""
	n_weeks : 週数
	n_stores : 店舗数
	n_jans_per_store : 1店舗あたりのJAN数
	"""

	# --- 店舗コードを生成 ---
	store_cds = np.random.choice(1_000_000, N_STORES, replace=False)
	store_cds = [f"{x:06d}" for x in store_cds]
	
	# --- 各店舗に JAN を割り当て ---
	arr = [_ for _ in range(1,N_TOTAL_JANS+1)]
	base_records = []
	for store_cd in store_cds:
		jan_cds = np.random.choice(arr, size=N_JANS_PER_STORE, replace=False)
		jan_cds = [f"{x:06d}" for x in jan_cds]
		base_records.extend([(store_cd, jan) for jan in jan_cds])
	base_df = pd.DataFrame(columns=["week_id", "store_cd", "jan_cd"])
	base_df[["store_cd", "jan_cd"]] = base_records

	# --- 各週に展開 ---
	export_csv = pd.DataFrame()
	for week in range(1, N_WEEKS+1):
		week_id = f"{week:06d}"
		tmp = base_df.copy()
		tmp["week_id"] = week_id
		tmp["sales"] = np.round(np.random.uniform(0,1000, len(tmp)), 2)
		
		if week <= ALREADY_CREATED_WEEK:
			continue
		else:
			tmp.to_csv(f'week_id_{week}.csv', index=None)
		#export_csv = pd.concat(export_csv, tmp)
	#export_csv.to_csv(f'week_id_{week}.csv', index=None)


if __name__ == '__main__':
	np.random.seed(0)
	sales_data()