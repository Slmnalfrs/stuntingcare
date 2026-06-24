import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/app_sizes.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  final List<String> _suggestedQuestions = [
    'Apa itu stunting?',
    'Bagaimana cara mencegah stunting sejak kehamilan?',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args == null || args['fromHistory'] != true) {
          context.read<ChatProvider>().clearMessages();
        }
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _messageController.clear();
    FocusScope.of(context).unfocus();

    final profile = context.read<ProfileProvider>().profile;
    await context.read<ChatProvider>().sendMessage(text, profile: profile);
    _scrollToBottom();
  }

  void _showNewChatConfirmation(BuildContext context) {
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
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: s.iconLg,
                ),
              ),
              SizedBox(height: s.spacingLg),
              Text(
                'Mulai Chat Baru?',
                style: TextStyle(
                  fontSize: s.fontXl,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              SizedBox(height: s.spacing),
              Text(
                'Percakapan saat ini akan dibersihkan dan Anda dapat memulai topik baru.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: s.fontMd,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: s.spacingXL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: s.spacing),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(s.radiusSm)),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: s.fontMd,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: s.spacing),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<ChatProvider>().clearMessages();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: s.spacing),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(s.radiusSm)),
                      ),
                      child: Text(
                        'Ya, Mulai',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: s.fontMd,
                        ),
                      ),
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

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<ChatProvider>().clearMessages();
        }
      },
      child: Scaffold(
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
            'AI Chatbot',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: s.fontXl,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: Colors.white),
              onPressed: () => _showNewChatConfirmation(context),
              tooltip: 'Chat Baru',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  final messages = chatProvider.messages;

                  if (messages.isEmpty) {
                    return _buildWelcomeView(s);
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                        horizontal: s.padding, vertical: s.spacing),
                    itemCount: messages.length +
                        (chatProvider.isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && chatProvider.isSending) {
                        return _buildTypingIndicator(s);
                      }
                      return MessageBubble(message: messages[index]);
                    },
                  );
                },
              ),
            ),
            _buildInputArea(colorScheme, s),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeView(AppSizes s) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(s.padding),
      child: Column(
        children: [
          SizedBox(height: s.spacingLg),
          Container(
            padding: EdgeInsets.all(s.spacingLg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(s.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(s.spacing),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    size: s.icon2xl,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: s.spacing),
                Text(
                  'Halo, Bunda! 👋',
                  style: TextStyle(
                    fontSize: s.font2xl,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                SizedBox(height: s.spacingXS),
                Text(
                  'Saya adalah AI StuntingCare yang siap membantu Anda dengan informasi seputar pencegahan stunting.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: s.fontMd,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: s.spacingLg),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pertanyaan yang sering diajukan:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: s.fontMd,
              ),
            ),
          ),
          SizedBox(height: s.spacing),
          ..._suggestedQuestions.map((q) => _buildSuggestionChip(s, q)),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(AppSizes s, String question) {
    return GestureDetector(
      onTap: () => _sendMessage(question),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: s.spacingXS),
        padding: EdgeInsets.symmetric(horizontal: s.spacing, vertical: s.spacing),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(s.radiusSm),
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                color: Theme.of(context).colorScheme.primary, size: s.iconSm),
            SizedBox(width: s.spacingSm),
            Expanded(
              child: Text(
                question,
                style: TextStyle(color: Colors.grey[700], fontSize: s.fontSm),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: s.fontSm, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(AppSizes s) {
    return Padding(
      padding: EdgeInsets.only(bottom: s.spacing),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(s.spacingXS),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.psychology_rounded, color: Colors.white, size: s.iconSm - 4),
          ),
          SizedBox(width: s.spacingXS),
          Container(
            padding: EdgeInsets.symmetric(horizontal: s.spacing, vertical: s.spacing),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(),
                SizedBox(width: s.spacingXS / 2),
                _buildDot(),
                SizedBox(width: s.spacingXS / 2),
                _buildDot(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea(ColorScheme colorScheme, AppSizes s) {
    return Container(
      padding: EdgeInsets.fromLTRB(s.spacing, s.spacingXS, s.spacing, s.spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !chatProvider.isSending,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(fontSize: s.fontMd),
                    decoration: InputDecoration(
                      hintText: 'Tanyakan sesuatu...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: s.fontMd),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(s.radius2x),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: s.spacingLg, vertical: s.spacing),
                    ),
                    onSubmitted: (text) => _sendMessage(text),
                  ),
                ),
                SizedBox(width: s.spacingXS),
                GestureDetector(
                  onTap: chatProvider.isSending
                      ? null
                      : () => _sendMessage(_messageController.text),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(s.spacing),
                    decoration: BoxDecoration(
                      color: chatProvider.isSending
                          ? Colors.grey[300]
                          : colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: chatProvider.isSending
                          ? []
                          : [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: chatProvider.isSending
                        ? SizedBox(
                            width: s.iconSm,
                            height: s.iconSm,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(Icons.send_rounded,
                            color: Colors.white, size: s.iconSm),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
