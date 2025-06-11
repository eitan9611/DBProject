CREATE OR REPLACE FUNCTION get_technician_efficiency(tid VARCHAR)
RETURNS FLOAT AS $$
DECLARE
    total INT;
    fixed INT;
BEGIN
    SELECT COUNT(*) INTO total
    FROM equipment_malfunction
    WHERE technician_id = tid;

    IF total = 0 THEN
        RETURN 0;
    END IF;

    SELECT COUNT(*) INTO fixed
    FROM equipment_malfunction em
    JOIN equipment e ON e.equipment_id = em.equipment_id
    WHERE em.technician_id = tid AND e.safety_status = 'Fixed';

    RETURN (fixed::FLOAT / total) * 100;
END;
$$ LANGUAGE plpgsql;
