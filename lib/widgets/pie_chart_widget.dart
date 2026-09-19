// lib/widgets/pie_chart_widget.dart
// Widget สำหรับแสดงแผนภูมิวงกลม - แสดงสัดส่วนรายจ่ายตามหมวดหมู่
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../services/database_service.dart';
import '../models/category.dart';

class PieChartWidget extends StatefulWidget {
  // ข้อมูลยอดรวมตามหมวดหมู่
  final Map<String, double> categoryTotals;
  
  const PieChartWidget({
    Key? key,
    required this.categoryTotals,
  }) : super(key: key);

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  // Database service instance
  final DatabaseService _databaseService = DatabaseService();
  
  // เก็บข้อมูลหมวดหมู่
  Map<String, Category> _categories = {};
  
  // Index ของส่วนที่ถูกแตะ
  int _touchedIndex = -1;
  
  // สีสำหรับแต่ละส่วนของแผนภูมิ
  final List<Color> _colors = [
    Colors.orange,
    Colors.blue,
    Colors.pink,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.amber,
    Colors.green,
    Colors.indigo,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
  ];
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }
  
  // โหลดข้อมูลหมวดหมู่
  void _loadCategories() {
    final categories = _databaseService.getAllCategories();
    _categories = {
      for (var category in categories) category.name: category
    };
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    // ตรวจสอบว่ามีข้อมูลหรือไม่
    if (widget.categoryTotals.isEmpty) {
      return _buildEmptyChart();
    }
    
    return Column(
      children: [
        // แผนภูมิ
        Container(
          height: 200,
          child: PieChart(
            PieChartData(
              // ระยะห่างจากจุดกึ่งกลาง
              sectionsSpace: 2,
              
              // รัศมีจุดกึ่งกลาง
              centerSpaceRadius: 40,
              
              // ข้อมูลแต่ละส่วน
              sections: _buildPieChartSections(),
              
              // การจัดการการแตะ
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
        ),
        
        SizedBox(height: AppSpacing.md),
        
        // คำอธิบายแผนภูมิ
        _buildLegend(),
      ],
    );
  }
  
  // สร้างข้อมูลแต่ละส่วนของแผนภูมิ
  List<PieChartSectionData> _buildPieChartSections() {
    final List<PieChartSectionData> sections = [];
    
    // คำนวณยอดรวมทั้งหมด
    final double total = widget.categoryTotals.values.fold(0.0, (a, b) => a + b);
    
    int index = 0;
    widget.categoryTotals.forEach((category, amount) {
      // คำนวณเปอร์เซ็นต์
      final double percentage = (amount / total) * 100;
      
      // ตรวจสอบว่าเป็นส่วนที่ถูกแตะหรือไม่
      final bool isTouched = index == _touchedIndex;
      
      // สร้าง Section
      sections.add(
        PieChartSectionData(
          color: _getColorForCategory(category, index),
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: isTouched ? 110 : 100,
          titleStyle: GoogleFonts.notoSansThai(
            fontSize: isTouched ? 14 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 2,
              ),
            ],
          ),
          titlePositionPercentageOffset: 0.6,
        ),
      );
      
      index++;
    });
    
    return sections;
  }
  
  // ดึงสีสำหรับหมวดหมู่
  Color _getColorForCategory(String categoryName, int index) {
    // ตรวจสอบว่ามีหมวดหมู่ในฐานข้อมูลหรือไม่
    if (_categories.containsKey(categoryName)) {
      return _categories[categoryName]!.color;
    }
    
    // ใช้สีจาก array หากไม่พบ
    return _colors[index % _colors.length];
  }
  
  // ดึงไอคอนสำหรับหมวดหมู่
  IconData _getIconForCategory(String categoryName) {
    if (_categories.containsKey(categoryName)) {
      return _categories[categoryName]!.icon;
    }
    
    return AppIcons.other;
  }
  
  // สร้างคำอธิบายแผนภูมิ
  Widget _buildLegend() {
    return Column(
      children: widget.categoryTotals.entries.map((entry) {
        final int index = widget.categoryTotals.keys.toList().indexOf(entry.key);
        final String category = entry.key;
        final double amount = entry.value;
        
        // คำนวณเปอร์เซ็นต์
        final double total = widget.categoryTotals.values.fold(0.0, (a, b) => a + b);
        final double percentage = (amount / total) * 100;
        
        return Container(
          margin: EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              // จุดสี
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getColorForCategory(category, index),
                  shape: BoxShape.circle,
                ),
              ),
              
              SizedBox(width: 8),
              
              // ไอคอนหมวดหมู่
              Icon(
                _getIconForCategory(category),
                size: 16,
                color: AppColors.darkGray,
              ),
              
              SizedBox(width: 8),
              
              // ชื่อหมวดหมู่
              Expanded(
                child: Text(
                  category,
                  style: GoogleFonts.notoSansThai(
                    fontSize: AppFontSizes.small,
                    color: AppColors.black,
                  ),
                ),
              ),
              
              // จำนวนเงินและเปอร์เซ็นต์
              Text(
                '฿${amount.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                style: GoogleFonts.notoSansThai(
                  fontSize: AppFontSizes.small,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  // แผนภูมิเปล่าเมื่อไม่มีข้อมูล
  Widget _buildEmptyChart() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: AppColors.lightGray,
            ),
            SizedBox(height: 16),
            Text(
              'ยังไม่มีข้อมูล',
              style: GoogleFonts.notoSansThai(
                fontSize: AppFontSizes.medium,
                color: AppColors.darkGray,
              ),
            ),
            Text(
              'เริ่มบันทึกรายจ่ายของคุณ',
              style: GoogleFonts.notoSansThai(
                fontSize: AppFontSizes.small,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}