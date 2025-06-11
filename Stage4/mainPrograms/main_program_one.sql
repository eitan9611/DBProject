DO $$
DECLARE
    cur refcursor;
    eq equipment%ROWTYPE;
BEGIN
    CALL mark_old_malfunctions_as_fixed();

    cur := get_equipment_needing_attention('dumbbells');
    LOOP
        FETCH cur INTO eq;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Equipment needing fix: %', eq.equipment_name;
    END LOOP;
    CLOSE cur;
END;
$$;
