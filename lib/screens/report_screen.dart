// lib/screens/report_screen.dart
// หน้าจอรายงาน - แก้ไข warnings สีเหลืองแล้ว
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../services/database_service.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';
import '../widgets/transaction_item.dart';
import '../widgets/pie_chart_widget.dart';
import 'expense_screen.dart';
import 'income_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  // Database service instance
  final DatabaseService _databaseService = DatabaseService();
  
  // Tab Controller
  late TabController _tabController;
  
  // ข้อมูลสถิติ
  List<Transaction> _allTransactions = [];
  List<Transaction> _incomeTransactions = [];
  List<Transaction> _expenseTransactions = [];
  Map<String, double> _categoryTotals = {};
  
  // ช่วงวันที่
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  // สถานะการโหลด
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // โหลดข้อมูลรายงาน
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // ดึงธุรกรรมในช่วงวันที่ที่กำหนด
      _allTransactions = _databaseService.getTransactionsByDateRange(_startDate, _endDate);
      
      // แยกตามประเภท
      _incomeTransactions = _allTransactions.where((t) => t.isIncome).toList();
      _expenseTransactions = _allTransactions.where((t) => t.isExpense).toList();
      
      // คำนวณยอดตามหมวดหมู่ (เฉพาะรายจ่าย)
      _categoryTotals = {};
      for (var transaction in _expenseTransactions) {
        if (_categoryTotals.containsKey(transaction.category)) {
          _categoryTotals[transaction.category] = 
              _categoryTotals[transaction.category]! + transaction.amount;
        } else {
          _categoryTotals[transaction.category] = transaction.amount;
        }
      }
      
      // เรียงตามวันที่จากใหม่ไปเก่า
      _allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _incomeTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _expenseTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('เกิดข้อผิดพลาดในการโหลดข้อมูล');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // เลือกช่วงวันที่
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      helpText: 'เลือกช่วงวันที่',
      cancelText: 'ยกเลิก',
      confirmText: 'ตกลง',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }
  
  // แสดง SnackBar error
  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.expenseRed,
        ),
      );
    }
  }
  
  // แสดง SnackBar success
  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.incomeGreen,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      
      // AppBar
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Text(
          'รายงานการเงิน',
          style: GoogleFonts.notoSansThai(
            fontSize: AppFontSizes.large,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          // ปุ่มเลือกวันที่
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range, color: Colors.white),
            tooltip: 'เลือกช่วงวันที่',
          ),
          
          // ปุ่มรีเฟรช
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'รีเฟรชข้อมูล',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.notoSansThai(
            fontSize: AppFontSizes.medium,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.notoSansThai(
            fontSize: AppFontSizes.medium,
            fontWeight: FontWeight.normal,
          ),
          tabs: [
            Tab(text: 'ทั้งหมด (${_allTransactions.length})'),
            Tab(text: 'รายรับ (${_incomeTransactions.length})'),
            Tab(text: 'รายจ่าย (${_expenseTransactions.length})'),
          ],
        ),
      ),
      
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'กำลังโหลดข้อมูล...',
                    style: GoogleFonts.notoSansThai(
                      fontSize: AppFontSizes.medium,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // ส่วนสรุปและช่วงวันที่
                _buildSummarySection(),
                
                // เนื้อหาแยกตาม Tab
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllTransactionsTab(),
                      _buildIncomeTab(),
                      _buildExpenseTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
  // ส่วนสรุปและช่วงวันที่
  Widget _buildSummarySection() {
    final double totalIncome = _incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final double totalExpense = _expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);
    final double balance = totalIncome - totalExpense;
    
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ช่วงวันที่
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ช่วงวันที่:',
                style: GoogleFonts.notoSansThai(
                  fontSize: AppFontSizes.medium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                onTap: _selectDateRange,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(color: AppColors.primaryGreen),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                        style: GoogleFonts.notoSansThai(
                          fontSize: AppFontSizes.small,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit,
                        size: 14,
                        color: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // สถิติสรุป
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'รายรับ',
                  amount: totalIncome,
                  color: AppColors.incomeGreen,
                  icon: AppIcons.income,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildSummaryCard(
                  title: 'รายจ่าย',
                  amount: totalExpense,
                  color: AppColors.expenseRed,
                  icon: AppIcons.expense,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildSummaryCard(
                  title: 'คงเหลือ',
                  amount: balance,
                  color: balance >= 0 ? AppColors.incomeGreen : AppColors.expenseRed,
                  icon: AppIcons.wallet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // การ์ดสรุป
  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.notoSansThai(
              fontSize: AppFontSizes.small,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '฿${amount.toStringAsFixed(2)}',
            style: GoogleFonts.notoSansThai(
              fontSize: AppFontSizes.small,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  // Tab รายการทั้งหมด
  Widget _buildAllTransactionsTab() {
    if (_allTransactions.isEmpty) {
      return _buildEmptyState('ไม่มีรายการในช่วงวันที่ที่เลือก');
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.sm),
        itemCount: _allTransactions.length,
        itemBuilder: (context, index) {
          final transaction = _allTransactions[index];
          return TransactionItem(
            transaction: transaction,
            onTap: () => _showTransactionDetails(transaction),
            onDelete: () => _deleteTransaction(transaction),
          );
        },
      ),
    );
  }
  
  // Tab รายรับ
  Widget _buildIncomeTab() {
    if (_incomeTransactions.isEmpty) {
      return _buildEmptyState('ไม่มีรายรับในช่วงวันที่ที่เลือก');
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.incomeGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.sm),
        itemCount: _incomeTransactions.length,
        itemBuilder: (context, index) {
          final transaction = _incomeTransactions[index];
          return TransactionItem(
            transaction: transaction,
            onTap: () => _showTransactionDetails(transaction),
            onDelete: () => _deleteTransaction(transaction),
          );
        },
      ),
    );
  }
  
  // Tab รายจ่าย
  Widget _buildExpenseTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.expenseRed,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แผนภูมิรายจ่าย
            if (_categoryTotals.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'สัดส่วนรายจ่าย',
                          style: GoogleFonts.notoSansThai(
                            fontSize: AppFontSizes.large,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.expenseRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.small),
                          ),
                          child: Text(
                            '฿${_expenseTransactions.fold(0.0, (sum, t) => sum + t.amount).toStringAsFixed(2)}',
                            style: GoogleFonts.notoSansThai(
                              fontSize: AppFontSizes.small,
                              fontWeight: FontWeight.bold,
                              color: AppColors.expenseRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PieChartWidget(categoryTotals: _categoryTotals),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
            ],
            
            // รายการรายจ่าย
            if (_expenseTransactions.isEmpty)
              _buildEmptyState('ไม่มีรายจ่ายในช่วงวันที่ที่เลือก')
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'รายการรายจ่าย',
                            style: GoogleFonts.notoSansThai(
                              fontSize: AppFontSizes.large,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          Text(
                            '${_expenseTransactions.length} รายการ',
                            style: GoogleFonts.notoSansThai(
                              fontSize: AppFontSizes.small,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _expenseTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _expenseTransactions[index];
                        return TransactionItem(
                          transaction: transaction,
                          onTap: () => _showTransactionDetails(transaction),
                          onDelete: () => _deleteTransaction(transaction),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Empty State
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'ไม่มีข้อมูล',
              style: GoogleFonts.notoSansThai(
                fontSize: AppFontSizes.large,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: GoogleFonts.notoSansThai(
                fontSize: AppFontSizes.medium,
                color: AppColors.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range),
              label: const Text('เลือกช่วงวันที่ใหม่'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // แสดงรายละเอียดธุรกรรม
  void _showTransactionDetails(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (transaction.isIncome 
                          ? AppColors.incomeGreen 
                          : AppColors.expenseRed).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Icon(
                      transaction.isIncome ? AppIcons.income : AppIcons.expense,
                      color: transaction.isIncome 
                          ? AppColors.incomeGreen 
                          : AppColors.expenseRed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'รายละเอียดธุรกรรม',
                      style: GoogleFonts.notoSansThai(
                        fontSize: AppFontSizes.large,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // รายละเอียด
              _buildDetailRow('ประเภท', transaction.isIncome ? 'รายรับ' : 'รายจ่าย'),
              _buildDetailRow('จำนวนเงิน', '฿${transaction.amount.toStringAsFixed(2)}'),
              _buildDetailRow('หมวดหมู่', transaction.category),
              _buildDetailRow('รายละเอียด', 
                transaction.description.isNotEmpty ? transaction.description : '-'),
              _buildDetailRow('วันที่', transaction.formattedDate),
              _buildDetailRow('เวลา', transaction.formattedTime),
              if (transaction.updatedAt != null)
                _buildDetailRow('แก้ไขล่าสุด', 
                  '${transaction.updatedAt!.day.toString().padLeft(2, '0')}/'
                  '${transaction.updatedAt!.month.toString().padLeft(2, '0')}/'
                  '${transaction.updatedAt!.year} '
                  '${transaction.updatedAt!.hour.toString().padLeft(2, '0')}:'
                  '${transaction.updatedAt!.minute.toString().padLeft(2, '0')}'),
              
              const SizedBox(height: AppSpacing.lg),
              
              // ปุ่ม
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _editTransaction(transaction);
                      },
                      icon: const Icon(AppIcons.edit, size: 18),
                      label: const Text('แก้ไข'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteTransaction(transaction);
                      },
                      icon: const Icon(AppIcons.delete, size: 18),
                      label: const Text('ลบ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.expenseRed,
                        side: const BorderSide(color: AppColors.expenseRed),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('ปิด'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // แก้ไขธุรกรรม
  void _editTransaction(Transaction transaction) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => transaction.isIncome
            ? IncomeScreen(editTransaction: transaction)
            : ExpenseScreen(editTransaction: transaction),
      ),
    );
    
    if (result == true && mounted) {
      _loadData();
      _showSuccessSnackbar('แก้ไขรายการเรียบร้อยแล้ว');
    }
  }
  
  // ลบธุรกรรม
  void _deleteTransaction(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'ยืนยันการลบ',
          style: GoogleFonts.notoSansThai(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'คุณต้องการลบรายการนี้หรือไม่?\n\n'
          'รายการ: ${transaction.description.isNotEmpty ? transaction.description : transaction.category}\n'
          'จำนวน: ฿${transaction.amount.toStringAsFixed(2)}\n'
          'วันที่: ${transaction.formattedDate}',
          style: GoogleFonts.notoSansThai(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.notoSansThai(
                color: AppColors.darkGray,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _databaseService.deleteTransaction(transaction.id);
                if (mounted) {
                  Navigator.of(context).pop();
                  _loadData();
                  _showSuccessSnackbar('ลบรายการเรียบร้อยแล้ว');
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  _showErrorSnackbar('เกิดข้อผิดพลาดในการลบ');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'ลบ',
              style: GoogleFonts.notoSansThai(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // แถวรายละเอียด
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: GoogleFonts.notoSansThai(
                fontSize: AppFontSizes.small,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.notoSansThai(
                fontSize: AppFontSizes.small,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Format วันที่
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}'
           '/${date.month.toString().padLeft(2, '0')}'
           '/${date.year}';
  }
}