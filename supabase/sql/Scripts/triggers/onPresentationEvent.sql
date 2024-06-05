-- DROP FUNCTION handle_presentation_event_inserted()
create or replace function handle_presentation_event_inserted()
    returns trigger
    language plpgsql
as $$
begin
    raise log 'event handling triggered for %', new;
    if new.type = 'presentation_start' then
        update postgres.public.presentations set lc_status = 'started' where id = new.presentation;
    end if;
    if new.type = 'presentation_stop' then
        update postgres.public.presentations set lc_status = 'stopped' where id = new.presentation;
    end if;
    return new;
end;
$$;

-- drop trigger if exists after_presentation_event_inserted on postgres.public.presentation_events;

create or replace trigger after_presentation_event_inserted
    after insert on postgres.public.presentation_events
    for each row
execute function handle_presentation_event_inserted();
