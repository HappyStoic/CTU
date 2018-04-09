-- Get all hotel names with number of its rooms
SELECT H.name, COUNT(R) AS count
FROM Room AS R
	JOIN Hotel AS H ON (R.hotel = H.id)
GROUP BY H.name;

-- Names of customers, who did not reserve any room from 2015.
SELECT C.name
FROM customer as C
EXCEPT
(
  SELECT DISTINCT C2.name
  FROM reservation AS R
      INNER JOIN customer C2 ON R.customer_id = C2.customer_number
  WHERE (R.day > '20151231') -- After 31.12.2015
);


-- statistics about how many employees have the same, but higher than 2000€, salary.
SELECT E.salary, COUNT(*)
FROM employee as E
GROUP BY (E.salary)
HAVING (E.salary > 2000)
ORDER BY E.salary DESC;


-- get average fee and salary for every orientation of lady_companions employees that our hotel organization can offer
SELECT LC.orientation, AVG(LC.fee) AS fee, AVG(E.salary) AS salary
FROM employee as E
  NATURAL JOIN lady_companion AS LC
GROUP BY LC.orientation;


-- Names of lady_companions employees (not cleaners), who's name is not 'Jiri' nor 'Ovcacek'
SELECT E2.name
FROM cleaner AS C
  RIGHT OUTER JOIN lady_companion AS LC USING (employee_num)
  INNER JOIN (
            SELECT *
            FROM employee as E
            WHERE (E.name != 'Jiri') AND (E.name != 'Ovcacek')) AS E2 USING (employee_num);