CREATE OR REPLACE FUNCTION auto_log_malfunction_on_failed_check()
RETURNS trigger AS $$
DECLARE
    tech RECORD;
    new_id TEXT;
BEGIN
    IF NEW.result = 'Fail' THEN
        -- בוחר טכנאי רנדומלי לתיקון
        SELECT * INTO tech
        FROM maintenance_technician
        ORDER BY RANDOM()
        LIMIT 1;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'No technician found to assign malfunction.';
        END IF;

        new_id := 'MALF_' || NEW.check_id || '_' || EXTRACT(EPOCH FROM now())::BIGINT;

        INSERT INTO equipment_malfunction (
            malfunction_id,
            report_date,
            malfunction_severity,
            repair_status,
            equipment_id,
            technician_id
        ) VALUES (
            new_id,
            CURRENT_DATE,
            'Medium',
            'Pending',
            NEW.equipment_id,
            tech.technician_id
        );

        RAISE NOTICE 'Auto-logged malfunction % for equipment % by technician %',
            new_id, NEW.equipment_id, tech.technician_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
