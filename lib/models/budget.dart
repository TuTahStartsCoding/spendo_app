// lib/models/budget.dart — งบประมาณรายหมวดหมู่
import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 3)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryName;

  @HiveField(2)
  double limitAmount;

  @HiveField(3)
  int month; // 1-12

  @HiveField(4)
  int year;

  @HiveField(5)
  DateTime createdAt;

  Budget({
    required this.id,
    required this.categoryName,
    required this.limitAmount,
    required this.month,
    required this.year,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'categoryName': categoryName,
        'limitAmount': limitAmount,
        'month': month,
        'year': year,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Budget.fromMap(Map<String, dynamic> map) => Budget(
        id: map['id'] ?? '',
        categoryName: map['categoryName'] ?? '',
        limitAmount: (map['limitAmount'] ?? 0.0).toDouble(),
        month: map['month'] ?? DateTime.now().month,
        year: map['year'] ?? DateTime.now().year,
        createdAt: map['createdAt'] is DateTime
            ? map['createdAt']
            : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      );

  String get monthYearKey => '$year-$month';
}
