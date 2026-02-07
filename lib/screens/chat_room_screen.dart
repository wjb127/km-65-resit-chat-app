import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'disposal_chat_screen.dart';
import 'relocation_chat_screen.dart';

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
  final _scrollController = ScrollController();

  // Current tab: 0=처분신청, 1=이전설치, 2=신청내역, 3=마이
  int _currentTab = 0;

  @override
  void dispose() {
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
            // 탭 0 = 처분신청 (하이브리드: 폼 → 채팅)
            if (_currentTab == 0)
              const Expanded(child: DisposalChatScreen())
            // 탭 1 = 이전설치 (하이브리드: 폼 → 채팅)
            else if (_currentTab == 1)
              const Expanded(child: RelocationChatScreen())
            // 탭 2 = 신청내역
            else if (_currentTab == 2)
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    _buildHistoryTab(),
                  ],
                ),
              )
            // 탭 3 = 마이페이지
            else
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    _buildMyPageTab(),
                  ],
                ),
              ),

            // Bottom navigation
            _buildBottomNavigation(),
          ],
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

  // ============ Bottom Navigation ============

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
