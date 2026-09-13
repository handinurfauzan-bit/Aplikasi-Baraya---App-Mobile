import 'package:flutter/material.dart';
import '../widgets/aura_logo.dart';
import '../widgets/brand_logos.dart';
import '../widgets/social_button.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty) {
      _snack('Nama lengkap wajib diisi');
      return;
    }
    if (username.isEmpty) {
      _snack('Username wajib diisi');
      return;
    }
    if (!email.contains('@')) {
      _snack('Masukkan email yang valid');
      return;
    }
    if (phone.isNotEmpty && phone.replaceAll(RegExp('[^0-9]'), '').length < 9) {
      _snack('Nomor HP tidak valid');
      return;
    }
    if (password.length < 6) {
      _snack('Kata sandi minimal 6 karakter');
      return;
    }
    if (password != confirm) {
      _snack('Konfirmasi kata sandi tidak sama');
      return;
    }
    _submitSuccess();
  }

  void _submitSuccess() {
    final messenger = ScaffoldMessenger.of(context);
    final name = _nameController.text.trim();
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Pendaftaran berhasil. Silakan masuk, $name!'),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _goToHome() {
    final name = _nameController.text.trim();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) =>
            HomeScreen(communityId: 'kumpul_001', welcomeName: name),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              const Color(0xFF16A34A).withValues(alpha: 0.25),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        color: const Color(0xFF14532D),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const AuraLogo(
                  asset: 'assets/logo1.1.png',
                  size: 95,
                  auraSize: 160,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Daftar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F3D24),
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gabung dan mulailah berkomunitas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7C72)),
                ),
                const SizedBox(height: 20),
                _field(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'misal: Handi Nurfauzan',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'misal: dimasaditya',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'nama@email.com',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _phoneController,
                  label: 'Nomor HP (opsional)',
                  hint: '08xxxxxxxxxx',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _decoration(
                    label: 'Kata Sandi',
                    hint: 'Minimal 6 karakter',
                    icon: Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  decoration: _decoration(
                    label: 'Konfirmasi Kata Sandi',
                    hint: 'Ulangi kata sandi kamu',
                    icon: Icons.lock_reset_outlined,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirm = !_obscureConfirm,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Daftar',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun?',
                      style: TextStyle(fontSize: 13, color: Color(0xFF5F6F65)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Masuk sekarang',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.black12)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'atau daftar dengan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.black12)),
                  ],
                ),
                const SizedBox(height: 14),
                SocialButton(
                  height: 48,
                  icon: const GoogleLogo(size: 22),
                  label: 'Daftar dengan Google',
                  onPressed: _goToHome,
                ),
                const SizedBox(height: 10),
                SocialButton(
                  height: 48,
                  icon: const AppleLogo(size: 22),
                  label: 'Daftar dengan Apple',
                  onPressed: _goToHome,
                ),
                const SizedBox(height: 10),
                SocialButton(
                  height: 48,
                  icon: const FacebookLogo(size: 22),
                  label: 'Daftar dengan Facebook',
                  onPressed: _goToHome,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _decoration(label: label, hint: hint, icon: icon),
    );
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
    );
  }
}
