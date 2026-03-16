# Xcode 프로젝트 설정 가이드

> macOS 14 Sonoma 이상 + Xcode 15 이상 필요

---

## 1. 새 Xcode 프로젝트 생성

1. Xcode 실행 → **Create New Project**
2. **macOS → App** 선택 → Next
3. 설정:
   - Product Name: `TO-DO-DO`
   - Bundle Identifier: `com.yejinms.tododo`
   - Interface: **SwiftUI**
   - Language: **Swift**
4. 저장 위치: 이 repo의 `swift/` 폴더 안

---

## 2. 소스 파일 추가

Xcode 프로젝트 navigator에서 **기존 파일 삭제** 후 아래 파일들을 드래그하여 추가:

### 메인 앱 타겟 (TO-DO-DO)
```
swift/Shared/TodoItem.swift
swift/Shared/TodoStore.swift
swift/Shared/Extensions.swift
swift/MainApp/TO_DO_DOApp.swift
swift/MainApp/ContentView.swift
swift/MainApp/TodoItemRow.swift
```

---

## 3. Widget Extension 추가

1. **File → New → Target**
2. **macOS → Widget Extension** 선택
3. Product Name: `TO-DO-DOWidget`
4. "Include Configuration Intent": **체크 해제**
5. Activate scheme: **Yes**

### 위젯 타겟에 파일 추가
```
swift/Shared/TodoItem.swift      ← Target Membership: 양쪽 모두 체크
swift/Shared/TodoStore.swift     ← Target Membership: 양쪽 모두 체크
swift/Shared/Extensions.swift   ← Target Membership: 양쪽 모두 체크
swift/Widget/TO_DO_DOWidget.swift ← 위젯 타겟만
```

> 공유 파일(Shared/)은 File inspector → Target Membership에서 **두 타겟 모두 체크**

---

## 4. App Groups 설정 (데이터 공유 핵심)

앱과 위젯이 같은 데이터를 읽으려면 App Group이 필요합니다.

**메인 앱 타겟:**
1. Xcode → 프로젝트 선택 → **TO-DO-DO** 타겟
2. **Signing & Capabilities** 탭
3. **+ Capability** → **App Groups**
4. `+` 클릭 → `group.com.yejinms.tododo` 입력

**위젯 타겟도 동일하게:**
1. **TO-DO-DOWidget** 타겟 선택
2. 같은 방법으로 `group.com.yejinms.tododo` 추가

> `TodoStore.swift`의 `kAppGroupID` 값과 반드시 일치해야 함

---

## 5. 커스텀 폰트 추가

1. 폰트 파일 준비:
   - `EF_jejudoldam.ttf` (EF 제주돌담)
   - `LeeSeoyun.ttf` (이서윤체)

2. Xcode에서 **Add Files to "TO-DO-DO"** → 두 파일 선택
   - **Add to targets**: 메인 앱 + 위젯 **둘 다** 체크

3. 각 타겟의 `Info.plist`에 추가:
   ```
   Fonts provided by application (Array)
     Item 0: EF_jejudoldam.ttf
     Item 1: LeeSeoyun.ttf
   ```

---

## 6. 빌드 & 실행

1. **Command + R** → 앱 실행
2. 위젯 등록:
   - 바탕화면 우클릭 → **위젯 편집** (macOS 14 Sonoma)
   - 또는 알림 센터 하단 **위젯 편집** 버튼
   - `+` → `TO-DO-DO` 검색 → 원하는 크기 선택

---

## 7. 로그인 항목 등록 (자동 시작)

**시스템 설정 → 일반 → 로그인 항목 및 Extensions**
→ TO-DO-DO 앱 추가

---

## 파일 구조 요약

```
swift/
├── Shared/
│   ├── TodoItem.swift       # 데이터 모델
│   ├── TodoStore.swift      # 저장소 (App Group UserDefaults)
│   └── Extensions.swift     # Color, Font, DashedDivider
├── MainApp/
│   ├── TO_DO_DOApp.swift    # @main
│   ├── ContentView.swift    # 메인 UI
│   └── TodoItemRow.swift    # 투두 아이템 뷰
└── Widget/
    └── TO_DO_DOWidget.swift # WidgetKit 위젯
```
