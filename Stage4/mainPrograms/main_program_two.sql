DO $$
DECLARE
    percent FLOAT;
BEGIN
    CALL assign_equipment_to_exercise();

    percent := get_technician_efficiency('tech001');
    RAISE NOTICE 'Technician efficiency: %%%', percent;
END;
$$;
