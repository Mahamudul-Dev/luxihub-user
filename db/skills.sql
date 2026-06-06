create table public.skills (
  id uuid not null default gen_random_uuid (),
  profile_id uuid not null,
  name text not null,
  constraint skills_pkey primary key (id),
  constraint skills_profile_id_fkey foreign KEY (profile_id) references profiles (id) on delete CASCADE
) TABLESPACE pg_default;