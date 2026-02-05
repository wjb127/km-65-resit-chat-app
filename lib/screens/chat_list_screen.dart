import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/chat_message.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  List<ChatRoom> get _dummyRooms => [
        ChatRoom(
          id: '1',
          userName: 'RESIT 상담사',
          lastMessage: '안녕하세요! 안마의자 처분 관련 문의주셔서 감사합니다.',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 3)),
          unreadCount: 2,
          isOnline: true,
        ),
        ChatRoom(
          id: '2',
          userName: 'RESIT 이전설치팀',
          lastMessage: '이전설치 견적 안내드리겠습니다.',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
          unreadCount: 0,
          isOnline: true,
        ),
        ChatRoom(
          id: '3',
          userName: 'RESIT 수거팀',
          lastMessage: '수거 일정 확인해드리겠습니다. 편하신 시간대가 있으실까요?',
          lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
          unreadCount: 0,
          isOnline: false,
        ),
      ];

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else {
      return '${time.month}/${time.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rooms = _dummyRooms;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        title: const Text(
          '채팅',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.grey800),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.primary.withValues(alpha: 0.06),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '상담 가능 시간: 평일 09:00 ~ 18:00',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Chat list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: rooms.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppColors.grey200,
                indent: 80,
              ),
              itemBuilder: (context, index) {
                final room = rooms[index];
                return _ChatListTile(
                  room: room,
                  timeText: _formatTime(room.lastMessageTime),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(
                          roomId: room.id,
                          userName: room.userName,
                          isOnline: room.isOnline,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // FAB for new chat
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ChatRoomScreen(
                roomId: 'new',
                userName: 'RESIT 상담사',
                isOnline: true,
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_bubble_outline, color: AppColors.white),
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final ChatRoom room;
  final String timeText;
  final VoidCallback onTap;

  const _ChatListTile({
    required this.room,
    required this.timeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Image.asset(
                  'assets/images/resit-icon.png',
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                ),
                if (room.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.userName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeText,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: room.unreadCount > 0
                                ? AppColors.grey800
                                : AppColors.grey600,
                            fontWeight: room.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (room.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${room.unreadCount}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
