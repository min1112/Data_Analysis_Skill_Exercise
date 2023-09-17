--테이블 구조 확인하기
select *
from log_table_practice2 

select *
from first_ord_table_practice2 

--쇼핑 리드타임

with 
log as (
	select a.mem_no
		   ,SUBSTR(first_ord_dt, 1,7) as fst_ord_month
		   ,gender
		   ,age
		   ,log_dt
		   ,session_id
		   ,DATETIME(log_stamp) as log_stamp
		   ,last_value(session_id) over (partition by a.mem_no) as last_session
	from log_table_practice2 a
	inner join first_ord_table_practice2 b on a.mem_no = b.mem_no
)
,cart as (
	select mem_no
		   ,fst_ord_month
		   ,gender
		   ,age
		   ,session_id
		   ,last_session
		   ,min(log_stamp) over (partition by mem_no, session_id) as first_cartclk
		   ,max(log_stamp) over (partition by mem_no, session_id) as last_cartclk
	from log
)
,summary as (
	select distinct mem_no
		   ,fst_ord_month
		   ,gender
		   ,age
		   ,first_cartclk
		   ,last_cartclk
		   ,(julianday(last_cartclk)-julianday(first_cartclk)) * 24 * 60 as lead_time
	from cart
	where 1=1 
	and session_id = last_session
)
--연령대별로 쇼핑 리드타임 평균내기
	select gender, avg(lead_time) as avg_leadtime
	from summary
	group by 1
	order by 1