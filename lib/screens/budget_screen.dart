// lib/screens/budget_screen.dart — SPENDO v2 (ฟีเจอร์ใหม่)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../utils/constants.dart';
import '../models/budget.dart';
import '../providers/app_provider.dart';
import '../models/category.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final budgets  = provider.getBudgetsForMonth(_now.month, _now.year);
    final spending = provider.getBudgetSpending(_now.month, _now.year);

    final thaiMonths = ['มกราคม','กุมภาพันธ์','มีนาคม','เมษายน','พฤษภาคม','มิถุนายน',
                        'กรกฎาคม','สิงหาคม','กันยายน','ตุลาคม','พฤศจิกายน','ธันวาคม'];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('งบประมาณ', style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddBudgetDialog,
            tooltip: 'เพิ่มงบประมาณ',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            color: AppColors.primaryGreen,
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: Column(
              children: [
                Text(
                  '${thaiMonths[_now.month - 1]} ${_now.year + 543}',
                  style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.large, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                _BudgetOverallCard(budgets: budgets, spending: spending),
              ],
            ),
          ),

          // Budget list
          Expanded(
            child: budgets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_outlined, size: 80, color: AppColors.lightGray),
                        const SizedBox(height: AppSpacing.md),
                        Text('ยังไม่มีงบประมาณ', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.large, color: AppColors.mediumGray, fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        Text('กด + เพื่อกำหนดงบประมาณแต่ละหมวด', style: GoogleFonts.notoSansThai(color: AppColors.darkGray)),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton.icon(
                          onPressed: _showAddBudgetDialog,
                          icon: const Icon(Icons.add),
                          label: Text('เพิ่มงบประมาณ', style: GoogleFonts.notoSansThai()),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: budgets.length,
                    itemBuilder: (_, i) => _BudgetCard(
                      budget: budgets[i],
                      spent: spending[budgets[i].categoryName] ?? 0.0,
                      onDelete: () => _deleteBudget(budgets[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddBudgetDialog() async {
    final provider = context.read<AppProvider>();
    final categories = provider.categories.where((c) => (c as Category).isExpense).map((c) => (c as Category).name).toSet().toList();

    String? selectedCategory;
    final amountCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(2))),
                  Text('กำหนดงบประมาณ', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.extraLarge, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.lg),

                  Text('หมวดหมู่', style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.notoSansThai()))).toList(),
                    onChanged: (v) => setModal(() => selectedCategory = v),
                    validator: (v) => v == null ? 'กรุณาเลือกหมวดหมู่' : null,
                    decoration: InputDecoration(
                      hintText: 'เลือกหมวดหมู่',
                      hintStyle: GoogleFonts.notoSansThai(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text('วงเงินงบประมาณ (บาท)', style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'กรุณากรอกวงเงิน';
                      if (double.tryParse(v) == null || double.parse(v) <= 0) return 'กรุณากรอกจำนวนเงินที่ถูกต้อง';
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixText: '฿ ',
                      hintText: '0.00',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                    ),
                    style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.large, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final budget = Budget(
                          id: const Uuid().v4(),
                          categoryName: selectedCategory!,
                          limitAmount: double.parse(amountCtrl.text),
                          month: _now.month,
                          year: _now.year,
                          createdAt: DateTime.now(),
                        );
                        await provider.saveBudget(budget);
                        if (mounted) Navigator.pop(context);
                      },
                      child: Text('บันทึกงบประมาณ', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.regular, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteBudget(Budget b) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('ลบงบประมาณ', style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold)),
        content: Text('ต้องการลบงบประมาณ "${b.categoryName}" หรือไม่?', style: GoogleFonts.notoSansThai()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('ยกเลิก', style: GoogleFonts.notoSansThai())),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseRed), child: Text('ลบ', style: GoogleFonts.notoSansThai())),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<AppProvider>().deleteBudget(b.id);
    }
  }
}

class _BudgetOverallCard extends StatelessWidget {
  final List<Budget> budgets;
  final Map<String, double> spending;
  const _BudgetOverallCard({required this.budgets, required this.spending});

  @override
  Widget build(BuildContext context) {
    final totalLimit   = budgets.fold(0.0, (s, b) => s + b.limitAmount);
    final totalSpent   = budgets.fold(0.0, (s, b) => s + (spending[b.categoryName] ?? 0.0));
    final totalRemain  = totalLimit - totalSpent;
    final percent      = totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;
    final color        = percent >= 1.0 ? AppColors.budgetDanger : percent >= 0.8 ? AppColors.budgetWarning : AppColors.budgetSafe;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.large)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('วงเงินรวม', style: GoogleFonts.notoSansThai(color: Colors.white70)),
              Text('ใช้ไปแล้ว ${(percent * 100).toInt()}%', style: GoogleFonts.notoSansThai(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: percent, color: color, backgroundColor: Colors.white24, minHeight: 10),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ใช้ไป ฿${NumberFormat('#,##0').format(totalSpent)}', style: GoogleFonts.notoSansThai(color: Colors.white70, fontSize: AppFontSizes.small)),
              Text('คงเหลือ ฿${NumberFormat('#,##0').format(totalRemain)}', style: GoogleFonts.notoSansThai(color: Colors.white, fontWeight: FontWeight.bold, fontSize: AppFontSizes.small)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final VoidCallback onDelete;
  const _BudgetCard({required this.budget, required this.spent, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final remaining = budget.limitAmount - spent;
    final percent   = budget.limitAmount > 0 ? (spent / budget.limitAmount).clamp(0.0, 1.0) : 0.0;
    final color     = percent >= 1.0 ? AppColors.budgetDanger : percent >= 0.8 ? AppColors.budgetWarning : AppColors.budgetSafe;
    final isOver    = remaining < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(budget.categoryName, style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.regular, fontWeight: FontWeight.bold))),
                if (isOver) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.expenseLight, borderRadius: BorderRadius.circular(12)),
                  child: Text('เกินงบ!', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.small, color: AppColors.expenseRed, fontWeight: FontWeight.bold)),
                ),
                IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.mediumGray, size: 20), onPressed: onDelete),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: percent, color: color, backgroundColor: AppColors.lightGray, minHeight: 10),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ใช้ไป ฿${NumberFormat('#,##0.00').format(spent)}', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.small, color: AppColors.textSecondary)),
                Text(
                  isOver ? 'เกิน ฿${NumberFormat('#,##0.00').format(remaining.abs())}' : 'คงเหลือ ฿${NumberFormat('#,##0.00').format(remaining)}',
                  style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.small, color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('วงเงิน ฿${NumberFormat('#,##0.00').format(budget.limitAmount)}', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.tiny, color: AppColors.mediumGray)),
          ],
        ),
      ),
    );
  }
}