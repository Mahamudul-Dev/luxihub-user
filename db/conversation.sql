create table public.conversations (
  id uuid not null default gen_random_uuid (),
  job_request_id uuid not null,
  provider_id uuid not null,
  client_id uuid not null,
  last_message text null,
  last_message_at timestamp with time zone null,
  unread_count integer not null default 0,
  created_at timestamp with time zone not null default now(),
  constraint conversations_pkey primary key (id),
  constraint conversations_client_id_fkey foreign KEY (client_id) references profiles (id) on delete CASCADE,
  constraint conversations_job_request_id_fkey foreign KEY (job_request_id) references job_requests (id) on delete CASCADE,
  constraint conversations_provider_id_fkey foreign KEY (provider_id) references profiles (id) on delete CASCADE
) TABLESPACE pg_default;