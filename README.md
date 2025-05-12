# Gym Equipment Safety Management System – Project Report (Stage A) stage B - 110

## Submitted by:

* **Eliya Masa**
* **Eitan Weizman**

## System Name:

**Gym Equipment Safety Management System**

## Selected Unit:

**Equipment Safety**

---

## Table of Contents

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
[Insert screenshot showing up to 5 rows of results here]

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
[Insert screenshot showing up to 5 rows of results here]

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
[Insert screenshot showing up to 5 rows of results here]

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
[Insert screenshot showing up to 5 rows of results here]

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
[Insert screenshot showing up to 5 rows of results here]

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
[Insert screenshot showing up to 5 rows of results here]

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
[Insert screenshot showing up to 5 rows of results here]

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
[Insert screenshot of equipment table before update here]

**Execution Screenshot:**  
[Insert screenshot of query execution here]

**Database State After Update:**  
[Insert screenshot of equipment table showing updated safety status values here]

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
[Insert screenshot of Equipment_Malfunction table before update here]

**Execution Screenshot:**  
[Insert screenshot of query execution here]

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
[Insert screenshot of Maintenance_Technician table before update here]

**Execution Screenshot:**  
[Insert screenshot of query execution here]

**Database State After Update:**  
[Insert screenshot of Maintenance_Technician table showing updated certification dates here]

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
[Insert screenshot of Equipment_Malfunction and Maintenance_Technician tables before deletion here]

**Execution Screenshot:**  
[Insert screenshot of query execution here]

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
[Insert screenshot of Safety_Check table before deletion here]

**Execution Screenshot:**  
[Insert screenshot of query execution here]

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
[Insert screenshot of Equipment_Usage table before deletion here]

**Execution Screenshot:**  
[Insert screenshot of query execution here]

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
[Insert screenshot showing an attempt to insert a record with a negative or zero duration value, and the resulting error]

### Constraint 2: Default Value for Repair Status
**Description:**  
This constraint sets a default value of 'Pending' for the Repair_Status column in the Equipment_Malfunction table when no value is provided.

```sql
ALTER TABLE Equipment_Malfunction 
ALTER COLUMN Repair_Status 
SET DEFAULT 'Pending';
```

**Constraint Test:**  
[Insert screenshot showing insertion of a new malfunction record without specifying a repair status, and the resulting record showing the default value]

### Constraint 3: No Future Installation Dates
**Description:**  
This constraint prevents the entry of future dates as equipment installation dates, ensuring data accuracy.

```sql
ALTER TABLE Equipment 
ADD CONSTRAINT check_installation_date_not_future 
CHECK (Installation_Date <= CURRENT_DATE);
```

**Constraint Test:**  
[Insert screenshot showing an attempt to insert a record with a future installation date, and the resulting error]

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
[Insert screenshots showing:
1. Database state before transaction starts
2. After the UPDATE but before COMMIT
3. After the COMMIT operation]

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
[Insert screenshots showing:
1. Database state before transaction starts
2. After the UPDATE but before ROLLBACK
3. After the ROLLBACK operation, showing original data is preserved]
