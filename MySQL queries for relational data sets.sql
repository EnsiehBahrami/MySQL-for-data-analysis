use employees_mod;
SELECT 
 d.dept_name, avg(s.salary) as Avg_salary
FROM
    t_salaries s
        JOIN
    t_dept_manager dm ON dm.emp_no = s.emp_no
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
GROUP BY d.dept_name
having Avg_salary>60000
order by Avg_salary desc;


/*Stored procedure with an output parameter */
delimiter $$

create procedure emp_info(in p_first_name varchar(255), in p_last_name varchar(255), out p_emp_no integer)
    begin
    select e.emp_no into p_emp_no from employees e
    where 
    e.first_name=p_first_name and e.last_name=p_last_name;
end$$

delimiter ;



/* Create a variable, called ‘v_emp_no’, Call the the procedure, inserting the values ‘Aruna’ and ‘Journel’ as a first and last name respectively. 
Finally, select the obtained output. */
delimiter $$
create procedure emp_info(in p_first_name varchar(255), in p_last_name varchar(255), out p_emp_no integer)
begin
select e.emp_no into p_emp_no from employees e where e.first_name=p_first_name and e.last_name=p_last_name;
end$$

delimiter ;

set @v_emp_no=0;
call emp_info('Aruna','Journel', @v_emp_no);
select @v_emp_no; 

/* 	User defined functions, while  declare and use two variables – v_max_from_date that will be of the DATE type,
 and v_salary, that will be of the DECIMAL (10,2) type.*/
delimiter $$
create function emp_info (p_first_name varchar(255), p_last_name varchar(255)) returns decimal(10,2)
deterministic No sql reads sql data
begin
declare v_max_from_date date;
declare v_salary decimal(10,2);
SELECT 
    MAX(s.from_date)
INTO v_max_from_date FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
   e.first_name = p_first_name AND
   e.last_name = p_last_name;
         
SELECT 
    s.salary
INTO v_salary FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.first_name = p_first_name AND
    e.last_name = p_last_name AND 
    s.from_date = v_max_from_date;
return v_salary;
end$$

delimiter ;
select emp_info('Aruna','journel');


/* Devised a “before” trigger, which will be activated whenever new data is inserted in the “Salaries” table. */
use employees;
Commit;
Delimiter $$
create trigger before_salaries_insert before insert on salaries for each row 
begin 
if new. salary<0 then set new.salary=0; 
end if;
end $$
delimiter ;

/*A BEFORE UPDATE trigger. Instead of setting the new value to 0, we are basically telling MySQL to keep the old value. */
The code is similar to the one of the trigger we created above, with two substantial differences.
# BEFORE UPDATE
delimiter $$

create trigger trig_up_salary before update on salaries for each row 
begin
if new.salary<0 then set new.salary=old.salary; 
end if;
end $$

delimiter ;


/*create an index on the ‘salary’ column of that table.*/
create index i_salary on salaries(salary);

/*The CASE Statement */
SELECT 
    dm.emp_no,
    e.first_name,
    e.last_name,
    MAX(s.salary) - MIN(s.salary) AS salary_difference,
    CASE
        WHEN MAX(s.salary) - MIN(s.salary) > 30000 THEN 'higher raise'
        ELSE 'not higher raise'
    END AS salary_raise
FROM
    dept_manager dm
        JOIN
    employees e ON e.emp_no = dm.emp_no
        JOIN
    salaries s ON dm.emp_no = s.emp_no
GROUP BY s.emp_no;
LIMIT 100;
