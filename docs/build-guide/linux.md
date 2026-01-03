# Linux 빌드 가이드

## 환경 설정

### 1. 필수 패키지 설치

#### Ubuntu/Debian

```bash
sudo apt update
sudo apt install -y \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-12-dev
```

#### Fedora

```bash
sudo dnf install -y \
    clang \
    cmake \
    ninja-build \
    gtk3-devel \
    xz-devel
```

#### Arch Linux

```bash
sudo pacman -S --needed \
    clang \
    cmake \
    ninja \
    gtk3 \
    xz
```

### 2. 환경 확인

```bash
flutter doctor
```

다음 항목이 체크되어야 합니다:
- `[✓] Linux toolchain - develop for Linux desktop`

### 3. 추가 의존성 (선택)

클립보드 기능 사용 시:
```bash
# X11 클립보드
sudo apt install xclip xsel

# Wayland 클립보드
sudo apt install wl-clipboard
```

## 빌드 명령어

### 개발 모드

```bash
# 디버그 모드 실행
flutter run -d linux

# 핫 리로드 지원
```

### 릴리즈 빌드

```bash
# 릴리즈 빌드
flutter build linux

# 빌드 결과물 위치
# build/linux/x64/release/bundle/
```

### 상세 빌드 로그

```bash
flutter build linux --verbose
```

## 앱 설정 변경

### 앱 이름 변경

#### CMakeLists.txt

**파일**: `linux/CMakeLists.txt`

```cmake
# 실행 파일 이름
set(BINARY_NAME "magnet_copy")

# GTK 애플리케이션 ID (역도메인 형식)
set(APPLICATION_ID "com.yourcompany.magnetcopy")
```

#### 윈도우 제목

**파일**: `linux/runner/my_application.cc`

```cpp
static void my_application_activate(GApplication* application) {
    // ...

    // GTK HeaderBar 제목 설정
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_header_bar_set_title(header_bar, "MagnetCopy");  // 여기서 변경
    gtk_header_bar_set_show_close_button(header_bar, TRUE);

    // ...
}
```

### 앱 아이콘 설정

Linux는 시스템 아이콘 테마를 사용합니다. 커스텀 아이콘을 사용하려면:

#### 1. 아이콘 파일 준비

```
linux/runner/resources/
└── icons/
    ├── 16x16/
    │   └── magnetcopy.png
    ├── 32x32/
    │   └── magnetcopy.png
    ├── 64x64/
    │   └── magnetcopy.png
    ├── 128x128/
    │   └── magnetcopy.png
    └── 256x256/
        └── magnetcopy.png
```

#### 2. CMakeLists.txt에 설치 규칙 추가

**파일**: `linux/CMakeLists.txt`

```cmake
# 아이콘 설치 (선택적)
install(FILES "runner/resources/icons/256x256/magnetcopy.png"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/share/icons/hicolor/256x256/apps"
    RENAME "${APPLICATION_ID}.png")
```

#### 3. 코드에서 아이콘 설정

**파일**: `linux/runner/my_application.cc`

```cpp
// 윈도우 아이콘 설정
gtk_window_set_icon_name(GTK_WINDOW(window), "magnetcopy");
```

### 윈도우 크기 설정

**파일**: `linux/runner/my_application.cc`

```cpp
static void my_application_activate(GApplication* application) {
    // ...

    GtkWindow* window = GTK_WINDOW(gtk_application_window_new(app));

    // 기본 윈도우 크기 설정
    gtk_window_set_default_size(window, 1280, 720);

    // 최소 크기 설정 (선택)
    gtk_widget_set_size_request(GTK_WIDGET(window), 800, 600);

    // ...
}
```

### 데스크톱 엔트리 파일

배포 시 `.desktop` 파일이 필요합니다:

**파일**: `linux/magnetcopy.desktop`

```desktop
[Desktop Entry]
Type=Application
Name=MagnetCopy
Comment=클립보드 매니저
Exec=magnetcopy
Icon=com.yourcompany.magnetcopy
Terminal=false
Categories=Utility;
Keywords=clipboard;copy;paste;
```

## 트러블슈팅

### GTK 라이브러리 오류

```
Package gtk+-3.0 was not found in the pkg-config search path
```

**해결**:
```bash
# Ubuntu/Debian
sudo apt install libgtk-3-dev

# pkg-config 경로 확인
pkg-config --modversion gtk+-3.0
```

### clang 컴파일러 오류

```
Could not find compiler set in environment variable CC: clang
```

**해결**:
```bash
# clang 설치
sudo apt install clang

# 또는 GCC 사용
export CC=gcc
export CXX=g++
flutter build linux
```

### ninja 빌드 도구 오류

```
CMake Error: CMake was unable to find a build program corresponding to "Ninja"
```

**해결**:
```bash
sudo apt install ninja-build
```

### 런타임 라이브러리 누락

```
error while loading shared libraries: libflutter_linux_gtk.so
```

**해결**:
실행 파일과 같은 디렉토리에 `lib/` 폴더가 있어야 합니다. 번들 전체를 배포하세요.

### Wayland 세션 문제

Wayland에서 일부 기능이 작동하지 않을 경우:

```bash
# X11 모드로 강제 실행
GDK_BACKEND=x11 ./magnet_copy
```

### 한글 입력 문제

```bash
# ibus 입력기 설정
sudo apt install ibus ibus-hangul
im-config -n ibus
```

또는 fcitx 사용:
```bash
sudo apt install fcitx fcitx-hangul
im-config -n fcitx
```

### 빌드 캐시 정리

```bash
flutter clean
rm -rf build/linux
flutter build linux
```

## 배포 준비

### 번들 구조

빌드 결과물 (`build/linux/x64/release/bundle/`):

```
bundle/
├── magnet_copy           # 실행 파일
├── data/                 # Flutter 에셋
│   ├── flutter_assets/
│   └── icudtl.dat
└── lib/                  # 공유 라이브러리
    └── libflutter_linux_gtk.so
```

### AppImage 패키징

```bash
# appimagetool 다운로드
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage

# AppDir 구조 생성
mkdir -p MagnetCopy.AppDir/usr/bin
cp -r build/linux/x64/release/bundle/* MagnetCopy.AppDir/usr/bin/

# .desktop 파일 복사
cp linux/magnetcopy.desktop MagnetCopy.AppDir/

# AppRun 스크립트 생성
cat > MagnetCopy.AppDir/AppRun << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
exec "${HERE}/usr/bin/magnet_copy" "$@"
EOF
chmod +x MagnetCopy.AppDir/AppRun

# AppImage 생성
./appimagetool-x86_64.AppImage MagnetCopy.AppDir MagnetCopy.AppImage
```

### Snap 패키징

**파일**: `snap/snapcraft.yaml`

```yaml
name: magnetcopy
version: '1.0.0'
summary: 클립보드 매니저
description: |
  MagnetCopy - 크로스플랫폼 클립보드 매니저

base: core22
confinement: strict
grade: stable

apps:
  magnetcopy:
    command: magnet_copy
    extensions: [gnome]
    plugs:
      - desktop
      - desktop-legacy
      - wayland
      - x11
      - unity7

parts:
  magnetcopy:
    source: .
    plugin: flutter
    flutter-target: lib/main.dart
```

```bash
# Snap 빌드
snapcraft
```

### Flatpak 패키징

**파일**: `com.yourcompany.magnetcopy.yml`

```yaml
app-id: com.yourcompany.magnetcopy
runtime: org.gnome.Platform
runtime-version: '44'
sdk: org.gnome.Sdk
command: magnet_copy

finish-args:
  - --share=ipc
  - --socket=fallback-x11
  - --socket=wayland
  - --device=dri

modules:
  - name: magnetcopy
    buildsystem: simple
    build-commands:
      - cp -r bundle/* /app/
    sources:
      - type: dir
        path: build/linux/x64/release/bundle
```

```bash
# Flatpak 빌드
flatpak-builder --repo=repo --force-clean build-dir com.yourcompany.magnetcopy.yml
```

### DEB 패키지 (Debian/Ubuntu)

```bash
# 패키지 구조 생성
mkdir -p magnetcopy_1.0.0_amd64/DEBIAN
mkdir -p magnetcopy_1.0.0_amd64/usr/bin
mkdir -p magnetcopy_1.0.0_amd64/usr/share/applications
mkdir -p magnetcopy_1.0.0_amd64/usr/share/icons/hicolor/256x256/apps

# 파일 복사
cp -r build/linux/x64/release/bundle/* magnetcopy_1.0.0_amd64/usr/bin/
cp linux/magnetcopy.desktop magnetcopy_1.0.0_amd64/usr/share/applications/

# control 파일 생성
cat > magnetcopy_1.0.0_amd64/DEBIAN/control << EOF
Package: magnetcopy
Version: 1.0.0
Section: utils
Priority: optional
Architecture: amd64
Depends: libgtk-3-0
Maintainer: Your Name <your@email.com>
Description: MagnetCopy - 클립보드 매니저
 크로스플랫폼 클립보드 관리 애플리케이션
EOF

# DEB 패키지 생성
dpkg-deb --build magnetcopy_1.0.0_amd64
```
