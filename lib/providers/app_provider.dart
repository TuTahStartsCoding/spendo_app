// lib/providers/app_provider.dart — SPENDO v2
import 'package:flutter/foundation.dart' hide Category;
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/budget.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  // ======== STATE ========
  bool _isLoading = false;
  double _totalBalance  = 0;
  double _totalIncome   = 0;
  double _totalExpense  = 0;
  double _monthlyIncome  = 0;
  double _monthlyExpense = 0;

  List<Transaction> _recentTransactions = [];
  List<Transaction> _allTransactions    = [];
  List<Category>    _categories         = [];
  List<Budget>      _budgets            = [];
  Map<String, double> _categoryTotals  = {};
  Map<String, Map<String, double>> _monthlyTrend = {};

  // ======== GETTERS ========
  bool    get isLoading        => _isLoading;
  double  get totalBalance     => _totalBalance;
  double  get totalIncome      => _totalIncome;
  double  get totalExpense     => _totalExpense;
  double  get monthlyIncome    => _monthlyIncome;
  double  get monthlyExpense   => _monthlyExpense;
  double  get monthlySavings   => _monthlyIncome - _monthlyExpense;
  List<Transaction> get recentTransactions => _recentTransactions;
  List<Transaction> get allTransactions    => _allTransactions;
  List<Category>    get categories         => _categories;
  List<Budget>      get budgets            => _budgets;
  Map<String, double> get categoryTotals  => _categoryTotals;
  Map<String, Map<String, double>> get monthlyTrend => _monthlyTrend;

  // ======== LOAD ========
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      _totalIncome   = _db.getTotalIncome();
      _totalExpense  = _db.getTotalExpense();
      _totalBalance  = _db.getTotalBalance();
      _monthlyIncome  = _db.getMonthlyIncome();
      _monthlyExpense = _db.getMonthlyExpense();

      _allTransactions    = _db.getAllTransactions()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _recentTransactions = _db.getRecentTransactions(limit: 10);
      _categories         = _db.getAllCategories();
      _budgets            = _db.getBudgets();
      _categoryTotals     = _db.getTotalByCategory();
      _monthlyTrend       = _db.getMonthlyTrend(months: 6);
    } catch (e) {
      debugPrint('AppProvider loadAll error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ======== TRANSACTIONS ========
  Future<void> addTransaction(Transaction t) async {
    await _db.addTransaction(t);
    await loadAll();
  }

  Future<void> updateTransaction(Transaction t) async {
    await _db.updateTransaction(t);
    await loadAll();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    await loadAll();
  }

  // ======== BUDGETS ========
  Future<void> saveBudget(Budget b) async {
    await _db.saveBudget(b);
    await loadAll();
  }

  Future<void> deleteBudget(String id) async {
    await _db.deleteBudget(id);
    await loadAll();
  }

  Map<String, double> getBudgetSpending(int month, int year) =>
      _db.getBudgetSpending(month, year);

  List<Budget> getBudgetsForMonth(int month, int year) =>
      _db.getBudgetsForMonth(month, year);

  // ======== FILTER ========
  List<Transaction> getFilteredTransactions({
    DateTime? start,
    DateTime? end,
    TransactionType? type,
    String? category,
  }) {
    var list = _allTransactions;
    if (type     != null) list = list.where((t) => t.type == type).toList();
    if (category != null) list = list.where((t) => t.category == category).toList();
    if (start    != null) list = list.where((t) => !t.createdAt.isBefore(start)).toList();
    if (end      != null) list = list.where((t) => !t.createdAt.isAfter(end)).toList();
    return list;
  }
}
