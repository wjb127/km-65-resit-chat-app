import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import 'login_screen.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? _selectedChatRoomId;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedChatRoomId == null) return;

    _messageController.clear();

    // 관리자 메시지 추가
    await _firestore
        .collection('chats')
        .doc(_selectedChatRoomId)
        .collection('messages')
        .add({
      'senderId': 'admin',
      'content': text,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // 마지막 메시지 업데이트
    await _firestore.collection('chats').doc(_selectedChatRoomId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'RESIT 관리자',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: AppColors.white),
          ),
        ],
      ),
      body: Row(
        children: [
          // 왼쪽: 채팅방 목록
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                right: BorderSide(color: AppColors.grey200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '고객 상담 목록',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey800,
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('chats')
                        .orderBy('lastMessageTime', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final chatRooms = snapshot.data!.docs;

                      if (chatRooms.isEmpty) {
                        return Center(
                          child: Text(
                            '상담 내역이 없습니다',
                            style: TextStyle(color: AppColors.grey500),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: chatRooms.length,
                        itemBuilder: (context, index) {
                          final room = chatRooms[index];
                          final data = room.data() as Map<String, dynamic>;
                          return _buildChatRoomTile(room.id, data);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 오른쪽: 선택된 채팅방 메시지
          Expanded(
            child: _selectedChatRoomId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.grey300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '왼쪽에서 상담을 선택하세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // 채팅 헤더
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border(
                            bottom: BorderSide(color: AppColors.grey200),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: AppColors.grey600),
                            const SizedBox(width: 8),
                            Text(
                              '고객 상담',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'ID: ${_selectedChatRoomId?.substring(0, 8)}...',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 메시지 목록
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('chats')
                              .doc(_selectedChatRoomId)
                              .collection('messages')
                              .orderBy('timestamp', descending: false)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final messages = snapshot.data!.docs;

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToBottom();
                            });

                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final doc = messages[index];
                                final data = doc.data() as Map<String, dynamic>;
                                return _buildMessageBubble(data);
                              },
                            );
                          },
                        ),
                      ),

                      // 입력창
                      _buildInputBar(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomTile(String roomId, Map<String, dynamic> data) {
    final lastMessage = data['lastMessage'] as String? ?? '';
    final lastMessageTime = data['lastMessageTime'] as Timestamp?;
    final chatType = data['type'] as String? ?? 'general';
    final status = data['status'] as String? ?? 'pending';
    final isSelected = _selectedChatRoomId == roomId;

    // 채팅 타입에 따른 배지 색상
    Color typeColor;
    String typeLabel;
    if (chatType == 'disposal') {
      typeColor = AppColors.primary;
      typeLabel = '처분';
    } else if (chatType == 'relocation') {
      typeColor = const Color(0xFF7C4DFF);
      typeLabel = '이전';
    } else {
      typeColor = AppColors.grey500;
      typeLabel = '일반';
    }

    return InkWell(
      onTap: () {
        setState(() => _selectedChatRoomId = roomId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          border: Border(
            bottom: BorderSide(color: AppColors.grey200),
            left: isSelected
                ? BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.grey200,
              child: Icon(Icons.person, color: AppColors.grey600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 채팅 타입 배지
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '고객',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const Spacer(),
                      if (lastMessageTime != null)
                        Text(
                          _formatTime(lastMessageTime.toDate()),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey600,
                          ),
                        ),
                      ),
                      // 상태 표시
                      if (status == 'pending')
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
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

  Widget _buildMessageBubble(Map<String, dynamic> data) {
    final senderId = data['senderId'] as String? ?? '';
    final content = data['content'] as String? ?? '';
    final type = data['type'] as String? ?? 'text';
    final timestamp = data['timestamp'] as Timestamp?;

    final isAdmin = senderId == 'admin';
    final isSystem = type == 'system' || senderId == 'system';

    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: TextStyle(fontSize: 12, color: AppColors.grey600),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isAdmin) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.grey200,
              child: Icon(Icons.person, size: 18, color: AppColors.grey600),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isAdmin ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isAdmin ? null : Border.all(color: AppColors.grey200),
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isAdmin ? AppColors.white : AppColors.black,
                    ),
                  ),
                ),
                if (timestamp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatTime(timestamp.toDate()),
                      style: TextStyle(fontSize: 11, color: AppColors.grey400),
                    ),
                  ),
              ],
            ),
          ),
          if (isAdmin) const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return '방금';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inDays < 1) {
      final hour = time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = hour < 12 ? '오전' : '오후';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$period $displayHour:$minute';
    } else {
      return '${time.month}/${time.day}';
    }
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.grey200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontSize: 14),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: '답변을 입력하세요',
                  hintStyle: TextStyle(color: AppColors.grey400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
