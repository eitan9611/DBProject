CREATE OR REPLACE FUNCTION check_equipment_standard()
RETURNS trigger AS $$
DECLARE
    std RECORD;
BEGIN
    SELECT * INTO std
    FROM safety_standard
    WHERE standard_id = NEW.standard_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Standard ID % does not exist in safety_standard.', NEW.standard_id;
    END IF;

    RAISE NOTICE 'Inserting equipment with standard % (%).', std.standard_id, std.standard_name;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------------

CREATE TRIGGER trg_check_equipment_standard
BEFORE INSERT OR UPDATE ON equipment
FOR EACH ROW
EXECUTE FUNCTION check_equipment_standard();
