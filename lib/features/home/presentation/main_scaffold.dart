import 'package:flutter/material.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../announcements/presentation/announcements_screen.dart';
import '../../giving/presentation/prayer_and_give_screen.dart';
import '../../magazine/presentation/magazines_screen.dart';
import '../../sermons/presentation/sermons_screen.dart';
import 'home_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final drawer = AppDrawer(
      currentIndex: _currentIndex,
      onSelectTab: _onTabSelected,
    );

    final pages = [
      HomeScreen(
        onNavigateTab: _onTabSelected,
        drawer: drawer,
      ),
      AnnouncementsScreen(
        drawer: drawer,
      ),
      SermonsScreen(
        drawer: drawer,
      ),
      MagazinesScreen(
        drawer: drawer,
      ),
      PrayerAndGiveScreen(
        drawer: drawer,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
    );
  }
}
