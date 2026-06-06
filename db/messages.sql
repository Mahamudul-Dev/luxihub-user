create table public.messages (
  id uuid not null default gen_random_uuid (),
  conversation_id uuid not null,
  sender_id uuid not null,
  text text not null,
  created_at timestamp with time zone not null default now(),
  constraint messages_pkey primary key (id),
  constraint messages_conversation_id_fkey foreign KEY (conversation_id) references conversations (id) on delete CASCADE,
  constraint messages_sender_id_fkey foreign KEY (sender_id) references profiles (id) on delete CASCADE
) TABLESPACE pg_default;

create trigger on_message_created
after INSERT on messages for EACH row
execute FUNCTION handle_new_message ();