/* temp_table */
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


/* m_store */
create table m_store (
	store_cd varchar2(6)
);
insert into m_str
	select store_cd
	from t_store_weekly_sales
	group by store_cd;
select * from m_str;


/* そこそこ早い=> nested loopでインデックスを使う */
CREATE GLOBAL TEMPORARY TABLE temp_str (
	busho_code varchar2(6)
) on commit preserve rows;
-- indexを使う場合
CREATE UNIQUE INDEX idx_temp_str_busho_unique
ON temp_str(busho_code);

truncate table temp_str;
insert into temp_str
	select *
	from M_STR
	WHERE busho_code BETWEEN '000000' AND '100000';
select * from temp_str;

-- 駆動表(外部表m), 内部表(t) (参考: https://qiita.com/ttttfx702p/items/8238ccadb97259dec752)
-- indexをtemp_strに張ればうまくいきそう
-- 外部表mを読みに行き, 内部表tを走査
-- LEADING(t m) USE_NL(m)の場合、2000秒でも終わらない(mにはno index)が, mにindexを付与することで2分程度
truncate table w_target_table;
INSERT INTO w_target_table (store_cd, jan_cd)
	SELECT /*+ LEADING(m t) USE_NL(t) INDEX(t IDX_LOCAL_2) */ store_cd, jan_cd
	--SELECT /*+ LEADING(t m) USE_NL(m) */ store_cd, jan_cd
	--SELECT /*+ LEADING(m t) USE_HASH(t) */ store_cd, jan_cd
	--SELECT store_cd, jan_cd
	FROM t_store_weekly_sales t
	INNER JOIN temp_str m ON t.store_cd = m.busho_code
	GROUP BY store_cd, jan_cd;
ROLLBACK;

-- ハッシュ結合
-- LEADINGは読みに行く順序(mを読んでハッシュ化⇒tを一行ずつprobe)
-- SELECT /*+ LEADING(small big) USE_HASH(small big) */
truncate table w_target_table;
INSERT INTO w_target_table (store_cd, jan_cd)
	SELECT /*+ LEADING(m t) */ store_cd, jan_cd
	FROM t_store_weekly_sales t
	INNER JOIN temp_str m ON t.store_cd = m.busho_code
	GROUP BY store_cd, jan_cd;
ROLLBACK;











/* なぜかヒント句が効くけどhash join */
truncate table w_target_table;
INSERT INTO w_target_table (store_cd, jan_cd)
	SELECT store_cd, jan_cd
	FROM (
		SELECT /*+ USE_HASH(t m) LEADING(m t) */ store_cd, jan_cd
		FROM t_store_weekly_sales t
		INNER JOIN (
			SELECT * 
			FROM m_str
			WHERE busho_code BETWEEN '000000' AND '200000'
		) m 
			ON 1 = 1
			AND t.store_cd = m.busho_code
	)
	GROUP BY store_cd, jan_cd;
ROLLBACK;

/* UNION ALL */
SELECT /* USE_HASH(t m) LEADING(m t) */ store_cd, jan_cd
FROM t_store_weekly_sales t
INNER JOIN (
	select '004280' as busho_code from dual union all 
	select '676584' from dual union all 
	select '130290' from dual union all 
	select '853663' from dual union all 
	select '001981' from dual union all 
	select '466039' from dual union all 
	select '734751' from dual union all 
	select '703564' from dual union all 
	select '151774' from dual union all 
	select '951008' from dual union all 
	select '757400' from dual union all 
	select '839472' from dual union all 
	select '447380' from dual union all 
	select '068694' from dual union all 
	select '676433' from dual union all 
	select '453876' from dual union all 
	select '366482' from dual union all 
	select '514423' from dual union all 
	select '814028' from dual union all 
	select '955995' from dual union all 
	select '262983' from dual union all 
	select '467838' from dual union all 
	select '620967' from dual union all 
	select '058026' from dual union all 
	select '628255' from dual union all 
	select '958746' from dual union all 
	select '352120' from dual union all 
	select '551637' from dual union all 
	select '956421' from dual union all 
	select '865269' from dual union all 
	select '890788' from dual union all 
	select '615662' from dual union all 
	select '306905' from dual union all 
	select '875229' from dual union all 
	select '047400' from dual union all 
	select '849892' from dual union all 
	select '109610' from dual union all 
	select '328008' from dual union all 
	select '279458' from dual union all 
	select '218339' from dual union all 
	select '839831' from dual union all 
	select '267970' from dual union all 
	select '042111' from dual union all 
	select '304040' from dual union all 
	select '693203' from dual union all 
	select '869312' from dual union all 
	select '869117' from dual union all 
	select '991499' from dual union all 
	select '641116' from dual union all 
	select '169544' from dual union all 
	select '706572' from dual union all 
	select '674947' from dual union all 
	select '122674' from dual union all 
	select '879425' from dual union all 
	select '510067' from dual union all 
	select '685650' from dual union all 
	select '134662' from dual union all 
	select '026547' from dual union all 
	select '468141' from dual union all 
	select '229397' from dual union all 
	select '894327' from dual union all 
	select '091712' from dual union all 
	select '547333' from dual union all 
	select '176626' from dual union all 
	select '693105' from dual union all 
	select '055386' from dual union all 
	select '643882' from dual union all 
	select '612477' from dual union all 
	select '978859' from dual union all 
	select '568542' from dual union all 
	select '799606' from dual union all 
	select '265381' from dual union all 
	select '514674' from dual union all 
	select '939105' from dual union all 
	select '711187' from dual union all 
	select '760763' from dual union all 
	select '580080' from dual union all 
	select '103998' from dual union all 
	select '058500' from dual union all 
	select '072612' from dual union all 
	select '565210' from dual union all 
	select '303833' from dual union all 
	select '717488' from dual union all 
	select '763407' from dual union all 
	select '316698' from dual union all 
	select '104541' from dual union all 
	select '708731' from dual union all 
	select '207830' from dual union all 
	select '740889' from dual union all 
	select '750964' from dual union all 
	select '731087' from dual union all 
	select '601036' from dual union all 
	select '606559' from dual union all 
	select '806264' from dual union all 
	select '369216' from dual union all 
	select '428535' from dual union all 
	select '479157' from dual union all 
	select '739210' from dual union all 
	select '212944' from dual union all 
	select '135197' from dual union all 
	select '057302' from dual union all 
	select '735404' from dual union all 
	select '563233' from dual union all 
	select '077556' from dual union all 
	select '667929' from dual union all 
	select '493088' from dual union all 
	select '031056' from dual union all 
	select '603526' from dual union all 
	select '661139' from dual union all 
	select '714113' from dual union all 
	select '553891' from dual union all 
	select '819789' from dual union all 
	select '382876' from dual union all 
	select '578145' from dual union all 
	select '370702' from dual union all 
	select '408275' from dual union all 
	select '674675' from dual union all 
	select '604258' from dual union all 
	select '593237' from dual union all 
	select '516541' from dual union all 
	select '451999' from dual union all 
	select '566501' from dual union all 
	select '124138' from dual union all 
	select '384310' from dual union all 
	select '395263' from dual union all 
	select '643581' from dual union all 
	select '136582' from dual union all 
	select '303431' from dual union all 
	select '448920' from dual union all 
	select '907019' from dual union all 
	select '992529' from dual union all 
	select '462088' from dual union all 
	select '364763' from dual union all 
	select '952981' from dual union all 
	select '377794' from dual union all 
	select '198748' from dual union all 
	select '039369' from dual union all 
	select '971772' from dual union all 
	select '030386' from dual union all 
	select '118673' from dual union all 
	select '541280' from dual union all 
	select '571724' from dual union all 
	select '199884' from dual union all 
	select '171468' from dual union all 
	select '753889' from dual union all 
	select '385008' from dual union all 
	select '816093' from dual union all 
	select '040273' from dual union all 
	select '857724' from dual union all 
	select '082523' from dual union all 
	select '350336' from dual union all 
	select '055268' from dual union all 
	select '772946' from dual union all 
	select '034927' from dual union all 
	select '077930' from dual union all 
	select '611862' from dual union all 
	select '105911' from dual union all 
	select '313644' from dual union all 
	select '854086' from dual union all 
	select '971734' from dual union all 
	select '626173' from dual union all 
	select '832163' from dual union all 
	select '848454' from dual union all 
	select '198650' from dual union all 
	select '736413' from dual union all 
	select '308921' from dual union all 
	select '138036' from dual union all 
	select '771012' from dual union all 
	select '389584' from dual union all 
	select '947883' from dual union all 
	select '286199' from dual union all 
	select '743553' from dual union all 
	select '215625' from dual union all 
	select '019875' from dual union all 
	select '487528' from dual union all 
	select '351116' from dual union all 
	select '973195' from dual union all 
	select '666745' from dual union all 
	select '755768' from dual union all 
	select '457448' from dual union all 
	select '134040' from dual union all 
	select '675463' from dual union all 
	select '279192' from dual union all 
	select '908762' from dual union all 
	select '552298' from dual union all 
	select '311649' from dual union all 
	select '869013' from dual union all 
	select '989409' from dual union all 
	select '807881' from dual union all 
	select '255170' from dual union all 
	select '775432' from dual union all 
	select '610598' from dual union all 
	select '716902' from dual union all 
	select '117232' from dual union all 
	select '936927' from dual union all 
	select '984168' from dual union all 
	select '005364' from dual union all 
	select '977259' from dual union all 
	select '638341' from dual union all 
	select '951659' from dual union all 
	select '065434' from dual union all 
	select '598152' from dual union all 
	select '474059' from dual union all 
	select '066301' from dual union all 
	select '189533' from dual union all 
	select '784975' from dual union all 
	select '164802' from dual union all 
	select '259032' from dual union all 
	select '454781' from dual union all 
	select '737209' from dual union all 
	select '599235' from dual union all 
	select '566122' from dual union all 
	select '991608' from dual union all 
	select '159767' from dual union all 
	select '353740' from dual union all 
	select '706011' from dual union all 
	select '282593' from dual union all 
	select '740767' from dual union all 
	select '326496' from dual union all 
	select '460175' from dual union all 
	select '796710' from dual union all 
	select '955415' from dual union all 
	select '608171' from dual union all 
	select '436355' from dual union all 
	select '073054' from dual union all 
	select '316363' from dual union all 
	select '581410' from dual union all 
	select '613903' from dual union all 
	select '882238' from dual union all 
	select '891522' from dual union all 
	select '593389' from dual union all 
	select '551643' from dual union all 
	select '229395' from dual union all 
	select '613008' from dual union all 
	select '652273' from dual union all 
	select '342671' from dual union all 
	select '840348' from dual union all 
	select '776723' from dual union all 
	select '523656' from dual union all 
	select '157467' from dual union all 
	select '010387' from dual union all 
	select '124043' from dual union all 
	select '237778' from dual union all 
	select '486447' from dual union all 
	select '714529' from dual union all 
	select '146617' from dual union all 
	select '266233' from dual union all 
	select '472408' from dual union all 
	select '208749' from dual union all 
	select '596487' from dual union all 
	select '672526' from dual union all 
	select '245388' from dual union all 
	select '273343' from dual union all 
	select '515839' from dual union all 
	select '119993' from dual union all 
	select '863667' from dual union all 
	select '851159' from dual union all 
	select '646029' from dual union all 
	select '136867' from dual union all 
	select '963598' from dual union all 
	select '734013' from dual union all 
	select '322081' from dual union all 
	select '383359' from dual union all 
	select '379038' from dual union all 
	select '053583' from dual union all 
	select '238321' from dual union all 
	select '418202' from dual union all 
	select '084838' from dual union all 
	select '406950' from dual union all 
	select '376675' from dual union all 
	select '379540' from dual union all 
	select '268124' from dual union all 
	select '725843' from dual union all 
	select '120781' from dual union all 
	select '280690' from dual union all 
	select '159099' from dual union all 
	select '607881' from dual union all 
	select '517600' from dual union all 
	select '520027' from dual union all 
	select '297849' from dual union all 
	select '635698' from dual union all 
	select '858831' from dual union all 
	select '791038' from dual union all 
	select '397436' from dual union all 
	select '246075' from dual union all 
	select '233064' from dual union all 
	select '460511' from dual union all 
	select '854461' from dual union all 
	select '229142' from dual union all 
	select '862775' from dual union all 
	select '975365' from dual union all 
	select '194781' from dual union all 
	select '604780' from dual union all 
	select '332914' from dual union all 
	select '379771' from dual union all 
	select '771814' from dual union all 
	select '877032' from dual union all 
	select '458073' from dual union all 
	select '451074' from dual union all 
	select '873812' from dual union all 
	select '358320' from dual union all 
	select '335423' from dual union all 
	select '185474' from dual union all 
	select '042335' from dual union all 
	select '374554' from dual union all 
	select '157105' from dual union all 
	select '688694' from dual union all 
	select '568106' from dual union all 
	select '025532' from dual union all 
	select '058761' from dual union all 
	select '229156' from dual union all 
	select '397141' from dual union all 
	select '036376' from dual union all 
	select '872960' from dual union all 
	select '588063' from dual union all 
	select '113988' from dual union all 
	select '395558' from dual union all 
	select '170177' from dual union all 
	select '756849' from dual union all 
	select '342923' from dual union all 
	select '660825' from dual union all 
	select '591853' from dual union all 
	select '034399' from dual union all 
	select '300454' from dual union all 
	select '333985' from dual union all 
	select '592630' from dual union all 
	select '508461' from dual union all 
	select '428415' from dual union all 
	select '032219' from dual union all 
	select '337681' from dual union all 
	select '423337' from dual union all 
	select '970112' from dual union all 
	select '449524' from dual union all 
	select '667650' from dual union all 
	select '855168' from dual union all 
	select '349985' from dual union all 
	select '360192' from dual union all 
	select '916599' from dual union all 
	select '882286' from dual union all 
	select '369433' from dual union all 
	select '440590' from dual union all 
	select '287507' from dual union all 
	select '412522' from dual union all 
	select '463220' from dual union all 
	select '163442' from dual union all 
	select '952293' from dual union all 
	select '816214' from dual union all 
	select '686696' from dual union all 
	select '675024' from dual union all 
	select '357040' from dual union all 
	select '966601' from dual union all 
	select '381829' from dual union all 
	select '638326' from dual union all 
	select '631132' from dual union all 
	select '508067' from dual union all 
	select '572111' from dual union all 
	select '556661' from dual union all 
	select '487941' from dual union all 
	select '560912' from dual union all 
	select '957651' from dual union all 
	select '682773' from dual union all 
	select '200294' from dual union all 
	select '705734' from dual union all 
	select '476501' from dual union all 
	select '617167' from dual union all 
	select '164427' from dual union all 
	select '111296' from dual union all 
	select '200661' from dual union all 
	select '176124' from dual union all 
	select '025732' from dual union all 
	select '869199' from dual union all 
	select '727369' from dual union all 
	select '133936' from dual union all 
	select '917853' from dual union all 
	select '224285' from dual union all 
	select '051675' from dual union all 
	select '865417' from dual union all 
	select '247094' from dual union all 
	select '463747' from dual union all 
	select '326185' from dual union all 
	select '594305' from dual union all 
	select '442787' from dual union all 
	select '094727' from dual union all 
	select '840001' from dual union all 
	select '091739' from dual union all 
	select '916799' from dual union all 
	select '456626' from dual union all 
	select '785044' from dual union all 
	select '801135' from dual union all 
	select '089568' from dual union all 
	select '102328' from dual union all 
	select '551480' from dual union all 
	select '260284' from dual union all 
	select '182264' from dual union all 
	select '023477' from dual union all 
	select '688240' from dual union all 
	select '391898' from dual union all 
	select '638739' from dual union all 
	select '530683' from dual union all 
	select '809742' from dual union all 
	select '262787' from dual union all 
	select '605820' from dual union all 
	select '866735' from dual union all 
	select '472741' from dual union all 
	select '703068' from dual union all 
	select '971605' from dual union all 
	select '612812' from dual union all 
	select '413070' from dual union all 
	select '008877' from dual union all 
	select '241326' from dual union all 
	select '455391' from dual union all 
	select '675191' from dual union all 
	select '104149' from dual union all 
	select '315831' from dual union all 
	select '841277' from dual union all 
	select '556040' from dual union all 
	select '306398' from dual union all 
	select '773398' from dual union all 
	select '176594' from dual union all 
	select '877159' from dual union all 
	select '175679' from dual union all 
	select '890556' from dual union all 
	select '361934' from dual union all 
	select '867851' from dual union all 
	select '604246' from dual union all 
	select '466919' from dual union all 
	select '337215' from dual union all 
	select '443075' from dual union all 
	select '174301' from dual union all 
	select '968621' from dual union all 
	select '611393' from dual union all 
	select '215367' from dual union all 
	select '393426' from dual union all 
	select '897598' from dual union all 
	select '679666' from dual union all 
	select '171203' from dual union all 
	select '322147' from dual union all 
	select '631316' from dual union all 
	select '838930' from dual union all 
	select '325114' from dual union all 
	select '774914' from dual union all 
	select '140159' from dual union all 
	select '272477' from dual union all 
	select '772583' from dual union all 
	select '225853' from dual union all 
	select '539685' from dual union all 
	select '327626' from dual union all 
	select '068969' from dual union all 
	select '308073' from dual union all 
	select '798831' from dual union all 
	select '970950' from dual union all 
	select '550378' from dual union all 
	select '334658' from dual union all 
	select '800352' from dual union all 
	select '726752' from dual union all 
	select '257329' from dual union all 
	select '813637' from dual union all 
	select '985895' from dual union all 
	select '299941' from dual union all 
	select '833960' from dual union all 
	select '958356' from dual union all 
	select '474312' from dual union all 
	select '851770' from dual union all 
	select '214242' from dual union all 
	select '771948' from dual union all 
	select '228838' from dual union all 
	select '642296' from dual union all 
	select '171187' from dual union all 
	select '518736' from dual union all 
	select '216352' from dual union all 
	select '209838' from dual union all 
	select '199960' from dual union all 
	select '404937' from dual union all 
	select '960149' from dual union all 
	select '227882' from dual union all 
	select '431922' from dual union all 
	select '804853' from dual union all 
	select '549908' from dual union all 
	select '419055' from dual union all 
	select '133137' from dual union all 
	select '866245' from dual union all 
	select '902160' from dual union all 
	select '900071' from dual union all 
	select '762126' from dual union all 
	select '016929' from dual union all 
	select '968993' from dual union all 
	select '057453' from dual union all 
	select '999798' from dual union all 
	select '849285' from dual union all 
	select '088659' from dual union all 
	select '930967' from dual union all 
	select '064513' from dual union all 
	select '464796' from dual union all 
	select '030283' from dual union all 
	select '987314' from dual union all 
	select '431715' from dual union all 
	select '309631' from dual union all 
	select '075251' from dual union all 
	select '336226' from dual union all 
	select '046381' from dual union all 
	select '502680' from dual union all 
	select '964961' from dual union all 
	select '942574' from dual union all 
	select '202788' from dual union all 
	select '460196' from dual union all 
	select '384940' from dual union all 
	select '191601' from dual union all 
	select '059811' from dual union all 
	select '393523' from dual union all 
	select '150817' from dual union all 
	select '317525' from dual union all 
	select '369936' from dual union all 
	select '581089' from dual union all 
	select '627876' from dual union all 
	select '277523' from dual union all 
	select '327991' from dual union all 
	select '854755' from dual union all 
	select '257537' from dual union all 
	select '626081' from dual union all 
	select '310192' from dual union all 
	select '139219' from dual union all 
	select '574992' from dual union all 
	select '705446' from dual union all 
	select '642477' from dual union all 
	select '277864' from dual union all 
	select '723240' from dual union all 
	select '586964' from dual union all 
	select '925605' from dual union all 
	select '566682' from dual union all 
	select '005298' from dual union all 
	select '434708' from dual union all 
	select '019818' from dual union all 
	select '567152' from dual union all 
	select '939551' from dual union all 
	select '098332' from dual union all 
	select '325507' from dual union all 
	select '201632' from dual union all 
	select '594761' from dual union all 
	select '472010' from dual union all 
	select '255438' from dual union all 
	select '550034' from dual union all 
	select '201250' from dual union all 
	select '920509' from dual union all 
	select '743826' from dual union all 
	select '560686' from dual union all 
	select '049908' from dual union all 
	select '901021' from dual union all 
	select '091116' from dual union all 
	select '745799' from dual union all 
	select '285366' from dual union all 
	select '833346' from dual union all 
	select '222078' from dual union all 
	select '088216' from dual union all 
	select '703383' from dual union all 
	select '546994' from dual union all 
	select '495777' from dual union all 
	select '398921' from dual union all 
	select '037463' from dual union all 
	select '943481' from dual union all 
	select '690899' from dual union all 
	select '828797' from dual union all 
	select '640525' from dual union all 
	select '223536' from dual union all 
	select '296892' from dual union all 
	select '823419' from dual union all 
	select '044100' from dual union all 
	select '623291' from dual union all 
	select '582617' from dual union all 
	select '815991' from dual union all 
	select '444549' from dual union all 
	select '474540' from dual union all 
	select '968307' from dual union all 
	select '182971' from dual union all 
	select '757828' from dual union all 
	select '641056' from dual union all 
	select '046404' from dual union all 
	select '840073' from dual union all 
	select '589946' from dual union all 
	select '079879' from dual union all 
	select '014118' from dual union all 
	select '836710' from dual union all 
	select '350201' from dual union all 
	select '026972' from dual union all 
	select '025821' from dual union all 
	select '998068' from dual union all 
	select '437894' from dual union all 
	select '943795' from dual union all 
	select '569515' from dual union all 
	select '481316' from dual union all 
	select '746102' from dual union all 
	select '783967' from dual union all 
	select '466466' from dual union all 
	select '655166' from dual union all 
	select '399851' from dual union all 
	select '447629' from dual union all 
	select '866007' from dual union all 
	select '419671' from dual union all 
	select '818214' from dual union all 
	select '196988' from dual union all 
	select '295609' from dual
) m 
	ON 1 = 1
	AND t.store_cd = m.busho_code
GROUP BY store_cd, jan_cd;