import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/network/supabase_client.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend
  await SupabaseService.initialize();

  // Initialize Local Notifications & Sunday live reminders
  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: CityRevivalApp(),
    ),
  );
}
