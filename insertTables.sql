-- הכנסת נתונים לטבלת Safety_Standard
INSERT INTO Safety_Standard (Standard_ID, Standard_Name, Safety_Requirements_Description, Standard_Level, Equipment_Type)
VALUES (1, 'Fire Safety', 'Requires fire-resistant materials', 'High', 'Electrical');

INSERT INTO Safety_Standard (Standard_ID, Standard_Name, Safety_Requirements_Description, Standard_Level, Equipment_Type)
VALUES (2, 'Mechanical Safety', 'Ensure regular lubrication and maintenance', 'Medium', 'Mechanical');

INSERT INTO Safety_Standard (Standard_ID, Standard_Name, Safety_Requirements_Description, Standard_Level, Equipment_Type)
VALUES (3, 'Biohazard Safety', 'Requires protective equipment', 'Critical', 'Medical');

-- הכנסת נתונים לטבלת Equipment
INSERT INTO Equipment (Equipment_ID, Equipment_Name, Equipment_Type, Safety_Status, Installation_Date, Standard_ID)
VALUES (101, 'Hydraulic Press', 'Mechanical', 'Safe', TO_DATE('2020-05-15', 'YYYY-MM-DD'), 2);

INSERT INTO Equipment (Equipment_ID, Equipment_Name, Equipment_Type, Safety_Status, Installation_Date, Standard_ID)
VALUES (102, 'MRI Scanner', 'Medical', 'Under Inspection', TO_DATE('2018-11-20', 'YYYY-MM-DD'), 3);

INSERT INTO Equipment (Equipment_ID, Equipment_Name, Equipment_Type, Safety_Status, Installation_Date, Standard_ID)
VALUES (103, 'Generator', 'Electrical', 'Operational', TO_DATE('2022-03-10', 'YYYY-MM-DD'), 1);

-- הכנסת נתונים לטבלת Maintenance_Technician
INSERT INTO Maintenance_Technician (Technician_ID, Full_Name, Phone_Number, Professional_Certifications, Last_Certification_Date)
VALUES (201, 'David Cohen', '052-1234567', 'Electrical Safety', TO_DATE('2023-09-01', 'YYYY-MM-DD'));

INSERT INTO Maintenance_Technician (Technician_ID, Full_Name, Phone_Number, Professional_Certifications, Last_Certification_Date)
VALUES (202, 'Sarah Levy', '054-9876543', 'Medical Equipment Specialist', TO_DATE('2022-07-15', 'YYYY-MM-DD'));

INSERT INTO Maintenance_Technician (Technician_ID, Full_Name, Phone_Number, Professional_Certifications, Last_Certification_Date)
VALUES (203, 'Moshe Avraham', '053-4567890', 'Mechanical Engineering', TO_DATE('2024-01-20', 'YYYY-MM-DD'));

-- הכנסת נתונים לטבלת Equipment_Malfunction
INSERT INTO Equipment_Malfunction (Malfunction_ID, Equipment_ID, Technician_ID, Report_Date, Malfunction_Severity, Repair_Status)
VALUES (301, 101, 201, TO_DATE('2024-02-12', 'YYYY-MM-DD'), 'High', 'Pending');

INSERT INTO Equipment_Malfunction (Malfunction_ID, Equipment_ID, Technician_ID, Report_Date, Malfunction_Severity, Repair_Status)
VALUES (302, 102, 202, TO_DATE('2023-12-05', 'YYYY-MM-DD'), 'Critical', 'Repaired');

INSERT INTO Equipment_Malfunction (Malfunction_ID, Equipment_ID, Technician_ID, Report_Date, Malfunction_Severity, Repair_Status)
VALUES (303, 103, 203, TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'Medium', 'In Progress');

-- הכנסת נתונים לטבלת Safety_Check
INSERT INTO Safety_Check (Check_ID, Equipment_ID, Result, Inspector_Notes, Inspection_Date)
VALUES (401, 101, 'Pass', 'Equipment in excellent condition', TO_DATE('2024-06-10', 'YYYY-MM-DD'));

INSERT INTO Safety_Check (Check_ID, Equipment_ID, Result, Inspector_Notes, Inspection_Date)
VALUES (402, 102, 'Fail', 'Requires urgent maintenance', TO_DATE('2024-05-22', 'YYYY-MM-DD'));

INSERT INTO Safety_Check (Check_ID, Equipment_ID, Result, Inspector_Notes, Inspection_Date)
VALUES (403, 103, 'Pass', 'Routine check completed', TO_DATE('2024-06-05', 'YYYY-MM-DD'));

-- הכנסת נתונים לטבלת Equipment_Usage
INSERT INTO Equipment_Usage (Usage_ID, Equipment_ID, User_ID, Start_Time, Usage_Duration)
VALUES (501, 101, 1001, TO_TIMESTAMP('2024-06-15 08:30:00', 'YYYY-MM-DD HH24:MI:SS'), 120);

INSERT INTO Equipment_Usage (Usage_ID, Equipment_ID, User_ID, Start_Time, Usage_Duration)
VALUES (502, 102, 1002, TO_TIMESTAMP('2024-06-14 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 90);

INSERT INTO Equipment_Usage (Usage_ID, Equipment_ID, User_ID, Start_Time, Usage_Duration)
VALUES (503, 103, 1003, TO_TIMESTAMP('2024-06-13 10:15:00', 'YYYY-MM-DD HH24:MI:SS'), 150);

-- הכנסת נתונים לטבלת Repairs
INSERT INTO Repairs (Technician_ID, Equipment_ID, Malfunction_ID)
VALUES (201, 101, 301);

INSERT INTO Repairs (Technician_ID, Equipment_ID, Malfunction_ID)
VALUES (202, 102, 302);

INSERT INTO Repairs (Technician_ID, Equipment_ID, Malfunction_ID)
VALUES (203, 103, 303);

-- הכנסת נתונים לטבלת Equipment_Standard (קישור בין ציוד לסטנדרטים)
INSERT INTO Equipment_Standard (Equipment_ID, Standard_ID)
VALUES (101, 2);

INSERT INTO Equipment_Standard (Equipment_ID, Standard_ID)
VALUES (102, 3);

INSERT INTO Equipment_Standard (Equipment_ID, Standard_ID)
VALUES (103, 1);
