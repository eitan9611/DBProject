
CREATE EXTENSION IF NOT EXISTS dblink;
INSERT INTO equipment (equipment_id, equipment_name, purchasedate, conditionstatus, exerciseid)
SELECT equipment_id, equipment_name, purchasedate, conditionstatus, exerciseid
FROM dblink(
  'dbname=NOAM user=eitan password=weizman558',
  'SELECT equipment_id, equipment_name, purchasedate, conditionstatus, exerciseid FROM equipment'
) AS source(
  equipment_id INT,
  equipment_name VARCHAR(50),
  purchasedate DATE,
  conditionstatus VARCHAR(30),
  exerciseid INT
)
ON CONFLICT (equipment_id) DO NOTHING;

----------------------------------------------------------------------------------------------------------------

CREATE TABLE trainee (
    traineeid serial PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    email VARCHAR(50),
    phone VARCHAR(15),
    dateofbirth DATE
);

CREATE TABLE trainer (
    trainerid INTEGER PRIMARY KEY,
    programid INTEGER,
    hiredate DATE,
    employeeid INTEGER
);

CREATE TABLE trainingprogram (
    programid serial PRIMARY KEY,
    programname VARCHAR(50),
    startdate DATE,
    enddate DATE,
    traineeid INTEGER
);

CREATE TABLE traininglog (
    logid serial PRIMARY KEY,
    traineeid INTEGER,
    programid INTEGER,
    duration INTEGER,
    repetitions INTEGER,
    programname VARCHAR(50)
);

CREATE TABLE exercise (
    exerciseid serial PRIMARY KEY,
    exname VARCHAR(50),
    description VARCHAR(255),
    programid INTEGER
);

---------------------------------------------------------------------------------------------------------------
-- trainee
INSERT INTO trainee (traineeid, firstname, lastname, email, phone, dateofbirth)
SELECT * FROM dblink('dbname=NOAM user=eitan password=weizman558',
                     'SELECT traineeid, firstname, lastname, email, phone, dateofbirth FROM trainee')
AS t(traineeid INTEGER, firstname VARCHAR(50), lastname VARCHAR(50), email VARCHAR(50), phone VARCHAR(15), dateofbirth DATE);

-- trainer
INSERT INTO trainer (trainerid, programid, hiredate, employeeid)
SELECT * FROM dblink('dbname=NOAM user=eitan password=weizman558',
                     'SELECT trainerid, programid, hiredate, employeeid FROM trainer')
AS t(trainerid INTEGER, programid INTEGER, hiredate DATE, employeeid INTEGER);

-- trainingprogram
INSERT INTO trainingprogram (programid, programname, startdate, enddate, traineeid)
SELECT * FROM dblink('dbname=NOAM user=eitan password=weizman558',
                     'SELECT programid, programname, startdate, enddate, traineeid FROM trainingprogram')
AS t(programid INTEGER, programname VARCHAR(50), startdate DATE, enddate DATE, traineeid INTEGER);

-- traininglog
INSERT INTO traininglog (logid, traineeid, programid, duration, repetitions, programname)
SELECT * FROM dblink('dbname=NOAM user=eitan password=weizman558',
                     'SELECT logid, traineeid, programid, duration, repetitions, programname FROM traininglog')
AS t(logid INTEGER, traineeid INTEGER, programid INTEGER, duration INTEGER, repetitions INTEGER, programname VARCHAR(50));

-- exercise
INSERT INTO exercise (exerciseid, exname, description, programid)
SELECT * FROM dblink('dbname=NOAM user=eitan password=weizman558',
                     'SELECT exerciseid, exname, description, programid FROM exercise')
AS t(exerciseid INTEGER, exname VARCHAR(50), description VARCHAR(255), programid INTEGER);


---------------------------------------------------------------------------------------------------------------------


CREATE TABLE EMPLOYEE (
    EMPLOYEEID SERIAL PRIMARY KEY,
    PHONE_NUMBER VARCHAR(30) UNIQUE NOT NULL
);


------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE TRAINER ADD COLUMN EMPLOYEEID INTEGER UNIQUE;
ALTER TABLE MAINTAINCE_TECHNICIAN ADD COLUMN EMPLOYEEID INTEGER UNIQUE;


-------------------------------------------------------------------------------------------------------

INSERT INTO EMPLOYEE (PHONE_NUMBER)
SELECT DISTINCT PHONE_NUMBER FROM (
    SELECT PHONE_NUMBER FROM TRAINER
    UNION
    SELECT PHONE_NUMBER FROM MAINTAINCE_TECHNICIAN
) AS unique_phones;


--------------------------------------------------------------------------------------------------------


UPDATE TRAINER T
SET EMPLOYEEID = E.EMPLOYEEID
FROM EMPLOYEE E
WHERE T.PHONE_NUMBER = E.PHONE_NUMBER;

UPDATE MAINTAINCE_TECHNICIAN M
SET EMPLOYEEID = E.EMPLOYEEID
FROM EMPLOYEE E
WHERE M.PHONE_NUMBER = E.PHONE_NUMBER;

-----------------------------------------------------------------------------------------------------------------

ALTER TABLE TRAINER
ADD CONSTRAINT fk_trainer_employee
FOREIGN KEY (EMPLOYEEID) REFERENCES EMPLOYEE(EMPLOYEEID);

ALTER TABLE MAINTAINCE_TECHNICIAN
ADD CONSTRAINT fk_maintenance_employee
FOREIGN KEY (EMPLOYEEID) REFERENCES EMPLOYEE(EMPLOYEEID);


