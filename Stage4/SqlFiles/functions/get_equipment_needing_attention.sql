CREATE OR REPLACE FUNCTION get_equipment_needing_attention(e_type VARCHAR)
RETURNS refcursor AS $$
DECLARE
    ref refcursor;
BEGIN
    IF e_type IS NULL THEN
        RAISE EXCEPTION 'Equipment type must not be NULL';
    END IF;

    OPEN ref FOR
    SELECT * FROM equipment
    WHERE equipment_type = e_type
      AND safety_status IN ('NeedFix', 'NotWorking');

    RETURN ref;
END;
$$ LANGUAGE plpgsql;
