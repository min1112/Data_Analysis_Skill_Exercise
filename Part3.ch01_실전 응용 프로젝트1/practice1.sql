select *
from first_ord_table_practice1 
	
--코호트 분석	
--하루 2건이상 주문 제외 	
	
with
fst as (
	select mem_no, first_ord_dt
	from first_ord_table_practice1 
	where 1=1
	and first_ord_dt >= '2023-07-01' 
	and first_ord_dt <= '2023-07-31'
)
,ord as (
	select distinct a.mem_no
		   ,first_ord_dt
		   ,ord_dt
		   ,sum(case when first_ord_dt < ord_dt and DATE(ord_dt) <= DATE(first_ord_dt, '+7 days') then 1 else 0 end) over (partition by a.mem_no) as is_w1_ord
		   ,dense_rank() over (partition by a.mem_no order by ord_dt) as ord_seq
	from order_master_practive1 a
	inner join fst b on a.mem_no = b.mem_no
	where 1=1
	and ord_dt >= '2023-07-01'
	and ord_dt <= '2023-08-31'
	order by 1,3,4
)			   
	select ord_seq
		   ,case when is_w1_ord > 0 then 1 else 0 end as is_w1_ord
		   ,count(distinct mem_no) as mem_cnt
	from ord
	group by 1,2
	order by is_w1_ord