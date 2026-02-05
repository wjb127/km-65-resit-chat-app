# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RESIT 채팅 앱 — 안마의자 처분/이전설치 서비스용 고객-관리자 실시간 채팅 모바일 앱. Flutter + Firebase (계획) 기반.

## Build & Run Commands

```bash
# 분석 (린트)
flutter analyze

# 웹 빌드
flutter build web

# 웹 실행
flutter run -d chrome

# iOS 시뮬레이터 실행
flutter run -d <simulator_id>

# macOS 데스크탑 실행
flutter run -d macos

# 테스트
flutter test

# 단일 테스트 파일
flutter test test/widget_test.dart

# 의존성 설치
flutter pub get

# 클린 빌드
flutter clean && flutter pub get
```

## Architecture

```
lib/
├── main.dart              # 앱 진입점 (ResitApp), Material 3 테마 설정
├── constants/
│   ├── app_colors.dart    # 앱 컬러 팔레트 (primary: #2D9CDB)
│   └── app_styles.dart    # 텍스트 스타일 프리셋
├── models/
│   └── chat_message.dart  # ChatMessage, ChatRoom 데이터 모델
├── screens/
│   ├── splash_screen.dart     # 스플래시 (3초 후 로그인 전환, fade+scale 애니메이션)
│   ├── login_screen.dart      # 전화번호 로그인
│   ├── chat_list_screen.dart  # 채팅 목록 (온라인 표시, 안읽음 뱃지)
│   └── chat_room_screen.dart  # 채팅방 (메시지 버블, 입력, 자동응답)
└── widgets/               # 재사용 위젯 (확장 예정)
```

**화면 흐름:** SplashScreen → LoginScreen → ChatListScreen → ChatRoomScreen

## Key Conventions

- **패키지 이름:** `com.resit.resit`
- **상태 관리:** 현재 setState 사용 (Firebase 연동 시 상태관리 도입 예정)
- **테마:** Material 3, seed color `#2D9CDB`, 폰트 Pretendard 설정됨
- **데이터:** 현재 더미 데이터 하드코딩 (1차 시안 단계), Firebase Firestore 연동 예정
- **내비게이션:** MaterialPageRoute 기반 직접 push/pushReplacement
- **외부 패키지:** 현재 없음 (cupertino_icons만 사용), Firebase 등 추후 추가 예정

## Current Status

1차 UI 시안 완료 상태. 다음 단계:
- Firebase Auth 연동 (전화번호 인증)
- Firestore 실시간 채팅
- FCM 푸시 알림
- 앱스토어 배포
