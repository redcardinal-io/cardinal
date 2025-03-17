-- Add migration script here

-- auth.users definition

create table if not exists auth.users (
  instance_id uuid not null,
  id uuid not null,
  aud varchar(255) not null,
  "role" varchar(255) not null,
  email varchar(255) not null,
  encrypted_password varchar(255) not null,
  confirmed_at timestamptz null,
  invited_at timestamptz null,
  confirmation_sent_at timestamptz null,
  confirmation_token varchar(255) null,
  recovery_sent_at timestamptz null,
  recovery_token varchar(255) null,
  email_change_sent_at timestamptz null,
  email_change_token varchar(255) null,
  email_change varchar(255) null,
  last_sign_in_at timestamptz null,
  raw_app_metadata jsonb null,
  raw_user_metadata jsonb null,
  is_super_admin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint users_pkey primary key (id)
);
create index if not exists users_instance_id_email_idx on auth.users (instance_id, email);
create index if not exists users_instance_id_idx on auth.users (instance_id);
comment on table auth.users is 'Auth: Stores user login data within a secure schema.';

-- auth.refresh_tokens definition
create table if not exists auth.refresh_tokens (
  instance_id uuid null,
  id bigserial not null,
  "token" varchar(255) not null,
  user_id uuid not null,
  revoked boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint refresh_tokens_pkey primary key (id)
);
create index if not exists refresh_tokens_instance_id_idx on auth.refresh_tokens (instance_id);
create index if not exists refresh_tokens_instance_id_user_id_idx on auth.refresh_tokens (instance_id, user_id);
create index if not exists refresh_tokens_token_idx on auth.refresh_tokens using btree ("token");
comment on table auth.refresh_tokens is 'Auth: Store of tokens to refresh JWT tokens once they expire.';

-- auth.instances definition

create table if not exists auth.instances (
  id uuid not null,
  uuid uuid null,
  raw_base_config text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint instances_pkey primary key (id)
);
comment on table auth.instances is 'Auth: Manages users across multiple sites.';

-- auth.audit_log_entries definition
create table if not exists auth.audit_log_entries (
  instance_id uuid null,
  id uuid not null,
  payload jsonb null,
  created_at timestamptz not null default now(),
  constraint audit_log_entries_pkey primary key (id)
);
create index if not exists audit_logs_instance_id_idx on auth.audit_log_entries (instance_id);
comment on table auth.audit_log_entries is 'Auth: Audit trail for user actions.';

-- auth.schema_migrations definition
create table if not exists auth.schema_migrations (
  "version" varchar(255) not null,
  constraint schema_migrations_pkey primary key ("version")
);
comment on table auth.schema_migrations is 'Auth: Manages updates to the auth system.';

-- Gets the User ID from the request cookie
create or replace function auth.uid() returns uuid as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$ language sql stable;

-- Gets the User Role from the request cookie
create or replace function auth.role() returns varchar as $$
  select nullif(current_setting('request.jwt.claim.role', true), '');
$$ language sql stable;
