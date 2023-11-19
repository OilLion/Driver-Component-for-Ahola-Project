CREATE OR REPLACE FUNCTION insert_or_update_outstanding_delivery(
        IN delivery_id INT4,
        IN step INT4
    )
    RETURNS VOID AS $$
    BEGIN
        IF EXISTS(SELECT FROM outstandingupdates WHERE id = delivery_id) THEN
            UPDATE outstandingupdates
            SET current_step = step
            WHERE id = delivery_id
            AND current_step < step;
        ELSE
            INSERT INTO outstandingupdates (id, current_step)
            VALUES (delivery_id, step);
        END IF;
    END;
    $$ LANGUAGE plpgsql;  