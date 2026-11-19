import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

class ShareHelper {
  /// Formats today's promise verse in both English and Tamil stacked together with church branding
  static String formatDailyVerseMessage({
    required String verseEn,
    required String verseTa,
    required String reference,
    required String dateFormatted,
  }) {
    return '''
✨ *TODAY'S PROMISE VERSE • இன்றைய வாக்குத்தத்தம்* ✨
📅 $dateFormatted

📖 *${reference.trim()}*

🇬🇧 "$verseEn"

🇮🇳 "$verseTa"

✝️ *${AppConstants.churchName}*
Senior Pastor: ${AppConstants.seniorPastor}
📍 ${AppConstants.churchLocation}

📺 Watch Live on YouTube:
${AppConstants.youtubeChannelUrl}
'''.trim();
  }

  /// 1-Tap WhatsApp Share: Opens WhatsApp directly with formatted message
  static Future<void> shareToWhatsApp({
    required BuildContext context,
    required String message,
  }) async {
    final encoded = Uri.encodeComponent(message);
    final whatsappUrl = Uri.parse('whatsapp://send?text=$encoded');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    // Fallback to web whatsapp / universal share
    final webWhatsappUrl = Uri.parse('https://api.whatsapp.com/send?text=$encoded');
    try {
      if (await canLaunchUrl(webWhatsappUrl)) {
        await launchUrl(webWhatsappUrl, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    // Universal Share Sheet fallback
    await Share.share(message, subject: "Today's Promise Verse");
  }

  /// Universal system share sheet
  static Future<void> shareGeneral({
    required String message,
    String? subject,
  }) async {
    await Share.share(message, subject: subject);
  }
}
