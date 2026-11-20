import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import 'bank_transfer_card.dart';
import 'building_fund_card.dart';
import 'upi_giving_card.dart';

class GivingScreen extends StatelessWidget {
  final Widget? drawer;

  const GivingScreen({
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
              '1-TAP UPI GIVING',
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                fontSize: 17,
              ),
            ),
            Text(
              'Tithes • Building Fund • Missions Support',
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
            UpiGivingCard(),
            SizedBox(height: 16),
            BuildingFundCard(),
            SizedBox(height: 16),
            BankTransferCard(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
