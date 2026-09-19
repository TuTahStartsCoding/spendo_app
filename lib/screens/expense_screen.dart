// lib/screens/expense_screen.dart
// หน้าจอเพิ่มรายจ่าย - ฟอร์มบันทึกรายจ่าย
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../widgets/custom_button.dart';

class ExpenseScreen extends StatefulWidget {
  // ธุรกรรมที่ต้องการแก้ไข (หากมี)
  final Transaction? editTransaction;
  
  const ExpenseScreen({
    Key? key,
    this.editTransaction,
  }) : super(key: key);

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  // Controllers สำหรับ form fields
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Form key สำหรับ validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Database service instance
  final DatabaseService _databaseService = DatabaseService();
  
  // ข้อมูลฟอร์ม
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  List<Category> _expenseCategories = [];
  
  // สถานะต่างๆ
  bool _isLoading = false;
  bool _isEditMode = false;
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initializeForm();
  }
  
  // โหลดหมวดหมู่รายจ่าย
  void _loadCategories() {
    _expenseCategories = _databaseService.getExpenseCategories();
    setState(() {});
  }
  
  // เริ่มต้นฟอร์ม
  void _initializeForm() {
    if (widget.editTransaction != null) {
      _isEditMode = true;
      final transaction = widget.editTransaction!;
      
      _amountController.text = transaction.amount.toStringAsFixed(2);
      _descriptionController.text = transaction.description;
      _selectedCategory = transaction.category;
      _selectedDate = transaction.createdAt;
    }
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  // บันทึกรายจ่าย
  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedCategory == null) {
      _showErrorDialog('กรุณาเลือกหมวดหมู่');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final double amount = double.parse(_amountController.text);
      final String description = _descriptionController.text.trim();
      
      if (_isEditMode && widget.editTransaction != null) {
        // แก้ไขรายจ่ายที่มีอยู่
        final updatedTransaction = widget.editTransaction!.copyWith(
          amount: amount,
          description: description.isEmpty ? _selectedCategory : description,
          category: _selectedCategory!,
          updatedAt: DateTime.now(),
        );
        
        await _databaseService.updateTransaction(updatedTransaction);
        
        _showSuccessDialog('แก้ไขรายจ่ายเรียบร้อยแล้ว');
      } else {
        // เพิ่มรายจ่ายใหม่
        final transaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: amount,
          description: description.isEmpty ? _selectedCategory! : description,
          category: _selectedCategory!,
          type: TransactionType.expense,
          createdAt: _selectedDate,
        );
        
        await _databaseService.addTransaction(transaction);
        
        _showSuccessDialog('บันทึกรายจ่ายเรียบร้อยแล้ว');
      }
      
    } catch (e) {
      _showErrorDialog('เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // เลือกวันที่
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('th', 'TH'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  // แสดง Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('เกิดข้อผิดพลาด'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }
  
  // แสดง Success Dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('สำเร็จ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ปิด dialog
              Navigator.of(context).pop(true); // กลับไปหน้าเดิมพร้อมส่งผลลัพธ์
            },
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      
      // AppBar
      appBar: AppBar(
        backgroundColor: AppColors.expenseRed,
        elevation: 0,
        title: Text(
          _isEditMode ? 'แก้ไขรายจ่าย' : 'เพิ่มรายจ่าย',
          style: GoogleFonts.notoSansThai(
            fontSize: AppFontSizes.large,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(),
              
              SizedBox(height: AppSpacing.lg),
              
              // จำนวนเงิน
              _buildAmountField(),
              
              SizedBox(height: AppSpacing.md),
              
              // หมวดหมู่
              _buildCategoryField(),
              
              SizedBox(height: AppSpacing.md),
              
              // รายละเอียด
              _buildDescriptionField(),
              
              SizedBox(height: AppSpacing.md),
              
              // วันที่
              _buildDateField(),
              
              SizedBox(height: AppSpacing.xl),
              
              // ปุ่มบันทึก
              _buildSaveButton(),
              
              SizedBox(height: AppSpacing.md),
              
              // ปุ่มยกเลิก
              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }
  
  // Header Card แสดงข้อมูลสรุป
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.expenseRed, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.expenseRed.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.expense,
            color: Colors.white,
            size: 48,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            _isEditMode ? 'แก้ไขรายจ่าย' : 'บันทึกรายจ่าย',
            style: GoogleFonts.notoSansThai(
              fontSize: AppFontSizes.large,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'กรอกข้อมูลรายจ่ายของคุณ',
            style: GoogleFonts.notoSansThai(
              fontSize: AppFontSizes.medium,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
  
  // ฟิลด์จำนวนเงิน
  Widget _buildAmountField() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.amount,
            style: GoogleFonts.notoSansThai(
              fontSize: AppFontSizes.medium,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: '0.00',
              prefixIcon: Icon(Icons.attach_money, color: AppColors.expenseRed),
              suffixText: 'บาท',
              filled: true,
              fillColor: AppColors.backgroundColor,
            ),
            style: GoogleFonts.notoSansThai(
              fontSize: AppFontSizes.large,
              fontWeight: FontWeight.bold,
              color: AppColors.expenseRed,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณาใส่จำนวนเงิน';
              }
              
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'จำนวนเงินต้องมากกว่า 0';
              }
              
              if (amount > AppConstants.maxAmount) {
                return 'จำนวนเงินเกินขีดจำกัด';
              }
              
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  // ฟิลด์หมวดหมู่
  Widget _buildCategoryField() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.category,
            style: GoogleFonts.notoSansThai(
              fontSize: AppFontSizes.medium,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          
          // Grid หมวดหมู่
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.2,
            ),
            itemCount: _expenseCategories.length,
            itemBuilder: (context, index) {
              final category = _expenseCategories[index];
              final isSelected = _selectedCategory == category.name;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category.name;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? category.color.withOpacity(0.2)
                        : AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(
                      color: isSelected 
                          ? category.color
                          : AppColors.lightGray,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category.icon,
                        color: isSelected ? category.color : AppColors.darkGray,
                        size: 24,
                      ),
                      SizedBox(height: 4),
                      Text(
                        category.name,
                        style: GoogleFonts.notoSansThai(
                          fontSize: AppFontSizes.small,
                          color: isSelected ? category.color : AppColors.darkGray,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  // ฟิลด์รายละเอียด
  Widget _buildDescriptionField() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.description,
            style: GoogleFonts.notoSansThai(
              fontSize: AppFontSizes.medium,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'ระบุรายละเอียดเพิ่มเติม (ไม่บังคับ)',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.note_add, color: AppColors.darkGray),
              ),
              filled: true,
              fillColor: AppColors.backgroundColor,
            ),
            style: GoogleFonts.notoSansThai(
              fontSize: AppFontSizes.medium,
            ),
          ),
        ],
      ),
    );
  }
  
  // ฟิลด์วันที่
  Widget _buildDateField() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.date,
            style: GoogleFonts.notoSansThai(
              fontSize: AppFontSizes.medium,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: _selectDate,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: AppColors.lightGray),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.primaryGreen),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/'
                    '${_selectedDate.month.toString().padLeft(2, '0')}/'
                    '${_selectedDate.year}',
                    style: GoogleFonts.notoSansThai(
                      fontSize: AppFontSizes.medium,
                      color: AppColors.black,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_drop_down, color: AppColors.darkGray),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // ปุ่มบันทึก
  Widget _buildSaveButton() {
    return CustomButton(
      text: _isLoading 
          ? 'กำลังบันทึก...'
          : (_isEditMode ? 'อัพเดท' : 'บันทึกรายจ่าย'),
      backgroundColor: AppColors.expenseRed,
      textColor: Colors.white,
      onPressed: _isLoading ? null : _saveExpense,
      icon: _isLoading 
          ? null 
          : (_isEditMode ? Icons.update : Icons.save),
      isLoading: _isLoading,
      width: double.infinity,
      height: 56,
    );
  }
  
  // ปุ่มยกเลิก
  Widget _buildCancelButton() {
    return CustomButton(
      text: 'ยกเลิก',
      backgroundColor: AppColors.lightGray,
      textColor: AppColors.darkGray,
      onPressed: () => Navigator.of(context).pop(),
      icon: Icons.cancel,
      width: double.infinity,
      height: 48,
    );
  }
}