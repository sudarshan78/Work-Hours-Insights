Avg hours per quater per project
----------------------------------
with gr as (select sr.empid,pr.project_name,sr.Eventdate,case when month(Eventdate) in (04,05,06) then 'Q1' when month(Eventdate) in (07,08,09) then 'Q2' when month(Eventdate) in (10,11,12) then 'Q3' when month(Eventdate) in (01,02,03) then 'Q4' end as Quarter,
 sr.total_hours from employeeproject  ep join  project pr on ep.project_id=pr.project_id
join  swiperecords sr on sr.empid=ep.emp_id
where ep.current_project='True' )

select quarter,project_name,round(avg(Total_hours),2) as averagehours from gr 
group by Quarter,Project_name;

Avg hours per project in 2026
--------------------------------
with gr as (select sr.empid,pr.project_name,sr.Eventdate,sr.total_hours from employeeproject  ep join  project pr on ep.project_id=pr.project_id
join  swiperecords sr on sr.empid=ep.emp_id
where ep.current_project='True' )

select project_name,round(avg(Total_hours),3) as averagehours from gr 
group by Project_name;


Avg Hours per office_building
------------------------------
with gr as (select sr.empid,o.building_name,sr.Eventdate,
 sr.total_hours from Office o
join  swiperecords sr on sr.empid=o.emp_id )

select building_name,round(avg(Total_hours),3) as averagehours from gr 
group by building_name;
