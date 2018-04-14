DROP VIEW IF EXISTS v_only_lady_comps;
DROP INDEX IF EXISTS ladies_orientation;
DROP FUNCTION IF EXISTS Update_salary_cleaners(percentIncr INTEGER, hotelId INTEGER);
DROP TRIGGER IF EXISTS log_insert_empl on employee;
DROP FUNCTION IF EXISTS log_employee_insert();


-- View for employees who are employed ONLY as lady_companions (there are overlapping employees)
CREATE VIEW v_only_lady_comps AS
	SELECT *
	FROM lady_companion AS LC
  WHERE LC.employee_num NOT IN(SELECT C.employee_num
                    FROM cleaner AS C);

-- Index for orientation of lady companions because It's needed to search for specific orientation
-- and it is unfortunately VARCHAR
CREATE INDEX ladies_orientation ON lady_companion (orientation);

-- Update salary of every cleaner for X% in Y hotel;
CREATE FUNCTION Update_salary_cleaners(percentIncr INTEGER, hotelId INTEGER)
RETURNS BOOLEAN
AS
  $$
    BEGIN
      UPDATE employee
            SET salary = salary * percentIncr
            WHERE employee_num IN (SELECT C.employee_num FROM cleaner AS C)
                  AND hotel = hotelId;
      RETURN TRUE;
    END;
  $$
LANGUAGE plpgsql;


-- Just trigger to print to stdout log about new inserted employee to employee table
CREATE FUNCTION log_employee_insert()
RETURNS TRIGGER
AS
  $$
    BEGIN
      RAISE NOTICE 'Created employee: % %', NEW.employee_num, NEW.name;
      RETURN NEW;
    END;
  $$
LANGUAGE plpgsql;

-- Log insertion after every insert to employee table
CREATE TRIGGER log_insert_empl AFTER INSERT ON employee
FOR EACH ROW  EXECUTE PROCEDURE log_employee_insert();