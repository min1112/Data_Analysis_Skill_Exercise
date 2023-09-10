--테이블 구조 살피기
select *
from log_table

select *
from order_master_log 

--로그데이터 분석

with 
log as (
	select distinct mem_no
		   ,min(referrer) over (partition by mem_no order by log_stamp) as referrer
		   ,session_id
		   ,log_dt
		   ,DATETIME(log_stamp) as log_stamp
	from log_table 
)
,ord as (
	select distinct a.mem_no
		   ,referrer
		   ,log_stamp
		   ,DATETIME(ord_stamp) as ord_stamp
		   ,count(DISTINCT ord_no) as ord_cnt
	from log a
	left join order_master_log b 
		on a.mem_no = b.mem_no 
		and DATE(a.log_dt) = DATE(b.ord_stamp) 
		and a.log_stamp < DATETIME(b.ord_stamp)
	group by 1,2,3,4
)
,ord2 as (
	select distinct mem_no
		   ,referrer
		   ,case when ord_cnt >= 1 then 1 else 0 end as is_ord
	from ord
)
	select referrer
		   ,sum(is_ord) as ord_cnt
	from ord2
	group by 1

	
	