create table public.reviews (
  id uuid not null default gen_random_uuid (),
  job_request_id uuid not null,
  client_id uuid not null,
  provider_id uuid not null,
  score numeric not null,
  comment text null,
  created_at timestamp with time zone null default now(),
  constraint reviews_pkey primary key (id),
  constraint reviews_client_id_fkey foreign KEY (client_id) references auth.users (id),
  constraint reviews_job_request_id_fkey foreign KEY (job_request_id) references job_requests (id),
  constraint reviews_provider_id_fkey foreign KEY (provider_id) references profiles (id),
  constraint reviews_score_check check (
    (
      (score >= (1)::numeric)
      and (score <= (5)::numeric)
    )
  )
) TABLESPACE pg_default;