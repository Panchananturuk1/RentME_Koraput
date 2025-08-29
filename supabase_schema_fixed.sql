-- Supabase Database Schema for RentME Koraput (Fixed Version)
-- Run these SQL commands in your Supabase SQL Editor
-- Note: JWT secret configuration is handled automatically by Supabase

-- Create users table
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    phone VARCHAR(20),
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('passenger', 'driver')),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    profile_image TEXT,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create drivers table for additional driver information
CREATE TABLE IF NOT EXISTS public.drivers (
    id UUID REFERENCES public.users(id) PRIMARY KEY,
    license_number VARCHAR(50) UNIQUE,
    vehicle_type VARCHAR(50),
    vehicle_model VARCHAR(100),
    vehicle_number VARCHAR(20) UNIQUE,
    vehicle_color VARCHAR(30),
    is_available BOOLEAN DEFAULT false,
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    rating DECIMAL(3, 2) DEFAULT 0.00,
    total_rides INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create rides table
CREATE TABLE IF NOT EXISTS public.rides (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    passenger_id UUID REFERENCES public.users(id) NOT NULL,
    driver_id UUID REFERENCES public.users(id),
    pickup_address TEXT NOT NULL,
    pickup_latitude DECIMAL(10, 8) NOT NULL,
    pickup_longitude DECIMAL(11, 8) NOT NULL,
    destination_address TEXT NOT NULL,
    destination_latitude DECIMAL(10, 8) NOT NULL,
    destination_longitude DECIMAL(11, 8) NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'started', 'completed', 'cancelled')),
    fare_amount DECIMAL(10, 2),
    distance_km DECIMAL(8, 2),
    duration_minutes INTEGER,
    payment_method VARCHAR(20) DEFAULT 'cash' CHECK (payment_method IN ('cash', 'card', 'upi', 'wallet')),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Create ratings table
CREATE TABLE IF NOT EXISTS public.ratings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ride_id UUID REFERENCES public.rides(id) NOT NULL,
    rater_id UUID REFERENCES public.users(id) NOT NULL,
    rated_id UUID REFERENCES public.users(id) NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create payments table
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ride_id UUID REFERENCES public.rides(id) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
    transaction_id VARCHAR(100),
    gateway_response JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'general',
    is_read BOOLEAN DEFAULT false,
    data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users(phone);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON public.users(user_type);
CREATE INDEX IF NOT EXISTS idx_drivers_available ON public.drivers(is_available);
CREATE INDEX IF NOT EXISTS idx_drivers_location ON public.drivers(current_latitude, current_longitude);
CREATE INDEX IF NOT EXISTS idx_rides_passenger ON public.rides(passenger_id);
CREATE INDEX IF NOT EXISTS idx_rides_driver ON public.rides(driver_id);
CREATE INDEX IF NOT EXISTS idx_rides_status ON public.rides(status);
CREATE INDEX IF NOT EXISTS idx_rides_created_at ON public.rides(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON public.notifications(is_read);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- RLS Policies for drivers table
CREATE POLICY "Drivers can view own data" ON public.drivers
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Drivers can update own data" ON public.drivers
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Drivers can insert own data" ON public.drivers
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Public can view available drivers" ON public.drivers
    FOR SELECT USING (is_available = true);

-- RLS Policies for rides table
CREATE POLICY "Users can view own rides" ON public.rides
    FOR SELECT USING (auth.uid() = passenger_id OR auth.uid() = driver_id);

CREATE POLICY "Passengers can create rides" ON public.rides
    FOR INSERT WITH CHECK (auth.uid() = passenger_id);

CREATE POLICY "Users can update own rides" ON public.rides
    FOR UPDATE USING (auth.uid() = passenger_id OR auth.uid() = driver_id);

-- RLS Policies for ratings table
CREATE POLICY "Users can view ratings" ON public.ratings
    FOR SELECT USING (auth.uid() = rater_id OR auth.uid() = rated_id);

CREATE POLICY "Users can create ratings" ON public.ratings
    FOR INSERT WITH CHECK (auth.uid() = rater_id);

-- RLS Policies for payments table
CREATE POLICY "Users can view own payments" ON public.payments
    FOR SELECT USING (
        auth.uid() IN (
            SELECT passenger_id FROM public.rides WHERE id = ride_id
            UNION
            SELECT driver_id FROM public.rides WHERE id = ride_id
        )
    );

-- RLS Policies for notifications table
CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- Create functions for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updating timestamps
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_drivers_updated_at BEFORE UPDATE ON public.drivers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rides_updated_at BEFORE UPDATE ON public.rides
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON public.payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to calculate ride fare
CREATE OR REPLACE FUNCTION calculate_ride_fare(
    distance_km DECIMAL,
    vehicle_type VARCHAR
)
RETURNS DECIMAL AS $$
DECLARE
    base_fare DECIMAL := 50.00;
    per_km_rate DECIMAL;
BEGIN
    -- Set per km rate based on vehicle type
    CASE vehicle_type
        WHEN 'auto' THEN per_km_rate := 12.00;
        WHEN 'bike' THEN per_km_rate := 8.00;
        WHEN 'car' THEN per_km_rate := 15.00;
        WHEN 'suv' THEN per_km_rate := 20.00;
        ELSE per_km_rate := 10.00;
    END CASE;
    
    RETURN base_fare + (distance_km * per_km_rate);
END;
$$ LANGUAGE plpgsql;

-- Create function to update driver rating
CREATE OR REPLACE FUNCTION update_driver_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.drivers 
    SET rating = (
        SELECT AVG(rating::DECIMAL) 
        FROM public.ratings 
        WHERE rated_id = NEW.rated_id
    )
    WHERE id = NEW.rated_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update driver rating when new rating is added
CREATE TRIGGER update_driver_rating_trigger
    AFTER INSERT ON public.ratings
    FOR EACH ROW
    EXECUTE FUNCTION update_driver_rating();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;