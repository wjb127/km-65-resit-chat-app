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

  // Current tab: 0=처분신청, 1=이전설치, 2=신청내역, 3=마이
  int _currentTab = 0;

  // 처분신청 form state
  String _purchaseMethod = '카드/현금';
  bool _privacyAgreed = false;

  // 이전설치 form state
  String _elevatorOption = '양쪽 다 있음';

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
                  // Show different form based on tab
                  if (_currentTab == 0) ...[
                    _buildPhotoExampleCard(),
                    const SizedBox(height: 16),
                    _buildDisposalFormMessage(),
                  ] else if (_currentTab == 1) ...[
                    _buildRelocationFormMessage(),
                  ],
                  const SizedBox(height: 16),

                  // User image message
                  _buildUserImageMessage(),
                  const SizedBox(height: 12),

                  // User text message
                  _buildUserTextMessage(
                    _currentTab == 0 ? '안마의자 처분 신청 합니다.' : '안마의자 이전 신청 합니다.',
                  ),
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

  // ============ 처분신청 Widgets ============

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

  Widget _buildDisposalFormMessage() {
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
                _buildPrivacyCheckbox(),
                const SizedBox(height: 16),

                // Submit button
                _buildSubmitButton('안마의자 처분 신청'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============ 이전설치 Widgets ============

  Widget _buildRelocationFormMessage() {
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
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gradient header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFE8F4FD),
                        const Color(0xFFF5E6FF),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2분만에 이전 신청하기',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: '주소를 기재해주시면\n'),
                            TextSpan(
                              text: '2시간 이내',
                              style: TextStyle(color: AppColors.primary),
                            ),
                            const TextSpan(text: '로 연락드립니다.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Photo examples
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        '안마의자 사진',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildRelocationPhoto('앞면')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildRelocationPhoto('정면')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Form fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildFormRow(
                        '출발지',
                        Text(
                          '서울 강남구 신사동 OO아파트',
                          style: TextStyle(fontSize: 13, color: AppColors.grey600),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFormRow(
                        '도착지',
                        Text(
                          '부산 해운대구 좌동 OO아파트',
                          style: TextStyle(fontSize: 13, color: AppColors.grey600),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFormRow(
                        '모델명',
                        Text(
                          '바디프랜드 팬텀 / 모델명 모름',
                          style: TextStyle(fontSize: 13, color: AppColors.grey600),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFormRow(
                        '엘리베이터\n여부',
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildSelectableChip('양쪽 다 있음', _elevatorOption == '양쪽 다 있음', () {
                              setState(() => _elevatorOption = '양쪽 다 있음');
                            }),
                            _buildSelectableChip('출발지만 있음', _elevatorOption == '출발지만 있음', () {
                              setState(() => _elevatorOption = '출발지만 있음');
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFormRow(
                        '연락처',
                        Text(
                          '010-1234-1234',
                          style: TextStyle(fontSize: 13, color: AppColors.grey600),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPrivacyCheckbox(),
                      const SizedBox(height: 16),
                      _buildSubmitButton('안마의자 이전 신청'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelocationPhoto(String label) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.2,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Icon(
              Icons.chair,
              size: 36,
              color: AppColors.grey400,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  // ============ Shared Widgets ============

  Widget _buildFormRow(String label, Widget content) {
    return Row(
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
              height: 1.3,
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
              fontSize: 11,
              color: selected ? AppColors.black : AppColors.grey600,
            ),
          ),
          const SizedBox(width: 6),
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

  Widget _buildSelectableChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: selected ? AppColors.primary : AppColors.grey700,
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyCheckbox() {
    return Row(
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
    );
  }

  Widget _buildSubmitButton(String text) {
    return SizedBox(
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
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
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
        _buildUserAvatar(),
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
        _buildUserAvatar(),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        color: const Color(0xFFFFE4C9),
        child: Image.asset(
          'assets/images/resit-icon.png',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.person,
            color: AppColors.grey400,
            size: 24,
          ),
        ),
      ),
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
          _buildNavItem('처분신청', 0),
          _buildNavItem('이전설치', 1),
          _buildNavItem('신청내역', 2),
          _buildNavItem('마이', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, int index) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          color: Colors.transparent,
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
      ),
    );
  }
}
