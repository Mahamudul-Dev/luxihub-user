create table public.withdrawals (
  id uuid not null default gen_random_uuid (),
  profile_id uuid not null,
  amount double precision not null,
  bank_name text not null,
  account_last4 text not null,
  status text not null default 'pending'::text,
  created_at timestamp with time zone not null default now(),
  stripe_transfer_id text null,
  constraint withdrawals_pkey primary key (id),
  constraint withdrawals_profile_id_fkey foreign KEY (profile_id) references profiles (id) on delete CASCADE,
  constraint withdrawals_status_check check (
    (
      status = any (
        array[
          'pending'::text,
          'approved'::text,
          'rejected'::text
        ]
      )
    )
  )
) TABLESPACE pg_default;

create trigger on_withdrawal_approved
after
update on withdrawals for EACH row when (
  new.status = 'approved'::text
  and old.status is distinct from 'approved'::text
)
execute FUNCTION deduct_wallet_balance ();

create trigger on_withdrawal_approved_notify
after
update on withdrawals for EACH row when (
  new.status = 'approved'::text
  and old.status is distinct from 'approved'::text
)
execute FUNCTION notify_withdrawal_approved ();

create trigger trg_deduct_on_withdrawal
after INSERT on withdrawals for EACH row
execute FUNCTION deduct_balance_on_withdrawal ();

create trigger trg_refund_on_rejection
after
update on withdrawals for EACH row
execute FUNCTION refund_balance_on_rejection ();