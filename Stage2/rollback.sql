BEGIN TRANSACTION;

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

ROLLBACK;
