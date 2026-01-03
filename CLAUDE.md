# CLAUDE.md

이 파일은 Claude Code (claude.ai/code)가 이 저장소에서 작업할 때 참고하는 가이드입니다.

## 프로젝트 개요

MagnetCopy - macOS, Windows, Linux를 타겟으로 하는 Flutter 크로스플랫폼 데스크톱 GUI 애플리케이션.

## 개발 명령어

```bash
# 플랫폼별 실행
flutter run -d macos
flutter run -d windows
flutter run -d linux
flutter run -d chrome  # 웹 폴백 (테스트용)

# 릴리즈 빌드
flutter build macos
flutter build windows
flutter build linux

# 테스트
flutter test                          # 전체 테스트 실행
flutter test test/widget_test.dart    # 단일 테스트 파일 실행

# 코드 품질
flutter analyze                       # 정적 분석
dart format lib/                      # 코드 포맷팅

# 의존성 관리
flutter pub get                       # 의존성 설치
flutter pub upgrade                   # 의존성 업그레이드
```

## 아키텍처

현재 초기 템플릿 상태. 데스크톱 앱을 위한 계획된 구조:

```
lib/
├── main.dart              # 앱 진입점
├── app.dart               # MaterialApp 설정
├── features/              # 기능별 모듈
├── shared/                # 공유 위젯 및 유틸리티
└── core/                  # 핵심 서비스 (클립보드, 저장소 등)
```

## 플랫폼별 참고사항

- **macOS**: 네이티브 빌드에 Xcode와 CocoaPods 필요
- **Windows**: C++ 데스크톱 개발이 포함된 Visual Studio 필요
- **Linux**: GTK 개발 라이브러리 필요 (libgtk-3-dev, clang, cmake, ninja-build)

## 현재 의존성

- Flutter SDK ^3.10.4
- cupertino_icons (iOS 스타일 아이콘)
- flutter_lints (dev - 코드 스타일 검사)
