// lib/models/category.dart
// โมเดลสำหรับเก็บข้อมูลหมวดหมู่รายรับ-รายจ่าย
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

// ประกาศให้ Hive รู้จักคลาสนี้ โดยกำหนด typeId = 2
part 'category.g.dart';

@HiveType(typeId: 2)
class Category extends HiveObject {
  // ID ของหมวดหมู่
  @HiveField(0)
  String id;

  // ชื่อหมวดหมู่
  @HiveField(1)
  String name;

  // ชื่อไอคอนของหมวดหมู่ (เช่น 'food', 'transport')
  @HiveField(2)
  String iconName;

  // สีของหมวดหมู่ (เก็บเป็น int value)
  @HiveField(3)
  int colorValue;

  // ประเภทของหมวดหมู่ (รายรับ/รายจ่าย)
  @HiveField(4)
  String type; // 'income' หรือ 'expense'

  // สถานะการใช้งาน
  @HiveField(5)
  bool isActive;

  // วันที่สร้าง
  @HiveField(6)
  DateTime createdAt;

  // Constructor
  Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.type,
    this.isActive = true,
    required this.createdAt,
  });

  // Map ไอคอน string → IconData const
  static const Map<String, IconData> _iconMap = {
    'food': Icons.fastfood,
    'transport': Icons.directions_car,
    'shopping': Icons.shopping_cart,
    'entertainment': Icons.movie,
    'bills': Icons.receipt,
    'salary': Icons.attach_money,
    'bonus': Icons.card_giftcard,
    'other': Icons.category,
  };

  // Getter สำหรับไอคอน
  IconData get icon => _iconMap[iconName] ?? Icons.category;

  // Getter สำหรับสี
  Color get color => Color(colorValue);

  // ตรวจสอบว่าเป็นหมวดหมู่รายรับหรือไม่
  bool get isIncome => type == 'income';

  // ตรวจสอบว่าเป็นหมวดหมู่รายจ่ายหรือไม่
  bool get isExpense => type == 'expense';

  // สร้าง Category จาก Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      iconName: map['iconName'] ?? 'other',
      colorValue: map['colorValue'] ?? Colors.grey.value,
      type: map['type'] ?? 'expense',
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  // แปลง Category เป็น Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'colorValue': colorValue,
      'type': type,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // สร้างสำเนาของ Category พร้อมการแก้ไขค่าบางอย่าง
  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    int? colorValue,
    String? type,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: $type, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.iconName == iconName &&
        other.colorValue == colorValue &&
        other.type == type &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        iconName.hashCode ^
        colorValue.hashCode ^
        type.hashCode ^
        isActive.hashCode;
  }
}

// คลาสสำหรับจัดการหมวดหมู่เริ่มต้น
class DefaultCategories {
  // หมวดหมู่รายจ่ายเริ่มต้น
  static List<Category> get expenseCategories => [
        Category(
          id: 'exp_food',
          name: 'Food',
          iconName: 'food',
          colorValue: Colors.orange.value,
          type: 'expense',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 'exp_transport',
          name: 'Transport',
          iconName: 'transport',
          colorValue: Colors.blue.value,
          type: 'expense',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 'exp_shopping',
          name: 'Shopping',
          iconName: 'shopping',
          colorValue: Colors.pink.value,
          type: 'expense',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 'exp_entertainment',
          name: 'Entertainment',
          iconName: 'entertainment',
          colorValue: Colors.purple.value,
          type: 'expense',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 'exp_bills',
          name: 'Bills',
          iconName: 'bills',
          colorValue: Colors.red.value,
          type: 'expense',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 'exp_other',
          name: 'Other',
          iconName: 'other',
          colorValue: Colors.grey.value,
          type: 'expense',
          createdAt: DateTime.now(),
        ),
      ];

  // หมวดหมู่รายรับเริ่มต้น
  static List<Category> get incomeCategories => [
        Category(
          id: 'inc_salary',
          name: 'Salary',
          iconName: 'salary',
          colorValue: Colors.green.value,
          type: 'income',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 'inc_bonus',
          name: 'Bonus',
          iconName: 'bonus',
          colorValue: Colors.teal.value,
          type: 'income',
          createdAt: DateTime.now(),
        ),
        Category(
          id: 'inc_other',
          name: 'Other',
          iconName: 'other',
          colorValue: Colors.cyan.value,
          type: 'income',
          createdAt: DateTime.now(),
        ),
      ];

  // หมวดหมู่ทั้งหมด
  static List<Category> get allCategories => [
        ...expenseCategories,
        ...incomeCategories,
      ];
}