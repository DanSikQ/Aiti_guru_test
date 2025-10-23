

With full_sales as (
			select 
				sale_id, 
				sum(fs.revenue) as revenue, 
				sum(fs.margin) as margin, 
				max(dc.manager_id) as manager_id, 
				max(manager_name) as manager_name 
			from fact_sales fs
			left join dim_clients dc on fs.client_id = dc.client_id
			left join dim_managers dm on dc.manager_id = dm.manager_id WHERE dm.manager_id = 2 and sale_date BETWEEN '2023-11-01' AND '2023-11-30'
			Group by sale_id)

select res.*, plan_revenue, plan_margin, plan_avg_ticket from (select 
					fs.manager_id,
					max(fs.manager_name) as manager_name,
					SUM(fs.revenue - COALESCE(fr.revenue, 0)) as revenue_aft_ret,
    				SUM(fs.margin - COALESCE(fr.margin, 0)) as margin_aft_ret,
					AVG(fs.revenue) as avg_revenue,
					count(*) as count_sales
				from full_sales fs
				Left Join (select * from fact_returns Where sale_id in (select sale_id from full_sales)) fr on fr.sale_id = fs.sale_id 
				Group by manager_id) res
Left join fact_plans fp on res.manager_id = fp.manager_id where fp.period = '2023-11-01'

