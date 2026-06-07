import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/snack.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_pill.dart';

class NegativeKeywordsPanel extends StatefulWidget {
  const NegativeKeywordsPanel({super.key});
  @override
  State<NegativeKeywordsPanel> createState() => _NegativeKeywordsPanelState();
}

class _NegativeKeywordsPanelState extends State<NegativeKeywordsPanel> {
  final List<_Neg> _items = [
    const _Neg('free', 'broad', 1240, 0, '\$2.81'),
    const _Neg('jobs', 'phrase', 820, 0, '\$1.14'),
    const _Neg('cheap', 'broad', 502, 1, '\$3.40'),
    const _Neg('career', 'exact', 318, 0, '\$0.92'),
    const _Neg('login', 'phrase', 274, 0, '\$1.05'),
    const _Neg('hack', 'broad', 189, 0, '\$4.10'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Negative keywords',
              subtitle: 'Wasted spend triaged automatically',
              icon: Icons.block_flipped,
              trailing: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Snack.info(context, 'CSV import for negative keywords ships with the Ads OAuth rollout.'),
                    icon: const Icon(Icons.upload_file_rounded, size: 14),
                    label: const Text('Import list'),
                  ),
                  AppSpacing.hGapSm,
                  const GradientButton(
                    label: 'AI suggest 12 more',
                    icon: Icons.auto_awesome_rounded,
                    size: MythrixButtonSize.small,
                    onPressed: _noop,
                  ),
                ],
              ),
            ),
            Row(
              children: const [
                StatusPill(label: '38 auto-added · last 24h', tone: PillTone.brand, dense: true),
                AppSpacing.hGapXs,
                StatusPill(label: '\$1,820 saved this week', tone: PillTone.success, dense: true),
              ],
            ),
            AppSpacing.vGapMd,
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  headingRowHeight: 36,
                  columns: const [
                    DataColumn(label: Text('TERM')),
                    DataColumn(label: Text('MATCH TYPE')),
                    DataColumn(label: Text('IMPRESSIONS'), numeric: true),
                    DataColumn(label: Text('CONV'), numeric: true),
                    DataColumn(label: Text('AVG CPC'), numeric: true),
                    DataColumn(label: Text('')),
                  ],
                  rows: [
                    for (final n in _items)
                      DataRow(cells: [
                        DataCell(Text(n.term, style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(StatusPill(label: n.matchType, tone: PillTone.neutral, dense: true)),
                        DataCell(Text('${n.impressions}', style: AppTypography.mono(size: 12))),
                        DataCell(Text(n.conversions.toString(),
                            style: AppTypography.mono(size: 12, color: n.conversions == 0 ? AppColors.danger : null))),
                        DataCell(Text(n.cpc, style: AppTypography.mono(size: 12))),
                        DataCell(IconButton(
                          onPressed: () => Snack.info(context, 'Removing "${n.term}" — persistent negative-keyword storage ships next.'),
                          icon: const Icon(Icons.delete_outline_rounded, size: 16),
                        )),
                      ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _noop() {}
}

class _Neg {
  const _Neg(this.term, this.matchType, this.impressions, this.conversions, this.cpc);
  final String term;
  final String matchType;
  final int impressions;
  final int conversions;
  final String cpc;
}
