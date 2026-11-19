import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/upi_helper.dart';
import '../../../core/widgets/sacred_card.dart';

class BankTransferCard extends StatelessWidget {
  const BankTransferCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SacredCard(
      padding: const EdgeInsets.all(20),
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
                  Icons.account_balance,
                  color: AppColors.primaryWine,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEFT / RTGS / IMPS BANK TRANSFER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Tap any field to copy to clipboard',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          _buildCopyRow(
            context: context,
            label: 'Church Account Name',
            value: AppConstants.accountHolder,
          ),
          _buildCopyRow(
            context: context,
            label: 'Account Number',
            value: AppConstants.accountNumber,
          ),
          _buildCopyRow(
            context: context,
            label: 'Bank & Branch',
            value: '${AppConstants.bankName}, ${AppConstants.branchName}',
            copyValue: AppConstants.bankName,
          ),
          _buildCopyRow(
            context: context,
            label: 'IFSC Code',
            value: AppConstants.ifscCode,
          ),
          _buildCopyRow(
            context: context,
            label: 'Church UPI ID',
            value: AppConstants.upiId,
          ),
        ],
      ),
    );
  }

  Widget _buildCopyRow({
    required BuildContext context,
    required String label,
    required String value,
    String? copyValue,
  }) {
    final textToCopy = copyValue ?? value;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        UpiHelper.copyToClipboard(
          context: context,
          text: textToCopy,
          label: '$label copied: $textToCopy',
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.copy, size: 18, color: AppColors.divineGoldDark),
          ],
        ),
      ),
    );
  }
}
