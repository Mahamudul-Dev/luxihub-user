create table public.profiles (
  id uuid not null,
  name text not null default ''::text,
  phone text null,
  email text null,
  dob text null,
  contract_type text null,
  hourly_rate double precision null,
  service_area text null,
  service_lat double precision null,
  service_lng double precision null,
  service_radius_km integer null,
  avatar_path text null,
  is_online boolean not null default false,
  is_kyc_verified boolean not null default false,
  created_at timestamp with time zone not null default now(),
  stripe_account_id text null,
  stripe_payouts_enabled boolean null default false,
  registration_completed_at timestamp with time zone null,
  constraint profiles_pkey primary key (id),
  constraint profiles_id_fkey foreign KEY (id) references auth.users (id) on delete CASCADE
) TABLESPACE pg_default;

create trigger on_profile_created
after INSERT on profiles for EACH row
execute FUNCTION handle_new_profile ();