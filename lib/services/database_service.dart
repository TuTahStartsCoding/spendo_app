// lib/services/database_service.dart — SPENDO v2
import 'package:hive/hive.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/budget.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static String? _currentUserPhone;

  late Box<Transaction> _transactionsBox;
  late Box<Category> _categoriesBox;
  late Box<Budget> _budgetsBox;
  late Box _settingsBox;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionAdapter());
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TransactionTypeAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(CategoryAdapter());
      if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(BudgetAdapter());
      _initialized = true;
    } catch (e) {
      print('DatabaseService init error: $e');
    }
  }

  // ==================== USER ====================
  static Future<void> setCurrentUser(String phoneNumber) async {
    _currentUserPhone = phoneNumber;
    final tx  = 'transactions_$phoneNumber';
    final cat = 'categories_$phoneNumber';
    final bud = 'budgets_$phoneNumber';
    final set = 'settings_$phoneNumber';

    await Hive.openBox<Transaction>(tx);
    await Hive.openBox<Category>(cat);
    await Hive.openBox<Budget>(bud);
    await Hive.openBox(set);

    _instance._transactionsBox = Hive.box<Transaction>(tx);
    _instance._categoriesBox   = Hive.box<Category>(cat);
    _instance._budgetsBox      = Hive.box<Budget>(bud);
    _instance._settingsBox     = Hive.box(set);

    await _instance._initializeDefaultCategories();
  }

  static String? get currentUserPhone => _currentUserPhone;

  static Future<void> clearCurrentUser() async {
    if (_currentUserPhone != null) {
      final p = _currentUserPhone!;
      await Hive.box<Transaction>('transactions_$p').close();
      await Hive.box<Category>('categories_$p').close();
      await Hive.box<Budget>('budgets_$p').close();
      await Hive.box('settings_$p').close();
      _currentUserPhone = null;
    }
  }

  // ==================== CATEGORIES ====================
  Future<void> _initializeDefaultCategories() async {
    if (_categoriesBox.isEmpty) {
      for (var cat in DefaultCategories.allCategories) {
        await _categoriesBox.put(cat.id, cat);
      }
    }
  }

  List<Category> getAllCategories()    => _categoriesBox.values.where((c) => c.isActive).toList();
  List<Category> getExpenseCategories() => getAllCategories().where((c) => c.isExpense).toList();
  List<Category> getIncomeCategories()  => getAllCategories().where((c) => c.isIncome).toList();
  Category? getCategory(String id)     => _categoriesBox.get(id);

  Future<void> addCategory(Category cat)    async => await _categoriesBox.put(cat.id, cat);
  Future<void> updateCategory(Category cat) async => await _categoriesBox.put(cat.id, cat);
  Future<void> deleteCategory(String id)    async => await _categoriesBox.delete(id);

  // ==================== TRANSACTIONS ====================
  Future<void> addTransaction(Transaction t) async    => await _transactionsBox.put(t.id, t);
  Future<void> deleteTransaction(String id)  async    => await _transactionsBox.delete(id);
  Future<void> updateTransaction(Transaction t) async =>
      await _transactionsBox.put(t.id, t.copyWith(updatedAt: DateTime.now()));

  List<Transaction> getAllTransactions() => _transactionsBox.values.toList();
  Transaction? getTransaction(String id) => _transactionsBox.get(id);

  List<Transaction> getRecentTransactions({int limit = 10}) {
    final list = getAllTransactions()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(limit).toList();
  }

  List<Transaction> getTransactionsByType(TransactionType type) =>
      getAllTransactions().where((t) => t.type == type).toList();

  List<Transaction> getTransactionsByCategory(String category) =>
      getAllTransactions().where((t) => t.category == category).toList();

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return getAllTransactions()
        .where((t) => !t.createdAt.isBefore(s) && !t.createdAt.isAfter(e))
        .toList();
  }

  /// รายการในเดือนปัจจุบัน
  List<Transaction> getThisMonthTransactions() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end   = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getTransactionsByDateRange(start, end);
  }

  double getTotalIncome()   => getTransactionsByType(TransactionType.income).fold(0.0, (s, t) => s + t.amount);
  double getTotalExpense()  => getTransactionsByType(TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
  double getTotalBalance()  => getTotalIncome() - getTotalExpense();

  double getMonthlyIncome()  => getThisMonthTransactions().where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
  double getMonthlyExpense() => getThisMonthTransactions().where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount);

  Map<String, double> getTotalByCategory({bool expenseOnly = true}) {
    final Map<String, double> result = {};
    final list = expenseOnly
        ? getTransactionsByType(TransactionType.expense)
        : getAllTransactions();
    for (final t in list) {
      result[t.category] = (result[t.category] ?? 0.0) + t.amount;
    }
    return result;
  }

  /// Trend: รายได้/รายจ่ายย้อนหลัง N เดือน
  Map<String, Map<String, double>> getMonthlyTrend({int months = 6}) {
    final result = <String, Map<String, double>>{};
    final now = DateTime.now();
    for (int i = months - 1; i >= 0; i--) {
      final target = DateTime(now.year, now.month - i, 1);
      final key    = '${target.year}-${target.month.toString().padLeft(2, '0')}';
      final start  = DateTime(target.year, target.month, 1);
      final end    = DateTime(target.year, target.month + 1, 0, 23, 59, 59);
      final txs    = getTransactionsByDateRange(start, end);
      result[key]  = {
        'income':  txs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount),
        'expense': txs.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount),
      };
    }
    return result;
  }

  // ==================== BUDGETS ====================
  Future<void> saveBudget(Budget budget) async => await _budgetsBox.put(budget.id, budget);
  Future<void> deleteBudget(String id)   async => await _budgetsBox.delete(id);

  List<Budget> getBudgets() => _budgetsBox.values.toList();

  List<Budget> getBudgetsForMonth(int month, int year) =>
      getBudgets().where((b) => b.month == month && b.year == year).toList();

  /// คำนวณว่าแต่ละ budget ใช้ไปเท่าไหร่ในเดือนนั้น
  Map<String, double> getBudgetSpending(int month, int year) {
    final start = DateTime(year, month, 1);
    final end   = DateTime(year, month + 1, 0, 23, 59, 59);
    final txs   = getTransactionsByDateRange(start, end).where((t) => t.isExpense);
    final Map<String, double> spending = {};
    for (final t in txs) {
      spending[t.category] = (spending[t.category] ?? 0.0) + t.amount;
    }
    return spending;
  }

  // ==================== SETTINGS ====================
  Future<void> saveSetting(String key, dynamic value) async => await _settingsBox.put(key, value);
  T? getSetting<T>(String key, {T? defaultValue}) => _settingsBox.get(key, defaultValue: defaultValue) as T?;
  Future<void> deleteSetting(String key) async => await _settingsBox.delete(key);

  // ==================== EXPORT / IMPORT ====================
  Map<String, dynamic> exportData() => {
        'transactions': getAllTransactions().map((t) => t.toMap()).toList(),
        'categories':   getAllCategories().map((c) => c.toMap()).toList(),
        'budgets':      getBudgets().map((b) => b.toMap()).toList(),
        'exportDate':   DateTime.now().toIso8601String(),
        'version':      '2.0',
      };

  Future<void> clearAllData() async {
    await _transactionsBox.clear();
    await _categoriesBox.clear();
    await _budgetsBox.clear();
    await _settingsBox.clear();
    await _initializeDefaultCategories();
  }
}
