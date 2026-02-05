import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/chat_message.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String userName;
  final bool isOnline;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.userName,
    required this.isOnline,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadDummyMessages();
  }

  void _loadDummyMessages() {
    _messages.addAll([
      ChatMessage(
        id: '1',
        senderId: 'admin',
        senderName: widget.userName,
        text: '안녕하세요! RESIT입니다.\n안마의자 관련 어떤 도움이 필요하신가요?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isMe: false,
      ),
      ChatMessage(
        id: '2',
        senderId: 'user',
        senderName: '나',
        text: '안마의자 처분하고 싶은데요',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        isMe: true,
      ),
      ChatMessage(
        id: '3',
        senderId: 'admin',
        senderName: widget.userName,
        text: '네, 안마의자 처분 도와드리겠습니다!\n\n사진을 보내주시면 빠르게 견적 안내드릴 수 있습니다. 측면, 등가죽, 다리부 사진 3장 부탁드립니다.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
        isMe: false,
      ),
      ChatMessage(
        id: '4',
        senderId: 'user',
        senderName: '나',
        text: '브랜드는 바디프랜드이고 3년 정도 사용했습니다',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isMe: true,
      ),
      ChatMessage(
        id: '5',
        senderId: 'admin',
        senderName: widget.userName,
        text: '바디프랜드 모델이시군요! 모델명도 알 수 있을까요? 의자 옆면에 라벨이 부착되어 있습니다.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        isMe: false,
      ),
    ]);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'user',
        senderName: '나',
        text: text,
        timestamp: DateTime.now(),
        isMe: true,
      ));
    });

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Simulate admin reply
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: 'admin',
            senderName: widget.userName,
            text: '확인했습니다! 잠시만 기다려주세요.',
            timestamp: DateTime.now(),
            isMe: false,
          ));
        });

        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$period $displayHour:$minute';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.black),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/resit-icon.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                ),
                if (widget.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  widget.isOnline ? '상담 가능' : '오프라인',
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isOnline ? AppColors.online : AppColors.grey400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: AppColors.grey800),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(
                  message: message,
                  timeText: _formatTime(message.timestamp),
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppColors.grey400, size: 28),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                // Camera button
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.grey400, size: 26),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                const SizedBox(width: 4),

                // Text field
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 100),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      style: const TextStyle(fontSize: 15, color: AppColors.black),
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요',
                        hintStyle: TextStyle(
                          color: AppColors.grey400,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // Send button
                IconButton(
                  onPressed: _sendMessage,
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward,
                        color: AppColors.white, size: 20),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String timeText;

  const _MessageBubble({
    required this.message,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            Image.asset(
              'assets/images/resit-icon.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
          ],

          if (message.isMe)
            Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 2),
              child: Text(
                timeText,
                style: TextStyle(fontSize: 11, color: AppColors.grey400),
              ),
            ),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isMe ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isMe ? 18 : 4),
                  bottomRight: Radius.circular(message.isMe ? 4 : 18),
                ),
                boxShadow: [
                  if (!message.isMe)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  color: message.isMe ? AppColors.white : AppColors.black,
                  height: 1.5,
                ),
              ),
            ),
          ),

          if (!message.isMe)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 2),
              child: Text(
                timeText,
                style: TextStyle(fontSize: 11, color: AppColors.grey400),
              ),
            ),
        ],
      ),
    );
  }
}
