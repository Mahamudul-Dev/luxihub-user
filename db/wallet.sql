create table public.wallet (
  id uuid not null,
  balance double precision not null default 0.0,
  constraint wallet_pkey primary key (id),
  constraint wallet_id_fkey foreign KEY (id) references profiles (id) on delete CASCADE
) TABLESPACE pg_default;