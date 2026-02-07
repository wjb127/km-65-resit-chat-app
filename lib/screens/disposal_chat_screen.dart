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
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();

  String? _chatRoomId;
  bool _isLoading = true;
  bool _isUploading = false;
  bool _isSubmitting = false;

  // 폼 상태
  List<String> _uploadedPhotos = [];
  List<String?> _photoSlots = [null, null, null]; // 3개 슬롯
  String _purchaseMethod = '카드/현금';
  List<String> _selectedDefects = [];
  bool _privacyAgreed = false;
  bool _isSubmitted = false;

  final List<String> _defectOptions = ['가죽 해짐', '롤러 이상', '외관 스크래치', '에어불량', '기타'];

  @override
  void initState() {
    super.initState();
    _initChatRoom();
  }

  Future<void> _initChatRoom() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 간단한 쿼리로 변경 (복합 인덱스 불필요)
      final existingRooms = await _firestore
          .collection('chats')
          .where('userId', isEqualTo: user.uid)
          .where('type', isEqualTo: 'disposal')
          .get()
          .timeout(const Duration(seconds: 5));

      // 클라이언트에서 필터링
      final activeRooms = existingRooms.docs.where((doc) {
        final status = doc.data()['status'] as String?;
        return status == 'pending' || status == 'inProgress';
      }).toList();

      // 가장 최근 것 선택
      if (activeRooms.isNotEmpty) {
        activeRooms.sort((a, b) {
          final aTime = a.data()['createdAt'] as Timestamp?;
          final bTime = b.data()['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

        final doc = activeRooms.first;
        _chatRoomId = doc.id;
        final data = doc.data();
        _isSubmitted = data['formSubmitted'] ?? false;

        // 기존 폼 데이터 복원
        if (data['formData'] != null) {
          final formData = data['formData'] as Map<String, dynamic>;
          _uploadedPhotos = List<String>.from(formData['photos'] ?? []);
          _photoSlots = List<String?>.from(_uploadedPhotos);
          while (_photoSlots.length < 3) _photoSlots.add(null);
          _purchaseMethod = formData['purchaseMethod'] ?? '카드/현금';
          _selectedDefects = List<String>.from(formData['defects'] ?? []);
          _locationController.text = formData['location'] ?? '';
          _contactController.text = formData['contact'] ?? '';
        }
      }
    } catch (e) {
      // 타임아웃이나 에러 시 그냥 새 폼으로 시작
      debugPrint('채팅방 조회 실패: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // 단일 슬롯 클릭 시 (해당 슬롯만 교체)
  Future<void> _pickImage(int slotIndex) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      final url = await _uploadImage(image, slotIndex);
      if (url != null) {
        setState(() {
          _photoSlots[slotIndex] = url;
          _uploadedPhotos = _photoSlots.whereType<String>().toList();
        });
      }

      setState(() => _isUploading = false);
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: $e')),
        );
      }
    }
  }

  // 여러 장 한번에 업로드 (빈 슬롯에 순차 배분)
  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isEmpty) return;

      setState(() => _isUploading = true);

      // 빈 슬롯 찾기
      List<int> emptySlots = [];
      for (int i = 0; i < 3; i++) {
        if (_photoSlots[i] == null) {
          emptySlots.add(i);
        }
      }

      // 업로드할 이미지 수 제한
      final imagesToUpload = images.take(emptySlots.length).toList();

      for (int i = 0; i < imagesToUpload.length; i++) {
        final slotIndex = emptySlots[i];
        final url = await _uploadImage(imagesToUpload[i], slotIndex);
        if (url != null) {
          setState(() {
            _photoSlots[slotIndex] = url;
            _uploadedPhotos = _photoSlots.whereType<String>().toList();
          });
        }
      }

      setState(() => _isUploading = false);

      // 초과된 이미지가 있으면 알림
      if (images.length > emptySlots.length) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${emptySlots.length}장만 업로드되었습니다 (최대 3장)')),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: $e')),
        );
      }
    }
  }

  // 이미지 업로드 공통 함수
  Future<String?> _uploadImage(XFile image, int slotIndex) async {
    try {
      final user = _auth.currentUser;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$slotIndex.jpg';
      final ref = _storage.ref().child('disposal/${user?.uid}/$fileName');

      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(File(image.path));
      }
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('이미지 업로드 실패: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    // 유효성 검사
    if (_uploadedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진을 최소 1장 이상 업로드해주세요')),
      );
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('수거 지역을 입력해주세요')),
      );
      return;
    }
    if (_contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('연락처를 입력해주세요')),
      );
      return;
    }
    if (!_privacyAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('개인정보 수집/이용에 동의해주세요')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final formData = {
        'photos': _uploadedPhotos,
        'purchaseMethod': _purchaseMethod,
        'defects': _selectedDefects,
        'location': _locationController.text.trim(),
        'contact': _contactController.text.trim(),
        'submittedAt': FieldValue.serverTimestamp(),
      };

      // 채팅방 생성 또는 업데이트
      if (_chatRoomId == null) {
        final newRoom = await _firestore.collection('chats').add({
          'userId': user.uid,
          'type': 'disposal',
          'status': 'inProgress',
          'formSubmitted': true,
          'formData': formData,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '처분 신청이 접수되었습니다',
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
        _chatRoomId = newRoom.id;
      } else {
        await _firestore.collection('chats').doc(_chatRoomId).update({
          'formSubmitted': true,
          'status': 'inProgress',
          'formData': formData,
          'lastMessage': '처분 신청이 접수되었습니다',
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      }

      // 시스템 메시지 추가
      await _firestore
          .collection('chats')
          .doc(_chatRoomId)
          .collection('messages')
          .add({
        'senderId': 'system',
        'content': '처분 신청이 접수되었습니다',
        'type': 'system',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 신청 내용 요약 메시지
      final defectsText = _selectedDefects.isEmpty ? '없음' : _selectedDefects.join(', ');
      await _firestore
          .collection('chats')
          .doc(_chatRoomId)
          .collection('messages')
          .add({
        'senderId': 'bot',
        'content': '''📋 신청 내용
• 사진: ${_uploadedPhotos.length}장
• 구매방법: $_purchaseMethod
• 하자: $defectsText
• 수거지역: ${_locationController.text.trim()}
• 연락처: ${_contactController.text.trim()}

1일 이내로 견적을 안내해 드리겠습니다.
궁금하신 점이 있으시면 메시지를 남겨주세요!''',
        'type': 'text',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isSubmitted = true;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('신청 실패: $e')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _chatRoomId == null) return;

    _messageController.clear();

    final user = _auth.currentUser;
    await _firestore
        .collection('chats')
        .doc(_chatRoomId)
        .collection('messages')
        .add({
      'senderId': user?.uid ?? 'user',
      'content': text,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('chats').doc(_chatRoomId).update({
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 제출 완료 후: 채팅 모드
    if (_isSubmitted) {
      return _buildChatMode();
    }

    // 제출 전: 폼 모드
    return _buildFormMode();
  }

  // ==================== 폼 모드 ====================
  Widget _buildFormMode() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFormCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE8F4FD),
                  const Color(0xFFF0F8FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/resit-icon.png',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '30초 만에 안마의자 처리하기',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: '사진 올려주시면 '),
                            TextSpan(
                              text: '1일 이내',
                              style: TextStyle(color: AppColors.primary),
                            ),
                            const TextSpan(text: ' 연락드립니다'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 사진 업로드
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '안마의자 상태 사진 등록',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey800,
                      ),
                    ),
                    // 여러 장 선택 버튼
                    if (_photoSlots.any((slot) => slot == null))
                      GestureDetector(
                        onTap: _isUploading ? null : _pickMultipleImages,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo_library, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '여러 장 선택',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPhotoSlot(0, '측면', 'assets/images/chair-side.png'),
                    const SizedBox(width: 8),
                    _buildPhotoSlot(1, '등가죽', 'assets/images/chair-back.png'),
                    const SizedBox(width: 8),
                    _buildPhotoSlot(2, '다리부', 'assets/images/chair-leg.png'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '⚠️ 하자 부위가 있다면 함께 찍어주세요',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 폼 필드들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // 구매 방법
                _buildFormField(
                  '구매 방법',
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildRadioChip('카드/현금', _purchaseMethod == '카드/현금', () {
                        setState(() => _purchaseMethod = '카드/현금');
                      }),
                      _buildRadioChip('렌탈 만료', _purchaseMethod == '렌탈 만료', () {
                        setState(() => _purchaseMethod = '렌탈 만료');
                      }),
                      _buildRadioChip('렌탈 계약 중', _purchaseMethod == '렌탈 계약 중', () {
                        setState(() => _purchaseMethod = '렌탈 계약 중');
                      }),
                    ],
                  ),
                ),

                // 하자 여부
                _buildFormField(
                  '하자 여부',
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _defectOptions.map((defect) {
                      final isSelected = _selectedDefects.contains(defect);
                      return _buildSelectableChip(defect, isSelected, () {
                        setState(() {
                          if (isSelected) {
                            _selectedDefects.remove(defect);
                          } else {
                            _selectedDefects.add(defect);
                          }
                        });
                      });
                    }).toList(),
                  ),
                ),

                // 수거 지역
                _buildFormField(
                  '수거 지역',
                  TextField(
                    controller: _locationController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '예: 서울 강남구',
                      hintStyle: TextStyle(color: AppColors.grey400),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // 연락처
                _buildFormField(
                  '연락처',
                  TextField(
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '예: 010-1234-5678',
                      hintStyle: TextStyle(color: AppColors.grey400),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 개인정보 동의
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _privacyAgreed,
                        onChanged: (v) => setState(() => _privacyAgreed = v ?? false),
                        shape: const CircleBorder(),
                        activeColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '개인정보 수집/이용 동의',
                      style: TextStyle(fontSize: 13, color: AppColors.grey800),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '보기 ▼',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 제출 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF),
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            '안마의자 처분 신청',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlot(int index, String label, String placeholderPath) {
    final photoUrl = _photoSlots[index];
    final hasPhoto = photoUrl != null;

    return Expanded(
      child: GestureDetector(
        onTap: _isUploading ? null : () => _pickImage(index),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: hasPhoto
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.grey200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle, color: AppColors.primary, size: 24),
                                      const SizedBox(height: 4),
                                      Text(
                                        '업로드됨',
                                        style: TextStyle(fontSize: 10, color: AppColors.grey600),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _photoSlots[index] = null;
                                    _uploadedPhotos = _photoSlots.whereType<String>().toList();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Opacity(
                              opacity: 0.3,
                              child: Image.asset(
                                placeholderPath,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                          Center(
                            child: _isUploading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        size: 28,
                                        color: AppColors.grey500,
                                      ),
                                      Positioned(
                                        right: -6,
                                        top: -6,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: AppColors.grey500,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            size: 12,
                                            color: AppColors.white,
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
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, Widget content) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildRadioChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? AppColors.primary : AppColors.grey700,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? AppColors.primary : AppColors.grey700,
          ),
        ),
      ),
    );
  }

  // ==================== 채팅 모드 ====================
  Widget _buildChatMode() {
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
                        style: TextStyle(fontSize: 12, color: AppColors.grey600),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // 새 신청 버튼
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSubmitted = false;
                    _chatRoomId = null;
                    _uploadedPhotos = [];
                    _photoSlots = [null, null, null];
                    _purchaseMethod = '카드/현금';
                    _selectedDefects = [];
                    _locationController.clear();
                    _contactController.clear();
                    _privacyAgreed = false;
                  });
                },
                child: Text(
                  '새 신청',
                  style: TextStyle(color: AppColors.primary, fontSize: 14),
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

        // 입력창
        _buildChatInputBar(),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data) {
    final currentUserId = _auth.currentUser?.uid;
    final senderId = data['senderId'] as String? ?? '';
    final content = data['content'] as String? ?? '';
    final type = data['type'] as String? ?? 'text';
    final timestamp = data['timestamp'] as Timestamp?;

    final isMe = senderId == currentUserId;
    final isSystem = type == 'system' || senderId == 'system';
    final isBot = senderId == 'bot';
    final isAdmin = senderId == 'admin';

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
                      style: TextStyle(fontSize: 12, color: AppColors.grey600),
                    ),
                  ),

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

  Widget _buildChatInputBar() {
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
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(fontSize: 14),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요',
                    hintStyle: TextStyle(color: AppColors.grey400, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Icons.arrow_upward,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
