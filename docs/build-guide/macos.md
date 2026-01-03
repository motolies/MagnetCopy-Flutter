# macOS 빌드 가이드

## 환경 설정

### 1. Xcode 설치

App Store에서 Xcode를 설치하거나 [Apple Developer](https://developer.apple.com/xcode/)에서 다운로드합니다.

```bash
# Xcode 설치 후 명령줄 도구 설정
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# 라이선스 동의 및 초기 설정
sudo xcodebuild -runFirstLaunch
```

### 2. CocoaPods 설치

Flutter macOS 플러그인들은 CocoaPods를 통해 관리됩니다.

```bash
# CocoaPods 설치 (Ruby gem)
sudo gem install cocoapods

# 또는 Homebrew 사용
brew install cocoapods
```

### 3. 환경 확인

```bash
flutter doctor
```

다음 항목이 체크되어야 합니다:
- `[✓] Xcode - develop for iOS and macOS`

## 빌드 명령어

### 개발 모드

```bash
# 디버그 모드 실행
flutter run -d macos

# 핫 리로드 지원 (코드 변경 시 자동 반영)
```

### 릴리즈 빌드

```bash
# 릴리즈 빌드
flutter build macos

# 빌드 결과물 위치
# build/macos/Build/Products/Release/magnet_copy.app
```

### Xcode에서 직접 빌드

```bash
# Xcode 프로젝트 열기
open macos/Runner.xcworkspace
```

## 앱 설정 변경

### 앱 이름 변경

**파일**: `macos/Runner/Configs/AppInfo.xcconfig`

```xcconfig
// 앱 표시 이름
PRODUCT_NAME = MagnetCopy

// 번들 식별자 (고유해야 함)
PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.magnetcopy

// 저작권 표시
PRODUCT_COPYRIGHT = Copyright © 2024 YourCompany. All rights reserved.
```

### 앱 아이콘 변경

**위치**: `macos/Runner/Assets.xcassets/AppIcon.appiconset/`

필요한 아이콘 크기:
| 파일명 | 크기 | 용도 |
|--------|------|------|
| app_icon_16.png | 16x16 | 메뉴바, Dock 축소 |
| app_icon_32.png | 32x32 | Finder 목록 |
| app_icon_64.png | 64x64 | Finder |
| app_icon_128.png | 128x128 | Finder 미리보기 |
| app_icon_256.png | 256x256 | Finder 큰 아이콘 |
| app_icon_512.png | 512x512 | App Store |
| app_icon_1024.png | 1024x1024 | App Store 고해상도 |

아이콘 변경 후 `Contents.json` 파일도 함께 업데이트해야 합니다.

### 권한 설정 (Entitlements)

macOS 앱은 샌드박스 환경에서 실행되며, 특정 기능 사용 시 권한 설정이 필요합니다.

**파일**: `macos/Runner/DebugProfile.entitlements` (개발용)
**파일**: `macos/Runner/Release.entitlements` (배포용)

#### 네트워크 접근

```xml
<!-- 외부 서버 연결 -->
<key>com.apple.security.network.client</key>
<true/>

<!-- 서버 역할 (로컬 서버 등) -->
<key>com.apple.security.network.server</key>
<true/>
```

#### 파일 시스템 접근

```xml
<!-- 사용자가 선택한 파일 읽기 -->
<key>com.apple.security.files.user-selected.read-only</key>
<true/>

<!-- 사용자가 선택한 파일 읽기/쓰기 -->
<key>com.apple.security.files.user-selected.read-write</key>
<true/>

<!-- 다운로드 폴더 접근 -->
<key>com.apple.security.files.downloads.read-write</key>
<true/>
```

#### 클립보드 접근

```xml
<!-- 클립보드 읽기/쓰기 (기본 허용) -->
<!-- 샌드박스 환경에서도 클립보드는 기본 접근 가능 -->
```

### 최소 macOS 버전 설정

**파일**: `macos/Runner.xcodeproj/project.pbxproj`

Xcode에서 설정하거나 직접 수정:
- Target → General → Deployment Info → macOS Deployment Target

### 윈도우 크기 설정

**파일**: `macos/Runner/MainFlutterWindow.swift`

```swift
override func awakeFromNib() {
    // 윈도우 크기 설정
    self.setFrame(NSRect(x: 0, y: 0, width: 1280, height: 720), display: true)

    // 최소 크기 설정
    self.minSize = NSSize(width: 800, height: 600)
}
```

## 트러블슈팅

### CocoaPods 관련 오류

```bash
# Pod 캐시 정리 및 재설치
cd macos
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

### 코드 서명 오류

개발 중에는 Xcode에서 자동 서명을 사용합니다:
1. `Runner.xcworkspace` 열기
2. Runner 타겟 선택
3. Signing & Capabilities 탭
4. "Automatically manage signing" 체크
5. Team 선택 (Apple Developer 계정 필요)

### "Unable to boot simulator" 오류

```bash
# 시뮬레이터 캐시 정리
xcrun simctl erase all
```

### 빌드 캐시 문제

```bash
# Flutter 빌드 캐시 정리
flutter clean

# Xcode 파생 데이터 정리
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Rosetta 관련 문제 (Apple Silicon)

Apple Silicon Mac에서 일부 도구가 Rosetta로 실행될 수 있습니다:

```bash
# arm64 네이티브로 Flutter 실행 확인
flutter doctor -v
```

## 배포 준비

### App Store 배포

1. Apple Developer Program 가입 필요 ($99/년)
2. App Store Connect에서 앱 등록
3. Xcode에서 Archive 생성
4. App Store Connect에 업로드

### 직접 배포 (DMG)

```bash
# create-dmg 설치
brew install create-dmg

# DMG 생성
create-dmg \
  --volname "MagnetCopy" \
  --window-size 600 400 \
  --app-drop-link 400 200 \
  "MagnetCopy.dmg" \
  "build/macos/Build/Products/Release/magnet_copy.app"
```

### 공증 (Notarization)

App Store 외부 배포 시 Apple 공증이 필요합니다:

```bash
# 앱 공증 요청
xcrun notarytool submit MagnetCopy.dmg \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password" \
  --wait
```
