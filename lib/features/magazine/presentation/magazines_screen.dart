import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../data/magazine_repository.dart';
import 'magazine_card.dart';

class MagazinesScreen extends ConsumerWidget {
  const MagazinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final years = ref.watch(magazineYearsProvider);
    final selectedYear = ref.watch(selectedMagazineYearProvider) ??
        (years.isNotEmpty ? years.first : 2026);
    final magazinesByYear = ref.watch(magazinesBySelectedYearProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PARIPOORANA JEEVAN',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(magazinesProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Header Description
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book, color: AppColors.divineGold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'MONTHLY CHURCH MAGAZINE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: isDark ? AppColors.divineGold : AppColors.primaryWine,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Messages & teachings from Senior Pastor Rev. Dr. Jerry Daniel. Download any issue to read offline anytime.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Year selector tabs
            SliverToBoxAdapter(
              child: Container(
                height: 48,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final yr = years[index];
                    final isSelected = yr == selectedYear;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('$yr'),
                        selected: isSelected,
                        selectedColor: AppColors.primaryWine,
                        backgroundColor: isDark ? AppColors.darkCardAlt : Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.divineGold
                              : (isDark ? Colors.white12 : Colors.grey.shade300),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(selectedMagazineYearProvider.notifier).state = yr;
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Magazines List for Selected Year
            magazinesByYear.when(
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: ShimmerLoading(width: double.infinity, height: 180, borderRadius: 16),
                    ),
                    childCount: 3,
                  ),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Error loading magazines: $err'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(magazinesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (magazines) {
                if (magazines.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('No magazines found for $selectedYear.'),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return MagazineCard(magazine: magazines[index]);
                      },
                      childCount: magazines.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
