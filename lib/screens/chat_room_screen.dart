import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

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

  // Form state
  String _purchaseMethod = '카드/현금';
  final List<String> _selectedDefects = [];
  bool _privacyAgreed = false;

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
      body: SafeArea(
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // Photo example card
                  _buildPhotoExampleCard(),
                  const SizedBox(height: 16),

                  // Bot message with form
                  _buildBotFormMessage(),
                  const SizedBox(height: 16),

                  // User image message
                  _buildUserImageMessage(),
                  const SizedBox(height: 12),

                  // User text message
                  _buildUserTextMessage('안마의자 처분 신청 합니다.'),
                ],
              ),
            ),

            // Input bar
            _buildInputBar(),

            // Bottom navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoExampleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Text(
            '사진 촬영 예시',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildExamplePhoto('옆면'),
              const SizedBox(width: 8),
              _buildExamplePhoto('등가죽'),
              const SizedBox(width: 8),
              _buildExamplePhoto('다리'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamplePhoto(String label) {
    return Expanded(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chair,
                size: 40,
                color: AppColors.grey400,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotFormMessage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/resit-icon.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '안마의자 상태 사진 3장을 보내주시면\n1일 이내 처분 안내 드리겠습니다.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Purchase method
                _buildFormRow(
                  '구매 방법',
                  Row(
                    children: [
                      _buildRadioOption('카드/현금', _purchaseMethod == '카드/현금', () {
                        setState(() => _purchaseMethod = '카드/현금');
                      }),
                      _buildRadioOption('렌탈 만료', _purchaseMethod == '렌탈 만료', () {
                        setState(() => _purchaseMethod = '렌탈 만료');
                      }),
                      _buildRadioOption('렌탈 계약 중', _purchaseMethod == '렌탈 계약 중', () {
                        setState(() => _purchaseMethod = '렌탈 계약 중');
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Defects
                _buildFormRow(
                  '하자 여부',
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildChip('가죽 해짐'),
                      _buildChip('롤러 이상'),
                      _buildChip('외관 스크래치'),
                      _buildChip('에어불량 등'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Location
                _buildFormRow(
                  '수거 지역',
                  Text(
                    '서울 강남구',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Contact
                _buildFormRow(
                  '연락처',
                  Text(
                    '010-1234-1234',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grey600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Privacy checkbox
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
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.grey800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '보기 ▼',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C4DFF),
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '안마의자 처분 신청',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormRow(String label, Widget content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
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
    );
  }

  Widget _buildRadioOption(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.grey400,
                width: 1.5,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? AppColors.black : AppColors.grey600,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.grey700,
        ),
      ),
    );
  }

  Widget _buildUserImageMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImageThumbnail(),
                const SizedBox(width: 6),
                _buildImageThumbnail(),
                const SizedBox(width: 6),
                _buildImageThumbnail(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 36,
            height: 36,
            color: AppColors.grey200,
            child: Icon(Icons.person, color: AppColors.grey400, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.chair,
        size: 32,
        color: AppColors.grey400,
      ),
    );
  }

  Widget _buildUserTextMessage(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 36,
            height: 36,
            color: AppColors.grey200,
            child: Icon(Icons.person, color: AppColors.grey400, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.grey200),
        ),
      ),
      child: Row(
        children: [
          // Gallery icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_outlined,
              color: AppColors.grey500,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Text input
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontSize: 14, color: AppColors.black),
                decoration: InputDecoration(
                  hintText: '안마의자 처분 상담을 받아보세요.',
                  hintStyle: TextStyle(
                    color: AppColors.grey400,
                    fontSize: 14,
                  ),
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

          // Send button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7C4DFF), width: 2),
            ),
            child: const Icon(
              Icons.arrow_upward,
              color: Color(0xFF7C4DFF),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.grey200),
        ),
      ),
      child: Row(
        children: [
          _buildNavItem('처분신청', true),
          _buildNavItem('이전설치', false),
          _buildNavItem('신청내역', false),
          _buildNavItem('마이', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.black : AppColors.grey500,
          ),
        ),
      ),
    );
  }
}
