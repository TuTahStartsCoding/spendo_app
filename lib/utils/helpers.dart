// lib/utils/helpers.dart
// ไฟล์เก็บ helper functions และ utility methods
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

// คลาส Helper functions
class AppHelpers {
  // กันการสร้าง instance
  AppHelpers._();
  
  // === DATE & TIME HELPERS ===
  
  // Format วันที่เป็นรูปแบบไทย
  static String formatDateThai(DateTime date) {
    final months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
      'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
      'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }
  
  // Format เวลา
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
  
  // Format วันที่และเวลา
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  
  // ตรวจสอบว่าเป็นวันนี้หรือไม่
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
  
  // ตรวจสอบว่าเป็นเมื่อวานหรือไม่
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }
  
  // แปลงวันที่เป็นข้อความ (วันนี้, เมื่อวาน, หรือวันที่)
  static String getDateLabel(DateTime date) {
    if (isToday(date)) return 'วันนี้';
    if (isYesterday(date)) return 'เมื่อวาน';
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  // === CURRENCY & NUMBER HELPERS ===
  
  // Format ตัวเลขเป็นรูปแบบเงิน
  static String formatCurrency(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat('#,##0.00', 'th_TH');
    final formatted = formatter.format(amount.abs());
    
    if (showSymbol) {
      return '฿$formatted';
    }
    return formatted;
  }
  
  // Format ตัวเลขแบบย่อ (เช่น 1K, 1M)
  static String formatCompactCurrency(double amount) {
    if (amount >= 1000000) {
      return '฿${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '฿${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatCurrency(amount);
  }
  
  // แปลง String เป็น double (สำหรับการป้อนเงิน)
  static double? parseAmount(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned);
  }
  
  // === VALIDATION HELPERS ===
  
  // ตรวจสอบเบอร์โทรศัพท์ไทย
  static bool isValidThaiPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final regex = RegExp(r'^(06|08|09)[0-9]{8}$');
    return regex.hasMatch(cleaned);
  }
  
  // ตรวจสอบอีเมล
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }
  
  // ตรวจสอบจำนวนเงิน
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณาใส่จำนวนเงิน';
    }
    
    final amount = parseAmount(value);
    if (amount == null) {
      return 'รูปแบบจำนวนเงินไม่ถูกต้อง';
    }
    
    if (amount <= 0) {
      return 'จำนวนเงินต้องมากกว่า 0';
    }
    
    if (amount > AppConstants.maxAmount) {
      return 'จำนวนเงินเกินขีดจำกัด';
    }
    
    return null;
  }
  
  // === UI HELPERS ===
  
  // แสดง SnackBar
  static void showSnackBar(
    BuildContext context, 
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  // แสดง Loading Dialog
  static void showLoadingDialog(BuildContext context, {String message = 'กำลังโหลด...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
  
  // ปิด Loading Dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  // แสดง Confirmation Dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'ยืนยัน',
    String cancelText = 'ยกเลิก',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.primaryGreen,
            ),
            child: Text(
              confirmText,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  // === DEVICE HELPERS ===
  
  // ตรวจสอบว่าเป็น iOS หรือไม่
  static bool get isIOS => Platform.isIOS;
  
  // ตรวจสอบว่าเป็น Android หรือไม่
  static bool get isAndroid => Platform.isAndroid;
  
  // สั่นเครื่อง (Haptic Feedback)
  static void vibrate() {
    HapticFeedback.lightImpact();
  }
  
  // สั่นเครื่องแรง
  static void vibrateHeavy() {
    HapticFeedback.heavyImpact();
  }
  
  // === COLOR HELPERS ===
  
  // สร้างสีแบบสุ่ม
  static Color getRandomColor() {
    final colors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    ];
    
    return colors[(DateTime.now().millisecondsSinceEpoch % colors.length)];
  }
  
  // แปลงสีเป็น hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  
  // แปลง hex string เป็นสี
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
  
  // === FILE HELPERS ===
  
  // สร้างชื่อไฟล์สำหรับ export
  static String generateFileName(String prefix, {String extension = 'json'}) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(now);
    return '${prefix}_$dateStr.$extension';
  }
  
  // แปลงข้อมูลเป็น JSON string
  static String toJsonString(Map<String, dynamic> data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }
  
  // แปลง JSON string เป็นข้อมูล
  static Map<String, dynamic>? fromJsonString(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing JSON: $e');
      return null;
    }
  }
  
  // === CALCULATION HELPERS ===
  
  // คำนวณเปอร์เซ็นต์
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }
  
  // คำนวณส่วนต่างเปอร์เซ็นต์
  static double calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return newValue > 0 ? 100 : 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }
  
  // คำนวณค่าเฉลี่ย
  static double calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
  
  // หาค่าสูงสุด
  static double findMaxValue(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a > b ? a : b);
  }
  
  // หาค่าต่ำสุด
  static double findMinValue(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a < b ? a : b);
  }
  
  // === TEXT HELPERS ===
  
  // ตัดข้อความให้สั้นลง
  static String truncateText(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + suffix;
  }
  
  // Capitalize คำแรก
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  // Capitalize ทุกคำ
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
  
  // ลบ HTML tags
  static String stripHtmlTags(String html) {
    final regex = RegExp(r'<[^>]*>');
    return html.replaceAll(regex, '');
  }
  
  // === SEARCH HELPERS ===
  
  // ค้นหาข้อความแบบไม่สนใจตัวพิมพ์เล็ก-ใหญ่
  static bool containsIgnoreCase(String source, String query) {
    return source.toLowerCase().contains(query.toLowerCase());
  }
  
  // ค้นหาหลายคำ
  static bool matchesMultipleKeywords(String source, List<String> keywords) {
    final lowerSource = source.toLowerCase();
    return keywords.every((keyword) => 
      lowerSource.contains(keyword.toLowerCase()));
  }
  
  // === ANIMATION HELPERS ===
  
  // สร้าง Animation Duration
  static Duration getAnimationDuration(String type) {
    switch (type.toLowerCase()) {
      case 'fast':
        return Duration(milliseconds: 150);
      case 'medium':
        return Duration(milliseconds: 300);
      case 'slow':
        return Duration(milliseconds: 500);
      default:
        return Duration(milliseconds: 300);
    }
  }
  
  // สร้าง Animation Curve
  static Curve getAnimationCurve(String type) {
    switch (type.toLowerCase()) {
      case 'bounce':
        return Curves.bounceOut;
      case 'elastic':
        return Curves.elasticOut;
      case 'ease':
        return Curves.easeInOut;
      case 'linear':
        return Curves.linear;
      default:
        return Curves.easeInOut;
    }
  }
}

// Extension สำหรับ DateTime
extension DateTimeExtension on DateTime {
  // เริ่มต้นวัน (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);
  
  // สิ้นสุดวัน (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
  
  // เริ่มต้นเดือน
  DateTime get startOfMonth => DateTime(year, month, 1);
  
  // สิ้นสุดเดือน
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);
  
  // เริ่มต้นปี
  DateTime get startOfYear => DateTime(year, 1, 1);
  
  // สิ้นสุดปี
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59);
  
  // ตรวจสอบว่าอยู่ในช่วงเวลาหรือไม่
  bool isBetween(DateTime start, DateTime end) {
    return isAfter(start) && isBefore(end) || 
           isAtSameMomentAs(start) || 
           isAtSameMomentAs(end);
  }
  
  // คำนวณอายุ
  int ageInYears(DateTime birthDate) {
    int age = year - birthDate.year;
    if (month < birthDate.month || 
        (month == birthDate.month && day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

// Extension สำหรับ String
extension StringExtension on String {
  // ตรวจสอบว่าเป็น null หรือว่างหรือไม่
  bool get isNullOrEmpty => isEmpty;
  
  // ตรวจสอบว่าไม่เป็น null และไม่ว่าง
  bool get isNotNullOrEmpty => isNotEmpty;
  
  // แปลงเป็นตัวเลข
  double? get toDouble => double.tryParse(this);
  int? get toInt => int.tryParse(this);
  
  // ตรวจสอบว่าเป็นตัวเลขหรือไม่
  bool get isNumeric => double.tryParse(this) != null;
  
  // ลบช่องว่างต้นและท้าย
  String get trimmed => trim();
  
  // Capitalize คำแรก
  String get capitalized => AppHelpers.capitalize(this);
  
  // Capitalize ทุกคำ
  String get capitalizedWords => AppHelpers.capitalizeWords(this);
}

// Extension สำหรับ List<double>
extension DoubleListExtension on List<double> {
  // คำนวณผลรวม
  double get sum => isEmpty ? 0 : reduce((a, b) => a + b);
  
  // คำนวณค่าเฉลี่ย
  double get average => isEmpty ? 0 : sum / length;
  
  // หาค่าสูงสุด
  double get max => isEmpty ? 0 : reduce((a, b) => a > b ? a : b);
  
  // หาค่าต่ำสุด
  double get min => isEmpty ? 0 : reduce((a, b) => a < b ? a : b);
}

// Extension สำหรับ Color
extension ColorExtension on Color {
  // แปลงเป็น hex string
  String get toHex => AppHelpers.colorToHex(this);
  
  // สร้างสีที่อ่อนลง
  Color get lighter => Color.lerp(this, Colors.white, 0.3) ?? this;
  
  // สร้างสีที่เข้มลง
  Color get darker => Color.lerp(this, Colors.black, 0.3) ?? this;
}