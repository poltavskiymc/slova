# Supabase Integration Setup

## 🚀 Quick Start

### 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign up/Login to your account
4. Click "New project"
5. Fill in project details:
   - Name: `slova-app`
   - Database Password: Choose a strong password
   - Region: Select closest to your users

### 2. Get Project Credentials

1. Go to Settings → API
2. Copy:
   - Project URL
   - Project API Key (anon/public)

### 3. Configure Flutter App

1. Open `lib/config/supabase_config.dart`
2. Replace placeholder values:
```dart
static const String supabaseUrl = 'https://your-project-id.supabase.co';
static const String supabaseAnonKey = 'your-anon-key-here';
```

### 4. Setup Database

1. Go to Supabase Dashboard → SQL Editor
2. Copy and paste the contents of `supabase_setup.sql`
3. Click "Run" to execute the SQL

### 5. Configure Authentication

#### Google OAuth:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project or select existing
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs:
   - `https://your-project-id.supabase.co/auth/v1/callback`
6. In Supabase Dashboard:
   - Authentication → Providers → Google
   - Enable Google provider
   - Paste Client ID and Client Secret

#### VK OAuth (Optional):
1. Go to [VK Developers](https://vk.com/dev)
2. Create Standalone app
3. Get App ID and Secure Key
4. In Supabase Dashboard:
   - Authentication → Providers → Custom OAuth
   - Configure VK OAuth provider

### 6. Test Connection

Run the app and check console for any Supabase connection errors.

## 📋 Database Schema

### Tables Overview:

#### **System Data:**
- **`system_categories`** - Base categories (animals, objects, professions)
- **`system_words`** - Base words for each category (with difficulty levels)

#### **User Data:**
- **`profiles`** - Extended user profiles (extends `auth.users`)
- **`user_category_overrides`** - User modifications to system categories
- **`user_word_overrides`** - User modifications to system words
- **`user_custom_categories`** - Completely user-created categories
- **`user_custom_words`** - Completely user-created words

#### **Authentication:**
- **`auth.users`** - System auth table (managed by Supabase Auth)

### Key Features:

- **Row Level Security (RLS)** - Users can only access their own data
- **Automatic user profile creation** - Trigger creates profile on signup
- **Override system** - Users can modify system content without duplicating everything
- **Audit trail** - Created/updated timestamps on all tables

## 🔄 Data Synchronization

The app uses a hybrid approach:

1. **Local-first**: SQLite for offline functionality
2. **Sync on connection**: Upload changes when online
3. **Conflict resolution**: User chooses which version to keep

## 🔐 Security

- All tables have RLS enabled
- Users can only access their own data
- System data is read-only for authenticated users
- OAuth providers ensure secure authentication

## 🚀 Next Steps

1. Test authentication flow
2. Implement data synchronization
3. Add user profile management
4. Setup monetization features

## 📞 Support

If you encounter issues:
1. Check Supabase logs in Dashboard
2. Verify API keys are correct
3. Ensure RLS policies are properly configured
4. Check Flutter console for detailed error messages
