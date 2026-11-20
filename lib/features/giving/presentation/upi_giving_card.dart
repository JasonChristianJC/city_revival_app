import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/upi_helper.dart';
import '../../../core/widgets/sacred_card.dart';

class UpiGivingCard extends StatefulWidget {
  const UpiGivingCard({super.key});

  @override
  State<UpiGivingCard> createState() => _UpiGivingCardState();
}

class _UpiGivingCardState extends State<UpiGivingCard> {
  final TextEditingController _amountController = TextEditingController(text: '1000');
  String _selectedPurpose = 'Tithe & Offering';

  final List<String> _purposes = [
    'Tithe & Offering',
    'Vision 2035 Building Fund',
    'Missions Support',
  ];

  final List<String> _presetAmounts = ['500', '1000', '2000', '5000'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _triggerPayment(UpiAppType appType) {
    final amount = _amountController.text.trim();
    UpiHelper.launchUpiPayment(
      context: context,
      appType: appType,
      amount: amount.isNotEmpty ? amount : null,
      note: '$_selectedPurpose - ${AppConstants.churchName}',
      upiId: AppConstants.upiId,
      payeeName: AppConstants.upiPayeeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SacredCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.divineGold.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.divineGoldDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1-TAP UPI GIVING',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Direct native intent via GPay, PhonePe, or Paytm',
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

          // Purpose selector
          const Text(
            'Giving Purpose',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPurpose,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: _purposes.map((p) {
              return DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13.5)));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedPurpose = val;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          // Amount Input & Preset Chips
          const Text(
            'Amount (₹ INR)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: 'Enter amount',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => _amountController.clear(),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Preset Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _presetAmounts.map((amt) {
              final isSelected = _amountController.text == amt;
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  setState(() {
                    _amountController.text = amt;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryWine
                        : (isDark ? AppColors.darkCardAlt : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.divineGold : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '₹$amt',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 22),

          // Direct Native UPI Buttons (Google Pay, PhonePe, Paytm)
          const Text(
            'Select Your UPI App:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              // Google Pay
              Expanded(
                child: _buildUpiAppButton(
                  title: 'Google Pay',
                  icon: FontAwesomeIcons.google,
                  iconColor: const Color(0xFF4285F4),
                  bgColor: isDark ? AppColors.darkCardAlt : Colors.white,
                  borderColor: Colors.grey.shade300,
                  onTap: () => _triggerPayment(UpiAppType.googlePay),
                ),
              ),
              const SizedBox(width: 8),

              // PhonePe
              Expanded(
                child: _buildUpiAppButton(
                  title: 'PhonePe',
                  icon: Icons.payments,
                  iconColor: const Color(0xFF5F259F),
                  bgColor: isDark ? AppColors.darkCardAlt : Colors.white,
                  borderColor: const Color(0xFF5F259F).withOpacity(0.4),
                  onTap: () => _triggerPayment(UpiAppType.phonePe),
                ),
              ),
              const SizedBox(width: 8),

              // Paytm
              Expanded(
                child: _buildUpiAppButton(
                  title: 'Paytm',
                  icon: Icons.account_balance,
                  iconColor: const Color(0xFF00B9F5),
                  bgColor: isDark ? AppColors.darkCardAlt : Colors.white,
                  borderColor: const Color(0xFF00B9F5).withOpacity(0.4),
                  onTap: () => _triggerPayment(UpiAppType.paytm),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Universal UPI Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _triggerPayment(UpiAppType.generic),
              icon: const Icon(Icons.qr_code_2, size: 18),
              label: const Text('Other UPI Apps (BHIM, CRED, iMobile)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiAppButton({
    required String title,
    required Object icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon is FaIconData)
                FaIcon(icon, size: 22, color: iconColor)
              else if (icon is IconData)
                Icon(icon, size: 22, color: iconColor),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
