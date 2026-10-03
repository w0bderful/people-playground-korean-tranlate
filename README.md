# People Playground 한국어 번역

BepInEx와 XUnity.AutoTranslator를 이용한 영어 → 한국어 번역 설정과 게임 번역 파일입니다. DeepL API 키는 포함하지 않습니다.

## 설치

1. 이 저장소를 **Code → Download ZIP**으로 내려받아 압축을 해제합니다.
2. 게임을 종료한 뒤 `Install.cmd`를 실행합니다. Steam 설치 폴더를 자동으로 찾으며, 찾지 못하면 `People Playground.exe`가 있는 폴더를 입력합니다.
3. `DeepL-Key-Setup.cmd`를 실행하고 자신의 **DeepL API 키**를 입력합니다. 입력은 화면에 표시되지 않으며 Free/Pro를 자동 판별합니다.
4. Steam에서 게임을 실행합니다.

키를 입력하기 전에는 포함된 번역만 사용합니다. 키는 저장소 파일이 아닌 **게임 폴더의 `BepInEx/config/AutoTranslatorConfig.ini`**에 저장됩니다. 기존 키가 있으면 설치 시 보존합니다. 게임 폴더의 설정 파일이나 백업을 공유하지 마세요.

게임 폴더를 직접 지정할 수도 있습니다.

```powershell
.\Install.ps1 -GamePath 'D:\SteamLibrary\steamapps\common\People Playground'
.\Set-DeepL-Key.ps1 -GamePath 'D:\SteamLibrary\steamapps\common\People Playground'
```

## 포함 내용

- 게임 메뉴·설정·아이템 등 약 650개 번역. 일부는 DeepL 기계 번역입니다.
- 체력·혈액량·혈압·체온 및 사망·내출혈·뇌사·상처·부패 상태창 전용 규칙.
- 수치가 바뀌어도 번역을 바로 적용하며, 수치·색상·굵게 표시를 유지합니다.
- 상태창의 두 텍스트 영역은 자동 글자 크기 조정을 끄고 크기 18로 고정합니다. 수치 변화에 따른 글자 크기 변동을 방지합니다.
- 한국어 글꼴 설정과 공식 배포 파일의 SHA-256 검증.

게임 실행 파일, 개인 설정, 로그, API 키는 포함하지 않습니다. 설치 스크립트는 아래 공식 배포 파일을 다운로드합니다. 기존에 덮어쓸 파일은 게임 폴더의 `BepInEx/KoreanTranslationBackups`에 백업합니다.

| 구성 요소 | 버전 | 공식 배포처 |
| --- | --- | --- |
| BepInEx Windows x64 | 5.4.23.5 | [BepInEx](https://github.com/BepInEx/BepInEx/releases/tag/v5.4.23.5) |
| XUnity.AutoTranslator BepInEx | 5.6.2 | [XUnity.AutoTranslator](https://github.com/bbepis/XUnity.AutoTranslator/releases/tag/v5.6.2) |
| TextMeshPro 글꼴 번들 | v5.4.4 배포의 `arialuni_sdf_u2018` | [공식 글꼴 배포](https://github.com/bbepis/XUnity.AutoTranslator/releases/tag/v5.4.4) |

이 저장소는 번역 파일과 설정·설치 스크립트를 제공합니다. 외부 구성 요소와 글꼴의 권리 및 사용 조건은 각 원본 배포처를 따릅니다. 공식 XUnity 설정 및 단축키 설명은 [원본 문서](https://github.com/bbepis/XUnity.AutoTranslator#key-mapping)를 참고하세요.

## 확인 범위

People Playground Windows 64비트 Mono / Unity 2020.3.1f1 / TextMeshPro 1.4.0 환경에서 BepInEx 및 번역기 로드를 확인했습니다. 실제 TextMeshPro 컴포넌트에 상태창 문장을 입력하여 서로 다른 체력·혈압·온도 및 복합 상태의 한국어 출력과 수치·태그 보존을 확인했습니다. 상태창과 같은 오브젝트 경로에서 4가지 문장을 각각 20회 연속 갱신하여 글자 크기 18 및 자동 크기 조정 비활성화가 유지되는 것을 확인했습니다.

구형 TextMeshPro 훅 일부와 글꼴 버전 차이에 대한 경고가 남습니다. 전체 게임 화면, 모든 모드, 모든 해상도에 대한 검증은 하지 않았습니다. 일부 UI는 공간 부족으로 번역이 잘릴 수 있습니다.
