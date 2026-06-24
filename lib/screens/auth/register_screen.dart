import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_sizes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran berhasil! Silakan masuk.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Pendaftaran gagal'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
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
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
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
                              'Buat Akun Baru',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E1E1E),
                                fontSize: s.fontXl,
                              ),
                            ),
                            SizedBox(height: s.spacingXS),
                            Text(
                              'Isi data berikut untuk membuat akun',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: s.fontMd),
                            ),
                            SizedBox(height: s.spacingLg),
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
                                if (v.length < 6) return 'Minimal 6 karakter';
                                return null;
                              },
                            ),
                            SizedBox(height: s.spacing),
                            _buildTextField(
                              s: s,
                              controller: _confirmPasswordController,
                              label: 'Konfirmasi Kata Sandi',
                              icon: Icons.lock_clock_outlined,
                              isPassword: true,
                              obscureText: _obscurePassword,
                              validator: (v) {
                                if (v != _passwordController.text) return 'Kata sandi tidak cocok';
                                return null;
                              },
                            ),
                            SizedBox(height: s.spacingLg),
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return ElevatedButton(
                                  onPressed:
                                      auth.isLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        vertical: s.spacingLg),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(s.radiusLg),
                                    ),
                                    elevation: 8,
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
                                          'DAFTAR',
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
                        Text('Sudah punya akun?',
                            style: TextStyle(color: Colors.grey[600], fontSize: s.fontMd)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Masuk Sekarang',
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
