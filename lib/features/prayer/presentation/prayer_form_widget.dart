import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sacred_button.dart';
import '../../../core/widgets/sacred_card.dart';
import '../data/prayer_repository.dart';
import '../domain/prayer_request.dart';
import 'prayer_confirmation_dialog.dart';

class PrayerFormWidget extends ConsumerStatefulWidget {
  const PrayerFormWidget({super.key});

  @override
  ConsumerState<PrayerFormWidget> createState() => _PrayerFormWidgetState();
}

class _PrayerFormWidgetState extends ConsumerState<PrayerFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _needController = TextEditingController();

  bool _isAnonymous = false;
  bool _isSubmitting = false;
  String _selectedCategory = 'Healing & Health';

  final List<String> _categories = [
    'Healing & Health',
    'Family Peace',
    'Financial Need',
    'Spiritual Growth',
    'Deliverance',
    'Thanksgiving',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _needController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final request = PrayerRequest(
      requesterName: _isAnonymous ? 'Anonymous' : _nameController.text.trim(),
      contactInfo: _isAnonymous ? '' : _phoneController.text.trim(),
      isAnonymous: _isAnonymous,
      requestText: _needController.text.trim(),
      category: _selectedCategory,
    );

    final success = await ref
        .read(prayerRepositoryProvider)
        .submitPrayerRequest(request);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => PrayerConfirmationDialog(
            onDismiss: () {
              Navigator.of(context).pop();
              _nameController.clear();
              _phoneController.clear();
              _needController.clear();
              setState(() {
                _isAnonymous = false;
                _selectedCategory = 'Healing & Health';
              });
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit prayer request. Please check your internet connection.'),
            backgroundColor: AppColors.liveRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SacredCard(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWine.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_person,
                    color: AppColors.primaryWine,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONFIDENTIAL PRAYER REQUEST',
                        style: GoogleFonts.cinzel(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isDark ? AppColors.divineGold : AppColors.primaryWine,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Directly received by Pastor Jerry Daniel & Prayer Team',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Submit Anonymously Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCardAlt
                    : AppColors.parchmentCream.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isAnonymous
                      ? AppColors.divineGold
                      : (isDark ? Colors.white10 : Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isAnonymous ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                        color: _isAnonymous ? AppColors.divineGold : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Submit Anonymously',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          Text(
                            _isAnonymous
                                ? 'Your identity is fully hidden'
                                : 'Include name & contact details',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: _isAnonymous,
                    activeColor: AppColors.divineGold,
                    activeTrackColor: AppColors.primaryWine,
                    onChanged: (val) {
                      setState(() {
                        _isAnonymous = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Name Field (only if not anonymous)
            if (!_isAnonymous) ...[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Full Name',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
                validator: (val) {
                  if (!_isAnonymous && (val == null || val.trim().isEmpty)) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Phone / WhatsApp Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone / WhatsApp Number',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  hintText: 'e.g. 9876543210',
                ),
                validator: (val) {
                  if (!_isAnonymous && (val == null || val.trim().isEmpty)) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Category Chips
            const Text(
              'Prayer Category',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.primaryWine,
                  backgroundColor: isDark ? AppColors.darkCardAlt : Colors.grey.shade100,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Prayer Need Text Area
            TextFormField(
              controller: _needController,
              maxLines: 4,
              minLines: 3,
              decoration: const InputDecoration(
                labelText: 'Share your prayer need in detail...',
                alignLabelWithHint: true,
                hintText:
                    'Tell us what burden, sickness, or life situation you want pastor and the church team to intercede for...',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please describe your prayer need';
                }
                if (val.trim().length < 5) {
                  return 'Please write at least a few words';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Submit Button
            SacredButton(
              label: 'Submit Prayer Request',
              icon: Icons.send_rounded,
              isLoading: _isSubmitting,
              width: double.infinity,
              onPressed: _submit,
              variant: SacredButtonVariant.primaryWine,
            ),
          ],
        ),
      ),
    );
  }
}
