-- ================================================
-- פקודה 1: מחיקת טכנאים שלא ביצעו תיקונים מוצלחים בשנה האחרונה
-- ================================================

-- שלב ראשון: מחיקת תקלות שבהן מופיעים טכנאים שלא ביצעו תיקונים מוצלחים בשנה האחרונה
-- (על מנת למנוע שגיאות של foreign key בעת מחיקת הטכנאים עצמם)
DELETE FROM Equipment_Malfunction
WHERE Technician_ID IN (
    SELECT Technician_ID
    FROM Maintenance_Technician
    WHERE Technician_ID NOT IN (
        -- מאתרים את כל הטכנאים שביצעו לפחות תיקון אחד מוצלח בשנה האחרונה
        SELECT Technician_ID
        FROM Equipment_Malfunction
        WHERE Report_Date > (CURRENT_DATE - INTERVAL '1 year')  -- מתוך השנה האחרונה
        AND Repair_Status = 'COMPLETED'                         -- תיקון הושלם
    )
);

-- שלב שני: מחיקת טכנאים שאינם מופיעים עוד ברשימת התקלות
-- כלומר, טכנאים שאין להם אף רשומת תקלה מקושרת – לאחר שהרשומות נמחקו בשלב הקודם
DELETE FROM Maintenance_Technician
WHERE Technician_ID NOT IN (
    SELECT Technician_ID
    FROM Equipment_Malfunction
);
-- ================================================
-- פקודה 2: מחיקת בדיקות בטיחות ישנות שבוצעו לציוד שכבר לא בשימוש
-- ================================================

-- הפקודה מוחקת בדיקות בטיחות שבוצעו לפני יותר מ־2 שנים,
-- **רק אם הציוד שאליו הן שייכות לא היה בשימוש בשנה האחרונה**
DELETE FROM Safety_Check
WHERE Inspection_Date < (CURRENT_DATE - INTERVAL '2 years')  -- בדיקה ישנה (לפני יותר מ־2 שנים)
AND Equipment_ID NOT IN (
    -- מזהים את הציוד שהיה בשימוש בשנה האחרונה
    SELECT DISTINCT Equipment_ID
    FROM Equipment_Usage
    WHERE Start_Time > (CURRENT_DATE - INTERVAL '1 year')  -- שימוש שבוצע ב־12 החודשים האחרונים
    GROUP BY Equipment_ID
    HAVING COUNT(*) > 0  -- ודא שהיו שימושים בפועל
);
-- ================================================
-- פקודה 3: מחיקת רשומות שימוש בציוד קצרות מ־15 דקות
-- ================================================

-- הפקודה מוחקת רשומות שימוש בציוד שהיו קצרות מאוד (פחות מ־15 דקות),
-- **שלא התרחשו בשלושת החודשים האחרונים**,
-- **ובלבד שאין להן קשר לתקלה שתועדה באותו פרק זמן**.

DELETE FROM Equipment_Usage
WHERE Usage_Duration < 15  -- שימוש קצר מ-15 דקות (נחשב זניח)
AND Start_Time < (CURRENT_DATE - INTERVAL '3 months')  -- שימוש ישן (לפני יותר מ-3 חודשים)
AND Equipment_ID NOT IN (
    -- ציוד שהיה מעורב בתקלה שתועדה בזמן הסמוך לשימוש
    SELECT Equipment_ID
    FROM Equipment_Malfunction
    WHERE Report_Date BETWEEN Start_Time AND (Start_Time + INTERVAL '1 day')  -- תקלה דווחה באותו היום של השימוש
);
