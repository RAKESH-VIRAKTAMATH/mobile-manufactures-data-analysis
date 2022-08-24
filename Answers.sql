--SQL Advance Case Study
select * from DIM_CUSTOMER
select * from DIM_DATE
select * from DIM_LOCATION
select * from DIM_MANUFACTURER
select * from DIM_MODEL
select * from FACT_TRANSACTIONS

--Q1--BEGIN 

select distinct t1.State from FACT_TRANSACTIONS t2 left join DIM_LOCATION t1
on t2.IDLocation = t1.IDLocation
where year(t2.Date) > 2005

--Q1--END

--Q2--BEGIN
	
		
select top 1 t1.State, sum(t2.Quantity) as qnty 
from FACT_TRANSACTIONS t2 
left join DIM_LOCATION t1
on t2.IDLocation = t1.IDLocation 
RIGHT join DIM_MODEL m on  m.IDModel = t2.IDModel 
RIGHT join DIM_MANUFACTURER mn on mn.IDManufacturer= m.IDManufacturer
where Manufacturer_Name = 'Samsung' and t1.Country = 'US'
group by t1.State
order by sum(t2.Quantity) desc

--Q2--END

--Q3--BEGIN      
	
	Select  t1.ZipCode , t1.State,count(t2.IDModel) ' no_of_trans' 
	from FACT_TRANSACTIONS t2
	Join DIM_LOCATION t1 on t2.IDLocation= t1.IDLocation
    join DIM_MODEL on  t2.IDModel = DIM_MODEL.IDModel
    join DIM_MANUFACTURER  on DIM_MODEL.IDManufacturer = DIM_MANUFACTURER.IDManufacturer
	Group by t1.ZipCode , t1.State
	Order by COUNT(t2.IDModel) Desc

--Q3--END

--Q4--BEGIN

select t1.Manufacturer_Name,t2.Model_Name, avg(Totalprice) Avg_price
from FACT_TRANSACTIONS f 
inner join DIM_MODEL t2 on t2.IDModel = f.IDModel 
inner join DIM_MANUFACTURER t1 on t1.IDManufacturer = t2.IDManufacturer 
where Manufacturer_Name in (
select top 5 Manufacturer_Name
from FACT_TRANSACTIONS f 
inner join DIM_MODEL t2 on t2.IDModel = f.IDModel 
inner join DIM_MANUFACTURER t1 on t1.IDManufacturer = t2.IDManufacturer 
group by Manufacturer_Name
order by COUNT(Quantity) desc)
group by Manufacturer_Name,Model_Name
order by avg(totalprice) desc


--Q4--END

--Q5--BEGIN
select IDManufacturer, IDModel, avg(Unit_price) avg_price from DIM_MODEL
where IDManufacturer 
in (
	select top 5 IDManufacturer 
	from FACT_TRANSACTIONS  
	left join DIM_MODEL  on FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
	group by IDManufacturer
	order by sum(Quantity) desc
	)
group by IDManufacturer, IDModel
order by avg(Unit_price) desc

--Q5--END

--Q6--BEGIN

select DIM_CUSTOMER.Customer_Name, DIM_DATE.year ,avg(TotalPrice) Avg_spend 
from FACT_TRANSACTIONS
inner join DIM_CUSTOMER
on DIM_CUSTOMER.IDCustomer = FACT_TRANSACTIONS.IDCustomer 
inner join DIM_DATE
on DIM_DATE.DATE = FACT_TRANSACTIONS.Date 
where [YEAR] = 2009 
group by DIM_CUSTOMER.Customer_Name ,[YEAR] 
having avg(TotalPrice) > 500

--Q6--END
	
--Q7--BEGIN  
	

  Select t1.Model_Name  
  from (select top 5 m.Model_Name,m.IDmodel ,sum(f.Quantity) as Total_Qnty
  from FACT_TRANSACTIONS as f


  inner join DIM_MODEL as m on m.IDModel=f.IDModel
  where year(f.[Date])=2008 
  group by m.Model_Name,m.IDmodel
  order by Total_Qnty desc) as t1 


  inner join
  (select top 5 m.Model_Name,m.IDmodel ,sum(f.Quantity) as Total_Qnty 
  from FACT_TRANSACTIONS as f


  inner join DIM_MODEL as m on m.IDModel=f.IDModel
  where year(f.[Date])=2009
  group by m.Model_Name,m.IDmodel
  order by Total_Qnty desc) as t2 on t1.Model_Name=t2.Model_Name 


  inner join
  (select top 5 m.Model_Name,m.IDmodel ,sum(f.Quantity) as Total_Qnty 
  from FACT_TRANSACTIONS as f


  inner join DIM_MODEL as m on m.IDModel=f.IDModel
  where year(f.[Date])=2010
  group by m.Model_Name,m.IDmodel
  order by Total_Qnty desc) as t3 on t3.Model_Name=t2.Model_Name;
	

--Q7--END	
--Q8--BEGIN

select Manufacturer_Name, [year], [Qnty_sold]
from (
select Manufacturer_Name,year(date) [year], sum(Quantity) [Qnty_sold] 
from FACT_TRANSACTIONS t
left join DIM_MODEL m on t.IDModel = m.IDModel 
left join DIM_MANUFACTURER mn on m.IDManufacturer = mn.IDManufacturer
where year(Date) = '2009'
group by Manufacturer_Name, year(date)
order by sum(Quantity) desc
offset 1 row
fetch next 1 row only
union all
select Manufacturer_Name,  year(date) [year], sum(Quantity) [Qnty_sold] 
from FACT_TRANSACTIONS t 
left join DIM_MODEL m on t.IDModel = m.IDModel 
left join DIM_MANUFACTURER mn on m.IDManufacturer = mn.IDManufacturer
where year(Date) = '2010'
group by Manufacturer_Name, year(date)
order by sum(Quantity) desc
offset 1 row
fetch next 1 row only
) as t1


--Q8--END
--Q9--BEGIN
	
Select DIM_MANUFACTURER.Manufacturer_Name from FACT_TRANSACTIONS 
Join  DIM_MODEL  on  FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
Join DIM_MANUFACTURER on DIM_MODEL.IDManufacturer = DIM_MANUFACTURER.IDManufacturer
where  YEAR(FACT_TRANSACTIONS.Date) = 2010
group by DIM_MANUFACTURER.Manufacturer_Name
EXCEPT
Select DIM_MANUFACTURER.Manufacturer_Name from FACT_TRANSACTIONS
Join  DIM_MODEL  on  FACT_TRANSACTIONS.IDModel = DIM_MODEL.IDModel
Join DIM_MANUFACTURER on DIM_MODEL.IDManufacturer = DIM_MANUFACTURER.IDManufacturer
where  YEAR(FACT_TRANSACTIONS.Date) = 2009 
group by DIM_MANUFACTURER.Manufacturer_Name

--Q9--END

--Q10--BEGIN
	
select top 100 Customer_Name, TotalPrice, 
avg_spnd as [Average_spend], 
avg_qty as [Avg_Quantity], 
dt as [year_of_spend], 
case when A.prev_spend = 0 
then null else convert(numeric(25,0),
(([TotalPrice]-prev_spend)/prev_spend )*100) end [% chng_in spend] 
from
(select [Customer_Name], [TotalPrice], 
avg([TotalPrice]) as avg_spnd, 
avg([Quantity]) as avg_qty, year as dt, 
lag(avg([TotalPrice]), 1,0) over(PARTITION by [Customer_Name] 
order by (year)) as prev_spend 
from DIM_CUSTOMER c 
inner join FACT_TRANSACTIONS f on c.IDCustomer = f.IDCustomer 
inner join DIM_DATE d on f.Date = d.DATE
group by [Customer_Name], year, [TotalPrice])A
order by avg_spnd desc

--Q10--END
	