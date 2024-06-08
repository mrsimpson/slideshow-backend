-- DROP FUNCTION public.send_reaction(int8);

CREATE OR REPLACE FUNCTION public.send_reaction(
    n_presentation int8,
    t_emoji text,
    t_user_alias text
)
    RETURNS generic_acknowledgement_type
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_acknowledgement generic_acknowledgement_type;
BEGIN
    -- Insert the event and return the inserted row
    INSERT INTO presentation_events (presentation, type, value, created_by, created_by_alias)
    VALUES (n_presentation, 'reaction', ('{"emoji": "' || t_emoji || '"}')::json, auth.uid(), t_user_alias)
    RETURNING 'presentation_events', id, created_at
        INTO v_acknowledgement;

    RETURN v_acknowledgement;
END ;
$$;
