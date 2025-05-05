-- אילוץ CHECK עבור טבלת שימוש בציוד
ALTER TABLE Equipment_Usage
ADD CONSTRAINT check_usage_duration_positive CHECK (Usage_Duration > 0);

-- ערך ברירת מחדל לסטטוס תיקון
ALTER TABLE Equipment_Malfunction
ALTER COLUMN Repair_Status SET DEFAULT 'Pending';

ALTER TABLE Equipment
ADD CONSTRAINT check_installation_date_not_future
CHECK (Installation_Date <= CURRENT_DATE);

