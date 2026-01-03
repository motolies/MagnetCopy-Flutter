# 빌드 가이드

MagnetCopy는 Flutter를 사용하여 macOS, Windows, Linux에서 실행되는 크로스플랫폼 데스크톱 애플리케이션입니다.

## 지원 플랫폼

| 플랫폼 | 상태 | 문서 |
|--------|------|------|
| macOS | 지원 | [macOS 빌드 가이드](./macos.md) |
| Windows | 지원 | [Windows 빌드 가이드](./windows.md) |
| Linux | 지원 | [Linux 빌드 가이드](./linux.md) |

## 공통 요구사항

### Flutter SDK

모든 플랫폼에서 Flutter SDK가 필요합니다.

```bash
# Flutter 설치 확인
flutter --version

# 개발 환경 상태 확인
flutter doctor
```

**요구 버전**: Flutter 3.10.0 이상 (Dart 3.10.0 이상)

### 의존성 설치

```bash
# 프로젝트 의존성 설치
flutter pub get
```

## 공통 빌드 명령어

### 개발 모드 실행

```bash
# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

### 릴리즈 빌드

```bash
# macOS (.app 번들)
flutter build macos

# Windows (.exe)
flutter build windows

# Linux (실행 파일)
flutter build linux
```

### 빌드 결과물 위치

| 플랫폼 | 경로 |
|--------|------|
| macOS | `build/macos/Build/Products/Release/magnet_copy.app` |
| Windows | `build/windows/x64/runner/Release/magnet_copy.exe` |
| Linux | `build/linux/x64/release/bundle/magnet_copy` |

## 플랫폼별 상세 설정

각 플랫폼에는 고유한 환경 설정과 앱 커스터마이징 방법이 있습니다. 자세한 내용은 플랫폼별 문서를 참조하세요.

- [macOS 빌드 가이드](./macos.md) - Xcode, CocoaPods, 코드 서명
- [Windows 빌드 가이드](./windows.md) - Visual Studio, CMake 설정
- [Linux 빌드 가이드](./linux.md) - GTK 라이브러리, 패키지 의존성
