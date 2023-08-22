with
T1 as (
	select distinct ft.mem_no
		   ,is_promotion
		   --,first_ord_dt
		   --,ord_dt 
		   ,case when ord_dt = first_ord_dt then 0
		   		 when ord_dt > first_ord_dt and DATE(ord_dt) <= DATE(first_ord_dt, '+7 days') then 1
		   		 when DATE(ord_dt) > DATE(first_ord_dt, '+7 days') and DATE(ord_dt) <= DATE(first_ord_dt, '+14 days') then 2
		   		 when DATE(ord_dt) > DATE(first_ord_dt, '+14 days') and DATE(ord_dt) <= DATE(first_ord_dt, '+21 days') then 3
		   		 when DATE(ord_dt) > DATE(first_ord_dt, '+21 days') and DATE(ord_dt) <= DATE(first_ord_dt, '+28 days') then 4
		   		 else null end as week_range
	from first_ord_table ft 
	left join order_master_cohort omc on ft.mem_no = omc.mem_no
)
,T2 as (
	select is_promotion
		   ,mem_no
		   ,week_range
		   ,row_number() over (partition by mem_no order by week_range) as seq
	from T1
	where week_range is not null
	order by 1,2,3,4
)
	select is_promotion
		   ,case when week_range = 0 then '1.w-0'
		   		 when week_range = 1 and seq = 2 then '2.w-1'
		   		 when week_range = 2 and seq = 3 then '3.w-2'
				 when week_range = 3 and seq = 4 then '4.w-3'
				 when week_range = 4 and seq = 5 then '5.w-4' end as week_range
		   ,count(mem_no) as mem_cnt
	from T2
	group by 1,2
	order by 1,2
	
