// lib/utils/constants.dart — SPENDO v2
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF00C853);
  static const Color darkGreen    = Color(0xFF00897B);
  static const Color accentGreen  = Color(0xFF69F0AE);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor    = Color(0xFFFFFFFF);
  static const Color cardColor       = Color(0xFFFFFFFF);
  static const Color expenseRed   = Color(0xFFE53935);
  static const Color expenseLight = Color(0xFFFFEBEE);
  static const Color incomeGreen  = Color(0xFF43A047);
  static const Color incomeLight  = Color(0xFFE8F5E9);
  static const Color savingsBlue  = Color(0xFF1E88E5);
  static const Color warningOrange = Color(0xFFFF6D00);
  static const Color lightGray    = Color(0xFFEEEEEE);
  static const Color mediumGray   = Color(0xFFBDBDBD);
  static const Color darkGray     = Color(0xFF616161);
  static const Color textPrimary  = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color white  = Colors.white;
  static const Color black  = Colors.black;
  static const Color orange = Color(0xFFFF9800);

  // Budget progress colors
  static const Color budgetSafe    = Color(0xFF43A047);
  static const Color budgetWarning = Color(0xFFFFA000);
  static const Color budgetDanger  = Color(0xFFE53935);

  // Chart palette
  static const List<Color> chartColors = [
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
    Color(0xFF558B2F),
    Color(0xFF4E342E),
    Color(0xFFAD1457),
    Color(0xFF37474F),
    Color(0xFFE65100),
    Color(0xFF00695C),
    Color(0xFF283593),
  ];
}

class AppFontSizes {
  static const double tiny       = 10.0;
  static const double small      = 12.0;
  static const double medium     = 14.0;
  static const double regular    = 16.0;
  static const double large      = 18.0;
  static const double extraLarge = 22.0;
  static const double title      = 26.0;
  static const double display    = 32.0;
}

class AppSpacing {
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double small    = 8.0;
  static const double medium   = 12.0;
  static const double large    = 16.0;
  static const double xl       = 24.0;
  static const double circular = 50.0;
}

class AppStrings {
  static const String appName       = 'SPENDO';
  static const String appSubtitle   = 'จัดการเงินอย่างชาญฉลาด';
  static const String totalBalance  = 'ยอดคงเหลือ';
  static const String income        = 'รายรับ';
  static const String expense       = 'รายจ่าย';
  static const String savings       = 'ออมเงิน';
  static const String budget        = 'งบประมาณ';
  static const String transactions  = 'รายการ';
  static const String categories    = 'หมวดหมู่';
  static const String reports       = 'รายงาน';
  static const String settings      = 'ตั้งค่า';
  static const String save          = 'บันทึก';
  static const String cancel        = 'ยกเลิก';
  static const String delete        = 'ลบ';
  static const String edit          = 'แก้ไข';
  static const String amount        = 'จำนวนเงิน';
  static const String description   = 'หมายเหตุ';
  static const String category      = 'หมวดหมู่';
  static const String date          = 'วันที่';
  static const String confirm       = 'ยืนยัน';
  static const String noData        = 'ไม่มีข้อมูล';
}

class AppConstants {
  static const double maxAmount        = 999999999.99;
  static const int    decimalPlaces    = 2;
  static const int    maxRecentTrans   = 10;
  static const String dateFormat       = 'dd/MM/yyyy';
  static const String dateTimeFormat   = 'dd/MM/yyyy HH:mm';
  static const String transactionsBox  = 'transactions';
  static const String categoriesBox    = 'categories';
  static const String settingsBox      = 'settings';
  static const String budgetsBox       = 'budgets';

  // Budget alert threshold (percentage)
  static const double budgetWarningThreshold = 0.8;
  static const double budgetDangerThreshold  = 1.0;
}

class AppIcons {
  static const IconData income        = Icons.trending_up;
  static const IconData expense       = Icons.trending_down;
  static const IconData wallet        = Icons.account_balance_wallet;
  static const IconData food          = Icons.restaurant;
  static const IconData transport     = Icons.directions_car;
  static const IconData shopping      = Icons.shopping_bag;
  static const IconData entertainment = Icons.movie;
  static const IconData bills         = Icons.receipt_long;
  static const IconData salary        = Icons.work;
  static const IconData bonus         = Icons.card_giftcard;
  static const IconData health        = Icons.local_hospital;
  static const IconData education     = Icons.school;
  static const IconData savings       = Icons.savings;
  static const IconData other         = Icons.more_horiz;
  static const IconData add           = Icons.add;
  static const IconData delete        = Icons.delete_outline;
  static const IconData edit          = Icons.edit_outlined;
  static const IconData budget        = Icons.account_balance;
  static const IconData report        = Icons.bar_chart;
  static const IconData settings      = Icons.settings;
  static const IconData notification  = Icons.notifications;
  static const IconData search        = Icons.search;
  static const IconData filter        = Icons.tune;
  static const IconData export        = Icons.file_download;
  static const IconData calendar      = Icons.calendar_today;
}
