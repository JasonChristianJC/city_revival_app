import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../prayer/presentation/prayer_form_widget.dart';
import 'bank_transfer_card.dart';
import 'building_fund_card.dart';
import 'upi_giving_card.dart';

class PrayerAndGiveScreen extends StatefulWidget {
  final int initialTabIndex;
  final Widget? drawer;

  const PrayerAndGiveScreen({
    super.key,
    this.initialTabIndex = 0,
    this.drawer,
  });

  @override
  State<PrayerAndGiveScreen> createState() => _PrayerAndGiveScreenState();
}

class _PrayerAndGiveScreenState extends State<PrayerAndGiveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: widget.drawer,
      appBar: AppBar(
        title: Text(
          'PRAYER & GIVING',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.divineGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: const [
            Tab(
              icon: Icon(Icons.volunteer_activism, size: 20),
              text: '1-Tap UPI Giving',
            ),
            Tab(
              icon: Icon(Icons.lock_person, size: 20),
              text: 'Confidential Prayer',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Giving & Building Fund
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: const [
                UpiGivingCard(),
                SizedBox(height: 16),
                BuildingFundCard(),
                SizedBox(height: 16),
                BankTransferCard(),
                SizedBox(height: 32),
              ],
            ),
          ),

          // Tab 2: Confidential Prayer Request
          const SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                PrayerFormWidget(),
                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
