# RESIT 2차 개발 - 사용자 설정 가이드

2차 개발을 진행하기 위해 아래 설정이 필요합니다.

---

## 1. Firebase 프로젝트 설정

### 1.1 Firebase 콘솔에서 프로젝트 생성
1. https://console.firebase.google.com 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름: `resit-chat` (또는 원하는 이름)
4. Google Analytics 설정 (선택사항)
5. 프로젝트 생성 완료

### 1.2 앱 등록
Firebase 콘솔에서 각 플랫폼 앱을 등록:

#### Android
1. 프로젝트 설정 → 앱 추가 → Android
2. 패키지 이름: `com.seungbeen.resit`
3. `google-services.json` 다운로드
4. 파일을 `android/app/` 폴더에 복사

#### iOS
1. 프로젝트 설정 → 앱 추가 → iOS
2. 번들 ID: `com.seungbeen.resit`
3. `GoogleService-Info.plist` 다운로드
4. Xcode에서 `ios/Runner/` 폴더에 추가

#### Web
1. 프로젝트 설정 → 앱 추가 → Web
2. 앱 닉네임: `resit-web`
3. Firebase SDK 설정 값 확인

### 1.3 FlutterFire CLI로 설정 자동화 (권장)
```bash
# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 설정 자동 생성
cd /Users/seungbeenwi/Project/km-65-resit-chat-app
flutterfire configure
```

이 명령어가 `lib/firebase_options.dart` 파일을 자동으로 업데이트합니다.

### 1.4 Firebase 서비스 활성화

#### Firestore Database
1. Firebase 콘솔 → Firestore Database
2. "데이터베이스 만들기" 클릭
3. 테스트 모드로 시작 (개발용)
4. 위치: `asia-northeast3` (서울)

#### Firebase Storage
1. Firebase 콘솔 → Storage
2. "시작하기" 클릭
3. 테스트 모드로 시작

#### Firebase Authentication
1. Firebase 콘솔 → Authentication
2. "시작하기" 클릭
3. 로그인 방법 → 이메일/비밀번호 활성화

#### Cloud Messaging (FCM)
1. Firebase 콘솔 → 프로젝트 설정
2. Cloud Messaging 탭
3. 서버 키 확인 (푸시 발송용)

---

## 2. 카카오 개발자 설정

### 2.1 카카오 앱 등록
1. https://developers.kakao.com 접속
2. 로그인 → 내 애플리케이션 → 애플리케이션 추가
3. 앱 이름: `RESIT`
4. 회사명: (본인 또는 회사명)

### 2.2 앱 키 확인
애플리케이션 → 앱 설정 → 앱 키에서:
- **네이티브 앱 키**: Android/iOS용
- **JavaScript 키**: Web용

### 2.3 플랫폼 등록
애플리케이션 → 플랫폼에서:

#### Android
- 패키지명: `com.seungbeen.resit`
- 키 해시: (아래 명령어로 생성)

```bash
# 디버그 키 해시 생성
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64
```

#### iOS
- 번들 ID: `com.seungbeen.resit`

#### Web
- 사이트 도메인: `https://web-m46jywsh9-seungbeen-wis-projects.vercel.app`

### 2.4 카카오 로그인 활성화
1. 제품 설정 → 카카오 로그인
2. 활성화 설정 → ON
3. Redirect URI 등록:
   - `kakao{NATIVE_APP_KEY}://oauth`

### 2.5 동의 항목 설정
제품 설정 → 카카오 로그인 → 동의항목:
- 닉네임: 필수 동의
- 프로필 사진: 선택 동의

---

## 3. 코드에 키 입력

### 3.1 Firebase (자동)
`flutterfire configure` 실행 시 자동으로 `lib/firebase_options.dart` 업데이트됨

### 3.2 카카오 키 입력
`lib/main.dart` 파일에서:

```dart
KakaoSdk.init(
  nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY', // 여기에 네이티브 앱 키 입력
  javaScriptAppKey: 'YOUR_KAKAO_JS_APP_KEY', // 여기에 JavaScript 키 입력
);
```

### 3.3 Android 설정
`android/app/src/main/AndroidManifest.xml`에 추가:

```xml
<activity
    android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:host="oauth" android:scheme="kakao{NATIVE_APP_KEY}" />
    </intent-filter>
</activity>
```

### 3.4 iOS 설정
`ios/Runner/Info.plist`에 추가:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>kakao{NATIVE_APP_KEY}</string>
        </array>
    </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>kakaokompassauth</string>
    <string>kakaolink</string>
</array>
```

---

## 4. 완료 후 알려주세요

위 설정을 완료하시면 알려주세요. 그러면:
1. `flutterfire configure` 실행 결과 확인
2. 카카오 키가 입력된 main.dart 확인
3. 실제 기능 구현 진행

---

## 체크리스트

- [ ] Firebase 프로젝트 생성
- [ ] Android 앱 등록 + google-services.json 복사
- [ ] iOS 앱 등록 + GoogleService-Info.plist 추가
- [ ] Web 앱 등록
- [ ] flutterfire configure 실행
- [ ] Firestore 활성화
- [ ] Storage 활성화
- [ ] Authentication 활성화
- [ ] 카카오 앱 등록
- [ ] 카카오 플랫폼 등록 (Android, iOS, Web)
- [ ] 카카오 로그인 활성화
- [ ] main.dart에 카카오 키 입력
- [ ] AndroidManifest.xml 수정
- [ ] Info.plist 수정
