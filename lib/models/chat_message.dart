enum MessageType { text, image, system }

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isMe;
  final String? imageUrl;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.senderId,
    this.senderName = '',
    required this.content,
    required this.timestamp,
    required this.isMe,
    this.imageUrl,
    this.type = MessageType.text,
  });

  // Alias for backward compatibility
  String get text => content;
}

class ChatRoom {
  final String id;
  final String userName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  ChatRoom({
    required this.id,
    required this.userName,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}
