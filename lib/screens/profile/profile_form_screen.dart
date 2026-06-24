import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/user_profile.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/app_sizes.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usiaController = TextEditingController();
  final _tinggiBadanController = TextEditingController();
  final _beratBadanController = TextEditingController();
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingProfile());
  }

  void _loadExistingProfile() {
    final profile = context.read<ProfileProvider>().profile;
    if (profile != null) {
      setState(() => _isEditMode = true);
      _namaController.text = profile.nama;
      _usiaController.text = profile.usia.toString();
      _tinggiBadanController.text = profile.tinggiBadan.toString();
      _beratBadanController.text = profile.beratBadanAwal.toString();
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usiaController.dispose();
    _tinggiBadanController.dispose();
    _beratBadanController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;

    final profile = UserProfile(
      uid: uid,
      nama: _namaController.text.trim(),
      usia: int.parse(_usiaController.text.trim()),
      tinggiBadan: double.parse(_tinggiBadanController.text.trim()),
      beratBadanAwal: double.parse(_beratBadanController.text.trim()),
    );

    final success = await context.read<ProfileProvider>().saveProfile(profile);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Profil berhasil diperbarui!' : 'Profil berhasil disimpan!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      final error = context.read<ProfileProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal menyimpan profil'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final s = AppSizes(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.segment_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
        title: Text(
          _isEditMode ? 'Edit Profil' : 'Lengkapi Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: s.fontXl,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(s.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isEditMode) _buildInfoBanner(colorScheme, s),
            SizedBox(height: s.spacingLg),
            _buildFormCard(colorScheme, s),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner(ColorScheme colorScheme, AppSizes s) {
    return Container(
      padding: EdgeInsets.all(s.spacing),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(s.radiusMd),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: colorScheme.primary, size: s.iconMd),
          SizedBox(width: s.spacing),
          Expanded(
            child: Text(
              'Lengkapi profil Anda agar AI dapat memberikan saran yang lebih personal.',
              style: TextStyle(color: colorScheme.primary, fontSize: s.fontSm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(ColorScheme colorScheme, AppSizes s) {
    return Container(
      padding: EdgeInsets.all(s.paddingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(s, 'Data Pribadi', Icons.person_outline_rounded),
            SizedBox(height: s.spacing),
            _buildTextField(
              s: s,
              controller: _namaController,
              label: 'Nama Lengkap',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
            ),
            SizedBox(height: s.spacing),
            _buildTextField(
              s: s,
              controller: _usiaController,
              label: 'Usia (tahun)',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Usia tidak boleh kosong';
                final n = int.tryParse(v);
                if (n == null || n < 15 || n > 50) return 'Usia harus antara 15-50 tahun';
                return null;
              },
            ),
            SizedBox(height: s.spacing),
            _buildTextField(
              s: s,
              controller: _tinggiBadanController,
              label: 'Tinggi Badan (cm)',
              icon: Icons.height_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Tinggi badan tidak boleh kosong';
                final n = double.tryParse(v);
                if (n == null || n < 100 || n > 250) return 'Tinggi badan harus antara 100-250 cm';
                return null;
              },
            ),
            SizedBox(height: s.spacing),
            _buildTextField(
              s: s,
              controller: _beratBadanController,
              label: 'Berat Badan Awal (kg)',
              icon: Icons.monitor_weight_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Berat badan tidak boleh kosong';
                final n = double.tryParse(v);
                if (n == null || n < 30 || n > 200) return 'Berat badan harus antara 30-200 kg';
                return null;
              },
            ),
            SizedBox(height: s.spacingXL),
            _buildSubmitButton(colorScheme, s),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(AppSizes s, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: s.iconSm),
        SizedBox(width: s.spacingXS),
        Text(
          title,
          style: TextStyle(
            fontSize: s.fontLg, fontWeight: FontWeight.bold, color: const Color(0xFF1E1E1E)),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ColorScheme colorScheme, AppSizes s) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: s.spacingLg),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(s.radiusLg)),
              elevation: 8,
            ),
            child: provider.isLoading
                ? SizedBox(
                    height: s.iconMd,
                    width: s.iconMd,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(
                    _isEditMode ? 'PERBARUI PROFIL' : 'SIMPAN PROFIL',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: s.fontLg,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required AppSizes s,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: s.fontMd),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey[400], fontSize: s.fontMd),
        prefixIcon: Icon(icon, color: Colors.blueGrey[300], size: s.iconSm),
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
