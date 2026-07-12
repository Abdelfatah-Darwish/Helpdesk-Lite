import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ChartPlaceholder extends StatelessWidget {
  final int newCount;
  final int inProgressCount;
  final int resolvedCount;
  final int closedCount;

  const ChartPlaceholder({
    super.key,
    required this.newCount,
    required this.inProgressCount,
    required this.resolvedCount,
    required this.closedCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = newCount + inProgressCount + resolvedCount + closedCount;
    final theme = Theme.of(context);

    // Calculate percentages
    final double newPct = total > 0 ? newCount / total : 0;
    final double progressPct = total > 0 ? inProgressCount / total : 0;
    final double resolvedPct = total > 0 ? resolvedCount / total : 0;
    final double closedPct = total > 0 ? closedCount / total : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ticket Status Distribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Relative distribution of all tickets in system',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          
          // Chart Graphic (Progress bar-based stack)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 24,
              child: total == 0
                  ? Container(color: AppColors.border)
                  : Row(
                      children: [
                        if (newPct > 0)
                          Expanded(
                            flex: (newPct * 100).round(),
                            child: Container(
                              color: AppColors.statusNew,
                              child: const Tooltip(message: 'New'),
                            ),
                          ),
                        if (progressPct > 0)
                          Expanded(
                            flex: (progressPct * 100).round(),
                            child: Container(
                              color: AppColors.statusInProgress,
                              child: const Tooltip(message: 'In Progress'),
                            ),
                          ),
                        if (resolvedPct > 0)
                          Expanded(
                            flex: (resolvedPct * 100).round(),
                            child: Container(
                              color: AppColors.statusResolved,
                              child: const Tooltip(message: 'Resolved'),
                            ),
                          ),
                        if (closedPct > 0)
                          Expanded(
                            flex: (closedPct * 100).round(),
                            child: Container(
                              color: AppColors.statusClosed,
                              child: const Tooltip(message: 'Closed'),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 32),

          // Legend Indicators
          Row(
            flexWrap: WrapFlexCheck.wrap, // Handle wrapping on tiny screens
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem('New', newCount, AppColors.statusNew, '${(newPct * 100).toStringAsFixed(0)}%'),
              _buildLegendItem('In Progress', inProgressCount, AppColors.statusInProgress, '${(progressPct * 100).toStringAsFixed(0)}%'),
              _buildLegendItem('Resolved', resolvedCount, AppColors.statusResolved, '${(resolvedPct * 100).toStringAsFixed(0)}%'),
              _buildLegendItem('Closed', closedCount, AppColors.statusClosed, '${(closedPct * 100).toStringAsFixed(0)}%'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color, String percentage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 4),
                Text(
                  '($count)',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            Text(
              percentage,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        )
      ],
    );
  }
}

// Helper to make wrap work inside row if needed
extension WrapFlexCheck on Row {
  static const wrap = null;
}
