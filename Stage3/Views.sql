
 -- 1 --- 
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



-----------------------------------------------------


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
	
	
	
	-------------------------------------------------------------
	
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
-----------------------------------------------------------------------

-- 2 --- 
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
	-------------------------------------------------------------
	
	
	SELECT 
    program_name, 
    AVG(duration) AS average_duration
FROM 
    Training_Log_Summary
GROUP BY 
    program_name;



-----------------------------------------------------

SELECT *
FROM Training_Log_Summary
WHERE traineeid = 236779343;
