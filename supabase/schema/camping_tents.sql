-- Camping tent facility schema and policies
-- Run this in Supabase SQL editor with service role privileges.

-- Extensions (Supabase has pgcrypto enabled by default for gen_random_uuid)

-- Tents catalog
CREATE TABLE IF NOT EXISTS public.tents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  capacity int NOT NULL DEFAULT 2,
  base_price numeric(10,2) NOT NULL,
  amenities text[] DEFAULT '{}',
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Bookings
CREATE TABLE IF NOT EXISTS public.tent_bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  tent_id uuid NOT NULL REFERENCES public.tents(id) ON DELETE RESTRICT,
  start_date date NOT NULL,
  end_date date NOT NULL,
  nights int NOT NULL,
  quantity int NOT NULL DEFAULT 1,
  total_price numeric(10,2) NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Ensure end_date >= start_date via constraint
ALTER TABLE public.tent_bookings
  ADD CONSTRAINT tent_bookings_valid_dates
  CHECK (end_date >= start_date AND nights > 0);

-- Row Level Security
ALTER TABLE public.tents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tent_bookings ENABLE ROW LEVEL SECURITY;

-- Policies: allow read of active tents to everyone
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'tents' AND policyname = 'tents_select_active'
  ) THEN
    CREATE POLICY tents_select_active ON public.tents
      FOR SELECT
      USING (active = true);
  END IF;
END$$;

-- Policies: bookings only by authenticated users on their own rows
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'tent_bookings' AND policyname = 'bookings_select_own'
  ) THEN
    CREATE POLICY bookings_select_own ON public.tent_bookings
      FOR SELECT
      USING (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'tent_bookings' AND policyname = 'bookings_insert_own'
  ) THEN
    CREATE POLICY bookings_insert_own ON public.tent_bookings
      FOR INSERT
      WITH CHECK (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'tent_bookings' AND policyname = 'bookings_update_own'
  ) THEN
    CREATE POLICY bookings_update_own ON public.tent_bookings
      FOR UPDATE
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;
END$$;

-- Seed some tent types (idempotent upserts)
INSERT INTO public.tents (id, name, description, capacity, base_price, amenities, active)
VALUES
  (gen_random_uuid(), 'Standard Tent', 'Affordable tent for 2 persons', 2, 999.00, ARRAY['sleeping_bag','lantern'], true),
  (gen_random_uuid(), 'Family Tent', 'Spacious tent for 4 persons', 4, 1799.00, ARRAY['sleeping_bag','lantern','mat'], true),
  (gen_random_uuid(), 'Luxury Tent', 'Premium tent with extra comfort', 2, 2499.00, ARRAY['bed','heater','lantern'], true)
ON CONFLICT DO NOTHING;