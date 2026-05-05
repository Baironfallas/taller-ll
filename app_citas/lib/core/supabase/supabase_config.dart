import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://zqwjrojzhpiqocaelbbk.supabase.co';
  static const String anonKey =
      'sb_publishable_3Ci8o3ZQKpZ33yz6Zp3dMw_OnU6i5W_';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}
