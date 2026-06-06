create table public.job_attachments (
  id uuid not null default gen_random_uuid (),
  job_request_id uuid not null,
  storage_path text not null,
  constraint job_attachments_pkey primary key (id),
  constraint job_attachments_job_request_id_fkey foreign KEY (job_request_id) references job_requests (id) on delete CASCADE
) TABLESPACE pg_default;