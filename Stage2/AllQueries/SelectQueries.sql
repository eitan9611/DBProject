-- ======================================================
-- 1. שאילתא המציגה את כל הציוד שלא עבר בדיקת בטיחות בחצי השנה האחרונה
-- עם פרטי הבדיקה האחרונה שבוצעה עליו ושם הסטנדרט שהוא אמור לעמוד בו
-- ======================================================

SELECT 
    e.Equipment_ID,  -- מזהה הציוד
    e.Equipment_Name,  -- שם הציוד
    e.Equipment_Type,  -- סוג הציוד
    e.Safety_Status,  -- סטטוס הבטיחות של הציוד
    MAX(sc.Inspection_Date) AS Last_Inspection_Date,  -- התאריך האחרון בו בוצעה בדיקה
    CURRENT_DATE - MAX(sc.Inspection_Date) AS Days_Since_Last_Inspection,  -- מספר הימים מאז הבדיקה האחרונה
    EXTRACT(MONTH FROM MAX(sc.Inspection_Date)) AS Last_Inspection_Month,  -- חודש הבדיקה האחרונה
    EXTRACT(YEAR FROM MAX(sc.Inspection_Date)) AS Last_Inspection_Year,  -- שנה הבדיקה האחרונה
    sc.Result AS Last_Inspection_Result,  -- תוצאת הבדיקה האחרונה
    ss.Standard_Name,  -- שם הסטנדרט הבטיחותי
    ss.Standard_Level  -- רמת הסטנדרט הבטיחותי
FROM 
    Equipment e  -- טבלת ציוד
LEFT JOIN 
    Safety_Check sc ON e.Equipment_ID = sc.Equipment_ID  -- חיבור לטבלת בדיקות הבטיחות לפי מזהה הציוד
LEFT JOIN 
    Safety_Standard ss ON e.Standard_ID = ss.Standard_ID  -- חיבור לטבלת סטנדרטים בטיחותיים לפי מזהה הסטנדרט
GROUP BY 
    e.Equipment_ID, e.Equipment_Name, e.Equipment_Type, e.Safety_Status, sc.Result, ss.Standard_Name, ss.Standard_Level  -- קיבוץ לפי פרטי הציוד והסטנדרט
HAVING 
    MAX(sc.Inspection_Date) < (CURRENT_DATE - INTERVAL '6 months') OR MAX(sc.Inspection_Date) IS NULL  -- סינון ציוד שלא עבר בדיקה בחצי שנה האחרונה או ציוד שאין לו בדיקות כלל
ORDER BY 
    Days_Since_Last_Inspection DESC;  -- מיון הציוד לפי מספר הימים מאז הבדיקה האחרונה

-- ======================================================
-- 2. שאילתא המציגה את הטכנאים שטיפלו במספר הגבוה ביותר של תקלות חמורות בשנה האחרונה
-- כולל פירוט מספר תקלות לפי חודש
-- ======================================================

SELECT 
    mt.Technician_ID,  -- מזהה הטכנאי
    mt.Full_Name,  -- שם הטכנאי
    mt.Professional_Certifications,  -- תעודות מקצועיות של הטכנאי
    COUNT(em.Malfunction_ID) AS Total_Severe_Malfunctions,  -- מספר התקלות החמורות שהטכנאי טיפל בהן
    EXTRACT(MONTH FROM em.Report_Date) AS Malfunction_Month,  -- חודש התרחשות התקלה
    EXTRACT(YEAR FROM em.Report_Date) AS Malfunction_Year,  -- שנה התרחשות התקלה
    (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM mt.Last_Certification_Date)) AS Years_Since_Last_Certification,  -- מספר השנים מאז שהטכנאי עדכן את תעודת ההסמכה שלו
    SUM(CASE WHEN em.Repair_Status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Repairs,  -- מספר התיקונים שהושלמו
    SUM(CASE WHEN em.Repair_Status = 'In Progress' THEN 1 ELSE 0 END) AS Ongoing_Repairs  -- מספר התיקונים שעדיין בתהליך
FROM 
    Maintenance_Technician mt  -- טבלת טכנאים
LEFT JOIN 
    Equipment_Malfunction em ON mt.Technician_ID = em.Technician_ID  -- חיבור לטבלת תקלות ציוד לפי מזהה הטכנאי
WHERE 
    (em.Malfunction_Severity = 'Critical' OR em.Malfunction_Severity = 'High')  -- הרחבת הסינון לכלול גם תקלות ברמת חומרה גבוהה
    AND em.Report_Date >= (CURRENT_DATE - INTERVAL '2 years')  -- הרחבת טווח הזמן ל-2 שנים אחרונות
GROUP BY 
    mt.Technician_ID, mt.Full_Name, mt.Professional_Certifications, Malfunction_Month, Malfunction_Year  -- קיבוץ לפי פרטי טכנאי, חודש ושנה
HAVING 
    COUNT(em.Malfunction_ID) > 0  -- מוודא שיש לפחות תקלה אחת
ORDER BY 
    Total_Severe_Malfunctions DESC, Malfunction_Month;  -- מיון לפי מספר התקלות החמורות ופי חודש

-- ======================================================
-- 3. שאילתא המציגה את הטכנאים שטיפלו במספר הרב ביותר של סוגי ציוד שונים
-- כולל מספר היחידות שטופלו ומספר תיקונים שהושלמו בפועל
-- ======================================================

SELECT 
    mt.Technician_ID,  -- מזהה ייחודי של הטכנאי מתוך טבלת Maintenance_Technician

    mt.Full_Name,  -- שם מלא של הטכנאי (לצורך תצוגה ברורה)

    COUNT(DISTINCT e.Equipment_Type) AS Unique_Equipment_Types,
    -- סופרת כמה סוגים שונים של ציוד (לפי Equipment_Type) טופלו ע"י הטכנאי
    -- השימוש ב-DISTINCT מונע ספירה כפולה של אותו סוג

    COUNT(DISTINCT em.Equipment_ID) AS Total_Equipment_Units,
    -- סופרת כמה יחידות ציוד שונות (לפי Equipment_ID) טופלו ע"י הטכנאי
    -- נותן תמונה של כמות המכשירים ולא רק הסוגים

    SUM(CASE WHEN em.Repair_Status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Repairs
    -- סכימה של מספר התיקונים שהסטטוס שלהם הוא "הושלם" (Completed)
    -- אם התיקון הושלם – נספור 1, אחרת 0

FROM 
    Maintenance_Technician mt
    -- טבלת הטכנאים – מכילה נתוני זיהוי, שמות, הסמכות מקצועיות וכדומה

JOIN 
    Equipment_Malfunction em ON mt.Technician_ID = em.Technician_ID
    -- מצרפים את טבלת התקלות, כך שלכל טכנאי נקבל את התקלות שהוא טיפל בהן

JOIN 
    Equipment e ON em.Equipment_ID = e.Equipment_ID
    -- מצרפים גם את טבלת הציוד כדי לדעת איזה סוג ציוד כל תקלה מייצגת

GROUP BY 
    mt.Technician_ID, mt.Full_Name
    -- מקבצים את הנתונים לפי כל טכנאי (מזהה + שם), כדי לחשב עבורו סיכומים

ORDER BY 
    Unique_Equipment_Types DESC,  -- קודם כל לפי מגוון סוגי ציוד (יורד)
    Completed_Repairs DESC        -- ואם יש שוויון – לפי מספר תיקונים שהושלמו
;


-- ======================================================
-- 4. שאילתא המציגה את התאמת הציוד לסטנדרטים שלהם, כולל אחוז המעבר בבדיקות בטיחות
-- ======================================================

SELECT 
    e.Equipment_Type,  -- סוג הציוד
    ss.Standard_Level,  -- רמת הסטנדרט הבטיחותי
    COUNT(DISTINCT e.Equipment_ID) AS Equipment_Count,  -- מספר הציוד המתואם לסטנדרט
    AVG(CURRENT_DATE - e.Installation_Date) AS Avg_Days_Since_Installation,  -- ממוצע הימים מאז התקנת הציוד
    COUNT(DISTINCT sc.Check_ID) AS Total_Safety_Checks,  -- מספר הבדיקות הבטיחותיות
    ROUND(
        COUNT(DISTINCT sc.Check_ID) FILTER (WHERE sc.Result = 'Passed') * 100.0 / 
        NULLIF(COUNT(DISTINCT sc.Check_ID), 0),  -- חישוב אחוז המעבר בבדיקות בטיחות
        2
    ) AS Pass_Rate_Percentage,  -- אחוז המעבר בבדיקות בטיחות
    TO_CHAR(MAX(e.Installation_Date), 'YYYY-MM') AS Most_Recent_Installation,  -- התאריך האחרון בו הותקן ציוד
    TO_CHAR(MIN(e.Installation_Date), 'YYYY-MM') AS Oldest_Installation  -- התאריך הראשון בו הותקן ציוד
FROM 
    Equipment e  -- טבלת ציוד
JOIN 
    Safety_Standard ss ON e.Standard_ID = ss.Standard_ID  -- חיבור לטבלת סטנדרטים בטיחותיים לפי מזהה הסטנדרט
LEFT JOIN 
    Safety_Check sc ON e.Equipment_ID = sc.Equipment_ID  -- חיבור לטבלת בדיקות בטיחות לפי מזהה הציוד
GROUP BY 
    e.Equipment_Type, ss.Standard_Level  -- קיבוץ לפי סוג הציוד ורמת הסטנדרט
HAVING 
    COUNT(DISTINCT e.Equipment_ID) > 1  -- סינון ציוד לפי כמות הציוד
ORDER BY 
    Pass_Rate_Percentage DESC, Equipment_Count DESC;  -- מיון לפי אחוז המעבר והכמות


-- ================================================
-- 5. דוח מצב בטיחות חודשי לפי סוג ציוד וחומרת תקלה
-- ================================================

-- השאילתה הפנימית מחשבת את מספר התקלות החודשיות, תקלות שטופלו, ממוצע זמן פתיחת תקלה
-- לפי סוג ציוד וחומרת תקלה ב-12 חודשים האחרונים
-- לאחר מכן, השאילתה הראשית מוסיפה גם את מספר הטכנאים המעורבים

SELECT 
    monthly_data.Report_Month,              -- חודש הדיווח
    monthly_data.Report_Year,               -- שנת הדיווח
    monthly_data.Equipment_Type,            -- סוג הציוד
    monthly_data.Malfunction_Severity,      -- חומרת התקלה
    monthly_data.Malfunction_Count,         -- מספר תקלות באותו חודש/סוג/חומרה
    monthly_data.Completed_Repairs,         -- כמה תקלות מתוך זה טופלו
    monthly_data.Avg_Days_Open,             -- כמה ימים בממוצע תקלה נשארה פתוחה
    (SELECT COUNT(DISTINCT mt.Technician_ID)
     FROM Maintenance_Technician mt
     JOIN Equipment_Malfunction em2 ON mt.Technician_ID = em2.Technician_ID
     WHERE EXTRACT(MONTH FROM em2.Report_Date) = monthly_data.Report_Month 
       AND EXTRACT(YEAR FROM em2.Report_Date) = monthly_data.Report_Year
       AND em2.Malfunction_Severity = monthly_data.Malfunction_Severity
    ) AS Technicians_Involved               -- מספר טכנאים שטיפלו בתקלות דומות באותו חודש
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
        em.Report_Date >= (CURRENT_DATE - INTERVAL '12 months')  -- רק תקלות מהשנה האחרונה
    GROUP BY 
        Report_Month, Report_Year, e.Equipment_Type, em.Malfunction_Severity
) AS monthly_data
ORDER BY 
    monthly_data.Report_Year DESC,
    monthly_data.Report_Month DESC,
    monthly_data.Malfunction_Count DESC;
-- ===========================================================
-- שאילתא מספר 6: ציוד בסיכון גבוה - זיהוי "נקודות חמות" בטיחותיות
-- ===========================================================

-- מטרת השאילתה: זיהוי ציוד שנמצא בסיכון גבוה לכשל על בסיס שילוב של:
-- 1. טכנאים עם הסמכה שפגה (מעל 90 יום)
-- 2. היעדר בדיקות עדכניות (מעל 180 יום) או כשלון בבדיקה אחרונה
-- 3. היסטוריית תקלות קיימת
-- השאילתה מחשבת "ציון סיכון" משוקלל לכל פריט ציוד ומציגה את בעלי הסיכון הגבוה ביותר

WITH Equipment_Safety_History AS (
    -- מחשב סטטיסטיקות בטיחות ומידע על בדיקות עבור כל פריט ציוד
    -- כולל: מספר בדיקות, מספר כשלונות, תאריך בדיקה אחרונה, זמן מאז בדיקה אחרונה
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
    -- מחשב מידע על הסמכות טכנאים: זמן מאז הסמכה, סטטוס הסמכה
    SELECT 
        mt.Technician_ID,
        mt.Full_Name,
        mt.Professional_Certifications,
        mt.Last_Certification_Date,
        CURRENT_DATE - mt.Last_Certification_Date AS Days_Since_Certification,
        CASE
            WHEN CURRENT_DATE - mt.Last_Certification_Date > 365 THEN 'פג תוקף מעל שנה'
            WHEN CURRENT_DATE - mt.Last_Certification_Date > 180 THEN 'פג תוקף מעל חצי שנה'
            ELSE 'בתוקף או פג לאחרונה'
        END AS Certification_Status
    FROM 
        Maintenance_Technician mt
    WHERE 
        mt.Last_Certification_Date IS NOT NULL  -- רק טכנאים עם תאריכי הסמכה
),

Equipment_Malfunction_History AS (
    -- מחשב סטטיסטיקות תקלות עבור כל פריט ציוד
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

-- השאילתה הראשית: משלבת את כל המידע ומחשבת ציון סיכון משוקלל
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
    -- חישוב "ציון סיכון" משוקלל מחדש - נוסחה מותאמת שלא מסתמכת על אחוז כשלונות
    ROUND(
        (COALESCE(esh.Days_Since_Last_Check, 365) * 0.3 / 365) +  -- משקל 30% למספר ימים מאז בדיקה אחרונה
        (tcs.Days_Since_Certification * 0.3 / 365) +  -- משקל 30% למספר ימים מאז הסמכה אחרונה
        (COALESCE(emh.Total_Malfunctions, 0) * 5 * 0.2) +  -- משקל 20% למספר התקלות הכולל
        (COALESCE(emh.Critical_Malfunctions, 0) * 10 * 0.1) +  -- משקל 10% למספר תקלות קריטיות
        (CASE WHEN esh.Safety_Status = 'Failed' THEN 25 ELSE 0 END)  -- תוספת של 25 נקודות אם הסטטוס נכשל
    , 2) AS Risk_Score
FROM 
    Equipment_Safety_History esh
JOIN 
    -- מקשר לטכנאים שטיפלו בציוד זה (הם בהכרח מופיעים בטבלת התקלות)
    Technician_Certification_Status tcs ON tcs.Technician_ID IN (
        SELECT DISTINCT em.Technician_ID 
        FROM Equipment_Malfunction em 
        WHERE em.Equipment_ID = esh.Equipment_ID
    )
LEFT JOIN 
    Equipment_Malfunction_History emh ON esh.Equipment_ID = emh.Equipment_ID
WHERE 
    tcs.Days_Since_Certification > 90  -- טכנאים שהסמכתם פגה לפני יותר מ-90 יום
    AND (
        esh.Days_Since_Last_Check > 180  -- ציוד שלא נבדק יותר מחצי שנה
        OR esh.Safety_Status = 'Failed'  -- או ציוד שנכשל בבדיקת בטיחות אחרונה
        OR COALESCE(emh.Total_Malfunctions, 0) >= 1  -- או ציוד עם לפחות תקלה אחת
    )
ORDER BY 
    Risk_Score DESC  -- מיון לפי ציון הסיכון (מהגבוה לנמוך)
LIMIT 30;  -- מציג את 30 פריטי הציוד המסוכנים ביותר
-- ===============================================================
-- 7. קורלציה בין תדירות שימוש בתקלות שהתרחשו בחודש האחרון
-- ===============================================================

-- מטרת השאילתה: להציג קשר בין כמה פעמים ציוד שומש (ותוך כמה זמן)
-- לבין מספר התקלות שאירעו בו במהלך החודש האחרון בלבד.
-- מתבצעת חישוב של תקלות לשעת שימוש (Malfunctions_Per_Hour)
-- באמצעות תת-שאילתה המסננת רק ציוד שבאמת נעשה בו שימוש.

SELECT 
    usage_data.Equipment_ID,
    usage_data.Equipment_Name,
    usage_data.Equipment_Type,
    usage_data.Standard_Name,
    usage_data.Usage_Count_Last_Month,               -- כמה פעמים הציוד שומש החודש
    usage_data.Total_Usage_Minutes_Last_Month,       -- סה"כ דקות שימוש החודש
    usage_data.Malfunction_Count_Last_Month,         -- סה"כ תקלות החודש
    usage_data.Malfunctions_Per_Hour,                -- תקלות לשעת שימוש
    usage_data.Last_Usage_Date,                      -- תאריך שימוש אחרון
    usage_data.Last_Usage_Day,                       -- היום מתוך השימוש האחרון
    usage_data.Last_Usage_Month                      -- החודש של השימוש האחרון
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
    usage_data.Usage_Count_Last_Month > 0             -- ציוד שבאמת נעשה בו שימוש
ORDER BY 
    usage_data.Malfunctions_Per_Hour DESC,            -- תקלות לשעה – סדר יורד
    usage_data.Total_Usage_Minutes_Last_Month DESC;   -- אם זהה – לפי דקות שימוש


-- ========================================================
-- 8. מגמות עונתיות של תקלות ציוד לפי חודש וסוג ציוד
-- ========================================================

-- מטרת השאילתה: להפיק סטטיסטיקה לפי עונה, חודש וסוג ציוד
-- עבור תקלות שדווחו במהלך השנה האחרונה בלבד.
-- בנוסף, מחשבת ממוצע הימים שעברו בין התקנת ציוד לבדיקה בטיחותית באותו חודש.

SELECT 
    EXTRACT(YEAR FROM em.Report_Date) AS Report_Year,        -- שנת הדיווח
    EXTRACT(MONTH FROM em.Report_Date) AS Report_Month,      -- חודש הדיווח
    CASE 
        WHEN EXTRACT(MONTH FROM em.Report_Date) IN (12, 1, 2) THEN 'חורף'
        WHEN EXTRACT(MONTH FROM em.Report_Date) IN (3, 4, 5) THEN 'אביב'
        WHEN EXTRACT(MONTH FROM em.Report_Date) IN (6, 7, 8) THEN 'קיץ'
        ELSE 'סתיו'
    END AS Season,                                           -- קביעה ידנית של עונה
    e.Equipment_Type,
    COUNT(em.Malfunction_ID) AS Total_Malfunctions,          -- סה"כ תקלות באותו חודש
    COUNT(DISTINCT e.Equipment_ID) AS Affected_Equipment_Count, -- כמה ציודים שונים הושפעו
    ROUND(COUNT(em.Malfunction_ID) * 100.0 / (
        SELECT COUNT(*) 
        FROM Equipment_Malfunction 
        WHERE Report_Date >= (CURRENT_DATE - INTERVAL '1 year')
    ), 2) AS Percentage_Of_Annual_Malfunctions,              -- אחוז מתוך כלל תקלות השנה
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
    em.Report_Date >= (CURRENT_DATE - INTERVAL '1 year')     -- רק השנה האחרונה
GROUP BY 
    Report_Year, Report_Month, Season, e.Equipment_Type
ORDER BY 
    Report_Year, Report_Month, Total_Malfunctions DESC;


