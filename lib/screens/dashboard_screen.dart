// lib/screens/dashboard_screen.dart — SPENDO v2
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../services/database_service.dart';
import '../models/transaction.dart';
import '../providers/app_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_item.dart';
import 'expense_screen.dart';
import 'income_screen.dart';
import 'report_screen.dart';
import 'budget_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabCtrl;

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadAll();
    });
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('ออกจากระบบ', style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold)),
        content: Text('คุณต้องการออกจากระบบหรือไม่?', style: GoogleFonts.notoSansThai()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('ยกเลิก', style: GoogleFonts.notoSansThai())),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseRed),
            child: Text('ออกจากระบบ', style: GoogleFonts.notoSansThai()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await DatabaseService().saveSetting('is_logged_in', false);
      await DatabaseService.clearCurrentUser();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _HomeTab(),
          ReportScreen(),
          BudgetScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.black26,
        indicatorColor: AppColors.primaryGreen.withOpacity(0.15),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: AppColors.primaryGreen),
            label: 'หน้าหลัก',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart, color: AppColors.primaryGreen),
            label: 'รายงาน',
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_outlined),
            selectedIcon: const Icon(Icons.account_balance, color: AppColors.primaryGreen),
            label: 'งบประมาณ',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddBottomSheet,
              backgroundColor: AppColors.primaryGreen,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('เพิ่มรายการ', style: GoogleFonts.notoSansThai(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  void _showAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: AppSpacing.lg),
            Text('เพิ่มรายการใหม่', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.large, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(child: _AddButton(label: 'รายรับ', icon: Icons.trending_up, color: AppColors.incomeGreen, onTap: () { Navigator.pop(context); _goToIncome(); })),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _AddButton(label: 'รายจ่าย', icon: Icons.trending_down, color: AppColors.expenseRed, onTap: () { Navigator.pop(context); _goToExpense(); })),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _goToIncome() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomeScreen()));
    if (mounted) Provider.of<AppProvider>(context, listen: false).loadAll();
  }

  Future<void> _goToExpense() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseScreen()));
    if (mounted) Provider.of<AppProvider>(context, listen: false).loadAll();
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.regular, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

// ==================== HOME TAB ====================
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final now = DateTime.now();
    final thaiMonths = ['ม.ค.','ก.พ.','มี.ค.','เม.ย.','พ.ค.','มิ.ย.','ก.ค.','ส.ค.','ก.ย.','ต.ค.','พ.ย.','ธ.ค.'];
    final phone = DatabaseService.currentUserPhone ?? '';

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () => provider.loadAll(),
      child: CustomScrollView(
        slivers: [
          // ===== APP BAR =====
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00C853), Color(0xFF00897B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('สวัสดี 👋', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.medium, color: Colors.white70)),
                                  Text(phone.isNotEmpty ? '0${phone.substring(1)}' : 'ผู้ใช้งาน',
                                      style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.large, color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showLogout(context),
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.logout, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('ยอดคงเหลือทั้งหมด', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.medium, color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(provider.totalBalance),
                          style: GoogleFonts.notoSansThai(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${thaiMonths[now.month - 1]} ${now.year + 543}',
                          style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.small, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== SUMMARY CARDS =====
                  Row(
                    children: [
                      Expanded(child: SummaryCard(label: 'รายรับเดือนนี้', amount: provider.monthlyIncome,  icon: Icons.trending_up,   color: AppColors.incomeGreen)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: SummaryCard(label: 'รายจ่ายเดือนนี้', amount: provider.monthlyExpense, icon: Icons.trending_down, color: AppColors.expenseRed)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SavingsBanner(savings: provider.monthlySavings),
                  const SizedBox(height: AppSpacing.lg),

                  // ===== QUICK BUDGET STATUS =====
                  _BudgetPreview(),
                  const SizedBox(height: AppSpacing.lg),

                  // ===== RECENT TRANSACTIONS =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('รายการล่าสุด', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.large, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      TextButton(
                        onPressed: () {
                          // Switch to report tab handled by parent
                        },
                        child: Text('ดูทั้งหมด', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.medium, color: AppColors.primaryGreen)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (provider.isLoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
                    ))
                  else if (provider.recentTransactions.isEmpty)
                    _EmptyState()
                  else
                    ...provider.recentTransactions.map((t) => TransactionItem(
                          transaction: t,
                          onTap: () => _showTransactionDetail(context, t),
                          onDelete: () => context.read<AppProvider>().deleteTransaction(t.id),
                        )),
                  const SizedBox(height: 100), // FAB space
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('ออกจากระบบ', style: GoogleFonts.notoSansThai(fontWeight: FontWeight.bold)),
        content: Text('คุณต้องการออกจากระบบหรือไม่?', style: GoogleFonts.notoSansThai()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('ยกเลิก', style: GoogleFonts.notoSansThai())),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseRed),
            child: Text('ออกจากระบบ', style: GoogleFonts.notoSansThai()),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await DatabaseService().saveSetting('is_logged_in', false);
      await DatabaseService.clearCurrentUser();
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }

  void _showTransactionDetail(BuildContext context, Transaction t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: AppSpacing.lg),
            Icon(t.isIncome ? Icons.trending_up : Icons.trending_down,
                size: 48, color: t.isIncome ? AppColors.incomeGreen : AppColors.expenseRed),
            const SizedBox(height: AppSpacing.sm),
            Text(_formatCurrency(t.amount),
                style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.title, fontWeight: FontWeight.bold,
                    color: t.isIncome ? AppColors.incomeGreen : AppColors.expenseRed)),
            Text(t.description.isNotEmpty ? t.description : t.category,
                style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.regular, color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(label: 'หมวดหมู่', value: t.category),
            _DetailRow(label: 'ประเภท',   value: t.isIncome ? 'รายรับ' : 'รายจ่าย'),
            _DetailRow(label: 'วันที่',    value: DateFormat('dd MMMM yyyy HH:mm', 'th_TH').format(t.createdAt)),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AppProvider>().deleteTransaction(t.id);
                },
                icon: const Icon(Icons.delete_outline),
                label: Text('ลบรายการนี้', style: GoogleFonts.notoSansThai()),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseRed),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  static String _formatCurrency(double amount) {
    final f = NumberFormat('#,##0.00');
    return '฿${f.format(amount)}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.notoSansThai(color: AppColors.textSecondary)),
        Text(value,  style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _SavingsBanner extends StatelessWidget {
  final double savings;
  const _SavingsBanner({required this.savings});
  @override
  Widget build(BuildContext context) {
    final isPositive = savings >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      decoration: BoxDecoration(
        color: isPositive ? AppColors.incomeLight : AppColors.expenseLight,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: isPositive ? AppColors.incomeGreen.withOpacity(0.4) : AppColors.expenseRed.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(isPositive ? Icons.savings_outlined : Icons.warning_amber_outlined,
              color: isPositive ? AppColors.incomeGreen : AppColors.expenseRed),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isPositive ? 'ออมเงินได้เดือนนี้' : 'รายจ่ายเกินรายรับ',
                  style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.small, color: AppColors.textSecondary)),
              Text(
                '${isPositive ? "+" : ""}฿${NumberFormat('#,##0.00').format(savings)}',
                style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.large, fontWeight: FontWeight.bold,
                    color: isPositive ? AppColors.incomeGreen : AppColors.expenseRed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final now = DateTime.now();
    final budgets = provider.getBudgetsForMonth(now.month, now.year);
    if (budgets.isEmpty) return const SizedBox.shrink();

    final spending = provider.getBudgetSpending(now.month, now.year);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('งบประมาณเดือนนี้', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.large, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        ...budgets.take(3).map((b) {
          final spent   = spending[b.categoryName] ?? 0.0;
          final percent = b.limitAmount > 0 ? (spent / b.limitAmount).clamp(0.0, 1.0) : 0.0;
          final color   = percent >= 1.0 ? AppColors.budgetDanger : percent >= 0.8 ? AppColors.budgetWarning : AppColors.budgetSafe;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(b.categoryName, style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600)),
                        Text('${(percent * 100).toInt()}%', style: GoogleFonts.notoSansThai(color: color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: percent, color: color, backgroundColor: AppColors.lightGray, minHeight: 8),
                    ),
                    const SizedBox(height: 4),
                    Text('฿${NumberFormat('#,##0').format(spent)} / ฿${NumberFormat('#,##0').format(b.limitAmount)}',
                        style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.small, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.lightGray),
          const SizedBox(height: AppSpacing.md),
          Text('ยังไม่มีรายการ', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.large, color: AppColors.mediumGray, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Text('กดปุ่ม "เพิ่มรายการ" เพื่อเริ่มต้น', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.medium, color: AppColors.darkGray)),
        ],
      ),
    ),
  );
}
