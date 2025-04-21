# 🏥 Hospital Management SQL Project (PostgreSQL)

This project showcases SQL skills using only **subqueries** to solve real-world healthcare-related business problems. The database contains five interconnected tables and simulates a hospital's operations involving patients, doctors, departments, treatments, and bills.

---

## 🧾 Database Schema

- **patients**: patient_id, name, age, gender  
- **doctors**: doctor_id, name, department_id  
- **departments**: department_id, department_name  
- **treatments**: treatment_id, patient_id, doctor_id, treatment_date, cost  
- **bills**: bill_id, patient_id, total_amount  

---

## 📌 Problem Statement:

The hospital administration wants to understand patient visits, treatment costs, doctor performance, and departmental resource allocation. They are seeking data-driven insights to optimize operations, reduce costs, and improve service quality. Your task is to analyze this data using only subqueries.

---

## 🎯 Objectives and Subquery Solutions

- **Identify the most frequently visited department by patients.**
``` sql 
select department_name 
from departments
where department_id = (select department_id 
						from 
								(select department_id , count(*)
								from doctors dc
								join treatments t
								on dc.doctor_id = t.doctor_id
								group by department_id
								order by count(*) desc
								limit 1) as sub
								);
```
- **Calculate the average cost of treatment for each department**
```sql
select department_name , (select round(avg(cost),2) as average_cost 
							from treatments t
							join doctors dc
							on dc.doctor_id = t.doctor_id
							where dc.department_id = d.department_id)
from departments d;
```

- **List patients who spent more than the average total bill amount.**
```sql
select name 
from patients
where patient_id in (select patient_id
					from bills
					where total_amount > (select avg(total_amount)
											from bills))
;
```
- **Identify the department with the highest overall treatment revenue.**
```sql
select department_name 
from departments
where department_id in (select department_id 
						from  
							(select  department_id,sum(cost) as total 
							from treatments t
							join doctors dc
							on dc.doctor_id = t.doctor_id
							group by department_id
							order by total desc
							limit 1) as sub)
;
```
- **Identify the Patients who had more than one treatment**
```sql
select name 
from patients
where patient_id in 
    (select patient_id
    from treatments
    group by patient_id
    having count(*)>1)

;
```
- **Retrieve the names of doctors, their respective departments, and the patients they treated, where the treatment cost is higher than the average treatment cost within that department.**
```sql
select name,
department_name ,
patient_id ,
cost ,
    (select round(avg(cost),2)
    from treatments trt
    join doctors dd
    on dd.doctor_id = trt.doctor_id
    where dd.department_id= d.department_id) as avg_fee
from treatments t
join doctors d
on d.doctor_id = t.doctor_id
join departments dt
on dt.department_id = d.department_id
where cost > (select avg(cost)
				from treatments ttt
				join doctors ddd
				on ddd.doctor_id = ttt.doctor_id
				where d.department_id = ddd.department_id)
;
```
- **Identify Youngest patient who received treatment**
```sql
SELECT name
FROM patients
WHERE patient_id = (
  SELECT patient_id
  FROM (
    SELECT t.patient_id, p.age
    FROM treatments t
    JOIN patients p ON t.patient_id = p.patient_id
    ORDER BY p.age ASC
    LIMIT 1
  ) AS youngest
);
```
- **Identify the Departments with less than 3 unique doctors**
```sql
select department_name 
from departments
where department_id in 
						(select department_id 
						from doctors
						group by department_id
						having count(*)<3);
```
- **Find doctors who treated more than 2 patients.**
```sql
select name
from doctors
where doctor_id in (select doctor_id 
						from treatments
						group by doctor_id
						having count(DISTINCT patient_id)>2)
;
```
