-- ================================================
-- פקודה 1: עדכון סטטוס בטיחות של ציוד
-- ================================================

-- מטרת הפקודה: לעדכן את שדה ה-Safety_Status בטבלת הציוד (Equipment),
-- לפי תוצאת בדיקת הבטיחות האחרונה שבוצעה על הציוד.
-- התוצאה האפשרית היא אחת מתוך:
-- 'UNSAFE' – אם הבדיקה האחרונה נכשלה.
-- 'SAFE' – אם הבדיקה האחרונה עברה בהצלחה ונעשתה ב-3 חודשים האחרונים.
-- 'REQUIRES_INSPECTION' – אם אין בדיקה תקפה או שהתוצאה לא עומדת בקריטריונים.
UPDATE Equipment
SET Safety_Status = 
    CASE 
        -- תנאי 1: ציוד מסומן כ-UNSAFE אם הבדיקה האחרונה שלו נכשלה
        WHEN Equipment_ID IN (
            SELECT e.Equipment_ID
            FROM Equipment e
            JOIN Safety_Check sc ON e.Equipment_ID = sc.Equipment_ID
            WHERE sc.Inspection_Date = (
                -- מאתרים את תאריך הבדיקה האחרון עבור כל ציוד
                SELECT MAX(Inspection_Date)
                FROM Safety_Check
                WHERE Equipment_ID = e.Equipment_ID
            )
            AND sc.Result = 'FAIL'  -- תוצאה נכשלה
        ) THEN 'UNSAFE'

        -- תנאי 2: ציוד מסומן כ-SAFE אם הבדיקה האחרונה עברה והיא עדכנית (3 חודשים אחרונים)
        WHEN Equipment_ID IN (
            SELECT e.Equipment_ID
            FROM Equipment e
            JOIN Safety_Check sc ON e.Equipment_ID = sc.Equipment_ID
            WHERE sc.Inspection_Date = (
                SELECT MAX(Inspection_Date)
                FROM Safety_Check
                WHERE Equipment_ID = e.Equipment_ID
            )
            AND sc.Result = 'PASS'  -- תוצאה עברה
            AND sc.Inspection_Date > (CURRENT_DATE - INTERVAL '3 months')  -- בדיקה בוצעה לאחרונה
        ) THEN 'SAFE'

        -- תנאי 3: בכל מקרה אחר – הציוד נדרש לבדיקה נוספת
        ELSE 'REQUIRES_INSPECTION'
    END;

-- ================================================
-- פקודה 2: עדכון חומרת תקלות ציוד לפי משך שימוש ממוצע
-- ================================================

-- מטרת הפקודה: לעדכן את רמת חומרת התקלה (Malfunction_Severity) בטבלת Equipment_Malfunction
-- לפי משך השימוש הממוצע בציוד מתוך טבלת Equipment_Usage.
-- החומרה נקבעת כך:
-- HIGH – אם משך שימוש ממוצע בציוד גבוה מ-3 שעות (180 דקות).
-- MEDIUM – אם בין שעה ל-3 שעות (60 עד 180 דקות).
-- LOW – אם פחות משעה (ברירת מחדל).
-- הפקודה לא משפיעה על תקלות שתוקנו (Repair_Status = 'COMPLETED').
UPDATE Equipment_Malfunction
SET Malfunction_Severity = 
    CASE 
        -- ציוד עם שימוש ממוצע של יותר מ-180 דקות – חומרה גבוהה
        WHEN Equipment_ID IN (
            SELECT eu.Equipment_ID
            FROM Equipment_Usage eu
            GROUP BY eu.Equipment_ID
            HAVING AVG(eu.Usage_Duration) > 180
        ) THEN 'HIGH'

        -- ציוד עם שימוש ממוצע של 60 עד 180 דקות – חומרה בינונית
        WHEN Equipment_ID IN (
            SELECT eu.Equipment_ID
            FROM Equipment_Usage eu
            GROUP BY eu.Equipment_ID
            HAVING AVG(eu.Usage_Duration) BETWEEN 60 AND 180
        ) THEN 'MEDIUM'

        -- כל שאר המקרים – חומרה נמוכה
        ELSE 'LOW'
    END
-- תנאי סינון: לעדכן רק תקלות שעדיין לא הושלמה התיקון שלהן
WHERE Repair_Status != 'COMPLETED';

-- ================================================
-- פקודה 3: עדכון תאריך ההסמכה האחרון של טכנאים
-- ================================================

-- מטרת הפקודה: לעדכן את תאריך ההסמכה האחרון של טכנאים (Last_Certification_Date)
-- על סמך מספר התיקונים המוצלחים שביצעו בשנה האחרונה.
-- הלוגיקה היא:
-- טכנאי שביצע מעל 10 תיקונים בשנה האחרונה → ההסמכה מתעדכנת להיום.
-- טכנאי שביצע בין 5 ל-10 תיקונים → מוסיפים חצי שנה להסמכה הקיימת.
-- טכנאי עם פחות מ-5 תיקונים → אין שינוי.
UPDATE Maintenance_Technician
SET Last_Certification_Date = 
    CASE 
        -- טכנאי עם יותר מ-10 תיקונים מוצלחים בשנה האחרונה – חידוש הסמכה להיום
        WHEN Technician_ID IN (
            SELECT em.Technician_ID
            FROM Equipment_Malfunction em
            WHERE em.Repair_Status = 'COMPLETED'
            AND em.Report_Date > (CURRENT_DATE - INTERVAL '1 year')
            GROUP BY em.Technician_ID
            HAVING COUNT(*) > 10
        ) THEN CURRENT_DATE

        -- טכנאי עם בין 5 ל-10 תיקונים – מוסיפים חצי שנה להסמכה הקיימת
        WHEN Technician_ID IN (
            SELECT em.Technician_ID
            FROM Equipment_Malfunction em
            WHERE em.Repair_Status = 'COMPLETED'
            AND em.Report_Date > (CURRENT_DATE - INTERVAL '1 year')
            GROUP BY em.Technician_ID
            HAVING COUNT(*) BETWEEN 5 AND 10
        ) THEN Last_Certification_Date + INTERVAL '6 months'

        -- טכנאי עם פחות מ-5 תיקונים – אין שינוי
        ELSE Last_Certification_Date
    END;
