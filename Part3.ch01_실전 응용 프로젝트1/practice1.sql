
--코호트 분석	
	
with
fst as (
	select mem_no, first_ord_dt
	from first_ord_table_practice1 
	where 1=1
	and first_ord_dt >= '2023-07-01' 
	and first_ord_dt <= '2023-07-31' --7월 한 달 동안의 첫주문 고객
)
,ord as (
	select distinct a.mem_no
		   ,first_ord_dt
		   ,ord_dt
		   ,sum(case when first_ord_dt < ord_dt and DATE(ord_dt) <= DATE(first_ord_dt, '+7 days') then 1 else 0 end) over (partition by a.mem_no) as is_w1_ord
		   --첫주문 이후 1주일 이내 오더인지 판별
		   ,dense_rank() over (partition by a.mem_no order by ord_dt) as ord_seq 
		   	-- dense_rank 는 동일한 값이면 중복순위를 부여
	from order_master_practive1 a
	inner join fst b on a.mem_no = b.mem_no
	where 1=1
	and ord_dt >= '2023-07-01'
	and ord_dt <= '2023-08-31'
	order by 1,3,4
)			   
	select ord_seq
		   ,case when is_w1_ord > 0 then 1 else 0 end as is_w1_ord --1주일 이내 오더가 1건 이상이면 1로 분류
		   ,count(distinct mem_no) as mem_cnt
	from ord
	group by 1,2
	order by is_w1_ord