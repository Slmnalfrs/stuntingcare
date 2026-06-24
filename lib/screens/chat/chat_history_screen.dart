import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/app_sizes.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadChatHistory();
    });
  }

  String _formatTimestamp(String timestamp) {
    try {
      // Firebase kadang menyimpan presisi dengan koma, ganti dengan titik agar DateTime.parse berhasil
      final normalizedTimestamp = timestamp.replaceAll(',', '.');
      final dt = DateTime.parse(normalizedTimestamp).toLocal();
      return DateFormat('yyyy-MM-dd HH:mm').format(dt);
    } catch (_) {
      return timestamp;
    }
  }

  void _showDeleteConfirmation(BuildContext context, String chatId) {
    final s = AppSizes(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.radiusXl)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(s.paddingLg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(s.radiusXl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(s.spacing),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: s.iconLg),
              ),
              SizedBox(height: s.spacingLg),
              Text(
                'Hapus Riwayat?',
                style: TextStyle(fontSize: s.fontXl, fontWeight: FontWeight.bold, color: const Color(0xFF1E1E1E)),
              ),
              SizedBox(height: s.spacing),
              Text(
                'Percakapan ini akan dihapus secara permanen dari riwayat Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: s.fontMd, color: Colors.grey[600], height: 1.5),
              ),
              SizedBox(height: s.spacingXL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: s.spacing),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.radiusSm)),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Text('Batal',
                          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: s.fontMd)),
                    ),
                  ),
                  SizedBox(width: s.spacing),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<ChatProvider>().deleteChatFromHistory(chatId);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: s.spacing),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.radiusSm)),
                      ),
                      child: Text('Hapus',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: s.fontMd)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          'Riwayat Percakapan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: s.fontXl),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => context.read<ChatProvider>().loadChatHistory(),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          if (chatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (chatProvider.errorMessage != null) {
            return _buildErrorView(s, chatProvider.errorMessage!);
          }
          final history = chatProvider.history;
          if (history.isEmpty) {
            return _buildEmptyView(s, colorScheme);
          }
          return ListView.separated(
            padding: EdgeInsets.all(s.padding),
            itemCount: history.length,
            separatorBuilder: (context, index) => SizedBox(height: s.spacing),
            itemBuilder: (context, index) {
              final chat = history[index];
              return _buildHistoryCard(context, s, chat, colorScheme, chatProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, AppSizes s, dynamic chat, ColorScheme colorScheme, ChatProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s.radiusLg),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(s.radiusLg),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              provider.loadChatSession(chat);
              Navigator.pushReplacementNamed(context, '/chatbot',
                  arguments: {'fromHistory': true});
            },
            child: Padding(
              padding: EdgeInsets.all(s.spacing),
              child: Row(
                children: [
                  Container(
                    width: s.spacingXL + 4,
                    height: s.spacingXL + 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(s.radiusSm),
                    ),
                    child: Icon(Icons.chat_bubble_rounded, color: Colors.white, size: s.iconSm),
                  ),
                  SizedBox(width: s.spacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.pertanyaan,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: s.fontLg,
                              color: const Color(0xFF1E1E1E),
                              letterSpacing: -0.3),
                        ),
                        SizedBox(height: s.spacingXS / 2),
                        Text(
                          chat.jawaban,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: s.fontMd, color: Colors.grey[600]),
                        ),
                        SizedBox(height: s.spacingXS),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: s.fontSm, color: colorScheme.primary.withValues(alpha: 0.5)),
                            SizedBox(width: s.spacingXS / 2),
                            Text(
                              _formatTimestamp(chat.timestamp),
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: s.fontXs,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(s.radiusSm),
                      onTap: () => _showDeleteConfirmation(context, chat.id),
                      child: Container(
                        padding: EdgeInsets.all(s.spacingXS),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(s.radiusSm),
                        ),
                        child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: s.iconSm),
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

  Widget _buildErrorView(AppSizes s, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(s.paddingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: s.icon2xl + 16, color: Colors.grey[400]),
            SizedBox(height: s.spacing),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: s.fontMd)),
            SizedBox(height: s.spacing),
            ElevatedButton.icon(
              onPressed: () => context.read<ChatProvider>().loadChatHistory(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(AppSizes s, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: s.icon2xl + 32, color: Colors.grey[300]),
          SizedBox(height: s.spacing),
          Text(
            'Belum ada riwayat percakapan',
            style: TextStyle(color: Colors.grey[500], fontSize: s.fontLg, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: s.spacingXS),
          Text(
            'Mulai bertanya kepada AI StuntingCare',
            style: TextStyle(color: Colors.grey[400], fontSize: s.fontMd),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: s.spacingLg),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/chatbot'),
            icon: const Icon(Icons.psychology_rounded),
            label: const Text('Mulai Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: s.paddingLg, vertical: s.spacing),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s.radiusSm)),
            ),
          ),
        ],
      ),
    );
  }
}
