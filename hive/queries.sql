Avg hours per quarter per project
----------------------------------
with gr as (select sr.empid,pr.project_name,sr.Eventdate,case when month(Eventdate) in (04,05,06) then 'Q1' 
                                                              when month(Eventdate) in (07,08,09) then 'Q2' 
                                                              when month(Eventdate) in (10,11,12) then 'Q3' 
                                                              when month(Eventdate) in (01,02,03) then 'Q4' end as Quarter,
sr.total_hours from employeeproject  ep join  project pr on ep.project_id=pr.project_id
join  swiperecords sr on sr.empid=ep.emp_id
where ep.current_project='True' )

select quarter,project_name,round(avg(Total_hours),2) as averagehours from gr 
group by Quarter,Project_name;

Avg hours per project in 2026
--------------------------------
select sr.empid,pr.project_name,sr.Eventdate,round(avg(sr.total_hours),2) as avghours from employeeproject  ep join  project pr on ep.project_id=pr.project_id
join  swiperecords sr on sr.empid=ep.emp_id
where ep.current_project='True' 
group by Project_name;

Avg Hours per office_building in 2026
------------------------------
select building_name,round(avg(sr.total_hours),2) as averagehours from Office o
join  swiperecords sr on sr.empid=o.emp_id
group by building_name;

Top Ranked customers per quater 
-------------------------------
with grouped as (select  case when month(Eventdate) in (04,05,06) then 'Q1' 
             when month(Eventdate) in (07,08,09) then 'Q2' 
             when month(Eventdate) in (10,11,12) then 'Q3' 
             when month(Eventdate) in (01,02,03) then 'Q4' end as Quarter,e.emp_id,e.name,p.project_name,d.depart_name,sr.total_hours from Employee e 
join EmployeeProject ep on e.Emp_id=ep.Emp_id 
join Project p on p.Project_id=ep.project_id
join Department d on e.Department_Id=d.Department_Id 
join  swiperecords sr on sr.empid=e.Emp_id
where ep.current_project='True'),

r as(select  quarter,emp_id,name,project_name,depart_name,round(avg(total_hours),2) as avghours from grouped group by quarter,emp_id,name,project_name,depart_name),

ranked as (select  quarter,emp_id,name,project_name,depart_name,rank() over(partition by quarter order by avghours desc) as rn from r)

select quarter,emp_id,name,project_name,depart_name from ranked 
where rn<=3

Average total hours spent per employee by Department (2025)
-----------------------------------------------------------
select d.depart_name,round(avg(sr.total_hours),2) from swiperecords sr
join employee  e on e.Emp_id=sr.empid
join Department d on e.Department_Id=d.Department_Id 
group by d.depart_name


Avg Hours per office_building per quater
----------------------------------------
with grouped as (select case when month(Eventdate) in (04,05,06) then 'Q1' 
            when month(Eventdate) in (07,08,09) then 'Q2' 
            when month(Eventdate) in (10,11,12) then 'Q3' 
            when month(Eventdate) in (01,02,03) then 'Q4' end as Quarter,o.building_name, sr.total_hours from Office o
join  swiperecords sr on sr.empid=o.emp_id)

select quarter,building_name,round(avg(total_hours),3) as averagehours from grouped 
group by quarter,building_name