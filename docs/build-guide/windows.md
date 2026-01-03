# Windows 빌드 가이드

## 환경 설정

### 1. Visual Studio 설치

[Visual Studio 2022](https://visualstudio.microsoft.com/downloads/)를 설치합니다. Community 버전(무료)으로 충분합니다.

**필수 구성 요소** (설치 시 선택):
- "C++를 사용한 데스크톱 개발" 워크로드
- Windows 10/11 SDK
- CMake 도구 (선택적, Flutter에 포함됨)

### 2. 환경 확인

```powershell
flutter doctor
```

다음 항목이 체크되어야 합니다:
- `[✓] Visual Studio - develop Windows apps`

### 3. 추가 도구 (선택)

```powershell
# Chocolatey로 추가 도구 설치 (선택)
choco install cmake ninja
```

## 빌드 명령어

### 개발 모드

```powershell
# 디버그 모드 실행
flutter run -d windows

# 핫 리로드 지원
```

### 릴리즈 빌드

```powershell
# 릴리즈 빌드
flutter build windows

# 빌드 결과물 위치
# build\windows\x64\runner\Release\magnet_copy.exe
```

### Visual Studio에서 직접 빌드

```powershell
# Visual Studio 솔루션 생성
flutter build windows --debug

# Visual Studio에서 열기
start build\windows\x64\magnet_copy.sln
```

## 앱 설정 변경

### 앱 이름 변경

#### CMakeLists.txt

**파일**: `windows/CMakeLists.txt`

```cmake
# 실행 파일 이름
set(BINARY_NAME "MagnetCopy")
```

#### Runner.rc (리소스 파일)

**파일**: `windows/runner/Runner.rc`

```rc
// 버전 정보 블록에서 수정
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904e4"
        BEGIN
            VALUE "CompanyName", "YourCompany"
            VALUE "FileDescription", "MagnetCopy Application"
            VALUE "FileVersion", "1.0.0.0"
            VALUE "InternalName", "MagnetCopy"
            VALUE "LegalCopyright", "Copyright (C) 2024 YourCompany"
            VALUE "OriginalFilename", "MagnetCopy.exe"
            VALUE "ProductName", "MagnetCopy"
            VALUE "ProductVersion", "1.0.0.0"
        END
    END
END
```

### 앱 아이콘 변경

**파일**: `windows/runner/resources/app_icon.ico`

ICO 파일은 여러 크기의 이미지를 포함해야 합니다:
- 16x16
- 32x32
- 48x48
- 64x64
- 128x128
- 256x256

**ICO 파일 생성 도구**:
- [IcoFX](https://icofx.ro/) (Windows)
- [ImageMagick](https://imagemagick.org/): `magick convert icon.png -define icon:auto-resize=256,128,64,48,32,16 app_icon.ico`
- 온라인 변환기: [ICO Convert](https://icoconvert.com/)

### 윈도우 크기 설정

**파일**: `windows/runner/main.cpp`

```cpp
int APIENTRY wWinMain(...) {
    // ...
    FlutterWindow window(project);
    Win32Window::Point origin(10, 10);
    Win32Window::Size size(1280, 720);  // 너비 x 높이

    if (!window.Create(L"MagnetCopy", origin, size)) {
        return EXIT_FAILURE;
    }
    // ...
}
```

### 윈도우 제목 변경

**파일**: `windows/runner/main.cpp`

```cpp
// Create 함수의 첫 번째 인자가 윈도우 제목
if (!window.Create(L"MagnetCopy - 클립보드 매니저", origin, size)) {
```

### 버전 정보 설정

**파일**: `windows/runner/Runner.rc`

```rc
VS_VERSION_INFO VERSIONINFO
 FILEVERSION 1,0,0,0
 PRODUCTVERSION 1,0,0,0
 // ...
```

`pubspec.yaml`의 버전과 동기화하려면 빌드 스크립트를 사용하거나 수동으로 업데이트합니다.

### DPI 인식 설정

**파일**: `windows/runner/runner.exe.manifest`

```xml
<application xmlns="urn:schemas-microsoft-com:asm.v3">
    <windowsSettings>
        <!-- 높은 DPI 지원 -->
        <dpiAwareness xmlns="http://schemas.microsoft.com/SMI/2016/WindowsSettings">
            PerMonitorV2
        </dpiAwareness>
    </windowsSettings>
</application>
```

## 트러블슈팅

### Visual Studio 구성 요소 누락

```
Building Windows application...
CMake Error: CMAKE_CXX_COMPILER not set
```

**해결**:
1. Visual Studio Installer 실행
2. "수정" 클릭
3. "C++를 사용한 데스크톱 개발" 워크로드 설치
4. PC 재시작

### CMake 오류

```powershell
# CMake 캐시 정리
flutter clean
Remove-Item -Recurse -Force build\windows

# 재빌드
flutter build windows
```

### MSVC 도구 버전 문제

```
The C compiler identification is unknown
```

**해결**:
1. Visual Studio에서 최신 MSVC 도구 설치
2. 또는 특정 버전 지정:

```cmake
# windows/CMakeLists.txt에 추가
set(CMAKE_C_COMPILER "cl.exe")
set(CMAKE_CXX_COMPILER "cl.exe")
```

### 런타임 DLL 누락

배포 시 Visual C++ Redistributable이 필요할 수 있습니다:
- [Microsoft Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)

### 관리자 권한 오류

일부 작업에 관리자 권한이 필요한 경우:
```powershell
# PowerShell을 관리자로 실행
Start-Process powershell -Verb RunAs
```

### 한글 경로 문제

프로젝트 경로에 한글이 포함되면 빌드 오류가 발생할 수 있습니다:
- 프로젝트를 영문 경로로 이동 (예: `C:\Projects\MagnetCopy`)

## 배포 준비

### 단일 폴더 배포

릴리즈 빌드 결과물은 `build\windows\x64\runner\Release\` 폴더에 생성됩니다:

```
Release/
├── magnet_copy.exe          # 실행 파일
├── flutter_windows.dll      # Flutter 엔진
├── data/                    # Flutter 에셋
└── *.dll                    # 기타 의존성
```

이 폴더 전체를 배포하면 됩니다.

### MSIX 패키지 (Microsoft Store)

```powershell
# MSIX 패키지 빌드
flutter pub add msix
flutter pub run msix:create
```

`pubspec.yaml`에 MSIX 설정 추가:

```yaml
msix_config:
  display_name: MagnetCopy
  publisher_display_name: YourCompany
  identity_name: com.yourcompany.magnetcopy
  msix_version: 1.0.0.0
  logo_path: assets/icon.png
```

### 설치 프로그램 생성 (Inno Setup)

[Inno Setup](https://jrsoftware.org/isinfo.php)을 사용하여 설치 프로그램 생성:

```iss
; setup.iss
[Setup]
AppName=MagnetCopy
AppVersion=1.0.0
DefaultDirName={autopf}\MagnetCopy
DefaultGroupName=MagnetCopy
OutputBaseFilename=MagnetCopy_Setup

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\MagnetCopy"; Filename: "{app}\magnet_copy.exe"
Name: "{autodesktop}\MagnetCopy"; Filename: "{app}\magnet_copy.exe"
```

### 코드 서명 (선택)

배포 전 코드 서명을 권장합니다:

```powershell
# signtool로 서명 (Windows SDK 필요)
signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com magnet_copy.exe
```
