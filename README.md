# Gym Equipment Safety Management System – Project Report

## Stage A

### Submitted by:

* **Eliya Masa**
* **Eitan Weizman**

### System Name:

**Gym Equipment Safety Management System**

### Selected Unit:

**Equipment Safety**

---

### Table of Contents

1. Introduction
2. System Overview
3. Entity-Relationship Diagram (ERD)
4. Data Structure Diagram (DSD)
5. Design Decisions
6. Data Entry Methods
7. Data Backup and Restore

---

## 1. Introduction

This project focuses on managing the safety of gym equipment. The system is designed to ensure that each piece of equipment is monitored for safe usage, undergoes regular safety inspections, and is handled promptly in case of malfunctions.

The database manages various aspects of equipment usage, maintenance, technician assignments, safety standards, and incident tracking to maintain a safe environment for gym users.

---

## 2. System Overview

The system tracks the following types of information:

* **Gym Equipment**: Each item has details like installation date, equipment type, and current safety status. Some equipment is linked to a relevant safety standard.
* **Safety Checks**: Regular inspections are performed on equipment. Each check logs the result, the inspection date, and notes from the inspector.
* **Maintenance Technicians**: Technicians are responsible for addressing equipment malfunctions. Their details include certifications and contact information.
* **Equipment Malfunctions**: When a fault occurs, it is recorded along with its severity, repair status, and optionally the technician assigned to fix it.
* **Equipment Usage**: Tracks when and how long a user uses a particular piece of equipment.
* **Safety Standards**: Define safety requirements based on standard level (local/international) and equipment type. Standards can be associated with multiple pieces of equipment.

These entities are linked through foreign key relationships and enforce data integrity and consistency throughout the system.

---

## 3. Entity-Relationship Diagram (ERD)

![image](https://github.com/user-attachments/assets/036bd48b-8e6a-4142-b049-fdb574db023b)


Key relationships:

* One Safety Standard → Many Equipment (1\:N)
* One Equipment → Many Safety Checks (1\:N)
* One Equipment → Many Equipment Usages (1\:N)
* One Equipment → Many Malfunctions (1\:N)
* One Malfunction → One Technician (nullable) (N:1)

---

## 4. Data Structure Diagram (DSD)

![image](https://github.com/user-attachments/assets/e4a0a963-d383-4008-8306-c17618bff69a)

The DSD illustrates all data types, constraints, primary and foreign keys for each table.

---

## 5. Design Decisions

* We allowed nullable foreign keys in cases where the link is optional (e.g., Equipment without a Safety Standard or a Malfunction without an assigned Technician).
* Used ENUMs or CHECK constraints for fields like severity and statuses to ensure consistent input.
* Indexed foreign keys for better performance during join operations.
* Kept Equipment as the central entity, as most interactions in a gym revolve around it.

---

## 6. Data Entry Methods

We used the following methods to populate the database:

![image](https://github.com/user-attachments/assets/e40eba15-4f48-46ef-89be-eba0c596b8bc)
![image](https://github.com/user-attachments/assets/dfbf11a5-48d9-4000-a150-b85f4ec073a7)
![image](https://github.com/user-attachments/assets/21d54342-c176-4954-bc3e-071c55ff2986)


* Excel import of pre-filled .xlsx files
* Manual data entry via Python code
* SQL INSERT statements for batch data input

---

## 7. Data Backup and Restore

![image](https://github.com/user-attachments/assets/933bb995-0394-48ea-add6-a50bed6e3e22)
![image](https://github.com/user-attachments/assets/81cec819-1190-49df-a5cb-f9ab3ee625d9)


* **Backup Method**: Performed using SQL dump/export feature.
* **Restore Method**: Reloaded using SQL import and tested integrity post-restore.


# Gym Equipment Safety Management System – Project Report (Stage B)

**Submitted by:**
* **Eliya Masa**
* **Eitan Weitzman**

**System Name:**
**Gym Equipment Safety Management System**

**Selected Unit:**
**Equipment Safety**

## Table of Contents
1. [Introduction](#introduction)
2. [System Overview](#system-overview)
3. [SELECT Queries](#select-queries)
4. [UPDATE Queries](#update-queries)
5. [DELETE Queries](#delete-queries)
6. [Database Constraints](#database-constraints)
7. [Transaction Management (COMMIT/ROLLBACK)](#transaction-management)

## Introduction
This is the continuation of our project focusing on managing the safety of gym equipment. In Stage B, we've implemented advanced SQL features, including complex SELECT queries, data manipulation operations, database constraints, and transaction management capabilities.

## System Overview
The Gym Equipment Safety Management System continues to track equipment usage, maintenance, technician assignments, safety standards, and incident reporting. This stage adds more sophisticated data analysis and maintenance functionality.

## SELECT Queries

### Query 1: Equipment Without Recent Safety Checks
**תיאור השאילתה:**  
שאילתה זו מציגה את כל הציוד שלא עבר בדיקת בטיחות בששת החודשים האחרונים, כולל פרטים על הבדיקה האחרונה שבוצעה ותקן הבטיחות בו עליו לעמוד.

```sql
SELECT 
    e.Equipment_ID,
    e.Equipment_Name,
    e.Equipment_Type,
    e.Safety_Status,
    MAX(sc.Inspection_Date) AS Last_Inspection_Date,
    CURRENT_DATE - MAX(sc.Inspection_Date) AS Days_Since_Last_Inspection,
    EXTRACT(MONTH FROM MAX(sc.Inspection_Date)) AS Last_Inspection_Month,
    EXTRACT(YEAR FROM MAX(sc.Inspection_Date)) AS Last_Inspection_Year,
    sc.Result AS Last_Inspection_Result,
    ss.Standard_Name,
    ss.Standard_Level
FROM 
    Equipment e
LEFT JOIN 
    Safety_Check sc ON e.Equipment_ID = sc.Equipment_ID
LEFT JOIN 
    Safety_Standard ss ON e.Standard_ID = ss.Standard_ID
GROUP BY 
    e.Equipment_ID, e.Equipment_Name, e.Equipment_Type, e.Safety_Status, sc.Result, ss.Standard_Name, ss.Standard_Level
HAVING 
    MAX(sc.Inspection_Date) < (CURRENT_DATE - INTERVAL '6 months') OR MAX(sc.Inspection_Date) IS NULL
ORDER BY 
    Days_Since_Last_Inspection DESC;
```

**Execution Screenshot:**  
![WhatsApp Image 2025-05-05 at 21 57 01](https://github.com/user-attachments/assets/2f659529-31c2-4d37-b658-f8f701395370)


**Results Screenshot:**  
<img width="1002" alt="1" src="https://github.com/user-attachments/assets/a57c0590-85e0-4670-bee0-4e6640616ed0" />

### Query 2: Technicians Who Handled Most Critical Malfunctions
**תיאור השאילתה:**  
שאילתה זו מציגה טכנאים שטיפלו במספר התקלות החמורות הגבוה ביותר בשנה האחרונה, כולל פירוט התקלות לפי חודש ומצב ההסמכה שלהם.

```sql
SELECT 
    mt.Technician_ID,
    mt.Full_Name,
    mt.Professional_Certifications,
    COUNT(em.Malfunction_ID) AS Total_Severe_Malfunctions,
    EXTRACT(MONTH FROM em.Report_Date) AS Malfunction_Month,
    EXTRACT(YEAR FROM em.Report_Date) AS Malfunction_Year,
    (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM mt.Last_Certification_Date)) AS Years_Since_Last_Certification,
    SUM(CASE WHEN em.Repair_Status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Repairs,
    SUM(CASE WHEN em.Repair_Status = 'In Progress' THEN 1 ELSE 0 END) AS Ongoing_Repairs
FROM 
    Maintenance_Technician mt
LEFT JOIN 
    Equipment_Malfunction em ON mt.Technician_ID = em.Technician_ID
WHERE 
    (em.Malfunction_Severity = 'Critical' OR em.Malfunction_Severity = 'High')
    AND em.Report_Date >= (CURRENT_DATE - INTERVAL '2 years')
GROUP BY 
    mt.Technician_ID, mt.Full_Name, mt.Professional_Certifications, Malfunction_Month, Malfunction_Year
HAVING 
    COUNT(em.Malfunction_ID) > 0
ORDER BY 
    Total_Severe_Malfunctions DESC, Malfunction_Month;
```

**Execution Screenshot:**  
![WhatsApp Image 2025-05-05 at 21 56 59 (2)](https://github.com/user-attachments/assets/e88c2997-6ad1-45a9-966b-5ad6b4c42c56)


**Results Screenshot:**  
<img width="861" alt="2" src="https://github.com/user-attachments/assets/bea6f7ae-3835-4948-8ed1-b19d1c5aba20" />


### Query 3: Technicians by Equipment Diversity
**תיאור השאילתה:**  
שאילתה זו מדרגת טכנאים לפי מגוון סוגי הציוד עליהם עבדו, ומציגה כמה סוגים שונים של ציוד, יחידות בודדות ותיקונים שהושלמו הם טיפלו בהם.

```sql
SELECT 
    mt.Technician_ID,
    mt.Full_Name,
    COUNT(DISTINCT e.Equipment_Type) AS Unique_Equipment_Types,
    COUNT(DISTINCT em.Equipment_ID) AS Total_Equipment_Units,
    SUM(CASE WHEN em.Repair_Status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Repairs
FROM 
    Maintenance_Technician mt
JOIN 
    Equipment_Malfunction em ON mt.Technician_ID = em.Technician_ID
JOIN 
    Equipment e ON em.Equipment_ID = e.Equipment_ID
GROUP BY 
    mt.Technician_ID, mt.Full_Name
ORDER BY 
    Unique_Equipment_Types DESC,
    Completed_Repairs DESC;
```

**Execution Screenshot:**  
![WhatsApp Image 2025-05-05 at 21 56 59 (1)](https://github.com/user-attachments/assets/40339713-6770-4e2b-9aba-b5b75a5de173)


**Results Screenshot:**  
<img width="499" alt="3" src="https://github.com/user-attachments/assets/4f60db68-26b7-405d-b8d9-3777947547f0" />


### Query 4: Equipment Safety Standards Compliance
**תיאור השאילתה:**  
שאילתה זו מנתחת את מידת עמידתם של סוגים שונים של ציוד בתקני הבטיחות שהוקצו להם, מחשבת את אחוז שיעור המעבר של בדיקות בטיחות ומציגה נתוני התקנה.

```sql
SELECT 
    e.Equipment_Type,
    ss.Standard_Level,
    COUNT(DISTINCT e.Equipment_ID) AS Equipment_Count,
    AVG(CURRENT_DATE - e.Installation_Date) AS Avg_Days_Since_Installation,
    COUNT(DISTINCT sc.Check_ID) AS Total_Safety_Checks,
    ROUND(
        COUNT(DISTINCT sc.Check_ID) FILTER (WHERE sc.Result = 'Passed') * 100.0 / 
        NULLIF(COUNT(DISTINCT sc.Check_ID), 0),
        2
    ) AS Pass_Rate_Percentage,
    TO_CHAR(MAX(e.Installation_Date), 'YYYY-MM') AS Most_Recent_Installation,
    TO_CHAR(MIN(e.Installation_Date), 'YYYY-MM') AS Oldest_Installation
FROM 
    Equipment e
JOIN 
    Safety_Standard ss ON e.Standard_ID = ss.Standard_ID
LEFT JOIN 
    Safety_Check sc ON e.Equipment_ID = sc.Equipment_ID
GROUP BY 
    e.Equipment_Type, ss.Standard_Level
HAVING 
    COUNT(DISTINCT e.Equipment_ID) > 1
ORDER BY 
    Pass_Rate_Percentage DESC, Equipment_Count DESC;
```

**Execution Screenshot:**  
![WhatsApp Image 2025-05-05 at 21 56 58](https://github.com/user-attachments/assets/8414b278-df75-4975-ac8b-efbfa2a0366d)

**Results Screenshot:**  
<img width="746" alt="4" src="https://github.com/user-attachments/assets/3bd84ba7-cd4d-4c9b-90b1-d8abcca9b97a" />


### Query 5: Monthly Safety Status Report by Equipment Type
**תיאור השאילתה:**  
שאילתה זו מייצרת דוח בטיחות חודשי המציג תקלות לפי סוג הציוד ורמת החומרה, כולל סטטיסטיקות תיקונים ומעורבות טכנאים במהלך השנה האחרונה.

```sql
SELECT 
    monthly_data.Report_Month,
    monthly_data.Report_Year,
    monthly_data.Equipment_Type,
    monthly_data.Malfunction_Severity,
    monthly_data.Malfunction_Count,
    monthly_data.Completed_Repairs,
    monthly_data.Avg_Days_Open,
    (SELECT COUNT(DISTINCT mt.Technician_ID)
     FROM Maintenance_Technician mt
     JOIN Equipment_Malfunction em2 ON mt.Technician_ID = em2.Technician_ID
     WHERE EXTRACT(MONTH FROM em2.Report_Date) = monthly_data.Report_Month 
       AND EXTRACT(YEAR FROM em2.Report_Date) = monthly_data.Report_Year
       AND em2.Malfunction_Severity = monthly_data.Malfunction_Severity
    ) AS Technicians_Involved
FROM (
    SELECT 
        EXTRACT(MONTH FROM em.Report_Date) AS Report_Month,
        EXTRACT(YEAR FROM em.Report_Date) AS Report_Year,
        e.Equipment_Type,
        em.Malfunction_Severity,
        COUNT(em.Malfunction_ID) AS Malfunction_Count,
        SUM(CASE WHEN em.Repair_Status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Repairs,
        AVG(CURRENT_DATE - em.Report_Date) AS Avg_Days_Open
    FROM 
        Equipment_Malfunction em
    JOIN 
        Equipment e ON em.Equipment_ID = e.Equipment_ID
    WHERE 
        em.Report_Date >= (CURRENT_DATE - INTERVAL '12 months')
    GROUP BY 
        Report_Month, Report_Year, e.Equipment_Type, em.Malfunction_Severity
) AS monthly_data
ORDER BY 
    monthly_data.Report_Year DESC,
    monthly_data.Report_Month DESC,
    monthly_data.Malfunction_Count DESC;
```

**Execution Screenshot:**  
![WhatsApp Image 2025-05-05 at 21 57 00 (1)](https://github.com/user-attachments/assets/73092bc1-adb9-4dbc-a3d0-4845ef3cf303)


**Results Screenshot:**  
<img width="669" alt="5" src="https://github.com/user-attachments/assets/d12f0e10-511c-4321-81b1-d57cfd9d02f8" />


### Query 6: High-Risk Equipment Identification
**תיאור השאילתה:**  
שאילתה זו מזהה ציוד בסיכון גבוה לכשל על סמך שלושה גורמי סיכון: טכנאים עם הסמכות שפג תוקפן, חסרי בדיקות בטיחות אחרונות והיסטוריית תקלות. היא מחשבת ציון סיכון משוקלל עבור כל פריט ציוד.

```sql
WITH Equipment_Safety_History AS (
    SELECT 
        e.Equipment_ID,
        e.Equipment_Name,
        e.Equipment_Type,
        e.Installation_Date,
        e.Safety_Status,
        COUNT(DISTINCT sc.Check_ID) AS Total_Safety_Checks,
        SUM(CASE WHEN sc.Result = 'Failed' THEN 1 ELSE 0 END) AS Failed_Checks,
        CASE 
            WHEN COUNT(DISTINCT sc.Check_ID) = 0 THEN 0
            ELSE (SUM(CASE WHEN sc.Result = 'Failed' THEN 1 ELSE 0 END) * 100.0 / 
                  COUNT(DISTINCT sc.Check_ID))
        END AS Failure_Rate,
        MAX(sc.Inspection_Date) AS Last_Inspection_Date,
        CURRENT_DATE - MAX(sc.Inspection_Date) AS Days_Since_Last_Check
    FROM 
        Equipment e
    LEFT JOIN 
        Safety_Check sc ON e.Equipment_ID = sc.Equipment_ID
    GROUP BY 
        e.Equipment_ID, e.Equipment_Name, e.Equipment_Type, e.Installation_Date, e.Safety_Status
),
Technician_Certification_Status AS (
    SELECT 
        mt.Technician_ID,
        mt.Full_Name,
        mt.Professional_Certifications,
        mt.Last_Certification_Date,
        CURRENT_DATE - mt.Last_Certification_Date AS Days_Since_Certification,
        CASE
            WHEN CURRENT_DATE - mt.Last_Certification_Date > 365 THEN 'Expired over a year'
            WHEN CURRENT_DATE - mt.Last_Certification_Date > 180 THEN 'Expired over 6 months'
            ELSE 'Valid or recently expired'
        END AS Certification_Status
    FROM 
        Maintenance_Technician mt
    WHERE 
        mt.Last_Certification_Date IS NOT NULL
),
Equipment_Malfunction_History AS (
    SELECT 
        em.Equipment_ID,
        COUNT(em.Malfunction_ID) AS Total_Malfunctions,
        SUM(CASE WHEN em.Malfunction_Severity = 'Critical' THEN 1 ELSE 0 END) AS Critical_Malfunctions,
        SUM(CASE WHEN em.Repair_Status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Repairs,
        MAX(em.Report_Date) AS Last_Malfunction_Date
    FROM 
        Equipment_Malfunction em
    GROUP BY 
        em.Equipment_ID
)
SELECT 
    esh.Equipment_ID,
    esh.Equipment_Name,
    esh.Equipment_Type,
    esh.Safety_Status,
    esh.Total_Safety_Checks,
    esh.Failed_Checks,
    ROUND(esh.Failure_Rate, 2) AS Failure_Rate_Percentage,
    esh.Last_Inspection_Date,
    CURRENT_DATE - esh.Last_Inspection_Date AS Days_Since_Last_Inspection,
    tcs.Full_Name AS Technician_Name,
    tcs.Professional_Certifications,
    tcs.Last_Certification_Date,
    tcs.Days_Since_Certification,
    tcs.Certification_Status,
    emh.Total_Malfunctions,
    emh.Critical_Malfunctions,
    emh.Last_Malfunction_Date,
    ROUND(
        (COALESCE(esh.Days_Since_Last_Check, 365) * 0.3 / 365) +
        (tcs.Days_Since_Certification * 0.3 / 365) +
        (COALESCE(emh.Total_Malfunctions, 0) * 5 * 0.2) +
        (COALESCE(emh.Critical_Malfunctions, 0) * 10 * 0.1) +
        (CASE WHEN esh.Safety_Status = 'Failed' THEN 25 ELSE 0 END)
    , 2) AS Risk_Score
FROM 
    Equipment_Safety_History esh
JOIN 
    Technician_Certification_Status tcs ON tcs.Technician_ID IN (
        SELECT DISTINCT em.Technician_ID 
        FROM Equipment_Malfunction em 
        WHERE em.Equipment_ID = esh.Equipment_ID
    )
LEFT JOIN 
    Equipment_Malfunction_History emh ON esh.Equipment_ID = emh.Equipment_ID
WHERE 
    tcs.Days_Since_Certification > 90
    AND (
        esh.Days_Since_Last_Check > 180
        OR esh.Safety_Status = 'Failed'
        OR COALESCE(emh.Total_Malfunctions, 0) >= 1
    )
ORDER BY 
    Risk_Score DESC
LIMIT 30;
```

**Execution Screenshot:**  
![WhatsApp Image 2025-05-05 at 21 57 00](https://github.com/user-attachments/assets/90a867b2-cc24-4fa9-8884-f0551d92315c)


**Results Screenshot:**  
<img width="941" alt="6" src="https://github.com/user-attachments/assets/176a887d-2b42-4136-8f89-08a9061eb015" />


### Query 7: Correlation Between Usage Frequency and Malfunctions
**תיאור השאילתה:**  
שאילתה זו מנתחת את הקשר בין תדירות השימוש בציוד לבין תקלות בחודש האחרון, ומחשבת תקלות לשעת שימוש כדי לזהות ציוד שעלול להיות בעייתי.
```sql
SELECT 
    usage_data.Equipment_ID,
    usage_data.Equipment_Name,
    usage_data.Equipment_Type,
    usage_data.Standard_Name,
    usage_data.Usage_Count_Last_Month,
    usage_data.Total_Usage_Minutes_Last_Month,
    usage_data.Malfunction_Count_Last_Month,
    usage_data.Malfunctions_Per_Hour,
    usage_data.Last_Usage_Date,
    usage_data.Last_Usage_Day,
    usage_data.Last_Usage_Month
FROM (
    SELECT 
        e.Equipment_ID,
        e.Equipment_Name,
        e.Equipment_Type,
        ss.Standard_Name,
        COUNT(DISTINCT eu.Usage_ID) AS Usage_Count_Last_Month,
        SUM(eu.Usage_Duration) AS Total_Usage_Minutes_Last_Month,
        COUNT(DISTINCT em.Malfunction_ID) AS Malfunction_Count_Last_Month,
        ROUND(COUNT(DISTINCT em.Malfunction_ID) * 60.0 / NULLIF(SUM(eu.Usage_Duration), 0), 4) AS Malfunctions_Per_Hour,
        MAX(TO_CHAR(eu.Start_Time, 'YYYY-MM-DD')) AS Last_Usage_Date,
        EXTRACT(DAY FROM MAX(eu.Start_Time)) AS Last_Usage_Day,
        EXTRACT(MONTH FROM MAX(eu.Start_Time)) AS Last_Usage_Month
    FROM 
        Equipment e
    JOIN 
        Safety_Standard ss ON e.Standard_ID = ss.Standard_ID
    LEFT JOIN 
        Equipment_Usage eu ON e.Equipment_ID = eu.Equipment_ID 
        AND eu.Start_Time >= (CURRENT_DATE - INTERVAL '1 month')
    LEFT JOIN 
        Equipment_Malfunction em ON e.Equipment_ID = em.Equipment_ID 
        AND em.Report_Date >= (CURRENT_DATE - INTERVAL '1 month')
    GROUP BY 
        e.Equipment_ID, e.Equipment_Name, e.Equipment_Type, ss.Standard_Name
) AS usage_data
WHERE 
    usage_data.Usage_Count_Last_Month > 0
ORDER BY 
    usage_data.Malfunctions_Per_Hour DESC,
    usage_data.Total_Usage_Minutes_Last_Month DESC;
```

**Execution Screenshot:**  
![WhatsApp Image 2025-05-05 at 21 57 00 (2)](https://github.com/user-attachments/assets/f9989c4c-f6e4-458a-99fd-90ddc2477f75)


**Results Screenshot:**  
<img width="860" alt="7" src="https://github.com/user-attachments/assets/0d0c68d8-6a85-4b62-888b-dbebea1dcba9" />


### Query 8: Seasonal Malfunction Trends by Month and Equipment Type
**תיאור השאילתה:**  
שאילתה זו מזהה דפוסים עונתיים בתקלות בציוד במהלך השנה האחרונה, תוך פילוח אירועים לפי עונה, חודש וסוג ציוד כדי לסייע בחיזוי ובמניעת בעיות עתידיות.
```sql
SELECT 
    EXTRACT(YEAR FROM em.Report_Date) AS Report_Year,
    EXTRACT(MONTH FROM em.Report_Date) AS Report_Month,
    CASE 
        WHEN EXTRACT(MONTH FROM em.Report_Date) IN (12, 1, 2) THEN 'Winter'
        WHEN EXTRACT(MONTH FROM em.Report_Date) IN (3, 4, 5) THEN 'Spring'
        WHEN EXTRACT(MONTH FROM em.Report_Date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END AS Season,
    e.Equipment_Type,
    COUNT(em.Malfunction_ID) AS Total_Malfunctions,
    COUNT(DISTINCT e.Equipment_ID) AS Affected_Equipment_Count,
    ROUND(COUNT(em.Malfunction_ID) * 100.0 / (
        SELECT COUNT(*) 
        FROM Equipment_Malfunction 
        WHERE Report_Date >= (CURRENT_DATE - INTERVAL '1 year')
    ), 2) AS Percentage_Of_Annual_Malfunctions,
    ROUND(AVG(sc.Inspection_Date - e.Installation_Date), 2) AS Avg_Days_Between_Installation_And_Check
FROM 
    Equipment_Malfunction em
JOIN 
    Equipment e ON em.Equipment_ID = e.Equipment_ID
LEFT JOIN 
    Safety_Check sc ON sc.Equipment_ID = e.Equipment_ID 
        AND EXTRACT(MONTH FROM sc.Inspection_Date) = EXTRACT(MONTH FROM em.Report_Date)
        AND EXTRACT(YEAR FROM sc.Inspection_Date) = EXTRACT(YEAR FROM em.Report_Date)
WHERE 
    em.Report_Date >= (CURRENT_DATE - INTERVAL '1 year')
GROUP BY 
    Report_Year, Report_Month, Season, e.Equipment_Type
ORDER BY 
    Report_Year, Report_Month, Total_Malfunctions DESC;
```

**Execution Screenshot:**  
![WhatsApp Image 2025-05-05 at 21 56 59](https://github.com/user-attachments/assets/916585da-6eac-4135-98c4-e1a749f2ffaf)


**Results Screenshot:**  
<img width="764" alt="8" src="https://github.com/user-attachments/assets/3540911d-794f-47bf-a642-4ee6f381c149" />


## UPDATE Queries

### Update Query 1: Equipment Safety Status Update
**תיאור השאילתה:**  
שאילתה זו מעדכנת את השדה Safety_Status בטבלת הציוד בהתבסס על תוצאת בדיקת הבטיחות האחרונה. היא מגדירה את הסטטוס ל-'UNSAFE' אם הבדיקה האחרונה נכשלה, ל-'SAFE' אם הבדיקה האחרונה עברה ובוצעה בשלושת החודשים האחרונים, ול-'REQUIRES_INSPECTION' בכל שאר המקרים.
```sql
UPDATE Equipment
SET Safety_Status = 
    CASE 
        WHEN Equipment_ID IN (
            SELECT e.Equipment_ID
            FROM Equipment e
            JOIN Safety_Check sc ON e.Equipment_ID = sc.Equipment_ID
            WHERE sc.Inspection_Date = (
                SELECT MAX(Inspection_Date)
                FROM Safety_Check
                WHERE Equipment_ID = e.Equipment_ID
            )
            AND sc.Result = 'FAIL'
        ) THEN 'UNSAFE'

        WHEN Equipment_ID IN (
            SELECT e.Equipment_ID
            FROM Equipment e
            JOIN Safety_Check sc ON e.Equipment_ID = sc.Equipment_ID
            WHERE sc.Inspection_Date = (
                SELECT MAX(Inspection_Date)
                FROM Safety_Check
                WHERE Equipment_ID = e.Equipment_ID
            )
            AND sc.Result = 'PASS'
            AND sc.Inspection_Date > (CURRENT_DATE - INTERVAL '3 months')
        ) THEN 'SAFE'

        ELSE 'REQUIRES_INSPECTION'
    END;
```

**Database State Before Update:**  
<img width="311" alt="1A" src="https://github.com/user-attachments/assets/20b03644-f2f8-413a-866c-49b247bb1a35" />


**Execution Screenshot:**  
<img width="644" alt="1B" src="https://github.com/user-attachments/assets/13eea441-4d76-4e3b-9bf2-5c7eb2d64b06" />


**Database State After Update:**  
<img width="232" alt="1C" src="https://github.com/user-attachments/assets/96e11b38-f73f-419f-8b14-ca5700c893bb" />


### Update Query 2: Malfunction Severity Update Based on Average Usage Duration
**תיאור השאילתה:**  
שאילתה זו מעדכנת את רמת החומרה של תקלות בציוד בהתבסס על משך השימוש הממוצע בציוד. היא מקצה חומרה 'גבוהה' לציוד עם שימוש ממוצע של מעל 3 שעות, 'בינונית' ל-1-3 שעות ו-'נמוכה' לפחות משעה. היא משפיעה רק על תקלות שטרם תוקנו.
```sql
UPDATE Equipment_Malfunction
SET Malfunction_Severity = 
    CASE 
        WHEN Equipment_ID IN (
            SELECT eu.Equipment_ID
            FROM Equipment_Usage eu
            GROUP BY eu.Equipment_ID
            HAVING AVG(eu.Usage_Duration) > 180
        ) THEN 'HIGH'

        WHEN Equipment_ID IN (
            SELECT eu.Equipment_ID
            FROM Equipment_Usage eu
            GROUP BY eu.Equipment_ID
            HAVING AVG(eu.Usage_Duration) BETWEEN 60 AND 180
        ) THEN 'MEDIUM'

        ELSE 'LOW'
    END
WHERE Repair_Status != 'COMPLETED';
```

**Database State Before Update:**  
<img width="389" alt="B1" src="https://github.com/user-attachments/assets/94f383a2-e674-499a-915d-afb98262331e" />


**Execution Screenshot:**  
<img width="418" alt="B2" src="https://github.com/user-attachments/assets/2b011a87-32bc-44ed-bffd-eafa2d7b99fc" />


**Database State After Update:**  
[Insert screenshot of Equipment_Malfunction table showing updated malfunction severity values here]

### Update Query 3: Technician Certification Date Update
**תיאור השאילתה:**  
שאילתה זו מעדכנת את תאריכי ההסמכה של טכנאים בהתבסס על רישומי התיקונים המוצלחים שלהם במהלך השנה האחרונה. טכנאים עם יותר מ-10 תיקונים מוצלחים מקבלים תאריך הסמכה שנקבע להיום, טכנאים עם 5-10 תיקונים מקבלים הארכה של 6 חודשים, ואלה עם פחות מ-5 תיקונים שומרים על תאריך ההסמכה הנוכחי שלהם.
```sql
UPDATE Maintenance_Technician
SET Last_Certification_Date = 
    CASE 
        WHEN Technician_ID IN (
            SELECT em.Technician_ID
            FROM Equipment_Malfunction em
            WHERE em.Repair_Status = 'COMPLETED'
            AND em.Report_Date > (CURRENT_DATE - INTERVAL '1 year')
            GROUP BY em.Technician_ID
            HAVING COUNT(*) > 10
        ) THEN CURRENT_DATE

        WHEN Technician_ID IN (
            SELECT em.Technician_ID
            FROM Equipment_Malfunction em
            WHERE em.Repair_Status = 'COMPLETED'
            AND em.Report_Date > (CURRENT_DATE - INTERVAL '1 year')
            GROUP BY em.Technician_ID
            HAVING COUNT(*) BETWEEN 5 AND 10
        ) THEN Last_Certification_Date + INTERVAL '6 months'

        ELSE Last_Certification_Date
    END;
```

**Database State Before Update:**  
<img width="521" alt="C1" src="https://github.com/user-attachments/assets/ca3609cf-5fcb-4628-9cff-046d09f45cc6" />


**Execution Screenshot:**  
<img width="500" alt="C2" src="https://github.com/user-attachments/assets/c37536a9-561d-4b45-ac1c-07b77a288809" />


**Database State After Update:**  
<img width="533" alt="C3" src="https://github.com/user-attachments/assets/4cad0838-23ab-4b4e-9ff2-47026fe7c26c" />


## DELETE Queries

### Delete Query 1: Remove Inactive Technicians
**תיאור השאילתה:**  
שאילתה זו מזהה ומסירה טכנאים שלא השלימו תיקונים מוצלחים בשנה האחרונה. זהו תהליך דו-שלבי אשר תחילה מסיר רשומות תקלות תלויות כדי לשמר שלמות הקשרים, ולאחר מכן מסיר את הטכנאים הלא פעילים עצמם.
```sql
-- Step 1: Delete malfunction records related to inactive technicians
DELETE FROM Equipment_Malfunction
WHERE Technician_ID IN (
    SELECT Technician_ID
    FROM Maintenance_Technician
    WHERE Technician_ID NOT IN (
        SELECT Technician_ID
        FROM Equipment_Malfunction
        WHERE Report_Date > (CURRENT_DATE - INTERVAL '1 year')
        AND Repair_Status = 'COMPLETED'
    )
);

-- Step 2: Delete the inactive technicians
DELETE FROM Maintenance_Technician
WHERE Technician_ID NOT IN (
    SELECT Technician_ID
    FROM Equipment_Malfunction
);
```

**Database State Before Delete:**  
<img width="527" alt="A1" src="https://github.com/user-attachments/assets/2cccb4ae-53c8-4313-8017-da90692ecb78" />

**Database State After Delete:**  
[Insert screenshot of Equipment_Malfunction and Maintenance_Technician tables after deletion here]

### Delete Query 2: Remove Old Safety Checks for Unused Equipment
**תיאור השאילתה:**  
שאילתה זו מסירה רשומות בדיקות בטיחות בנות למעלה משנתיים, אך רק עבור ציוד שלא היה בשימוש בשנה האחרונה. זה עוזר לנקות את מסד הנתונים תוך שמירה על נתונים רלוונטיים מבחינה היסטורית.
```sql
DELETE FROM Safety_Check
WHERE Inspection_Date < (CURRENT_DATE - INTERVAL '2 years')
AND Equipment_ID NOT IN (
    SELECT DISTINCT Equipment_ID
    FROM Equipment_Usage
    WHERE Start_Time > (CURRENT_DATE - INTERVAL '1 year')
    GROUP BY Equipment_ID
    HAVING COUNT(*) > 0
);
```

**Database State Before Delete:**  
<img width="496" alt="B1" src="https://github.com/user-attachments/assets/affc628d-3a8f-4382-ae64-eb2e2ecd690a" />


**Execution Screenshot:**  
<img width="587" alt="B2" src="https://github.com/user-attachments/assets/935db17e-ba04-49d1-a252-c35b4121165a" />


**Database State After Delete:**  
[Insert screenshot of Safety_Check table after deletion here]

### Delete Query 3: Remove Short Equipment Usage Records
**תיאור השאילתה:**  
שאילתה זו מסירה רשומות שימוש בציוד שהיו קצרות מ-15 דקות, ישנות יותר מ-3 חודשים ולא קשורות לתקלה בציוד שדווחה באותו יום.
```sql
DELETE FROM Equipment_Usage
WHERE Usage_Duration < 15
AND Start_Time < (CURRENT_DATE - INTERVAL '3 months')
AND Equipment_ID NOT IN (
    SELECT Equipment_ID
    FROM Equipment_Malfunction
    WHERE Report_Date BETWEEN Start_Time AND (Start_Time + INTERVAL '1 day')
);
```

**Database State Before Delete:**  
<img width="512" alt="C1" src="https://github.com/user-attachments/assets/ca3499b5-ee6c-4fe0-b943-5694578f6346" />


**Execution Screenshot:**  
<img width="648" alt="C3" src="https://github.com/user-attachments/assets/f5b6d885-114f-4ede-82f1-9b82016d7809" />


**Database State After Delete:**  
[Insert screenshot of Equipment_Usage table after deletion here]

## Database Constraints

### Constraint 1: Check for Positive Usage Duration
**Description:**  
This constraint ensures that all equipment usage records have a positive duration value, preventing invalid data entry.

```sql
ALTER TABLE Equipment_Usage 
ADD CONSTRAINT check_usage_duration_positive 
CHECK (Usage_Duration > 0);
```

**Constraint Test:**  
<img width="506" alt="אילוץ1" src="https://github.com/user-attachments/assets/a1b40c55-3d89-4ae7-b5bd-189099ac2874" />


### Constraint 2: Default Value for Repair Status
**Description:**  
This constraint sets a default value of 'Pending' for the Repair_Status column in the Equipment_Malfunction table when no value is provided.

```sql
ALTER TABLE Equipment_Malfunction 
ALTER COLUMN Repair_Status 
SET DEFAULT 'Pending';
```

**Constraint Test:**  
<img width="711" alt="אילוץ2" src="https://github.com/user-attachments/assets/e5e3b70d-a52e-4a15-9bd5-fb64f0ba336c" />


### Constraint 3: No Future Installation Dates
**Description:**  
This constraint prevents the entry of future dates as equipment installation dates, ensuring data accuracy.

```sql
ALTER TABLE Equipment 
ADD CONSTRAINT check_installation_date_not_future 
CHECK (Installation_Date <= CURRENT_DATE);
```

**Constraint Test:**  
<img width="628" alt="אילוץ3" src="https://github.com/user-attachments/assets/a18b8332-dd52-48d8-942b-be5ef01047c6" />


## Transaction Management

### Example 1: COMMIT Operation
**Description:**  
Demonstration of a transaction with COMMIT to permanently save changes.

```sql
BEGIN;
-- Make changes to the database
UPDATE Equipment SET Safety_Status = 'REQUIRES_INSPECTION' WHERE Equipment_ID = 1;
-- Verify changes
SELECT Equipment_ID, Equipment_Name, Safety_Status FROM Equipment WHERE Equipment_ID = 1;
-- Commit changes
COMMIT;
-- Verify changes persist after commit
SELECT Equipment_ID, Equipment_Name, Safety_Status FROM Equipment WHERE Equipment_ID = 1;
```

**Transaction Stages:**  
<img width="555" alt="B1" src="https://github.com/user-attachments/assets/5cfa22c4-7aef-4bb5-8c58-f09ad3c55273" />
<img width="390" alt="B2" src="https://github.com/user-attachments/assets/911eaaed-8641-45c4-9d80-a42f94a9c7eb" />
<img width="219" alt="B3" src="https://github.com/user-attachments/assets/c3194885-5523-4c30-b82b-2fd06562f4c5" />
<img width="563" alt="B4" src="https://github.com/user-attachments/assets/75522ffb-2f1f-40c2-94ba-c4a79abe962f" />


### Example 2: ROLLBACK Operation
**Description:**  
Demonstration of a transaction with ROLLBACK to discard changes.

```sql
BEGIN;
-- Make changes to the database
UPDATE Equipment SET Safety_Status = 'UNSAFE' WHERE Equipment_ID = 2;
-- Verify changes within transaction
SELECT Equipment_ID, Equipment_Name, Safety_Status FROM Equipment WHERE Equipment_ID = 2;
-- Rollback changes
ROLLBACK;
-- Verify changes were discarded
SELECT Equipment_ID, Equipment_Name, Safety_Status FROM Equipment WHERE Equipment_ID = 2;
```

**Transaction Stages:**  
<img width="555" alt="A1" src="https://github.com/user-attachments/assets/5f82f24d-824e-448d-b1c6-ef16180971a7" />
<img width="390" alt="A2" src="https://github.com/user-attachments/assets/0276ce5b-73e2-4a2a-b01e-495b31b34e9f" />
<img width="260" alt="A3" src="https://github.com/user-attachments/assets/c63ee4e0-4088-4c7b-a9f0-f567b26faef8" />
<img width="661" alt="A4" src="https://github.com/user-attachments/assets/db5aacca-64bd-4103-a97d-17d087a751e7" />




## Integration Phase – README (Stage C)

### 1. DSD & ERD Diagrams (in correct order)

🔹 **1. DSD of the Received Department**  
<img width="275" alt="DSD_new" src="https://github.com/user-attachments/assets/48b53d97-5e8a-4e00-aa75-45004bfb9f51" />

<br/>

🔹 **2. ERD of the Received Department**  
<img width="546" alt="ERD_new" src="https://github.com/user-attachments/assets/9312212f-62fd-41d3-8f26-ba4f14a3c419" />

<br/>

🔹 **3. Combined ERD (After Integration)**  
<img width="1001" alt="ERD_together" src="https://github.com/user-attachments/assets/492e0725-0232-4169-b811-c41b8ac7c486" />

<br/>

🔹 **4. DSD After Integration**  
<img width="368" alt="DSD_together" src="https://github.com/user-attachments/assets/63efe6c6-1be7-4a7c-8143-a376670af467" />



### 2. We were tasked with integrating our database with Noam’s database.

In our initial analysis of the combined ERD diagrams, we identified two key aspects that required attention:

- **Harmonizing the Equipment tables** from both databases to create a unified structure.

- **Creating a shared `Employee` table**, from which both Noam’s `Trainer` table and our `Maintenance_Technician` table would inherit, as both represent types of employees.  
  This integration was based on common conceptual attributes.

### 3. Database Integration Process


####  Table of Contents
- [Step 1: Aligning Equipment Tables](#step-1-aligning-equipment-tables)
- [Step 2: Importing Remaining Tables](#step-2-importing-remaining-tables)
- [Step 3: Creating Shared Employee Table](#step-3-creating-shared-employee-table)

---

### Step 1: Aligning Equipment Tables

####  Challenge
The only shared table between both databases is the **Equipment** table, but with different structures:

##### Our Equipment Table Structure:
```sql
equipment_id, equipment_name, equipment_type, safety_status, installation_date, standard_id
```

##### Noam's Equipment Table Structure:
```sql
equipmentid, eqname, purchasedate, conditionstatus, exerciseid
```

####  Solution Process

1. **Standardize column names** to a common naming convention
2. **Resolve data type mismatches** where present
3. **Add missing columns** from Noam's schema

####  Implementation

```sql
-- Enable dblink extension
CREATE EXTENSION IF NOT EXISTS dblink;

-- Import data with conflict resolution
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
```

---

### Step 2: Importing Remaining Tables

####  Table Creation

Since Noam's remaining tables are independent and don't conflict with ours, we created their schema and imported the data:

#####  Schema Definitions

```sql
-- Trainee table
CREATE TABLE trainee (
    traineeid serial PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    email VARCHAR(50),
    phone VARCHAR(15),
    dateofbirth DATE
);

-- Trainer table
CREATE TABLE trainer (
    trainerid INTEGER PRIMARY KEY,
    programid INTEGER,
    hiredate DATE,
    employeeid INTEGER
);

-- Training Program table
CREATE TABLE trainingprogram (
    programid serial PRIMARY KEY,
    programname VARCHAR(50),
    startdate DATE,
    enddate DATE,
    traineeid INTEGER
);

-- Training Log table
CREATE TABLE traininglog (
    logid serial PRIMARY KEY,
    traineeid INTEGER,
    programid INTEGER,
    duration INTEGER,
    repetitions INTEGER,
    programname VARCHAR(50)
);

-- Exercise table
CREATE TABLE exercise (
    exerciseid serial PRIMARY KEY,
    exname VARCHAR(50),
    description VARCHAR(255),
    programid INTEGER
);
```

##### Data Import Process

```sql
-- Import trainee data
INSERT INTO trainee (traineeid, firstname, lastname, email, phone, dateofbirth)
SELECT * FROM dblink('dbname=NOAM user=eitan password=weizman558',
                     'SELECT traineeid, firstname, lastname, email, phone, dateofbirth FROM trainee')
AS t(traineeid INTEGER, firstname VARCHAR(50), lastname VARCHAR(50), 
     email VARCHAR(50), phone VARCHAR(15), dateofbirth DATE);

-- Import trainer data
INSERT INTO trainer (trainerid, programid, hiredate, employeeid)
SELECT * FROM dblink('dbname=NOAM user=eitan password=weizman558',
                     'SELECT trainerid, programid, hiredate, employeeid FROM trainer')
AS t(trainerid INTEGER, programid INTEGER, hiredate DATE, employeeid INTEGER);

-- Import training program data
INSERT INTO trainingprogram (programid, programname, startdate, enddate, traineeid)
SELECT * FROM dblink('dbname=NOAM user=eitan password=weizman558',
                     'SELECT programid, programname, startdate, enddate, traineeid FROM trainingprogram')
AS t(programid INTEGER, programname VARCHAR(50), startdate DATE, 
     enddate DATE, traineeid INTEGER);

-- Import training log data
INSERT INTO traininglog (logid, traineeid, programid, duration, repetitions, programname)
SELECT * FROM dblink('dbname=NOAM user=eitan password=weizman558',
                     'SELECT logid, traineeid, programid, duration, repetitions, programname FROM traininglog')
AS t(logid INTEGER, traineeid INTEGER, programid INTEGER, duration INTEGER, 
     repetitions INTEGER, programname VARCHAR(50));

-- Import exercise data
INSERT INTO exercise (exerciseid, exname, description, programid)
SELECT * FROM dblink('dbname=NOAM user=eitan password=weizman558',
                     'SELECT exerciseid, exname, description, programid FROM exercise')
AS t(exerciseid INTEGER, exname VARCHAR(50), description VARCHAR(255), programid INTEGER);
```

---

### Step 3: Creating Shared Employee Table

#### Objective
Unify both our `maintenance_technician` table and Noam's `trainer` table under a common **Employee** entity.

#### Challenge
The two tables shared **no common columns** initially.

#### Solution
We manually added a shared column `phone_number` by preparing a CSV with phone numbers and uploading it to Noam's database.

#### Implementation Steps

##### 1. Create the Unified Employee Table
```sql
CREATE TABLE employee (
    employeeid SERIAL PRIMARY KEY,
    phone_number VARCHAR(30) UNIQUE NOT NULL
);
```

##### 2. Add Foreign Key Columns
```sql
ALTER TABLE trainer ADD COLUMN employeeid INTEGER UNIQUE;
ALTER TABLE maintenance_technician ADD COLUMN employeeid INTEGER UNIQUE;
```

##### 3. Populate Employee Table
```sql
INSERT INTO employee (phone_number)
SELECT DISTINCT phone_number FROM (
    SELECT phone_number FROM trainer
    UNION
    SELECT phone_number FROM maintenance_technician
) AS unique_phones;
```

##### 4. Link Child Tables to Employee Table
```sql
-- Update trainer table
UPDATE trainer T
SET employeeid = E.employeeid
FROM employee E
WHERE T.phone_number = E.phone_number;

-- Update maintenance_technician table
UPDATE maintenance_technician M
SET employeeid = E.employeeid
FROM employee E
WHERE M.phone_number = E.phone_number;
```

##### 5. Enforce Referential Integrity
```sql
-- Add foreign key constraint for trainer
ALTER TABLE trainer
ADD CONSTRAINT fk_trainer_employee
FOREIGN KEY (employeeid) REFERENCES employee(employeeid);

-- Add foreign key constraint for maintenance_technician
ALTER TABLE maintenance_technician
ADD CONSTRAINT fk_maintenance_employee
FOREIGN KEY (employeeid) REFERENCES employee(employeeid);
```

---

### Integration Complete

The database integration process successfully:
-  Aligned Equipment table schemas
-  Imported all of Noam's independent tables  
-  Created a unified Employee structure
-  Maintained referential integrity

> **Note**: All operations use `dblink` for cross-database connectivity and include proper conflict resolution strategies.

 ### 4. Views and Queries
#### 📌 View 1: Equipment_Safety_Status_View
This SQL command creates a view named `Equipment_Safety_Status_View` that combines data from the `Equipment` and `Safety_Check` tables. It uses a **LEFT JOIN** to show all equipment items, along with their safety status and any related safety check details (inspection date, result, and notes). If no safety check exists for an item, those fields will be `NULL`. This view helps monitor equipment safety in one unified query.


CREATE VIEW Equipment_Safety_Status_View AS
SELECT 
    E.Equipment_ID,
    E.Equipment_Name,
    E.Installation_Date,
    E.Safety_Status,
    SC.Inspection_Date,
    SC.Result,
    SC.Inspector_Notes
FROM 
    Equipment E
LEFT JOIN 
    Safety_Check SC ON E.Equipment_ID = SC.Equipment_ID;

<img width="893" alt="SelectA" src="https://github.com/user-attachments/assets/12779283-d3c5-473e-92e9-4d59352598d2" />


##### Query 1 –
This query selects specific columns from the Equipment_Safety_Status_View view, focusing on equipment name, installation date, safety status, and details from the safety inspection. It also renames the Inspector_Notes column to Inspector_Comments for clarity. The results are ordered by the safety status, making it easier to prioritize or group equipment based on their current safety condition.

SELECT 
    Equipment_Name,
    Installation_Date,
    Safety_Status,
    Inspection_Date,
    Result,
    Inspector_Notes AS Inspector_Comments
FROM 
    Equipment_Safety_Status_View
ORDER BY 
    Safety_Status
    
<img width="783" alt="View1A" src="https://github.com/user-attachments/assets/a8c4a5f0-cfbb-4e39-9079-b523317ec856" />


##### Query 2 –
This query groups the equipment by their **safety status** and provides a summary for each group:

* `TotalEquipment`: the total number of equipment items with that safety status.
* `PassedInspections`: how many of them passed their last inspection.
* `FailedInspections`: how many failed.
* `NotInspected`: how many have not been inspected yet (i.e., inspection result is `NULL`).

This helps assess the overall safety situation for different types of equipment status.


SELECT 
    v.Safety_Status,
    COUNT(*) AS TotalEquipment,
    COUNT(CASE WHEN Result = 'Pass' THEN 1 END) AS PassedInspections,
    COUNT(CASE WHEN Result = 'Fail' THEN 1 END) AS FailedInspections,
    COUNT(CASE WHEN Result IS NULL THEN 1 END) AS NotInspected
FROM 
    Equipment_Safety_Status_View AS v
GROUP BY 
    v.Safety_Status;
    
<img width="483" alt="View1B" src="https://github.com/user-attachments/assets/d472b9bb-4112-426c-939d-b628fb2a324c" />


#### 📌 View 2: Training_Log_Summary
This view, named Training_Log_Summary, combines data from the traininglog and trainingprogram tables to provide a clearer summary of training activities.
For each training log entry, it shows:
logid: the unique ID of the log entry
traineeid: the trainee who performed the training
program_name: the name of the program (retrieved from the trainingprogram table)
duration: how long the training session lasted
repetitions: how many repetitions were done
It makes it easier to analyze training performance with program context included.

View Code:
CREATE VIEW Training_Log_Summary AS
SELECT 
    tl.logid,
    tl.traineeid,
    tp.programname AS program_name,
    tl.duration,
    tl.repetitions
FROM 
    traininglog tl
JOIN 
    trainingprogram tp ON tl.programid = tp.programid;
    
<img width="422" alt="SelectB" src="https://github.com/user-attachments/assets/9f7e1d65-015a-403b-8363-f2e080624faa" />


##### Query 1 – 
This query calculates the average duration of training sessions for each training program.
It selects program_name from the Training_Log_Summary view.
It uses AVG(duration) to compute the average duration of sessions in each program.
It groups the results by program_name to ensure the average is calculated per program.
The result shows how much time trainees spend on average in each training program.

	SELECT 
    program_name, 
    AVG(duration) AS average_duration
FROM 
    Training_Log_Summary
GROUP BY 
    program_name;

<img width="275" alt="View2A" src="https://github.com/user-attachments/assets/b64a5386-cc36-4636-a40e-3d0901efaac1" />


##### Query 2 –
This query retrieves all training session records for a specific trainee.
It selects all columns (*) from the Training_Log_Summary view.
It filters the results using WHERE traineeid = 236779343, so only records related to this trainee will be returned.
The result will show all the programs this trainee participated in, along with the session duration and number of repetitions.

SELECT *
FROM Training_Log_Summary
WHERE traineeid = 236779343;

<img width="369" alt="View2B" src="https://github.com/user-attachments/assets/cc77dbed-9d34-4a80-b5ed-fbe57c5946a2" />


## Project Stage D Report

This document contains a detailed report for stage D of the project. It includes PL/pgSQL functions, procedures, main programs, and triggers, alongside explanations, code, and proof of successful execution.

### ① Function 1:

* Description:
This function calculates the efficiency of a technician based on their repair history. It first counts how many malfunctions are assigned to the given technician. If the total is zero, it returns 0. Otherwise, it counts how many of those malfunctions are associated with equipment marked as "Fixed", and returns the percentage of successful repairs. The function uses DML (SELECT INTO), IF condition, JOIN, type casting, and basic arithmetic.


* Code:

```sql
CREATE OR REPLACE FUNCTION get_technician_efficiency(tid VARCHAR)
RETURNS FLOAT AS $$
DECLARE
    total INT;
    fixed INT;
BEGIN
    SELECT COUNT(*) INTO total
    FROM equipment_malfunction
    WHERE technician_id = tid;

    IF total = 0 THEN
        RETURN 0;
    END IF;

    SELECT COUNT(*) INTO fixed
    FROM equipment_malfunction em
    JOIN equipment e ON e.equipment_id = em.equipment_id
    WHERE em.technician_id = tid AND e.safety_status = 'Fixed';

    RETURN (fixed::FLOAT / total) * 100;
END;
$$ LANGUAGE plpgsql;

```

### ② Procedure 1:

* Description:
This procedure assigns a random exercise to each piece of equipment that currently has no exercise assigned (i.e., exerciseid is NULL). It loops through all such equipment, selects a random exercise from the exercise table, and updates the equipment with that exercise ID. A notice is printed for each assignment. The procedure uses an implicit cursor, SELECT INTO, IF condition, DML operations, and record variables.

* Code:

```sql
CREATE OR REPLACE PROCEDURE assign_equipment_to_exercise()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
    random_exercise INT;
BEGIN
    FOR rec IN
        SELECT * FROM equipment WHERE exerciseid IS NULL
    LOOP
        SELECT exerciseid INTO random_exercise
        FROM exercise ORDER BY RANDOM() LIMIT 1;

        IF random_exercise IS NOT NULL THEN
            UPDATE equipment
            SET exerciseid = random_exercise
            WHERE equipment_id = rec.equipment_id;

            RAISE NOTICE 'Assigned equipment % to exercise %', rec.equipment_id, random_exercise;
        END IF;
    END LOOP;
END;
$$;

```

### ③ Main Program A

* Description:
This main program first calls a procedure that assigns random exercises to all unassigned equipment. Then, it calls a function that calculates the efficiency (as a percentage) of a specific technician based on the number of malfunctions they handled that were marked as fixed. Finally, it prints the result using RAISE NOTICE. The program demonstrates procedure and function calls, variable assignment, and output display.

* Code:

```sql
DO $$
DECLARE
    percent FLOAT;
BEGIN
    CALL assign_equipment_to_exercise();

    percent := get_technician_efficiency('tech001');
    RAISE NOTICE 'Technician efficiency: %%%', percent;
END;
$$;
```

* Proof:
  <img width="402" alt="2" src="https://github.com/user-attachments/assets/09b3be2b-c08c-4e44-ba13-0ccb75d724b1" />


---

### ④ Function 2:

* Description:
This function returns a refcursor containing all equipment of a given type that requires attention (i.e., has a safety status of 'NeedFix' or 'NotWorking'). If the input type is NULL, it raises an exception. The function demonstrates parameter validation, conditional logic (IF), explicit cursor usage, refcursor return, and a SELECT query with a WHERE clause.


* Code:

```sql
CREATE OR REPLACE FUNCTION get_equipment_needing_attention(e_type VARCHAR)
RETURNS refcursor AS $$
DECLARE
    ref refcursor;
BEGIN
    IF e_type IS NULL THEN
        RAISE EXCEPTION 'Equipment type must not be NULL';
    END IF;

    OPEN ref FOR
    SELECT * FROM equipment
    WHERE equipment_type = e_type
      AND safety_status IN ('NeedFix', 'NotWorking');

    RETURN ref;
END;
$$ LANGUAGE plpgsql;

```

### ⑤ Procedure 2:

* Description:
This procedure finds all malfunctions reported more than 180 days ago and updates their equipment and malfunction status to "Fixed". It loops through the results, performs two UPDATE statements for each record, and prints a notice. If an error occurs during the update, it catches the exception and prints an error message. The procedure uses an implicit cursor, DML operations, exception handling, and a record variable.


* Code:

```sql
CREATE OR REPLACE PROCEDURE mark_old_malfunctions_as_fixed()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT equipment_id FROM equipment_malfunction
        WHERE report_date < CURRENT_DATE - INTERVAL '180 days'
    LOOP
        BEGIN
            UPDATE equipment
            SET safety_status = 'Fixed'
            WHERE equipment_id = rec.equipment_id;

            UPDATE equipment_malfunction
            SET repair_status = 'Fixed'
            WHERE equipment_id = rec.equipment_id;

            RAISE NOTICE 'Marked equipment % as Fixed', rec.equipment_id;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Failed to update equipment %: %', rec.equipment_id, SQLERRM;
        END;
    END LOOP;
END;
$$;

```
### ⑥ Main Program B

* Description:
This main program calls a procedure that marks old malfunctions as fixed, then calls a function that returns a refcursor containing all 'dumbbells' that still require maintenance. It loops through the results and prints the name of each equipment needing attention. The program demonstrates use of procedures, functions, refcursors, loops, and record variables.


* Code:

```sql
DO $$
DECLARE
    cur refcursor;
    eq equipment%ROWTYPE;
BEGIN
    CALL mark_old_malfunctions_as_fixed();

    cur := get_equipment_needing_attention('dumbbells');
    LOOP
        FETCH cur INTO eq;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Equipment needing fix: %', eq.equipment_name;
    END LOOP;
    CLOSE cur;
END;
$$;

```

* Proof:
  <img width="631" alt="1" src="https://github.com/user-attachments/assets/f54e88a4-cbe6-4b25-bf11-e6f918f78170" />
---

### Triggers

---

### Trigger 1: trg\_check\_equipment\_standard

* Description:
  This BEFORE trigger fires on INSERT or UPDATE on equipment. It checks whether the standard\_id specified in the new row exists in safety\_standard. If not, it raises an exception. This ensures referential integrity in logic layer (even if not enforced by FK). Includes branching, exception handling, and uses RECORD.

* Trigger Function Code:

```sql
CREATE OR REPLACE FUNCTION check_equipment_standard()
RETURNS trigger AS $$
DECLARE
    std RECORD;
BEGIN
    SELECT * INTO std FROM safety_standard WHERE standard_id = NEW.standard_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Standard ID % does not exist.', NEW.standard_id;
    END IF;
    RAISE NOTICE 'Inserted equipment with standard %: %', std.standard_id, std.standard_name;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

* Trigger:

```sql
CREATE TRIGGER trg_check_equipment_standard
BEFORE INSERT OR UPDATE ON equipment
FOR EACH ROW
EXECUTE FUNCTION check_equipment_standard();
```


---

### Trigger 2: trg\_auto\_log\_safety\_check\_failure

* Description:
  This AFTER INSERT trigger listens to safety\_check. If the result of a safety check is 'Fail', it automatically logs a malfunction to equipment\_malfunction with a generated ID, random technician, and default severity. Demonstrates DML, IF, RECORD, exception, and logic encapsulation.

* Trigger Function Code:

```sql
CREATE OR REPLACE FUNCTION auto_log_malfunction_on_failed_check()
RETURNS trigger AS $$
DECLARE
    tech RECORD;
    new_id TEXT;
BEGIN
    IF NEW.result = 'Fail' THEN
        SELECT * INTO tech FROM maintenance_technician ORDER BY RANDOM() LIMIT 1;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'No technician found.';
        END IF;
        new_id := 'MALF_' || NEW.check_id || '_' || EXTRACT(EPOCH FROM now())::BIGINT;
        INSERT INTO equipment_malfunction (
            malfunction_id, report_date, malfunction_severity, repair_status,
            equipment_id, technician_id
        ) VALUES (
            new_id, CURRENT_DATE, 'Medium', 'Pending', NEW.equipment_id, tech.technician_id
        );
        RAISE NOTICE 'Auto-malfunction % created for equipment %.', new_id, NEW.equipment_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

* Trigger:

```sql
CREATE TRIGGER trg_auto_log_safety_check_failure
AFTER INSERT ON safety_check
FOR EACH ROW
EXECUTE FUNCTION auto_log_malfunction_on_failed_check();
```

# 🧰 Gym Management System - APP | STAGE 5 

## ✨ Overview

A full-featured graphical user interface was developed for the Gym Management System application, enabling complete management of gym-related entities such as trainees, equipment, malfunctions, and advanced analytics. The application is directly integrated with a PostgreSQL database.

---

## 💪 Tools & Technologies

* **Programming Language**: Python 3
* **Backend Framework**: Flask
* **ORM**: SQLAlchemy
* **Database**: PostgreSQL 15
* **Schema Management**: Flask-Migrate
* **UI Libraries**: Bootstrap 5, Jinja2
* **Database GUI**: pgAdmin 4
* **AI Assistance**:

  * We used **Claude** (Anthropic) for help with HTML, Jinja templates, and advice on structuring Python and SQL code.

---

## 🚀 Application Setup

### 1. Run PostgreSQL

```bash
docker run --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres
```

### 2. Run pgAdmin (optional)

```bash
docker run -p 5050:80 \
  -e PGADMIN_DEFAULT_EMAIL=admin@admin.com \
  -e PGADMIN_DEFAULT_PASSWORD=admin \
  -d dpage/pgadmin4
```

### 3. Launch the Flask App

```bash
cd GymManagementSystem
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

### 4. Access the App

```
http://localhost:5000
```

---

## 📆 Application Structure & Screens

### 🏠 Dashboard

* Displays key system statistics
* Links to all system screens, including the Procedures & Queries page

### 👤 Trainees

* Full CRUD on trainees
* Age is calculated automatically from birthdate
* 🔽 Screenshot: `screenshots/trainee_edit.png`

### 🏋️ Equipment

* Full CRUD on equipment: name, type, safety status, standard, installation/purchase date, related exercise
* 🔽 Screenshot: `screenshots/equipment_edit.png`

### ⚒️ Malfunctions

* Displays reported equipment malfunctions
* Allows adding and deleting malfunctions
* 🔽 Screenshot: `screenshots/malfunctions_view.png`

### 📊 Analytics

* Pie chart showing equipment type distribution
* Bar chart for monthly malfunctions
* Participation chart for training programs
* 🔽 Screenshot: `screenshots/analytics_dashboard.png`

### ⚙️ Procedures & Queries

* Executes:

  * 2 PL/pgSQL procedures/functions
  * 2 advanced SQL queries from earlier project stages
* Accessible only through the Dashboard
* 🔽 Screenshot: `screenshots/procedures_page.png`

---

For any questions, please contact the development team.




