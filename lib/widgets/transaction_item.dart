// lib/widgets/transaction_item.dart — SPENDO v2
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final color  = t.isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
    final bgColor = t.isIncome ? AppColors.incomeLight : AppColors.expenseLight;
    final icon   = _getIcon(t.category);
    final amtStr = '${t.isIncome ? "+" : "-"}฿${NumberFormat("#,##0.00").format(t.amount)}';
    final dateStr = _getDateLabel(t.createdAt);

    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(color: AppColors.expenseRed, borderRadius: BorderRadius.circular(AppRadius.large)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('ลบรายการ', style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold)),
            content: Text('ต้องการลบรายการนี้หรือไม่?', style: GoogleFonts.notoSansThai()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('ยกเลิก', style: GoogleFonts.notoSansThai())),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseRed),
                child: Text('ลบ', style: GoogleFonts.notoSansThai()),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(AppRadius.medium)),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.description.isNotEmpty ? t.description : t.category,
                        style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.medium, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                            child: Text(t.category, style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.tiny, color: color, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 6),
                          Text(dateStr, style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.tiny, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  amtStr,
                  style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.medium, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String category) {
    const map = {
      'อาหาร': Icons.restaurant,
      'เดินทาง': Icons.directions_car,
      'ช้อปปิ้ง': Icons.shopping_bag,
      'บันเทิง': Icons.movie,
      'ค่าใช้จ่าย': Icons.receipt_long,
      'สุขภาพ': Icons.local_hospital,
      'การศึกษา': Icons.school,
      'เงินเดือน': Icons.work,
      'โบนัส': Icons.card_giftcard,
      'ออมเงิน': Icons.savings,
      'อื่นๆ': Icons.category,
    };
    return map[category] ?? Icons.attach_money;
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'วันนี้ ${DateFormat('HH:mm').format(date)}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'เมื่อวาน ${DateFormat('HH:mm').format(date)}';
    }
    return DateFormat('dd/MM/yy HH:mm').format(date);
  }
}
