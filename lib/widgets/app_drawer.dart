import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/chat_provider.dart';

/// Sidebar navigasi utama untuk aplikasi StuntingCare.
/// 
/// Menyediakan akses cepat ke berbagai fitur utama seperti Dashboard, 
/// AI Chatbot, Riwayat Chat, dan Pengaturan Profil.
class AppDrawer extends StatelessWidget {
  /// Membuat instance [AppDrawer] baru.
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().user;
    final profile = context.watch<ProfileProvider>().profile;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Header Modern dengan Informasi Pengguna
          Container(
            padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withAlpha(220),
                  colorScheme.primary.withAlpha(180),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(80),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar dengan ring modern
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(60),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_rounded,
                      color: colorScheme.primary,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.nama ?? 'Halo, Bunda',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withAlpha(180),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Menu Navigasi
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildDrawerItem(
                  context,
                  Icons.dashboard_outlined,
                  Icons.dashboard_rounded,
                  'Dashboard',
                  '/dashboard',
                  currentRoute == '/dashboard' || currentRoute == null,
                ),
                _buildDrawerItem(
                  context,
                  Icons.psychology_outlined,
                  Icons.psychology_rounded,
                  'AI Chatbot',
                  '/chatbot',
                  currentRoute == '/chatbot',
                ),
                _buildDrawerItem(
                  context,
                  Icons.question_answer_outlined,
                  Icons.question_answer_rounded,
                  'Riwayat Chat',
                  '/chat-history',
                  currentRoute == '/chat-history',
                ),
                _buildDrawerItem(
                  context,
                  Icons.face_outlined,
                  Icons.face_rounded,
                  'Profil Saya',
                  '/profile-form',
                  currentRoute == '/profile-form',
                ),
              ],
            ),
          ),

          // Tombol Keluar di bagian bawah
          const Divider(indent: 24, endIndent: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildLogoutItem(context),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Membangun item menu navigasi tunggal.
  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    IconData activeIcon,
    String title,
    String route,
    bool isActive,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () {
          final currentRoute = ModalRoute.of(context)?.settings.name;
          Navigator.pop(context);
          if (currentRoute != route) {
            // Bersihkan pesan chat jika pengguna berpindah dari layar chatbot
            if (currentRoute == '/chatbot') {
              context.read<ChatProvider>().clearMessages();
            }

            if (route == '/dashboard') {
              Navigator.pushReplacementNamed(context, route);
            } else {
              Navigator.pushNamed(context, route);
            }
          }
        },
        selected: isActive,
        selectedTileColor: colorScheme.primary.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? colorScheme.primary : Colors.grey[600],
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? colorScheme.primary : const Color(0xFF1E1E1E),
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            fontSize: 15,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }

  /// Membangun tombol "Keluar Akun" dengan gaya khusus.
  Widget _buildLogoutItem(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 24),
        title: const Text(
          'Keluar Akun',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        onTap: () => _showLogoutDialog(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }

  /// Menampilkan dialog konfirmasi sebelum pengguna keluar dari akun.
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Dialog dengan efek glossy merah
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(8),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withAlpha(40),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                      size: 32,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Keluar Akun?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: const Text(
                  'Apakah Anda yakin ingin mengakhiri sesi ini? Anda bisa masuk kembali kapan saja.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.withAlpha(40)),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withAlpha(60),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context); // Tutup dialog
                            Navigator.pop(context); // Tutup drawer
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            await authProvider.signOut(context);
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Ya, Keluar',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
