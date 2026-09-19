// lib/models/transaction.dart
// โมเดลสำหรับเก็บข้อมูลธุรกรรม (รายรับ-รายจ่าย) - แก้ไขแล้ว
import 'package:hive/hive.dart';

// part directive สำหรับ generated code
part 'transaction.g.dart';

// Enum สำหรับประเภทธุรกรรม
@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,   // รายรับ
  
  @HiveField(1)
  expense   // รายจ่าย
}

// โมเดลธุรกรรม
@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  double amount;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  String category;
  
  @HiveField(4)
  TransactionType type;
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  DateTime? updatedAt;
  
  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.type,
    required this.createdAt,
    this.updatedAt,
  });
  
  // สร้าง Transaction จาก Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      type: map['type'] == 'income' 
          ? TransactionType.income 
          : TransactionType.expense,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is DateTime
              ? map['updatedAt']
              : DateTime.tryParse(map['updatedAt']))
          : null,
    );
  }
  
  // แปลง Transaction เป็น Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
  
  // สร้างสำเนาของ Transaction พร้อมการแก้ไข
  Transaction copyWith({
    String? id,
    double? amount,
    String? description,
    String? category,
    TransactionType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // ตรวจสอบว่าเป็นรายรับหรือไม่
  bool get isIncome => type == TransactionType.income;
  
  // ตรวจสอบว่าเป็นรายจ่ายหรือไม่
  bool get isExpense => type == TransactionType.expense;
  
  // แสดงจำนวนเงินพร้อมเครื่องหมาย
  String get formattedAmount {
    final sign = isIncome ? '+' : '-';
    return '$sign฿${amount.toStringAsFixed(2)}';
  }
  
  // แสดงวันที่ในรูปแบบที่อ่านง่าย
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
           '${createdAt.month.toString().padLeft(2, '0')}/'
           '${createdAt.year}';
  }
  
  // แสดงเวลาในรูปแบบที่อ่านง่าย
  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:'
           '${createdAt.minute.toString().padLeft(2, '0')}';
  }
  
  // แสดงวันที่และเวลา
  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }
  
  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, description: $description, '
           'category: $category, type: $type, createdAt: $createdAt)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
           other.id == id &&
           other.amount == amount &&
           other.description == description &&
           other.category == category &&
           other.type == type;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
           amount.hashCode ^
           description.hashCode ^
           category.hashCode ^
           type.hashCode;
  }
}