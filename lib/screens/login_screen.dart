// lib/screens/login_screen.dart — SPENDO v2
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../services/database_service.dart';
import '../providers/app_provider.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn) as Animation<double>;
    _fadeAnim  = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
    DatabaseService().init();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'กรุณากรอกเบอร์โทรศัพท์';
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 10) return 'เบอร์โทรต้องมี 10 หลัก';
    if (!cleaned.startsWith('0')) return 'เบอร์โทรต้องขึ้นต้นด้วย 0';
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    setState(() => _isLoading = true);
    try {
      await DatabaseService.setCurrentUser(phone);
      await DatabaseService().saveSetting('is_logged_in', true);
      await DatabaseService().saveSetting('user_phone', phone);
      await DatabaseService().saveSetting('last_login', DateTime.now().toIso8601String());
      if (mounted) {
        await Provider.of<AppProvider>(context, listen: false).loadAll();
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const DashboardScreen(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: AppColors.expenseRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  // ===== HEADER =====
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white30, width: 2),
                            ),
                            child: const Icon(Icons.account_balance_wallet, size: 48, color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Text('SPENDO', style: GoogleFonts.notoSansThai(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4)),
                          const SizedBox(height: 6),
                          Text(AppStrings.appSubtitle, style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.medium, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),

                  // ===== FORM CARD =====
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('เข้าสู่ระบบ', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.title, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(height: 6),
                              Text('ใส่เบอร์โทรศัพท์เพื่อเริ่มใช้งาน', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.medium, color: AppColors.textSecondary)),
                              const SizedBox(height: AppSpacing.xl),

                              // Phone field
                              Text('เบอร์โทรศัพท์', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.medium, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              const SizedBox(height: AppSpacing.sm),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                                validator: _validatePhone,
                                style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.regular, color: AppColors.textPrimary, letterSpacing: 1.5),
                                decoration: InputDecoration(
                                  hintText: '0XX-XXX-XXXX',
                                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryGreen),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                                ),
                                onFieldSubmitted: (_) => _handleLogin(),
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  child: _isLoading
                                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : Text('เข้าสู่ระบบ', style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.regular, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Info
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.incomeLight,
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'ข้อมูลของคุณถูกเก็บบนอุปกรณ์ของคุณเองอย่างปลอดภัย',
                                        style: GoogleFonts.notoSansThai(fontSize: AppFontSizes.small, color: AppColors.darkGreen),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
