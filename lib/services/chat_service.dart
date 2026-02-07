import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _chatsRef => _firestore.collection('chats');
  CollectionReference get _usersRef => _firestore.collection('users');

  // Get chat room messages stream
  Stream<List<ChatMessage>> getMessages(String roomId) {
    return _chatsRef
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  // Send a message
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
    String? imageUrl,
    MessageType type = MessageType.text,
  }) async {
    await _chatsRef.doc(roomId).collection('messages').add({
      'senderId': senderId,
      'content': content,
      'imageUrl': imageUrl,
      'type': type.name,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Update last message in chat room
    await _chatsRef.doc(roomId).update({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // Create or get chat room
  Future<String> getOrCreateChatRoom(String userId) async {
    // Check if user already has a chat room
    final existingRoom = await _chatsRef
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingRoom.docs.isNotEmpty) {
      return existingRoom.docs.first.id;
    }

    // Create new chat room
    final newRoom = await _chatsRef.add({
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return newRoom.id;
  }

  // Mark messages as read
  Future<void> markAsRead(String roomId, String messageId) async {
    await _chatsRef
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }
}

// Extend ChatMessage model with Firestore support
extension ChatMessageFirestore on ChatMessage {
  static ChatMessage fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isMe: false, // Will be set by the UI based on current user
      imageUrl: data['imageUrl'],
      type: MessageType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
      'type': type.name,
    };
  }
}
