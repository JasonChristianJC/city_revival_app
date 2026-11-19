import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

enum UpiAppType {
  googlePay,
  phonePe,
  paytm,
  generic,
}

class UpiHelper {
  static String buildUpiUriString({
    required String upiId,
    required String payeeName,
    String? amount,
    String? note,
    UpiAppType appType = UpiAppType.generic,
  }) {
    final encodedPayee = Uri.encodeComponent(payeeName);
    final encodedNote = Uri.encodeComponent(note ?? 'Tithe & Offering');
    final amountParam = amount != null && amount.isNotEmpty && double.tryParse(amount) != null
        ? '&am=$amount'
        : '';

    final query = 'pa=$upiId&pn=$encodedPayee$amountParam&cu=INR&tn=$encodedNote';

    switch (appType) {
      case UpiAppType.googlePay:
        return 'tez://upi/pay?$query';
      case UpiAppType.phonePe:
        return 'phonepe://pay?$query';
      case UpiAppType.paytm:
        return 'paytmmp://pay?$query';
      case UpiAppType.generic:
        return 'upi://pay?$query';
    }
  }

  static Future<bool> launchUpiPayment({
    required BuildContext context,
    required UpiAppType appType,
    String? amount,
    String? note,
    String upiId = AppConstants.upiId,
    String payeeName = AppConstants.upiPayeeName,
  }) async {
    final specificUri = Uri.parse(
      buildUpiUriString(
        upiId: upiId,
        payeeName: payeeName,
        amount: amount,
        note: note,
        appType: appType,
      ),
    );

    try {
      if (await canLaunchUrl(specificUri)) {
        await launchUrl(specificUri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (_) {}

    // Fallback to generic upi:// schema
    final genericUri = Uri.parse(
      buildUpiUriString(
        upiId: upiId,
        payeeName: payeeName,
        amount: amount,
        note: note,
        appType: UpiAppType.generic,
      ),
    );

    try {
      if (await canLaunchUrl(genericUri)) {
        await launchUrl(genericUri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (_) {}

    // If no UPI app was found, copy UPI ID to clipboard and notify user
    await copyToClipboard(
      context: context,
      text: upiId,
      label: 'UPI ID copied! Paste it in your UPI app.',
    );
    return false;
  }

  static Future<void> copyToClipboard({
    required BuildContext context,
    required String text,
    required String label,
  }) async {
    await HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4A0E1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
