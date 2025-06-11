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
