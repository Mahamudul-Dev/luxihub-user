create table public.job_requests (
  id uuid not null default gen_random_uuid (),
  client_id uuid not null,
  provider_id uuid null,
  category text not null,
  description text not null,
  status text not null default 'pending'::text,
  client_lat double precision not null,
  client_lng double precision not null,
  amount double precision null,
  posted_at timestamp with time zone not null default now(),
  completed_at timestamp with time zone null,
  constraint job_requests_pkey primary key (id),
  constraint job_requests_client_id_fkey foreign KEY (client_id) references profiles (id) on delete CASCADE,
  constraint job_requests_provider_id_fkey foreign KEY (provider_id) references profiles (id) on delete set null,
  constraint job_requests_status_check check (
    (
      status = any (
        array[
          'pending'::text,
          'accepted'::text,
          'rejected'::text,
          'completed'::text
        ]
      )
    )
  )
) TABLESPACE pg_default;