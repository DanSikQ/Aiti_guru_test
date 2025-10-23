select fs.*, SUM(revenue) OVER(Order by sale_date) acc_revenue, SUM(margin) OVER(Order by sale_date) as acc_margin from fact_sales fs
left join dim_clients dc on fs.client_id = dc.client_id
Where sale_date between '2023-11-01' and '2023-11-30' and dc.manager_id = 2
order by sale_date