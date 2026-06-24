import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_sizes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordReset(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() => _emailSent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Gagal mengirim email'),
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
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.favorite_rounded, size: s.iconXl, color: colorScheme.primary),
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
                      padding: EdgeInsets.symmetric(horizontal: s.paddingLg, vertical: s.spacingXL),
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
                      child: _emailSent
                          ? _buildSuccessContent(s, colorScheme)
                          : _buildFormContent(s, theme, colorScheme),
                    ),
                    SizedBox(height: s.spacingLg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sudah ingat kata sandi?',
                            style: TextStyle(color: Colors.grey[600], fontSize: s.fontMd)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Kembali ke Login',
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

  Widget _buildFormContent(AppSizes s, ThemeData theme, ColorScheme colorScheme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.all(s.spacing),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_reset_rounded, size: s.iconXl, color: colorScheme.primary),
            ),
          ),
          SizedBox(height: s.spacingLg),
          Text(
            'Lupa Kata Sandi?',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1E1E),
              fontSize: s.fontXl,
            ),
          ),
          SizedBox(height: s.spacingXS),
          Text(
            'Masukkan email Anda yang terdaftar, kami akan mengirimkan tautan untuk mengatur ulang kata sandi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: s.fontMd),
          ),
          SizedBox(height: s.spacingXL),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontSize: s.fontMd),
            decoration: InputDecoration(
              labelText: 'Alamat Email',
              labelStyle: TextStyle(color: Colors.blueGrey[400], fontSize: s.fontMd),
              prefixIcon: Icon(Icons.alternate_email_rounded, color: Colors.blueGrey[300], size: s.iconSm),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(s.radiusMd), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(s.radiusMd),
                  borderSide: BorderSide(color: Colors.grey[100]!)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(s.radiusMd),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1.5)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(s.radiusMd),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: s.paddingLg, vertical: s.spacing),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
              if (!v.contains('@')) return 'Format email tidak valid';
              return null;
            },
          ),
          SizedBox(height: s.spacingXL),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return ElevatedButton(
                onPressed: auth.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: s.spacingLg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(s.radiusLg),
                  ),
                  elevation: 8,
                ),
                child: auth.isLoading
                    ? SizedBox(
                        height: s.iconMd,
                        width: s.iconMd,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'KIRIM TAUTAN RESET',
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
    );
  }

  Widget _buildSuccessContent(AppSizes s, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(s.spacingLg),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read_rounded, size: s.icon2xl, color: Colors.green),
        ),
        SizedBox(height: s.spacingLg),
        Text(
          'Email Terkirim!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: s.font2xl, color: const Color(0xFF1E1E1E)),
        ),
        SizedBox(height: s.spacing),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(color: Colors.grey[600], fontSize: s.fontMd, height: 1.5),
            children: [
              const TextSpan(text: 'Tautan reset kata sandi telah dikirim ke email\n'),
              TextSpan(
                text: _emailController.text.trim(),
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
              const TextSpan(text: '\n\nSilakan periksa kotak masuk atau folder spam Anda.'),
            ],
          ),
        ),
        SizedBox(height: s.spacingXL),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: s.spacingLg),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.radiusLg)),
              elevation: 8,
            ),
            child: Text(
              'KEMBALI KE LOGIN',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: s.fontLg,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
