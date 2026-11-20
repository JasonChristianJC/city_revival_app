import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/network/supabase_client.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }

  // Initialize Local Notifications & Sunday live reminders on supported mobile platforms
  if (!kIsWeb) {
    try {
      await NotificationService.initialize();
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: CityRevivalApp(),
    ),
  );
}
