--테이블 구조 확인
select *
from first_ord_table_ltv 


select *
from order_master_ltv


--문자형식 날짜형식으로 변형
DATE(first_ord_dt, '+7 days') 

--LTV 계산을 위한 리텐션 구하기
with
ord as (
	select a.mem_no
		   ,b.age_range
		   ,b.first_ord_dt
		   ,a.ord_dt
		   ,a.order_amount
	from order_master_ltv a
	left join first_ord_table_ltv b on a.mem_no = b.mem_no 
)
,cohort as (
	select age_range
		   ,case when first_ord_dt = ord_dt then 'M-0'
		   		 when first_ord_dt < ord_dt and DATE(ord_dt) <= DATE(first_ord_dt, '+1 month') then 'M-1'
		   		 when DATE(ord_dt) > DATE(first_ord_dt, '+1 month') and DATE(ord_dt) <= DATE(first_ord_dt, '+2 month') then 'M-2'
		   		 when DATE(ord_dt) > DATE(first_ord_dt, '+2 month') and DATE(ord_dt) <= DATE(first_ord_dt, '+3 month') then 'M-3'
		   		 when DATE(ord_dt) > DATE(first_ord_dt, '+3 month') and DATE(ord_dt) <= DATE(first_ord_dt, '+4 month') then 'M-4'
		   		 when DATE(ord_dt) > DATE(first_ord_dt, '+4 month') and DATE(ord_dt) <= DATE(first_ord_dt, '+5 month') then 'M-5'
		   		 else 'over_5m' end as month_nm
			,count(distinct mem_no) as sample_cnt
			,round(avg(order_amount)) as revenue
	from ord
	group by 1,2
	order by 1,2
)
	select age_range
		   ,month_nm
		   ,sample_cnt
		   ,sample_cnt * 1.00 / max(sample_cnt) over (partition by age_range) as retention
		   ,revenue
	from cohort
	order by 1,2
		 