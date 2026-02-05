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
                  // Show different content based on tab
                  if (_currentTab == 0) ...[
                    _buildDisposalFormMessage(),
                    const SizedBox(height: 16),
                    _buildUserImageMessage(),
                    const SizedBox(height: 12),
                    _buildUserTextMessage('안마의자 처분 신청 합니다.'),
                  ] else if (_currentTab == 1) ...[
                    _buildRelocationFormMessage(),
                    const SizedBox(height: 16),
                    _buildUserImageMessage(),
                    const SizedBox(height: 12),
                    _buildUserTextMessage('안마의자 이전 신청 합니다.'),
                  ] else if (_currentTab == 2) ...[
                    _buildHistoryTab(),
                  ] else if (_currentTab == 3) ...[
                    _buildMyPageTab(),
                  ],
                ],
              ),
            ),

            // Input bar (only for chat tabs)
            if (_currentTab == 0 || _currentTab == 1) _buildInputBar(),

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
    String imagePath;
    switch (label) {
      case '옆면':
        imagePath = 'assets/images/chair-side.png';
        break;
      case '등가죽':
        imagePath = 'assets/images/chair-back.png';
        break;
      case '다리':
        imagePath = 'assets/images/chair-leg.png';
        break;
      default:
        imagePath = 'assets/images/chair-side.png';
    }

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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
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
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with gradient
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
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: '사진 3장 올려주시면\n'),
                            TextSpan(
                              text: '1일 이내',
                              style: TextStyle(color: AppColors.primary),
                            ),
                            const TextSpan(text: '로 연락드립니다.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Photo upload section
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
                      Text(
                        '안마의자 상태 사진 등록',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildUploadSlot('측면', 'assets/images/chair-side.png'),
                          const SizedBox(width: 8),
                          _buildUploadSlot('등가죽', 'assets/images/chair-back.png'),
                          const SizedBox(width: 8),
                          _buildUploadSlot('다리부', 'assets/images/chair-leg.png'),
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

                // Form fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Purchase method
                      _buildFormFieldWithBorder(
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

                      // Defects
                      _buildFormFieldWithBorder(
                        '하자 여부',
                        Text(
                          '가죽 해짐 / 롤러 이상 / 외관 스크래치 / 에어불량 등',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                        ),
                      ),

                      // Location
                      _buildFormFieldWithBorder(
                        '수거 지역',
                        Text(
                          '서울 강남구',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey700,
                          ),
                        ),
                      ),

                      // Contact
                      _buildFormFieldWithBorder(
                        '연락처',
                        Text(
                          '010-1234-1234',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      _buildPrivacyCheckbox(),
                      const SizedBox(height: 16),
                      _buildSubmitButton('안마의자 처분 신청'),
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

  Widget _buildUploadSlot(String label, String imagePath) {
    return Expanded(
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
              child: Stack(
                children: [
                  // Background example image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Opacity(
                      opacity: 0.3,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  // Camera icon with plus badge
                  Center(
                    child: Stack(
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
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFieldWithBorder(String label, Widget content) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.grey200),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 65,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
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
    String imagePath = label == '앞면'
        ? 'assets/images/chair-side.png'
        : 'assets/images/chair-back.png';

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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
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
                _buildImageThumbnail('assets/images/chair-side.png'),
                const SizedBox(width: 6),
                _buildImageThumbnail('assets/images/chair-back.png'),
                const SizedBox(width: 6),
                _buildImageThumbnail('assets/images/chair-leg.png'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildUserAvatar(),
      ],
    );
  }

  Widget _buildImageThumbnail(String imagePath) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
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

  // ============ 신청내역 Tab ============

  Widget _buildHistoryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Text(
          '신청내역',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '최근 신청 내역을 확인하세요',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey600,
          ),
        ),
        const SizedBox(height: 20),

        // History items
        _buildHistoryItem(
          type: '처분',
          status: '완료',
          statusColor: AppColors.online,
          date: '2024.01.15',
          description: '바디프랜드 팬텀 / 서울 강남구',
        ),
        const SizedBox(height: 12),
        _buildHistoryItem(
          type: '이전',
          status: '진행중',
          statusColor: AppColors.primary,
          date: '2024.01.20',
          description: '세라젬 마스터 / 서울 → 부산',
        ),
        const SizedBox(height: 12),
        _buildHistoryItem(
          type: '처분',
          status: '견적대기',
          statusColor: const Color(0xFFFF9800),
          date: '2024.01.22',
          description: '코지마 안마의자 / 경기 성남시',
        ),
        const SizedBox(height: 24),

        // Empty state hint
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 40,
                color: AppColors.grey400,
              ),
              const SizedBox(height: 12),
              Text(
                '더 많은 신청 내역이 없습니다',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required String type,
    required String status,
    required Color statusColor,
    required String date,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: type == '처분'
                  ? const Color(0xFFE8F4FD)
                  : const Color(0xFFF5E6FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: type == '처분' ? AppColors.primary : const Color(0xFF7C4DFF),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ 마이페이지 Tab ============

  Widget _buildMyPageTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4C9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '홍길동',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '010-1234-5678',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),

              // Edit button
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.edit_outlined,
                  color: AppColors.grey500,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Menu items
        const Text(
          '설정',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),

        _buildMenuItem(
          icon: Icons.notifications_outlined,
          title: '알림 설정',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: '자주 묻는 질문',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.description_outlined,
          title: '이용약관',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.privacy_tip_outlined,
          title: '개인정보처리방침',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: Icons.info_outline,
          title: '앱 버전',
          trailing: Text(
            'v1.0.0',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey500,
            ),
          ),
          onTap: () {},
        ),

        const SizedBox(height: 24),

        // Logout button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.grey600,
              side: BorderSide(color: AppColors.grey300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '로그아웃',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.grey200),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.grey600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.black,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.grey400,
                ),
          ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _buildNavItem('처분신청', 0, Icons.delete_outline),
              _buildNavItem('이전설치', 1, Icons.local_shipping_outlined),
              _buildNavItem('신청내역', 2, Icons.list_alt_outlined),
              _buildNavItem('마이', 3, Icons.person_outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, int index, IconData icon) {
    final isSelected = _currentTab == index;
    final color = isSelected ? AppColors.primary : AppColors.grey500;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? _getFilledIcon(icon) : icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFilledIcon(IconData outlinedIcon) {
    if (outlinedIcon == Icons.delete_outline) return Icons.delete;
    if (outlinedIcon == Icons.local_shipping_outlined) return Icons.local_shipping;
    if (outlinedIcon == Icons.list_alt_outlined) return Icons.list_alt;
    if (outlinedIcon == Icons.person_outline) return Icons.person;
    return outlinedIcon;
  }
}
