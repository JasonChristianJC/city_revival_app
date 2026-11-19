import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../data/sermon_repository.dart';
import 'sermon_card.dart';
import '../../announcements/presentation/sunday_live_alert_banner.dart';

class SermonsScreen extends ConsumerStatefulWidget {
  final Widget? drawer;

  const SermonsScreen({super.key, this.drawer});

  @override
  ConsumerState<SermonsScreen> createState() => _SermonsScreenState();
}

class _SermonsScreenState extends ConsumerState<SermonsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _speakers = [
    'All',
    'Rev. Dr. Jerry Daniel',
    'Pastor Joseph',
    'Pastor Paul',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSermons = ref.watch(filteredSermonsProvider);
    final selectedSpeaker = ref.watch(selectedSpeakerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: widget.drawer,
      appBar: AppBar(
        title: Text(
          'SERMON VIDEO HUB',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sermonsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Live broadcast alert banner
            const SliverToBoxAdapter(
              child: SundayLiveAlertBanner(),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(sermonSearchQueryProvider.notifier).state = val;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search sermons by title or scripture...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.divineGold),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(sermonSearchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Speaker Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _speakers.length,
                  itemBuilder: (context, index) {
                    final speaker = _speakers[index];
                    final isSelected = selectedSpeaker == speaker;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(speaker),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12.5,
                        ),
                        backgroundColor: isDark ? AppColors.darkCardAlt : Colors.white,
                        selectedColor: AppColors.primaryWine,
                        checkmarkColor: AppColors.divineGold,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.divineGold
                              : (isDark ? Colors.white12 : Colors.grey.shade300),
                        ),
                        onSelected: (selected) {
                          ref.read(selectedSpeakerProvider.notifier).state = speaker;
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Sermons List
            filteredSermons.when(
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: ShimmerLoading(width: double.infinity, height: 230, borderRadius: 16),
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
                      Text('Error loading sermons: $err'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(sermonsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (sermons) {
                if (sermons.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('No sermons found matching your filter.'),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return SermonCard(sermon: sermons[index]);
                      },
                      childCount: sermons.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
