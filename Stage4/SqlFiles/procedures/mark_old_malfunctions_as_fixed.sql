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
