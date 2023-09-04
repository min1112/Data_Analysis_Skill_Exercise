--타겟 테이블
	select *
	from coupon_target_table ctt 
	
--오더마스터 테이블
	select *
	from order_master_did omd 
	
--두 테이블 조인
	select *
	from coupon_target_table ctt 
	left join order_master_did omd on ctt.mem_no = omd.mem_no
	
--그룹별 샘플사이즈 
	select "group"
		   ,count(mem_no) as mem_cnt
	from coupon_target_table ctt 
	group by 1
	
--이중차분법을 위한 그룹별주문수 집계
WITH 
T1 as (
	select ctt.mem_no
		   ,"group"
		   ,ord_no
		   ,case when ord_dt between '2023-06-05' and '2023-06-11' then '처치 전'
		   		 when ord_dt between '2023-06-12' and '2023-06-18' then '처치 후' end as period
	from coupon_target_table ctt 
	left join order_master_did omd on ctt.mem_no = omd.mem_no
)
	select "group"
			,period
			,count(distinct mem_no) as ord_cnt
	from T1
	where period is not null
	group by 1,2