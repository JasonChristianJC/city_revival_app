import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'prayer_form_widget.dart';

class PrayerScreen extends StatelessWidget {
  final Widget? drawer;

  const PrayerScreen({
    super.key,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'CONFIDENTIAL PRAYER',
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                fontSize: 17,
              ),
            ),
            Text(
              'Direct to ${AppConstants.seniorPastor} & Pastoral Team',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: AppColors.divineGoldLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            PrayerFormWidget(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
