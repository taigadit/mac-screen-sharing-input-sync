# macOS 화면 공유 입력 소스 동기화 도구

> **호환 기기:** Apple Mac, MacBook Air, MacBook Pro, Mac mini, iMac, Mac Studio, Mac Pro  
> **키워드:** macOS, 화면 공유, 입력 소스, IME, VNC, Hammerspoon

화면 공유 사용 시 로컬과 원격 Mac 간에 입력 소스를 동기화합니다.

## ⚠️ 이 도구가 필요한지 확인하세요

최신 macOS 화면 공유에는 "키보드 언어 동기화" 기능이 내장되어 있습니다.

확인 방법: **화면 공유 App → 설정**에서 이 옵션이 있는지 확인하세요.

- ✅ **옵션이 있음** → 활성화하면 됩니다. 이 도구는 필요 없습니다
- ❌ **옵션이 없음** → macOS 버전이 오래되었습니다. 이 도구를 사용하세요

**이 도구의 대상:**
- 로컬 또는 원격 Mac이 이전 macOS를 실행하여 내장 동기화 기능이 없는 경우
- 내장 기능에 문제가 있을 때의 백업 솔루션

## 문제

macOS 내장 화면 공유를 사용할 때 입력 소스는 다음과 같이 동작합니다:

| 로컬 입력 | 원격 입력 | 실제 출력 |
|----------|----------|----------|
| 영어 | 한글 | 영어 ❌ |
| 한글 | 영어 | 한글 ❌ |
| 한글 | 한글 | 한글 ✅ |

이는 화면 공유가 원시 키 입력 대신 "처리된 문자"를 전송하기 때문입니다.

## 기능

- ✅ **정확한 동기화** — macism 모드로 입력 소스를 직접 지정, 어긋나지 않음
- ✅ **호스트별 설정** — 각 호스트에 대해 toggle 또는 macism 모드 선택
- ✅ **SSH ControlMaster 가속** — 10-50ms 지연만
- ✅ **포커스 인식** — 화면 공유 창이 포커스될 때만 동작
- ✅ **새 호스트 자동 감지** — 첫 연결 시 설정, 이후 자동 기억
- ✅ **메뉴바 제어** — 일시정지/재개, 호스트 추가/편집/삭제

## 동기화 모드

| 모드 | 아이콘 | 설명 | 원격 요구사항 |
|-----|-------|------|--------------|
| **Toggle** | 🔄 | Ctrl+Space를 전송하여 전환 | SSH + 손쉬운 사용 권한 |
| **macism** | 🎯 | 입력 소스 ID를 직접 지정 | SSH + macism (macOS 10.15+ 필요) |

**참고:** macism은 macOS 10.15 (Catalina) 이상이 필요합니다. 이전 버전은 Toggle 모드를 사용하세요.

## 시스템 요구사항

**로컬 (제어 Mac):**
- macOS 10.15 이상
- Homebrew
- Hammerspoon

**원격 (피제어 Mac):**
- macOS 10.14 이상
- SSH (원격 로그인) 활성화
- 손쉬운 사용 권한 부여

---

## 설치

### 1단계: 원격 설정 (피제어 Mac에서 작업)

#### 1. SSH (원격 로그인) 활성화

```
시스템 환경설정 → 공유 → "원격 로그인" 체크
```

연결 정보를 메모하세요 (예: `ssh user@192.168.1.100`)

#### 2. 손쉬운 사용 권한 부여

SSH로 실행되는 AppleScript에는 손쉬운 사용 권한이 필요합니다:

```
시스템 환경설정 → 보안 및 개인정보 → 개인정보 → 손쉬운 사용
```

1. 🔒를 클릭하여 잠금 해제
2. "+"를 클릭하고 `/usr/bin/osascript` 추가
   - `Cmd+Shift+G`를 누르고 `/usr/bin/` 입력
   - `osascript` 선택

또는 "터미널" 앱을 추가해도 됩니다.

#### 3. 손쉬운 사용 권한 테스트

원격 Mac에서 실행:

```bash
osascript -e 'tell application "System Events" to key code 49 using control down'
```

입력 소스가 전환되면 권한 설정이 완료된 것입니다.

---

### 2단계: 로컬 설정 (제어 Mac에서 작업)

#### 1. Hammerspoon 설치

```bash
brew install --cask hammerspoon
```

#### 2. 설정 파일 다운로드

```bash
mkdir -p ~/.hammerspoon
curl -o ~/.hammerspoon/init.lua https://raw.githubusercontent.com/taigadit/mac-screen-sharing-input-sync/main/init.lua
```

#### 3. Hammerspoon 권한 부여

1. Hammerspoon 열기
2. "시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용"으로 이동
3. Hammerspoon 허용

#### 4. SSH 비밀번호 없는 로그인 설정

```bash
# 키 생성 (아직 안 했다면)
ssh-keygen -t ed25519

# 원격에 복사 (비밀번호 한 번 입력)
ssh-copy-id user@원격IP
```

비밀번호 없는 로그인 확인:

```bash
ssh user@원격IP "echo ok"
```

비밀번호 없이 `ok`가 표시되면 성공입니다.

#### 5. 원격 입력 전환 테스트

```bash
ssh user@원격IP "osascript -e 'tell application \"System Events\" to key code 49 using control down'"
```

원격 입력 소스가 전환되면 모든 설정이 완료된 것입니다!

#### 6. SSH ControlMaster 설정 (권장)

```bash
mkdir -p ~/.ssh/sockets
```

`~/.ssh/config` 편집, 추가:

```
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
```

권한 설정:

```bash
chmod 600 ~/.ssh/config
```

이렇게 하면 지연이 200-500ms에서 10-50ms로 줄어듭니다.

#### 7. Hammerspoon 설정 로드

메뉴바의 Hammerspoon 아이콘 (🔨) 클릭 → Reload Config

---

## 사용법

1. **화면 공유를 열고** 원격 Mac에 연결
2. **화면 공유 창을 클릭** (포커스 맞추기)
3. **로컬 입력 소스 전환**
4. 원격이 자동으로 동기화됩니다!

### 첫 연결

처음에는 대화상자가 표시됩니다:
1. SSH 연결 정보 입력 (예: `user@192.168.1.100`)
2. 동기화 모드 선택 (Toggle 또는 macism)
3. 설정이 자동 저장됩니다

### Toggle 모드 참고

Toggle 모드는 Ctrl+Space를 사용하여 입력 소스를 전환만 합니다.

**중요:** 사용 전에 양쪽 입력 소스를 수동으로 맞추세요 (둘 다 영어 또는 둘 다 한글). 그러면 동기화가 유지됩니다.

---

## FAQ

### Q: 원격이 반응하지 않나요?

1. SSH 비밀번호 없는 로그인 확인:
   ```bash
   ssh user@원격IP "echo ok"
   ```

2. 원격 손쉬운 사용 권한 확인:
   ```bash
   ssh user@원격IP "osascript -e 'tell application \"System Events\" to key code 49 using control down'"
   ```

3. 화면 공유 창이 포커스되어 있는지 확인

### Q: 입력 소스가 어긋나나요?

- **macism 모드**: 입력 소스를 직접 지정, 어긋나지 않음
- **Toggle 모드**: 먼저 수동으로 맞추면 동기화 유지

### Q: macism 설치 실패?

macism은 macOS 10.15 (Catalina) 이상이 필요합니다. Mojave (10.14)는 Toggle 모드를 사용하세요.

### Q: 지연이 길다?

SSH ControlMaster를 설정하면 (설치 단계 참조) 지연이 200-500ms에서 10-50ms로 줄어듭니다.

---

## 라이선스

MIT License

---

**Developed by [Dajiade Co., Ltd.](https://www.dajiade.com)** (taigadit)
