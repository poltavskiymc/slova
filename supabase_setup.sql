-- Supabase Database Setup for Slova App
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================================
-- SYSTEM DATA TABLES (Base content)
-- ===========================================

-- System categories table
CREATE TABLE IF NOT EXISTS system_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- System words table
CREATE TABLE IF NOT EXISTS system_words (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_id UUID REFERENCES system_categories(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  difficulty TEXT NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- USER TABLES
-- ===========================================

-- User profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- OAuth info
  provider TEXT,
  provider_id TEXT,
  avatar_url TEXT,

  -- Display info
  display_name TEXT,
  first_name TEXT,
  last_name TEXT,

  -- Preferences
  language TEXT DEFAULT 'ru',
  theme TEXT DEFAULT 'system',
  sound_enabled BOOLEAN DEFAULT true,
  notifications_enabled BOOLEAN DEFAULT true,

  -- Stats
  games_played INTEGER DEFAULT 0,
  total_score INTEGER DEFAULT 0,
  favorite_difficulty TEXT DEFAULT 'medium',
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Monetization
  subscription_status TEXT DEFAULT 'free',
  subscription_expires_at TIMESTAMP WITH TIME ZONE,
  ads_disabled BOOLEAN DEFAULT false,

  -- Sync
  last_sync_at TIMESTAMP WITH TIME ZONE,
  sync_enabled BOOLEAN DEFAULT true,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- USER OVERRIDES TABLES
-- ===========================================

-- User category overrides
CREATE TABLE IF NOT EXISTS user_category_overrides (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  system_category_id UUID REFERENCES system_categories(id) ON DELETE CASCADE,

  -- Overrides
  custom_name TEXT,
  is_hidden BOOLEAN DEFAULT false,
  custom_order INTEGER,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(user_id, system_category_id)
);

-- User word overrides
CREATE TABLE IF NOT EXISTS user_word_overrides (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  system_word_id UUID REFERENCES system_words(id) ON DELETE CASCADE,

  -- Overrides
  custom_text TEXT,
  custom_difficulty TEXT,
  is_deleted BOOLEAN DEFAULT false,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(user_id, system_word_id)
);

-- ===========================================
-- USER CUSTOM DATA TABLES
-- ===========================================

-- User custom categories
CREATE TABLE IF NOT EXISTS user_custom_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User custom words
CREATE TABLE IF NOT EXISTS user_custom_words (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  custom_category_name TEXT,
  text TEXT NOT NULL,
  difficulty TEXT NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===========================================
-- INDEXES
-- ===========================================

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_system_words_category_id ON system_words(category_id);
CREATE INDEX IF NOT EXISTS idx_user_category_overrides_user_id ON user_category_overrides(user_id);
CREATE INDEX IF NOT EXISTS idx_user_word_overrides_user_id ON user_word_overrides(user_id);
CREATE INDEX IF NOT EXISTS idx_user_custom_words_user_id ON user_custom_words(user_id);
CREATE INDEX IF NOT EXISTS idx_user_custom_categories_user_id ON user_custom_categories(user_id);

-- ===========================================
-- ROW LEVEL SECURITY (RLS)
-- ===========================================

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_category_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_word_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_custom_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_custom_words ENABLE ROW LEVEL SECURITY;

-- Users can read/write their own data
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own category overrides" ON user_category_overrides
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own word overrides" ON user_word_overrides
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own custom categories" ON user_custom_categories
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own custom words" ON user_custom_words
  FOR ALL USING (auth.uid() = user_id);

-- System data is readable by all authenticated users
CREATE POLICY "Authenticated users can view system categories" ON system_categories
  FOR SELECT TO authenticated USING (is_active = true);

CREATE POLICY "Authenticated users can view system words" ON system_words
  FOR SELECT TO authenticated USING (true);

-- ===========================================
-- TRIGGERS
-- ===========================================

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    provider,
    provider_id,
    display_name,
    first_name,
    last_name,
    avatar_url
  )
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'provider',
    NEW.raw_user_meta_data->>'provider_id',
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'name',
      NEW.email
    ),
    NEW.raw_user_meta_data->>'first_name',
    NEW.raw_user_meta_data->>'last_name',
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_category_overrides_updated_at
  BEFORE UPDATE ON user_category_overrides
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_word_overrides_updated_at
  BEFORE UPDATE ON user_word_overrides
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===========================================
-- SAMPLE DATA (for testing)
-- ===========================================

-- Insert sample system categories
INSERT INTO system_categories (name, description) VALUES
  ('Животные', 'Названия различных животных'),
  ('Предметы', 'Обычные предметы быта'),
  ('Профессии', 'Названия профессий')
ON CONFLICT DO NOTHING;

-- Insert sample system words
INSERT INTO system_words (category_id, text, difficulty) VALUES
  ((SELECT id FROM system_categories WHERE name = 'Животные'), 'кошка', 'easy'),
  ((SELECT id FROM system_categories WHERE name = 'Животные'), 'собака', 'easy'),
  ((SELECT id FROM system_categories WHERE name = 'Животные'), 'корова', 'easy'),
  ((SELECT id FROM system_categories WHERE name = 'Предметы'), 'стол', 'easy'),
  ((SELECT id FROM system_categories WHERE name = 'Предметы'), 'стул', 'easy'),
  ((SELECT id FROM system_categories WHERE name = 'Профессии'), 'врач', 'medium'),
  ((SELECT id FROM system_categories WHERE name = 'Профессии'), 'учитель', 'medium')
ON CONFLICT DO NOTHING;
