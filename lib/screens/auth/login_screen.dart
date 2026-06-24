import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../utils/app_sizes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final profileProvider = context.read<ProfileProvider>();
      final hasProfile = await profileProvider.checkProfileExists();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        hasProfile ? '/dashboard' : '/profile-form',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login gagal'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = AppSizes(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.7),
                  Colors.white,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: s.paddingLg),
                child: Column(
                  children: [
                    SizedBox(height: s.spacingSm),
                    Hero(
                      tag: 'logo',
                      child: Container(
                        padding: EdgeInsets.all(s.spacingSm + 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          size: s.iconXl,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: s.spacing),
                    Text(
                      'StuntingCare',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        fontSize: s.font2xl,
                      ),
                    ),
                    SizedBox(height: s.spacingXS),
                    Text(
                      'Mulai Untuk Pencegahan Stunting',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: s.fontMd,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: s.spacingLg),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: s.paddingLg, vertical: s.spacingLg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(s.radius2x),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Selamat Datang',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E1E1E),
                                fontSize: s.fontXl,
                              ),
                            ),
                            SizedBox(height: s.spacingXS),
                            Text(
                              'Silakan masuk untuk melanjutkan',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: s.fontMd),
                            ),
                            SizedBox(height: s.spacingXL),
                            _buildTextField(
                              s: s,
                              controller: _emailController,
                              label: 'Alamat Email',
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                                if (!v.contains('@')) return 'Format email tidak valid';
                                return null;
                              },
                            ),
                            SizedBox(height: s.spacing),
                            _buildTextField(
                              s: s,
                              controller: _passwordController,
                              label: 'Kata Sandi',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              obscureText: _obscurePassword,
                              onToggleVisibility: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Kata sandi tidak boleh kosong';
                                return null;
                              },
                            ),
                            SizedBox(height: s.spacingXS),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, '/forgot-password'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Lupa Kata Sandi?',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: s.fontSm,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: s.spacingLg),
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return ElevatedButton(
                                  onPressed:
                                      auth.isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        vertical: s.spacingLg),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(s.radiusLg),
                                    ),
                                    elevation: 8,
                                    shadowColor: colorScheme.primary
                                        .withValues(alpha: 0.4),
                                  ),
                                  child: auth.isLoading
                                      ? SizedBox(
                                          height: s.iconMd,
                                          width: s.iconMd,
                                          child: const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2),
                                        )
                                      : Text(
                                          'MASUK',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: s.fontLg,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5),
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: s.spacingLg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Belum punya akun?',
                            style: TextStyle(color: Colors.grey[600], fontSize: s.fontMd)),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: s.fontMd),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: s.spacing),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required AppSizes s,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscureText,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: s.fontMd),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey[400], fontSize: s.fontMd),
        prefixIcon: Icon(icon, color: Colors.blueGrey[300], size: s.iconSm),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.blueGrey[200],
                  size: s.iconSm,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(s.radiusMd),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(s.radiusMd),
            borderSide: BorderSide(color: Colors.grey[100]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(s.radiusMd),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(s.radiusMd),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
        contentPadding:
            EdgeInsets.symmetric(horizontal: s.paddingLg, vertical: s.spacing),
      ),
      validator: validator,
    );
  }
}
