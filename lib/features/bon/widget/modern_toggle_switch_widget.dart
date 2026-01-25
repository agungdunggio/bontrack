import 'package:bontrack/core/enum/bon_enum.dart';
import 'package:bontrack/features/bon/widget/toggle_option_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModernToggleSwitchWidget extends StatelessWidget {
  final BonType selectedType;
  final ValueChanged<BonType> onChanged;

  const ModernToggleSwitchWidget({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPiutang = selectedType == BonType.piutang;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sliderWidth = constraints.maxWidth / 2;
          
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                left: isPiutang ? 0 : sliderWidth,
                child: Container(
                  width: sliderWidth,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ToggleOptionWidget(
                      label: 'Piutang Saya',
                      icon: Icons.account_balance_wallet_outlined,
                      isSelected: isPiutang,
                      onTap: () => onChanged(BonType.piutang),
                    ),
                  ),
                  Expanded(
                    child: ToggleOptionWidget(
                      label: 'Utang Saya',
                      icon: Icons.credit_card_outlined,
                      isSelected: !isPiutang,
                      onTap: () => onChanged(BonType.utang),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}