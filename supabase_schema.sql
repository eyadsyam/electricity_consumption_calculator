-- ============================================
-- Electricity Tracker - Supabase Database Schema
-- ============================================
-- Project: Official Egyptian Electricity Consumption Calculator
-- Supabase URL: https://bmchbrtqsqmrlzthjdod.supabase.co
-- ============================================
-- 
-- IMPORTANT: OFFICIAL EGYPTIAN ELECTRICITY TARIFF SYSTEM
-- -------------------------------------------------------
-- This schema implements the OFFICIAL Egyptian residential
-- electricity billing system as mandated by:
-- - Ministry of Electricity and Renewable Energy (MOEE)
-- - Egyptian Electricity Holding Company (EEHC)
--
-- KEY PRINCIPLES:
-- 1. CUMULATIVE METER: Meter readings are cumulative (total lifetime consumption)
-- 2. BILLING CALCULATION: Bill = Current Reading - Previous Reading
-- 3. PROGRESSIVE SLABS: Consumption is distributed across tariff slabs sequentially
-- 4. FIXED DISCOUNT: 378 EGP discount for Slab 6 (651-1000 kWh/month)
--
-- OFFICIAL TARIFF SLABS (2024/2025):
-- Slab 1: 0-50 kWh      @ 0.68 EGP/kWh
-- Slab 2: 51-100 kWh    @ 0.78 EGP/kWh
-- Slab 3: 101-200 kWh   @ 0.95 EGP/kWh
-- Slab 4: 201-350 kWh   @ 1.55 EGP/kWh
-- Slab 5: 351-650 kWh   @ 1.95 EGP/kWh
-- Slab 6: 651-1000 kWh  @ 2.10 EGP/kWh (with 378 EGP discount)
-- Slab 7: >1000 kWh     @ 2.23 EGP/kWh
-- ============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 1. Users Table (extends Supabase auth.users)
-- ============================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    phone TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can only read/update their own data
CREATE POLICY "Users can view own data" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own data" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================
-- 2. Electricity Rates Table (Egyptian Tariffs 2024/2025)
-- ============================================
CREATE TABLE IF NOT EXISTS public.electricity_rates (
    id SERIAL PRIMARY KEY,
    range_start INTEGER NOT NULL,
    range_end INTEGER,
    price_per_kwh DECIMAL(10, 4) NOT NULL,
    tier_name TEXT NOT NULL,
    tier_color TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.electricity_rates ENABLE ROW LEVEL SECURITY;

-- Everyone can read rates (public data)
CREATE POLICY "Anyone can view electricity rates" ON public.electricity_rates
    FOR SELECT USING (true);

-- Insert Egyptian Electricity Tariffs (2024/2025) - Official EEHC Rates
INSERT INTO public.electricity_rates (range_start, range_end, price_per_kwh, tier_name, tier_color) VALUES
    (0, 50, 0.68, 'الشريحة الأولى - Tier 1', '#4CAF50'),
    (51, 100, 0.78, 'الشريحة الثانية - Tier 2', '#8BC34A'),
    (101, 200, 0.95, 'الشريحة الثالثة - Tier 3', '#FFC107'),
    (201, 350, 1.55, 'الشريحة الرابعة - Tier 4', '#FF9800'),
    (351, 650, 1.95, 'الشريحة الخامسة - Tier 5', '#FF5722'),
    (651, 1000, 2.10, 'الشريحة السادسة - Tier 6', '#F44336'),
    (1001, NULL, 2.23, 'الشريحة السابعة - Tier 7', '#9C27B0')
ON CONFLICT DO NOTHING;

-- ============================================
-- 3. User Devices Table
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    device_name TEXT NOT NULL,
    device_category TEXT NOT NULL,
    power_watts DECIMAL(10, 2) NOT NULL,
    usage_hours_per_day DECIMAL(5, 2) DEFAULT 0,
    icon_name TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;

-- Users can manage their own devices
CREATE POLICY "Users can view own devices" ON public.user_devices
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own devices" ON public.user_devices
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own devices" ON public.user_devices
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own devices" ON public.user_devices
    FOR DELETE USING (auth.uid() = user_id);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_user_devices_user_id ON public.user_devices(user_id);
CREATE INDEX IF NOT EXISTS idx_user_devices_active ON public.user_devices(is_active);

-- ============================================
-- 4. Meter Readings Table
-- ============================================
CREATE TABLE IF NOT EXISTS public.meter_readings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    reading_value DECIMAL(10, 2) NOT NULL,
    reading_date DATE NOT NULL,
    consumption_kwh DECIMAL(10, 2),
    estimated_cost DECIMAL(10, 2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.meter_readings ENABLE ROW LEVEL SECURITY;

-- Users can manage their own readings
CREATE POLICY "Users can view own readings" ON public.meter_readings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own readings" ON public.meter_readings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own readings" ON public.meter_readings
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own readings" ON public.meter_readings
    FOR DELETE USING (auth.uid() = user_id);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_meter_readings_user_id ON public.meter_readings(user_id);
CREATE INDEX IF NOT EXISTS idx_meter_readings_date ON public.meter_readings(reading_date DESC);

-- ============================================
-- 5. Budget Configurations Table
-- ============================================
CREATE TABLE IF NOT EXISTS public.budget_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
    monthly_budget_kwh DECIMAL(10, 2),
    monthly_budget_egp DECIMAL(10, 2),
    enable_budget_alerts BOOLEAN DEFAULT false,
    alert_threshold_percentage INTEGER DEFAULT 80,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.budget_configs ENABLE ROW LEVEL SECURITY;

-- Users can manage their own budget config
CREATE POLICY "Users can view own budget config" ON public.budget_configs
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own budget config" ON public.budget_configs
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own budget config" ON public.budget_configs
    FOR UPDATE USING (auth.uid() = user_id);

-- Create index
CREATE INDEX IF NOT EXISTS idx_budget_configs_user_id ON public.budget_configs(user_id);

-- ============================================
-- 6. Notifications Table
-- ============================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    notification_type TEXT NOT NULL, -- 'budget_alert', 'tier_change', 'reminder', 'info'
    is_read BOOLEAN DEFAULT false,
    action_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users can manage their own notifications
CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notifications" ON public.notifications
    FOR DELETE USING (auth.uid() = user_id);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON public.notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON public.notifications(created_at DESC);

-- ============================================
-- 7. Consumption History Table (Monthly Aggregates)
-- ============================================
CREATE TABLE IF NOT EXISTS public.consumption_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    month INTEGER NOT NULL CHECK (month >= 1 AND month <= 12),
    year INTEGER NOT NULL,
    total_kwh DECIMAL(10, 2) NOT NULL,
    total_cost_egp DECIMAL(10, 2) NOT NULL,
    average_daily_kwh DECIMAL(10, 2),
    tier_reached TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, month, year)
);

-- Enable RLS
ALTER TABLE public.consumption_history ENABLE ROW LEVEL SECURITY;

-- Users can view their own history
CREATE POLICY "Users can view own consumption history" ON public.consumption_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own consumption history" ON public.consumption_history
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_consumption_history_user_id ON public.consumption_history(user_id);
CREATE INDEX IF NOT EXISTS idx_consumption_history_date ON public.consumption_history(year DESC, month DESC);

-- ============================================
-- 8. Functions and Triggers
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_electricity_rates_updated_at BEFORE UPDATE ON public.electricity_rates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_devices_updated_at BEFORE UPDATE ON public.user_devices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meter_readings_updated_at BEFORE UPDATE ON public.meter_readings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_budget_configs_updated_at BEFORE UPDATE ON public.budget_configs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 9. Helper Functions
-- ============================================

-- Function to calculate electricity cost based on consumption
-- Implements Official Egyptian Residential Tariff (2024/2025)
-- Uses progressive cumulative slab system with fixed discount for Slab 6
CREATE OR REPLACE FUNCTION calculate_electricity_cost(kwh_consumed DECIMAL)
RETURNS DECIMAL AS $$
DECLARE
    total_cost DECIMAL := 0;
    remaining_kwh DECIMAL := kwh_consumed;
    slab_consumption DECIMAL;
    slab_capacity DECIMAL;
BEGIN
    -- Validate input
    IF kwh_consumed IS NULL OR kwh_consumed < 0 THEN
        RETURN 0;
    END IF;
    
    -- Slab 1: 0-50 kWh @ 0.68 EGP/kWh
    IF remaining_kwh > 0 THEN
        slab_capacity := 50;
        slab_consumption := LEAST(remaining_kwh, slab_capacity);
        total_cost := total_cost + (slab_consumption * 0.68);
        remaining_kwh := remaining_kwh - slab_consumption;
    END IF;
    
    -- Slab 2: 51-100 kWh @ 0.78 EGP/kWh
    IF remaining_kwh > 0 THEN
        slab_capacity := 50; -- 100 - 50
        slab_consumption := LEAST(remaining_kwh, slab_capacity);
        total_cost := total_cost + (slab_consumption * 0.78);
        remaining_kwh := remaining_kwh - slab_consumption;
    END IF;
    
    -- Slab 3: 101-200 kWh @ 0.95 EGP/kWh
    IF remaining_kwh > 0 THEN
        slab_capacity := 100; -- 200 - 100
        slab_consumption := LEAST(remaining_kwh, slab_capacity);
        total_cost := total_cost + (slab_consumption * 0.95);
        remaining_kwh := remaining_kwh - slab_consumption;
    END IF;
    
    -- Slab 4: 201-350 kWh @ 1.55 EGP/kWh
    IF remaining_kwh > 0 THEN
        slab_capacity := 150; -- 350 - 200
        slab_consumption := LEAST(remaining_kwh, slab_capacity);
        total_cost := total_cost + (slab_consumption * 1.55);
        remaining_kwh := remaining_kwh - slab_consumption;
    END IF;
    
    -- Slab 5: 351-650 kWh @ 1.95 EGP/kWh
    IF remaining_kwh > 0 THEN
        slab_capacity := 300; -- 650 - 350
        slab_consumption := LEAST(remaining_kwh, slab_capacity);
        total_cost := total_cost + (slab_consumption * 1.95);
        remaining_kwh := remaining_kwh - slab_consumption;
    END IF;
    
    -- Slab 6: 651-1000 kWh @ 2.10 EGP/kWh
    IF remaining_kwh > 0 THEN
        slab_capacity := 350; -- 1000 - 650
        slab_consumption := LEAST(remaining_kwh, slab_capacity);
        total_cost := total_cost + (slab_consumption * 2.10);
        remaining_kwh := remaining_kwh - slab_consumption;
    END IF;
    
    -- Slab 7: >1000 kWh @ 2.23 EGP/kWh
    IF remaining_kwh > 0 THEN
        total_cost := total_cost + (remaining_kwh * 2.23);
    END IF;
    
    -- CRITICAL: Apply fixed discount for Slab 6 (651-1000 kWh)
    -- Official Egyptian tariff rule
    IF kwh_consumed > 650 AND kwh_consumed <= 1000 THEN
        total_cost := total_cost - 378;
        -- Ensure cost doesn't go negative
        IF total_cost < 0 THEN
            total_cost := 0;
        END IF;
    END IF;
    
    RETURN ROUND(total_cost, 2);
END;
$$ LANGUAGE plpgsql;


-- Function to get current tier for consumption
CREATE OR REPLACE FUNCTION get_consumption_tier(kwh_consumed DECIMAL)
RETURNS TEXT AS $$
DECLARE
    tier_name TEXT;
BEGIN
    SELECT t.tier_name INTO tier_name
    FROM public.electricity_rates t
    WHERE kwh_consumed >= t.range_start 
      AND (t.range_end IS NULL OR kwh_consumed <= t.range_end)
    LIMIT 1;
    
    RETURN COALESCE(tier_name, 'Unknown Tier');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 10. Sample Data for Testing (Optional)
-- ============================================

-- Note: This section is commented out by default
-- Uncomment to insert sample data for testing

/*
-- Insert sample user (requires auth.users entry first)
INSERT INTO public.users (id, email, full_name) VALUES
    ('00000000-0000-0000-0000-000000000001', 'test@example.com', 'Test User')
ON CONFLICT DO NOTHING;

-- Insert sample devices
INSERT INTO public.user_devices (user_id, device_name, device_category, power_watts, usage_hours_per_day) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Living Room AC', 'AC', 1500, 8),
    ('00000000-0000-0000-0000-000000000001', 'Samsung Refrigerator', 'REFRIGERATOR', 150, 24),
    ('00000000-0000-0000-0000-000000000001', 'LG Smart TV', 'TELEVISION', 120, 5)
ON CONFLICT DO NOTHING;

-- Insert sample meter reading
INSERT INTO public.meter_readings (user_id, reading_value, reading_date, consumption_kwh) VALUES
    ('00000000-0000-0000-0000-000000000001', 1250.5, CURRENT_DATE, 250)
ON CONFLICT DO NOTHING;
*/

-- ============================================
-- 11. Views for Analytics
-- ============================================

-- View for monthly consumption summary
CREATE OR REPLACE VIEW monthly_consumption_summary AS
SELECT 
    user_id,
    DATE_TRUNC('month', reading_date) as month,
    SUM(consumption_kwh) as total_kwh,
    calculate_electricity_cost(SUM(consumption_kwh)) as total_cost,
    AVG(consumption_kwh) as avg_daily_kwh,
    COUNT(*) as reading_count
FROM public.meter_readings
GROUP BY user_id, DATE_TRUNC('month', reading_date);

-- View for device consumption estimates
CREATE OR REPLACE VIEW device_consumption_estimates AS
SELECT 
    id,
    user_id,
    device_name,
    device_category,
    power_watts,
    usage_hours_per_day,
    (power_watts * usage_hours_per_day / 1000) as daily_kwh,
    (power_watts * usage_hours_per_day / 1000 * 30) as monthly_kwh,
    calculate_electricity_cost((power_watts * usage_hours_per_day / 1000 * 30)) as estimated_monthly_cost
FROM public.user_devices
WHERE is_active = true;

-- ============================================
-- END OF SCHEMA
-- ============================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';
