// lib/main.dart — SPENDO v2
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'models/transaction.dart';
import 'models/category.dart';
import 'models/budget.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/constants.dart';
import 'services/database_service.dart';
import 'providers/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TransactionAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TransactionTypeAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(CategoryAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(BudgetAdapter());
    await Hive.openBox<Transaction>('transactions');
    await Hive.openBox<Category>('categories');
    await Hive.openBox<Budget>('budgets');
    await Hive.openBox('settings');
  } catch (e) {
    debugPrint('❌ Hive init error: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPENDO',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(context),
      home: const SplashScreen(),
      routes: {
        '/login':     (_) => const LoginScreen(),
        '/dashboard': (_) => const DashboardScreen(),
      },
      onUnknownRoute: (s) => MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        brightness: Brightness.light,
        primary: AppColors.primaryGreen,
        secondary: AppColors.darkGreen,
        surface: AppColors.surfaceColor,
        background: AppColors.backgroundColor,
        error: AppColors.expenseRed,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundColor,
      textTheme: GoogleFonts.notoSansThaiTextTheme(base.textTheme).copyWith(
        displayLarge:  GoogleFonts.notoSansThai(fontSize: AppFontSizes.display, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.notoSansThai(fontSize: AppFontSizes.title,   fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleLarge:   GoogleFonts.notoSansThai(fontSize: AppFontSizes.large,   fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        bodyMedium:   GoogleFonts.notoSansThai(fontSize: AppFontSizes.medium,  color: AppColors.textPrimary),
        bodySmall:    GoogleFonts.notoSansThai(fontSize: AppFontSizes.small,   color: AppColors.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.notoSansThai(
          fontSize: AppFontSizes.large,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardColor,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
          textStyle: GoogleFonts.notoSansThai(fontSize: AppFontSizes.regular, fontWeight: FontWeight.bold),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.expenseRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.notoSansThai(color: AppColors.mediumGray, fontSize: AppFontSizes.medium),
        labelStyle: GoogleFonts.notoSansThai(color: AppColors.darkGray, fontSize: AppFontSizes.medium),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.notoSansThai(fontSize: AppFontSizes.medium, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.small)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ==================== SPLASH ====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fadeAnim  = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    try {
      await DatabaseService().init();
      await Future.delayed(const Duration(milliseconds: 2000));
      final isLoggedIn = DatabaseService().getSetting<bool>('is_logged_in', defaultValue: false) ?? false;
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => isLoggedIn ? const DashboardScreen() : const LoginScreen(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF00897B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: const Icon(Icons.account_balance_wallet, size: 56, color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(height: 28),
                Text('SPENDO', style: GoogleFonts.notoSansThai(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4)),
                const SizedBox(height: 8),
                Text(AppStrings.appSubtitle, style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.medium, color: Colors.white70, fontWeight: FontWeight.w300)),
                const SizedBox(height: 60),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text('กำลังโหลด...', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.small, color: Colors.white60)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
