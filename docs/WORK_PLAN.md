# RESIT 채팅 앱 2차 개발 작업계획서

## 프로젝트 개요
- **프로젝트명**: RESIT 안마의자 처분/이전설치 채팅 앱
- **금액**: 50만원 + 5점 리뷰
- **클라이언트**: 크몽 고객

---

## 1차 개발 완료 내용 (UI Only)
- [x] 스플래시 화면
- [x] 로그인 화면 (카카오 로그인 버튼 UI)
- [x] 채팅 목록 화면
- [x] 채팅방 화면 (4개 탭: 처분신청, 이전설치, 신청내역, 마이)
- [x] 처분신청 폼 UI
- [x] 이전설치 폼 UI
- [x] 신청내역 목록 UI
- [x] 마이페이지 UI
- [x] Vercel 웹 배포
- [x] APK 빌드
- [x] iOS 설치

---

## 2차 개발 범위 (합의된 기능)

### 필수 기능
| # | 기능 | 설명 | 상태 |
|---|------|------|------|
| 1 | 카카오 로그인 | OAuth 연동 | 🔲 준비중 |
| 2 | 실시간 채팅 | Firestore 기반 | 🔲 준비중 |
| 3 | 사진 업로드 | Firebase Storage | 🔲 준비중 |
| 4 | 처분신청 폼 | 사진 + 메모 제출 | 🔲 준비중 |
| 5 | 이전설치 폼 | 주소/모델명/엘리베이터 | 🔲 준비중 |
| 6 | 신청내역 조회 | 사용자별 신청 목록 | 🔲 준비중 |
| 7 | 푸시 알림 | FCM 연동 | 🔲 준비중 |

### 제외 항목 (추가 비용 필요)
- 관리자 대시보드
- 결제 시스템
- 고급 분석/리포트

---

## 작업 단계

### Phase 1: Firebase 설정 (사용자 작업 필요)
1. Firebase 프로젝트 생성
2. `flutterfire configure` 실행
3. Firestore 데이터베이스 생성
4. Firebase Storage 활성화
5. Firebase Authentication 활성화

### Phase 2: 카카오 설정 (사용자 작업 필요)
1. Kakao Developers 앱 등록
2. 네이티브 앱 키 발급
3. JavaScript 앱 키 발급
4. 플랫폼 등록 (iOS, Android, Web)

### Phase 3: 인증 구현
- [ ] 카카오 로그인 연동
- [ ] Firebase Auth 연동
- [ ] 로그인 상태 관리
- [ ] 로그아웃 구현

### Phase 4: 채팅 구현
- [ ] Firestore 채팅 구조 구현
- [ ] 실시간 메시지 수신
- [ ] 메시지 전송
- [ ] 읽음 표시

### Phase 5: 폼 & 신청 구현
- [ ] 사진 업로드 (처분신청)
- [ ] 처분신청 제출 → Firestore 저장
- [ ] 이전설치 신청 제출 → Firestore 저장
- [ ] 신청내역 조회 (실시간)

### Phase 6: 푸시 알림
- [ ] FCM 토큰 저장
- [ ] 새 메시지 알림
- [ ] 신청 상태 변경 알림

### Phase 7: 테스트 & 배포
- [ ] 기능 테스트
- [ ] APK 빌드
- [ ] iOS 빌드
- [ ] Vercel 배포

---

## Firestore 데이터 구조

```
/users/{userId}
  - email: string
  - name: string
  - fcmToken: string
  - createdAt: timestamp

/chats/{chatId}
  - userId: string
  - createdAt: timestamp
  - lastMessage: string
  - lastMessageTime: timestamp
  /messages/{messageId}
    - senderId: string
    - content: string
    - imageUrl?: string
    - type: 'text' | 'image' | 'system'
    - timestamp: timestamp
    - isRead: boolean

/applications/{applicationId}
  - userId: string
  - type: 'disposal' | 'relocation'
  - status: 'pending' | 'inProgress' | 'completed' | 'cancelled'
  - createdAt: timestamp
  - formData: map
  - imageUrls: array<string>
```

---

## 현재 완료된 작업

### 코드 구조
```
lib/
├── main.dart                 # Firebase/Kakao 초기화 추가
├── firebase_options.dart     # Firebase 설정 (placeholder)
├── constants/
│   └── app_colors.dart
├── models/
│   └── chat_message.dart     # MessageType enum 추가
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── chat_list_screen.dart
│   └── chat_room_screen.dart
└── services/                 # 새로 생성
    ├── auth_service.dart     # 카카오 + Firebase Auth
    ├── chat_service.dart     # Firestore 채팅
    ├── storage_service.dart  # Firebase Storage
    ├── application_service.dart  # 신청 관리
    └── notification_service.dart # FCM 푸시
```

### 추가된 패키지
- firebase_core
- cloud_firestore
- firebase_auth
- firebase_storage
- firebase_messaging
- kakao_flutter_sdk_user
- image_picker
- uuid

---

## 다음 단계
사용자가 Firebase와 Kakao 설정을 완료하면 실제 기능 구현을 진행합니다.
