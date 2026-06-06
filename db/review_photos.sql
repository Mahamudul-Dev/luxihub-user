create table public.review_photos (
  id uuid not null default gen_random_uuid (),
  review_id uuid not null,
  storage_path text not null,
  uploaded_at timestamp with time zone null default now(),
  constraint review_photos_pkey primary key (id),
  constraint review_photos_review_id_fkey foreign KEY (review_id) references reviews (id)
) TABLESPACE pg_default;