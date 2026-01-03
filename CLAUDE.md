# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

MagnetCopy - 마그넷 링크 수집기. macOS, Windows, Linux 크로스플랫폼 Flutter 데스크톱 앱.
브라우저에서 마그넷 링크 클릭 시 앱이 수신하여 리스트로 관리하고 클립보드 복사 기능 제공.

## 개발 명령어

```bash
# 실행 (macOS 기준)
flutter run -d macos

# 테스트
flutter test
flutter test test/widget_test.dart    # 단일 파일

# 코드 품질
flutter analyze && dart format lib/

# 빌드
flutter build macos
```

## 아키텍처

```
lib/
├── main.dart                 # 앱 초기화, deep link 핸들링, window 설정
├── models/
│   └── magnet_link.dart     # MagnetLink 데이터 모델 (uri, addedAt, displayName)
├── providers/
│   └── magnet_provider.dart # Provider 상태관리 (ChangeNotifier)
└── screens/
    └── home_screen.dart     # 단일 화면 UI (링크 리스트, 복사, 삭제)
```

### 상태 관리 흐름

```
브라우저에서 magnet:// 클릭
  → app_links 패키지가 deep link 수신
  → MagnetProvider.addLink() 호출 (중복 체크, 유효성 검증)
  → AddLinkResult 반환 (added/duplicate/invalid)
  → UI 토스트 표시 + 리스트 자동 갱신
```

### 플랫폼 통신

```dart
// macOS URL 핸들러 등록 (MethodChannel)
static const platform = MethodChannel('magnet_copy/url_handler');
await platform.invokeMethod('registerAsDefaultHandler');
await platform.invokeMethod('isDefaultHandler');
```

macOS 네이티브 코드: `macos/Runner/AppDelegate.swift`

## 핵심 의존성

- `provider: ^6.1.2` - 상태 관리
- `app_links: ^6.4.0` - URL scheme deep link 처리
- `window_manager: ^0.4.3` - 데스크톱 윈도우 관리 (always-on-top 등)

## 현재 제한사항

- Windows/Linux URL scheme 핸들러 미구현 (macOS만 완전 지원)

## 개발환경

- flutter 3.38.5
- Android Studio