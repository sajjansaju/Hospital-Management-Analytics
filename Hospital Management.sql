CREATE TABLE patients (
  patient_id SERIAL PRIMARY KEY,
  name VARCHAR(50),
  age INT,
  gender VARCHAR(10)
);

CREATE TABLE doctors (
  doctor_id SERIAL PRIMARY KEY,
  name VARCHAR(50),
  department_id INT
);

CREATE TABLE departments (
  department_id SERIAL PRIMARY KEY,
  department_name VARCHAR(50)
);


CREATE TABLE treatments (
  treatment_id SERIAL PRIMARY KEY,
  patient_id INT,
  doctor_id INT,
  treatment_date DATE,
  cost DECIMAL(10, 2)
);


CREATE TABLE bills (
  bill_id SERIAL PRIMARY KEY,
  patient_id INT,
  total_amount DECIMAL(10, 2)
);


INSERT INTO departments (department_name) VALUES
('Cardiology'),
('Neurology'),
('Orthopedics'),
('Pediatrics'),
('General Medicine');


INSERT INTO doctors (name, department_id) VALUES
('Dr. Smith', 1),
('Dr. Jones', 2),
('Dr. Lee', 3),
('Dr. Patel', 4),
('Dr. Gomez', 5),
('Dr. Wilson', 1),    
('Dr. Kim', 1),       
('Dr. Ahmed', 2),   
('Dr. Liu', 2),       
('Dr. Davis', 3),     
('Dr. Parker', 3),    
('Dr. Singh', 4),     
('Dr. Tanaka', 5);    


INSERT INTO patients (name, age, gender) VALUES
('Alice', 29, 'Female'),
('Bob', 45, 'Male'),
('Charlie', 33, 'Male'),
('Daisy', 24, 'Female'),
('Ethan', 51, 'Male'),
('Fiona', 38, 'Female'),
('George', 60, 'Male'),
('Hannah', 27, 'Female'),
('Ian', 36, 'Male'),
('Jane', 40, 'Female');


INSERT INTO treatments (patient_id, doctor_id, treatment_date, cost) VALUES
(1, 1, '2024-01-15', 500.00),
(2, 1, '2024-01-18', 700.00),
(3, 2, '2024-02-01', 650.00),
(4, 2, '2024-02-10', 400.00),
(5, 3, '2024-02-15', 900.00),
(6, 3, '2024-02-20', 800.00),
(7, 4, '2024-03-01', 300.00),
(8, 4, '2024-03-05', 200.00),
(9, 5, '2024-03-10', 350.00),
(10, 5, '2024-03-15', 450.00),
(1, 2, '2024-03-20', 600.00),
(2, 3, '2024-03-25', 750.00),
(3, 4, '2024-03-30', 500.00),
(4, 5, '2024-04-05', 400.00),
(5, 1, '2024-04-10', 900.00);
(6, 1, '2024-04-15', 550.00);


INSERT INTO bills (patient_id, total_amount) VALUES
(1, 1100.00),
(2, 1450.00),
(3, 1150.00),
(4, 800.00),
(5, 1800.00),
(6, 800.00),
(7, 300.00),
(8, 200.00),
(9, 350.00),
(10, 450.00);




--Identify the most frequently visited department by patients.

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




--Calculate the average cost of treatment for each department

select department_name , (select round(avg(cost),2) as average_cost 
							from treatments t
							join doctors dc
							on dc.doctor_id = t.doctor_id
							where dc.department_id = d.department_id)
from departments d;


--Find doctors who treated more than 2 patients.
select name
from doctors
where doctor_id in (select doctor_id 
						from treatments
						group by doctor_id
						having count(DISTINCT patient_id)>2)
;

--List patients who spent more than the average total bill amount.
select name 
from patients
where patient_id in (select patient_id
					from bills
					where total_amount > (select avg(total_amount)
											from bills))
;


--Identify the department with the highest overall treatment revenue.
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

--Identify the Patients who had more than one treatment
select name 
from patients
where patient_id in 
					(select patient_id
					from treatments
					group by patient_id
					having count(*)>1)

;

--Retrieve the names of doctors, their respective departments, and the patients they treated, 
--where the treatment cost is higher than the average treatment cost within that department.

select name, department_name , patient_id , cost , (select round(avg(cost),2) 
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

--Identify Youngest patient who received treatment
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

--Identify the Departments with less than 3 unique doctors
select department_name 
from departments
where department_id in 
						(select department_id 
						from doctors
						group by department_id
						having count(*)<3)
