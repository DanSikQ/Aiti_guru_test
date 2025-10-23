select 
	fs.client_id, 
	company_name,  
	sum(fs.revenue) as revenue, 
	sum(fs.margin) as margin, 
	max(dc.manager_id) as manager_id, 
	max(manager_name) as manager_name 
from fact_sales fs
left join dim_clients dc on fs.client_id = dc.client_id
left join dim_managers dm on dc.manager_id = dm.manager_id WHERE dm.manager_id = 2 and sale_date BETWEEN '2023-11-01' AND '2023-11-30'
Group by fs.client_id, company_name