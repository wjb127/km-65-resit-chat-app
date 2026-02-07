# RESIT 앱 스토어 출시 가이드

## 목차
1. [사전 준비사항](#1-사전-준비사항)
2. [카카오 로그인 설정](#2-카카오-로그인-설정)
3. [Android 출시 (Google Play Store)](#3-android-출시-google-play-store)
4. [iOS 출시 (App Store)](#4-ios-출시-app-store)
5. [출시 후 체크리스트](#5-출시-후-체크리스트)

---

## 1. 사전 준비사항

### 1.1 개발자 계정
| 플랫폼 | 비용 | 등록 URL |
|--------|------|----------|
| Google Play Console | $25 (1회) | https://play.google.com/console |
| Apple Developer Program | $99/년 | https://developer.apple.com/programs |
| Kakao Developers | 무료 | https://developers.kakao.com |

### 1.2 앱 정보 준비
- **앱 이름**: RESIT (리싯)
- **패키지명 (Android)**: `com.seungbeen.resit`
- **Bundle ID (iOS)**: `com.seungbeen.resit`
- **앱 설명** (한글/영문)
- **스크린샷** (각 기기 사이즈별)
- **앱 아이콘** (1024x1024)
- **개인정보처리방침 URL**
- **고객지원 이메일/전화번호**

---

## 2. 카카오 로그인 설정

### 2.1 Kakao Developers 앱 등록

1. https://developers.kakao.com 접속 및 로그인
2. **내 애플리케이션 > 애플리케이션 추가하기**
3. 앱 정보 입력:
   - 앱 이름: `RESIT`
   - 사업자명: (회사명)
   - 카테고리: 생활/편의

### 2.2 플랫폼 등록

#### Android 플랫폼
1. **내 애플리케이션 > 앱 설정 > 플랫폼**
2. **Android 플랫폼 등록** 클릭
3. 정보 입력:
   - **패키지명**: `com.seungbeen.resit`
   - **마켓 URL**: `https://play.google.com/store/apps/details?id=com.seungbeen.resit`
   - **키 해시**: (아래 명령어로 생성)

```bash
# 디버그 키 해시 (개발용)
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64

# 릴리스 키 해시 (출시용) - keystore 경로와 alias 수정 필요
keytool -exportcert -alias YOUR_ALIAS -keystore YOUR_KEYSTORE.jks | openssl sha1 -binary | openssl base64
```

#### iOS 플랫폼
1. **iOS 플랫폼 등록** 클릭
2. 정보 입력:
   - **번들 ID**: `com.seungbeen.resit`
   - **앱스토어 ID**: (출시 후 입력)

### 2.3 카카오 로그인 활성화

1. **제품 설정 > 카카오 로그인** 메뉴
2. **활성화 설정**: ON
3. **동의항목** 설정:
   - 닉네임: 필수 동의
   - 프로필 사진: 선택 동의
   - 카카오계정(이메일): 선택 동의 (이메일 필요시)

### 2.4 Redirect URI 설정

**카카오 로그인 > Redirect URI**에 추가:
```
kakao{NATIVE_APP_KEY}://oauth
```
예: `kakao1234567890abcdef://oauth`

### 2.5 앱 키 확인

**앱 설정 > 앱 키**에서 확인:
- **네이티브 앱 키**: Android/iOS 앱에서 사용
- **REST API 키**: 서버에서 사용
- **JavaScript 키**: 웹에서 사용

### 2.6 Flutter 프로젝트 설정

#### pubspec.yaml
```yaml
dependencies:
  kakao_flutter_sdk_user: ^1.9.0
```

#### Android 설정 (android/app/src/main/AndroidManifest.xml)
```xml
<manifest>
    <application>
        <!-- 카카오 로그인 커스텀 URL 스킴 -->
        <activity
            android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
            android:exported="true">
            <intent-filter android:label="flutter_web_auth">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="kakao{NATIVE_APP_KEY}" android:host="oauth"/>
            </intent-filter>
        </activity>
    </application>

    <!-- 카카오톡 공유, 카카오톡 메시지 전송 시 필요 -->
    <queries>
        <package android:name="com.kakao.talk" />
    </queries>
</manifest>
```

#### iOS 설정 (ios/Runner/Info.plist)
```xml
<dict>
    <!-- 카카오 로그인 -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>kakao{NATIVE_APP_KEY}</string>
            </array>
        </dict>
    </array>

    <!-- 카카오톡 실행 허용 -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>kakaokompassauth</string>
        <string>storykompassauth</string>
        <string>kakaolink</string>
    </array>

    <key>KAKAO_NATIVE_APP_KEY</key>
    <string>{NATIVE_APP_KEY}</string>
</dict>
```

#### main.dart 초기화
```dart
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '{NATIVE_APP_KEY}',
    javaScriptAppKey: '{JAVASCRIPT_KEY}', // 웹용 (선택)
  );

  runApp(MyApp());
}
```

---

## 3. Android 출시 (Google Play Store)

### 3.1 서명 키 생성

```bash
# keystore 생성 (최초 1회)
keytool -genkey -v -keystore ~/resit-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias resit

# 생성 시 입력 정보 기록해두기:
# - 키스토어 비밀번호
# - 키 별칭 (alias)
# - 키 비밀번호
```

### 3.2 서명 설정

**android/key.properties** 파일 생성:
```properties
storePassword=<키스토어 비밀번호>
keyPassword=<키 비밀번호>
keyAlias=resit
storeFile=/Users/YOUR_USERNAME/resit-release-key.jks
```

**android/app/build.gradle** 수정:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 3.3 릴리스 빌드

```bash
# App Bundle (권장 - Play Store 업로드용)
flutter build appbundle --release

# APK (테스트 배포용)
flutter build apk --release
```

빌드 결과물:
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

### 3.4 Google Play Console 등록

1. **Google Play Console** 접속 (https://play.google.com/console)
2. **앱 만들기** 클릭
3. 기본 정보 입력:
   - 앱 이름: RESIT
   - 기본 언어: 한국어
   - 앱 또는 게임: 앱
   - 무료 또는 유료: 무료

### 3.5 스토어 등록정보 작성

#### 기본 정보
- **앱 이름**: RESIT - 안마의자 처분/이전
- **간단한 설명** (80자):
  ```
  안마의자 무료 수거, 이전 설치를 30초만에 신청하세요. 전국 어디서나 빠른 상담!
  ```
- **자세한 설명** (4000자):
  ```
  RESIT은 안마의자 처분과 이전 설치를 간편하게 신청할 수 있는 서비스입니다.

  🪑 주요 기능
  • 안마의자 무료 수거 신청
  • 이전 설치 신청 및 견적
  • 실시간 채팅 상담
  • 신청 내역 관리

  📱 간편한 신청
  사진 몇 장과 기본 정보만 입력하면 1일 내 연락드립니다.

  🚚 전국 서비스
  서울, 경기 뿐 아니라 전국 어디서나 서비스 제공합니다.

  💬 빠른 상담
  카카오 로그인으로 간편하게 시작하고, 채팅으로 실시간 상담받으세요.
  ```

#### 그래픽 자료
| 항목 | 사이즈 | 필수 |
|------|--------|------|
| 앱 아이콘 | 512x512 | O |
| 그래픽 이미지 | 1024x500 | O |
| 스크린샷 (휴대전화) | 최소 2장, 16:9 또는 9:16 | O |
| 스크린샷 (태블릿 7인치) | 최소 1장 | X |
| 스크린샷 (태블릿 10인치) | 최소 1장 | X |

### 3.6 앱 콘텐츠 설정

1. **개인정보처리방침**: URL 입력
2. **앱 액세스 권한**: 제한 없음 선택 (또는 테스트 계정 제공)
3. **광고**: 광고 포함 여부 선택
4. **콘텐츠 등급**: 설문지 작성 후 등급 부여
5. **타겟층**: 성인 (18세 이상)
6. **뉴스 앱**: 아니오
7. **코로나19 앱**: 아니오
8. **데이터 보안**: 수집 데이터 종류 명시

### 3.7 출시 관리

1. **프로덕션 > 새 버전 만들기**
2. App Bundle(.aab) 업로드
3. 버전 이름 입력: `1.0.0`
4. 출시 노트 작성
5. **검토 시작** 클릭

> 검토 기간: 보통 1-3일 (첫 출시 시 더 오래 걸릴 수 있음)

---

## 4. iOS 출시 (App Store)

### 4.1 Apple Developer 계정 설정

1. https://developer.apple.com/account 접속
2. **Certificates, Identifiers & Profiles** 메뉴

### 4.2 App ID 등록

1. **Identifiers > + 버튼** 클릭
2. **App IDs** 선택 > Continue
3. **App** 선택 > Continue
4. 정보 입력:
   - Description: RESIT
   - Bundle ID: `com.seungbeen.resit` (Explicit)
5. Capabilities 선택:
   - [x] Push Notifications
   - [x] Sign In with Apple (선택사항)
6. **Register** 클릭

### 4.3 인증서 생성

#### 개발 인증서
1. **Certificates > + 버튼**
2. **iOS App Development** 선택
3. CSR 파일 업로드 (키체인 접근에서 생성)
4. 인증서 다운로드 및 설치

#### 배포 인증서
1. **Certificates > + 버튼**
2. **iOS Distribution (App Store and Ad Hoc)** 선택
3. CSR 파일 업로드
4. 인증서 다운로드 및 설치

### 4.4 Provisioning Profile 생성

1. **Profiles > + 버튼**
2. **App Store** 선택 > Continue
3. App ID 선택: `com.seungbeen.resit`
4. 배포 인증서 선택
5. Profile 이름 입력: `RESIT App Store`
6. **Generate** 클릭
7. 다운로드 및 Xcode에 설치

### 4.5 Xcode 프로젝트 설정

```bash
cd ios
open Runner.xcworkspace
```

Xcode에서:
1. **Runner** 프로젝트 선택
2. **Signing & Capabilities** 탭
3. **Team**: 개발자 계정 선택
4. **Bundle Identifier**: `com.seungbeen.resit`
5. **Signing Certificate**: Distribution 인증서 선택

### 4.6 Archive 및 업로드

#### 방법 1: Xcode 사용
```bash
# 1. Flutter 빌드
flutter build ios --release

# 2. Xcode에서 Archive
# Product > Archive

# 3. Organizer에서 Distribute App
# App Store Connect > Upload
```

#### 방법 2: CLI 사용
```bash
# 1. IPA 빌드
flutter build ipa --release

# 2. 업로드 (xcrun 사용)
xcrun altool --upload-app --type ios -f build/ios/ipa/RESIT.ipa -u "APPLE_ID" -p "APP_SPECIFIC_PASSWORD"
```

### 4.7 App Store Connect 설정

1. https://appstoreconnect.apple.com 접속
2. **나의 앱 > + 버튼 > 신규 앱**
3. 정보 입력:
   - 플랫폼: iOS
   - 이름: RESIT
   - 기본 언어: 한국어
   - 번들 ID: `com.seungbeen.resit`
   - SKU: `resit-ios-001`

### 4.8 앱 정보 입력

#### 일반 정보
- **부제**: 안마의자 처분/이전 서비스
- **카테고리**: 라이프스타일
- **콘텐츠 권한**: 4+
- **가격**: 무료

#### 앱 심사 정보
- **연락처 정보**: 이메일, 전화번호
- **로그인 정보**: 테스트 계정 (심사용)
- **메모**: 앱 설명, 특이사항

#### 스크린샷
| 기기 | 사이즈 | 필수 |
|------|--------|------|
| iPhone 6.7" | 1290 x 2796 | O |
| iPhone 6.5" | 1242 x 2688 | O |
| iPhone 5.5" | 1242 x 2208 | O |
| iPad Pro 12.9" | 2048 x 2732 | 조건부 |

### 4.9 심사 제출

1. 모든 정보 입력 완료 확인
2. **심사를 위해 제출** 클릭
3. 암호화 관련 질문 답변 (Firebase 사용 시: 예)

> 심사 기간: 보통 1-3일 (첫 출시 시 1주일 이상 걸릴 수 있음)

---

## 5. 출시 후 체크리스트

### 5.1 필수 확인 항목

- [ ] 앱 설치 및 실행 테스트
- [ ] 카카오 로그인 동작 확인
- [ ] Firebase 연동 확인 (Firestore, Storage, Auth)
- [ ] 푸시 알림 테스트
- [ ] 사진 업로드 테스트
- [ ] 채팅 기능 테스트

### 5.2 모니터링

| 도구 | 용도 | URL |
|------|------|-----|
| Firebase Console | 사용자 분석, 오류 | https://console.firebase.google.com |
| Google Play Console | Android 통계 | https://play.google.com/console |
| App Store Connect | iOS 통계 | https://appstoreconnect.apple.com |
| Kakao Developers | 로그인 통계 | https://developers.kakao.com |

### 5.3 업데이트 배포

#### Android
```bash
# 버전 올리기 (pubspec.yaml)
version: 1.0.1+2  # major.minor.patch+buildNumber

# 빌드 및 업로드
flutter build appbundle --release
# Play Console에서 새 버전 업로드
```

#### iOS
```bash
# 버전 올리기 (pubspec.yaml)
version: 1.0.1+2

# 빌드 및 업로드
flutter build ipa --release
# App Store Connect에서 새 버전 업로드
```

---

## 부록: 문제 해결

### A. 카카오 로그인 오류

| 오류 | 원인 | 해결 |
|------|------|------|
| `KOE101` | 앱 키 오류 | 네이티브 앱 키 확인 |
| `KOE302` | Redirect URI 불일치 | URI 설정 확인 |
| `키 해시 불일치` | Android 키 해시 미등록 | 카카오 콘솔에서 키 해시 추가 |

### B. iOS 빌드 오류

```bash
# Pod 캐시 정리
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update

# DerivedData 정리
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### C. Android 빌드 오류

```bash
# Gradle 캐시 정리
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

---

## 연락처

- 기술 지원: (이메일)
- 카카오 API 문의: https://devtalk.kakao.com
- Firebase 문의: https://firebase.google.com/support
