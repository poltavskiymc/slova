/// Supabase configuration
class SupabaseConfig {
  // TODO: Replace with your actual Supabase URL and anon key
  static const String supabaseUrl = 'https://uypdchzbamuhbncnxool.supabase.co';
  // static const String supabaseAnonKey =
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV5cGRjaHpiYW11aGJuY254b29sIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MzQzMTgyMiwiZXhwIjoyMDc5MDA3ODIyfQ.8MivoaskEGVyfcbw3TL8po5ZJQith6w41Als_YxeNWg';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV5cGRjaHpiYW11aGJuY254b29sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0MzE4MjIsImV4cCI6MjA3OTAwNzgyMn0.g-98h_AQLUyoQPUNwqY5vMVLqoYxe3tCRgJkk5xk3bA';

  // Table names
  static const String tableProfiles = 'profiles';
  static const String tableSystemCategories = 'system_categories';
  static const String tableSystemWords = 'system_words';
  static const String tableUserCategoryOverrides = 'user_category_overrides';
  static const String tableUserWordOverrides = 'user_word_overrides';
  static const String tableUserCustomWords = 'user_custom_words';
  static const String tableUserCustomCategories = 'user_custom_categories';
}
