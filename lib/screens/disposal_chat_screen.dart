import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';

class DisposalChatScreen extends StatefulWidget {
  const DisposalChatScreen({super.key});

  @override
  State<DisposalChatScreen> createState() => _DisposalChatScreenState();
}

class _DisposalChatScreenState extends State<DisposalChatScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  String? _chatRoomId;
  bool _isLoading = true;
  bool _isUploading = false;

  // 폼 상태
  List<String> _uploadedPhotos = [];
  String? _purchaseMethod;
  String? _defects;
  String? _location;
  String? _contact;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _initChatRoom();
  }

  Future<void> _initChatRoom() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 기존 처분신청 채팅방 찾기
    final existingRoom = await _firestore
        .collection('chats')
        .where('userId', isEqualTo: user.uid)
        .where('type', isEqualTo: 'disposal')
        .where('status', whereIn: ['pending', 'inProgress'])
        .limit(1)
        .get();

    if (existingRoom.docs.isNotEmpty) {
      _chatRoomId = existingRoom.docs.first.id;
      final data = existingRoom.docs.first.data();
      _isSubmitted = data['formSubmitted'] ?? false;
    } else {
      // 새 채팅방 생성
      final newRoom = await _firestore.collection('chats').add({
        'userId': user.uid,
        'type': 'disposal',
        'status': 'pending',
        'formSubmitted': false,
        'formData': {},
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      _chatRoomId = newRoom.id;

      // 환영 메시지
      await _addBotMessage('안녕하세요! RESIT 안마의자 처분 서비스입니다 😊');
      await Future.delayed(const Duration(milliseconds: 500));
      await _addBotMessage('안마의자 사진 3장을 올려주시면\n1일 이내로 견적을 안내해 드립니다.');
      await Future.delayed(const Duration(milliseconds: 300));
      await _addBotMessage('📷 아래 버튼을 눌러 사진을 업로드해주세요.\n(측면, 등가죽, 다리 부분)');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _addBotMessage(String content) async {
    await _firestore
        .collection('chats')
        .doc(_chatRoomId)
        .collection('messages')
        .add({
      'senderId': 'bot',
      'content': content,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('chats').doc(_chatRoomId).update({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _addUserMessage(String content, {String type = 'text', String? imageUrl}) async {
    final user = _auth.currentUser;
    await _firestore
        .collection('chats')
        .doc(_chatRoomId)
        .collection('messages')
        .add({
      'senderId': user?.uid ?? 'user',
      'content': content,
      'type': type,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('chats').doc(_chatRoomId).update({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _pickAndUploadImage() async {
    if (_uploadedPhotos.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진은 최대 3장까지 업로드 가능합니다')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      // Firebase Storage에 업로드
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('disposal/$_chatRoomId/$fileName');

      String downloadUrl;
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(File(image.path));
      }
      downloadUrl = await ref.getDownloadURL();

      _uploadedPhotos.add(downloadUrl);

      // 메시지로 추가
      await _addUserMessage('📷 사진 ${_uploadedPhotos.length}/3', type: 'image', imageUrl: downloadUrl);

      // 3장 다 올렸으면 다음 단계
      if (_uploadedPhotos.length == 3) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _addBotMessage('사진이 모두 등록되었습니다! ✅');
        await Future.delayed(const Duration(milliseconds: 300));
        await _addBotMessage('구매 방법을 선택해주세요:');
        await _addBotMessage('[선택] 카드/현금 | 렌탈 만료 | 렌탈 계약 중');
      }

      setState(() => _isUploading = false);
      _scrollToBottom();
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: $e')),
        );
      }
    }
  }

  Future<void> _selectPurchaseMethod(String method) async {
    _purchaseMethod = method;
    await _addUserMessage(method);

    await Future.delayed(const Duration(milliseconds: 300));
    await _addBotMessage('하자 여부를 알려주세요:');
    await _addBotMessage('[선택] 없음 | 가죽 해짐 | 롤러 이상 | 외관 스크래치');

    _scrollToBottom();
  }

  Future<void> _selectDefects(String defects) async {
    _defects = defects;
    await _addUserMessage(defects);

    await Future.delayed(const Duration(milliseconds: 300));
    await _addBotMessage('수거 지역을 입력해주세요:');
    await _addBotMessage('(예: 서울 강남구)');

    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    // 현재 단계에 따라 처리
    if (_uploadedPhotos.length == 3 && _purchaseMethod != null && _defects != null && _location == null) {
      _location = text;
      await _addUserMessage(text);

      await Future.delayed(const Duration(milliseconds: 300));
      await _addBotMessage('연락처를 입력해주세요:');
      await _addBotMessage('(예: 010-1234-5678)');
    } else if (_location != null && _contact == null) {
      _contact = text;
      await _addUserMessage(text);

      // 신청 완료 처리
      await _submitApplication();
    } else {
      // 일반 메시지
      await _addUserMessage(text);
    }

    _scrollToBottom();
  }

  Future<void> _submitApplication() async {
    await _firestore.collection('chats').doc(_chatRoomId).update({
      'formSubmitted': true,
      'status': 'inProgress',
      'formData': {
        'photos': _uploadedPhotos,
        'purchaseMethod': _purchaseMethod,
        'defects': _defects,
        'location': _location,
        'contact': _contact,
        'submittedAt': FieldValue.serverTimestamp(),
      },
    });

    await Future.delayed(const Duration(milliseconds: 500));
    await _addBotMessage('🎉 처분 신청이 완료되었습니다!');
    await Future.delayed(const Duration(milliseconds: 300));
    await _addBotMessage('1일 이내로 견적을 안내해 드리겠습니다.\n궁금하신 점이 있으시면 언제든 메시지를 남겨주세요.');

    setState(() => _isSubmitted = true);
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 헤더
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(bottom: BorderSide(color: AppColors.grey200)),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/resit-icon.png',
                width: 32,
                height: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RESIT 처분 상담',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.online,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '상담 가능',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // 메시지 목록
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('chats')
                .doc(_chatRoomId)
                .collection('messages')
                .orderBy('timestamp', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
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

        // 선택 버튼들 (상황에 따라)
        _buildActionButtons(),

        // 입력창
        _buildInputBar(),
      ],
    );
  }

  Widget _buildActionButtons() {
    // 사진 업로드 버튼
    if (_uploadedPhotos.length < 3) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isUploading ? null : _pickAndUploadImage,
            icon: _isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.camera_alt),
            label: Text(_isUploading ? '업로드 중...' : '사진 업로드 (${_uploadedPhotos.length}/3)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      );
    }

    // 구매 방법 선택
    if (_uploadedPhotos.length == 3 && _purchaseMethod == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(
          spacing: 8,
          children: [
            _buildChoiceButton('카드/현금', () => _selectPurchaseMethod('카드/현금')),
            _buildChoiceButton('렌탈 만료', () => _selectPurchaseMethod('렌탈 만료')),
            _buildChoiceButton('렌탈 계약 중', () => _selectPurchaseMethod('렌탈 계약 중')),
          ],
        ),
      );
    }

    // 하자 선택
    if (_purchaseMethod != null && _defects == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChoiceButton('없음', () => _selectDefects('없음')),
            _buildChoiceButton('가죽 해짐', () => _selectDefects('가죽 해짐')),
            _buildChoiceButton('롤러 이상', () => _selectDefects('롤러 이상')),
            _buildChoiceButton('외관 스크래치', () => _selectDefects('외관 스크래치')),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildChoiceButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary),
        elevation: 0,
      ),
      child: Text(label),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data) {
    final currentUserId = _auth.currentUser?.uid;
    final senderId = data['senderId'] as String? ?? '';
    final content = data['content'] as String? ?? '';
    final type = data['type'] as String? ?? 'text';
    final imageUrl = data['imageUrl'] as String?;
    final timestamp = data['timestamp'] as Timestamp?;

    final isMe = senderId == currentUserId;
    final isBot = senderId == 'bot';
    final isAdmin = senderId == 'admin';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Image.asset(
              'assets/images/resit-icon.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      isAdmin ? 'RESIT 상담사' : 'RESIT',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),

                if (type == 'image' && imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 150,
                          height: 150,
                          color: AppColors.grey100,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : const Color(0xFFE8F4FD),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : AppColors.black,
                        height: 1.4,
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
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$period $displayHour:$minute';
  }

  Widget _buildInputBar() {
    final showTextInput = _defects != null || _isSubmitted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grey200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: showTextInput ? AppColors.white : AppColors.grey100,
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: showTextInput,
                  style: const TextStyle(fontSize: 14),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: showTextInput
                        ? (_location == null ? '수거 지역 입력' : (_contact == null ? '연락처 입력' : '메시지 입력'))
                        : '위 버튼을 눌러 진행해주세요',
                    hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: showTextInput ? _sendMessage : null,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: showTextInput ? AppColors.primary : AppColors.grey300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: showTextInput ? Colors.white : AppColors.grey500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
