import 'package:flutter/material.dart';

import 'easy_support_chat_controller.dart';
import 'easy_support_repository.dart';
import 'easy_support_socket_service.dart';
import 'models/easy_support_chat_emit_payload.dart';
import 'models/easy_support_chat_message.dart';
import 'models/easy_support_config.dart';
import 'models/easy_support_customer_session.dart';
import 'widgets/easy_support_color_utils.dart';

class EasySupportChatView extends StatefulWidget {
  const EasySupportChatView({
    super.key,
    required this.title,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.isFullScreen,
    required this.onClose,
    required this.config,
    required this.session,
    this.repository,
  });

  final String title;
  final Color primaryColor;
  final Color onPrimaryColor;
  final bool isFullScreen;
  final VoidCallback onClose;
  final EasySupportConfig config;
  final EasySupportCustomerSession session;
  final EasySupportRepository? repository;

  @override
  State<EasySupportChatView> createState() => _EasySupportChatViewState();
}

class _EasySupportChatViewState extends State<EasySupportChatView> {
  late final EasySupportChatController _controller;
  late final EasySupportSocketService _socketService;
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controller = EasySupportChatController(
      repository: widget.repository ?? EasySupportDioRepository(),
    );
    _socketService = EasySupportSocketIoService();
    _messageController.addListener(_onMessageChanged);
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headerStart = EasySupportColorUtils.blend(
        widget.primaryColor, const Color(0xFFB000FF), 0.52);
    final headerEnd = EasySupportColorUtils.blend(
        widget.primaryColor, const Color(0xFF8A2BE2), 0.26);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF2F3F6),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[headerStart, headerEnd],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _buildHeaderIcon(
                  icon: Icons.logout_rounded,
                  onTap: () {},
                ),
                const SizedBox(width: 6),
                _buildHeaderIcon(
                  icon: Icons.close_rounded,
                  onTap: widget.onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F5F7),
              ),
              child: ValueListenableBuilder<EasySupportChatState>(
                valueListenable: _controller,
                builder: (context, state, _) {
                  if (state.isLoading && state.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == EasySupportChatStatus.error &&
                      state.messages.isEmpty) {
                    return Center(
                      child: Text(
                        'Failed to load messages',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 16),
                    itemCount: state.messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return _buildMessageBubble(message);
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(14),
              ),
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: headerStart, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Type your message',
                            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                          ),
                        ),
                      ),
                      Icon(Icons.attach_file_rounded,
                          color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Icon(Icons.sentiment_satisfied,
                          color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed:
                            _isSending || _messageController.text.trim().isEmpty
                                ? null
                                : _sendMessage,
                        icon: _isSending
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey.shade600,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.send_rounded,
                                color: _messageController.text.trim().isEmpty
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Powered by Easy Support',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(EasySupportChatMessage message) {
    final content = (message.content ?? '').trim();
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }

    if (message.isNotification) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final isCustomerMessage = message.customerId != null &&
        message.customerId!.trim().isNotEmpty &&
        message.customerId == widget.session.customerId;

    final alignment =
        isCustomerMessage ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor =
        isCustomerMessage ? const Color(0xFFD100FF) : const Color(0xFFF3F4F6);
    final textColor =
        isCustomerMessage ? Colors.white : const Color(0xFF374151);
    final border =
        isCustomerMessage ? null : Border.all(color: const Color(0xFFE5E7EB));

    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 230),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14),
          border: border,
          boxShadow: isCustomerMessage
              ? <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          content,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _loadMessages() {
    final chatId = widget.session.chatId;
    if (chatId == null || chatId.trim().isEmpty) {
      return;
    }
    debugPrint('EasySupport chat history call for chat_id: $chatId');
    _controller.loadMessages(
      config: widget.config,
      chatId: chatId,
      limit: 20,
      sortOrder: 'desc',
      sortBy: 'created_at',
    );
  }

  Future<void> _sendMessage() async {
    final body = _messageController.text.trim();
    if (body.isEmpty || _isSending) {
      return;
    }

    final chatId = widget.session.chatId;
    final customerId = widget.session.customerId;
    if (chatId == null ||
        chatId.trim().isEmpty ||
        customerId == null ||
        customerId.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final payload = EasySupportChatEmitPayload(
        author: '',
        body: body,
        chatId: chatId,
        customerId: customerId,
        unseenCount: 1,
      );

      await _socketService.sendChatMessage(
        config: widget.config,
        payload: payload,
      );

      _controller.addLocalCustomerMessage(
        customerId: customerId,
        chatId: chatId,
        body: body,
      );
      _messageController.clear();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('Message send failed: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _onMessageChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}
