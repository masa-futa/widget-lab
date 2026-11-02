# SwiftUI 版 Phase 1（土台・manifest・デモの仕組み・3 画面）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `swiftui/` に iPhone のアプリ「Widget Lab SwiftUI」を作り、manifest（収録すべき 458 件の一覧）を生成し、収録データから組み立てるデモの仕組みと 3 画面（ホーム・トピック・詳細）を 4 件の収録（`Button`・`Text`・`VStack`・`padding`）で通す。

**Architecture:** 収録 1 件を `CatalogEntry`（プロパティの定義・コードの形・組み立ての関数）で表し、操作パネル・プレビュー・比べる・コードを共通の仕組みで作る（Flutter 版の ADR-0002 と同じ考え方）。層は UI → ViewModel（`@Observable`）→ Repository。manifest は Python の道具が SwiftUI のリファレンスの JSON から生成する。

**Tech Stack:** Xcode 27.0 / Swift 6（既定の分離は MainActor）/ SwiftUI / Swift Testing（UI テストだけ XCTest）/ swift-format（Xcode 付属）/ Python 3.9 以上（標準ライブラリだけ）

**spec:** `swiftui/docs/superpowers/specs/2026-10-31-swiftui-app-design.md`

## Global Constraints

- 作業はすべて `swiftui/` で行う（コマンドも `swiftui/` で実行する）。Flutter 版（`flutter/`）は変えない
- 対象: iPhone、`IPHONEOS_DEPLOYMENT_TARGET = 27.0`。iPad はスマホと同じ 1 カラム
- bundle ID: `jp.nimi.widgetLab.swiftui`。表示名: `Widget Lab SwiftUI`
- Swift 6 の言語モード（`SWIFT_VERSION = 6.0`）、`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`。収録データの型（`WidgetLab/Catalog/`）は `nonisolated` にし、組み立ての関数だけ `@MainActor`
- 外部のパッケージは使わない
- 文言は日本語のみ。API の名前（`Button`・`.padding` など）は英語のまま
- XcodeGen・Tuist は使わない。`.xcodeproj` はこの計画の Task 1 の内容をそのまま書いてコミットする（フォルダと同期するグループなので、以降のタスクでファイルを足しても project.pbxproj は直さない）
- 整形: `xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests` が通ること（設定は `.swift-format`、1 行 120 文字）。この計画のコードは整形済み。自分で書き換えたら `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests` をかける
- テストのコマンド（以下「テストを実行」と書いたらこれ）:
  ```
  xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
    -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
    -derivedDataPath build CODE_SIGNING_ALLOWED=NO 2>&1 | tail -30
  ```
  `iPhone 17`（iOS 27.0）のシミュレータがなければ `xcrun simctl list devices available | grep -A12 "iOS 27.0"` で ある端末の名前に置き換える。特定のテストだけ実行するときは `-only-testing:WidgetLabTests/<型名>` を足す
- リポジトリは public。署名鍵・ストアの認証情報・`.env` などをコミットしない
- コミットのメッセージは日本語で、`<type>: <内容>` の形（例: `feat: ...`、`docs: ...`）。末尾に次の行を付ける:
  ```
  Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
  ```

## ファイルの構成

```
swiftui/
  .gitignore  .swift-format  CLAUDE.md  README.md
  WidgetLab.xcodeproj/project.pbxproj
  WidgetLab.xcodeproj/xcshareddata/xcschemes/WidgetLab.xcscheme
  WidgetLab/
    App/WidgetLabApp.swift                 入口・RootView（遷移）・Route
    Localizable.xcstrings
    Core/Data/CatalogRepository.swift
    Core/System/ClipboardClient.swift
    Catalog/Model/EntryKind.swift          収録の種類
    Catalog/Model/ManifestEntry.swift      manifest の 1 件
    Catalog/Model/PropertySpec.swift       PropertySpec・PropertyControl・Choice・Palette
    Catalog/Model/PropertyValues.swift     PropertyValue・PropertyValues・View.apply
    Catalog/Model/CodeTemplate.swift       CodeTemplate・CodeLine・CodeGenerator
    Catalog/Model/CatalogEntry.swift       DemoStage・CatalogEntry
    Catalog/Generated/Topic.swift          生成（Category・Topic）
    Catalog/Generated/Manifest.swift       生成（Manifest.entries）
    Catalog/Catalog.swift                  Catalog.all
    Catalog/ControlsAndIndicators/ButtonEntry.swift
    Catalog/TextInputAndOutput/TextEntry.swift
    Catalog/LayoutFundamentals/VStackEntry.swift
    Catalog/LayoutAdjustments/PaddingEntry.swift
    Features/Catalog/ViewModel/CatalogViewModel.swift
    Features/Catalog/UI/HomeScreen.swift
    Features/Catalog/UI/TopicScreen.swift  TopicScreen・EntryRow
    Features/Detail/ViewModel/DetailViewModel.swift
    Features/Detail/UI/DetailScreen.swift  DetailScreen・CodeStrip・InfoSheet
    Features/Detail/UI/PreviewArea.swift   プレビューと比べる
    Features/Detail/UI/PropertyChips.swift
    Features/Detail/UI/EditorPanel.swift
    Features/Detail/UI/CodeSheet.swift
  WidgetLabTests/
    Support/Fakes.swift
    Catalog/CodeGeneratorTests.swift
    Catalog/CatalogTests.swift
    Features/Catalog/CatalogViewModelTests.swift
    Features/Detail/DetailViewModelTests.swift
  WidgetLabUITests/LaunchUITests.swift
  tools/make_manifest.py
  tools/test_make_manifest.py
  docs/PRD.md  docs/architecture.md
  docs/adr/ADR-0001-project-structure-and-conventions.md
  docs/adr/ADR-0002-data-driven-demos.md
```

---

### Task 1: Xcode のプロジェクトの土台

**Files:**
- Create: `swiftui/.gitignore`、`swiftui/.swift-format`、`swiftui/WidgetLab.xcodeproj/project.pbxproj`、`swiftui/WidgetLab.xcodeproj/xcshareddata/xcschemes/WidgetLab.xcscheme`、`swiftui/WidgetLab/App/WidgetLabApp.swift`（仮）、`swiftui/WidgetLab/Localizable.xcstrings`
- Test: `swiftui/WidgetLabTests/SmokeTests.swift`（仮。Task 3 で消す）、`swiftui/WidgetLabUITests/LaunchUITests.swift`（仮。Task 7 で置き換える）

**Interfaces:**
- Produces: ターゲット `WidgetLab`（アプリ）・`WidgetLabTests`（Swift Testing、`@testable import WidgetLab`）・`WidgetLabUITests`、共有スキーム `WidgetLab`。各ターゲットは同名のフォルダと同期する

- [ ] **Step 1: フォルダを作り、.gitignore と .swift-format を書く**

```bash
mkdir -p swiftui && cd swiftui
mkdir -p WidgetLab.xcodeproj/xcshareddata/xcschemes WidgetLab/App WidgetLabTests WidgetLabUITests
```

`swiftui/.gitignore`:

```gitignore
# Xcode
build/
DerivedData/
xcuserdata/
*.xcuserstate
*.xcresult

# manifest を作る道具のキャッシュ
tools/.cache/
__pycache__/

# 秘密（ルートの .gitignore にもある。どちらかを消しても漏れないように残す）
.env
*.env
*.p8
*.p12
*.mobileprovision
```

`swiftui/.swift-format`:

```json
{
  "version": 1,
  "lineLength": 120,
  "indentation": { "spaces": 4 },
  "respectsExistingLineBreaks": true,
  "lineBreakBeforeEachArgument": false,
  "rules": {
    "AlwaysUseLowerCamelCase": false,
    "NeverForceUnwrap": false,
    "NeverUseForceTry": false
  }
}
```

- [ ] **Step 2: project.pbxproj を書く**

`swiftui/WidgetLab.xcodeproj/project.pbxproj`（ID は決め打ちの 24 桁。変えない）:

```text
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 77;
	objects = {

/* Begin PBXContainerItemProxy section */
		A10000000000000000000301 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = A10000000000000000000001 /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = A10000000000000000000101;
			remoteInfo = WidgetLab;
		};
		A10000000000000000000302 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = A10000000000000000000001 /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = A10000000000000000000101;
			remoteInfo = WidgetLab;
		};
/* End PBXContainerItemProxy section */

/* Begin PBXFileReference section */
		A10000000000000000000201 /* WidgetLab.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = WidgetLab.app; sourceTree = BUILT_PRODUCTS_DIR; };
		A10000000000000000000202 /* WidgetLabTests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = WidgetLabTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
		A10000000000000000000203 /* WidgetLabUITests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = WidgetLabUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFileSystemSynchronizedRootGroup section */
		A10000000000000000000011 /* WidgetLab */ = {isa = PBXFileSystemSynchronizedRootGroup; path = WidgetLab; sourceTree = "<group>"; };
		A10000000000000000000012 /* WidgetLabTests */ = {isa = PBXFileSystemSynchronizedRootGroup; path = WidgetLabTests; sourceTree = "<group>"; };
		A10000000000000000000013 /* WidgetLabUITests */ = {isa = PBXFileSystemSynchronizedRootGroup; path = WidgetLabUITests; sourceTree = "<group>"; };
/* End PBXFileSystemSynchronizedRootGroup section */

/* Begin PBXFrameworksBuildPhase section */
		A10000000000000000000411 = {isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = ( ); runOnlyForDeploymentPostprocessing = 0; };
		A10000000000000000000412 = {isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = ( ); runOnlyForDeploymentPostprocessing = 0; };
		A10000000000000000000413 = {isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = ( ); runOnlyForDeploymentPostprocessing = 0; };
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		A10000000000000000000002 = {
			isa = PBXGroup;
			children = (
				A10000000000000000000011 /* WidgetLab */,
				A10000000000000000000012 /* WidgetLabTests */,
				A10000000000000000000013 /* WidgetLabUITests */,
				A10000000000000000000003 /* Products */,
			);
			sourceTree = "<group>";
		};
		A10000000000000000000003 /* Products */ = {
			isa = PBXGroup;
			children = (
				A10000000000000000000201 /* WidgetLab.app */,
				A10000000000000000000202 /* WidgetLabTests.xctest */,
				A10000000000000000000203 /* WidgetLabUITests.xctest */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		A10000000000000000000101 /* WidgetLab */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A10000000000000000000601;
			buildPhases = ( A10000000000000000000421, A10000000000000000000411, A10000000000000000000431, );
			buildRules = ( );
			dependencies = ( );
			fileSystemSynchronizedGroups = ( A10000000000000000000011 /* WidgetLab */, );
			name = WidgetLab;
			productName = WidgetLab;
			productReference = A10000000000000000000201 /* WidgetLab.app */;
			productType = "com.apple.product-type.application";
		};
		A10000000000000000000102 /* WidgetLabTests */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A10000000000000000000602;
			buildPhases = ( A10000000000000000000422, A10000000000000000000412, A10000000000000000000432, );
			buildRules = ( );
			dependencies = ( A10000000000000000000311, );
			fileSystemSynchronizedGroups = ( A10000000000000000000012 /* WidgetLabTests */, );
			name = WidgetLabTests;
			productName = WidgetLabTests;
			productReference = A10000000000000000000202 /* WidgetLabTests.xctest */;
			productType = "com.apple.product-type.bundle.unit-test";
		};
		A10000000000000000000103 /* WidgetLabUITests */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A10000000000000000000603;
			buildPhases = ( A10000000000000000000423, A10000000000000000000413, A10000000000000000000433, );
			buildRules = ( );
			dependencies = ( A10000000000000000000312, );
			fileSystemSynchronizedGroups = ( A10000000000000000000013 /* WidgetLabUITests */, );
			name = WidgetLabUITests;
			productName = WidgetLabUITests;
			productReference = A10000000000000000000203 /* WidgetLabUITests.xctest */;
			productType = "com.apple.product-type.bundle.ui-testing";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		A10000000000000000000001 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 2700;
				LastUpgradeCheck = 2700;
				TargetAttributes = {
					A10000000000000000000101 = { CreatedOnToolsVersion = 27.0; };
					A10000000000000000000102 = { CreatedOnToolsVersion = 27.0; TestTargetID = A10000000000000000000101; };
					A10000000000000000000103 = { CreatedOnToolsVersion = 27.0; TestTargetID = A10000000000000000000101; };
				};
			};
			buildConfigurationList = A10000000000000000000600;
			developmentRegion = ja;
			hasScannedForEncodings = 0;
			knownRegions = ( ja, Base, );
			mainGroup = A10000000000000000000002;
			minimizedProjectReferenceProxies = 1;
			preferredProjectObjectVersion = 77;
			productRefGroup = A10000000000000000000003 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				A10000000000000000000101 /* WidgetLab */,
				A10000000000000000000102 /* WidgetLabTests */,
				A10000000000000000000103 /* WidgetLabUITests */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		A10000000000000000000431 = {isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ( ); runOnlyForDeploymentPostprocessing = 0; };
		A10000000000000000000432 = {isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ( ); runOnlyForDeploymentPostprocessing = 0; };
		A10000000000000000000433 = {isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ( ); runOnlyForDeploymentPostprocessing = 0; };
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		A10000000000000000000421 = {isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ( ); runOnlyForDeploymentPostprocessing = 0; };
		A10000000000000000000422 = {isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ( ); runOnlyForDeploymentPostprocessing = 0; };
		A10000000000000000000423 = {isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ( ); runOnlyForDeploymentPostprocessing = 0; };
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
		A10000000000000000000311 = {isa = PBXTargetDependency; target = A10000000000000000000101 /* WidgetLab */; targetProxy = A10000000000000000000301; };
		A10000000000000000000312 = {isa = PBXTargetDependency; target = A10000000000000000000101 /* WidgetLab */; targetProxy = A10000000000000000000302; };
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
		A10000000000000000000701 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CODE_SIGN_STYLE = Automatic;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				IPHONEOS_DEPLOYMENT_TARGET = 27.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				STRING_CATALOG_GENERATE_SYMBOLS = YES;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_APPROACHABLE_CONCURRENCY = YES;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 6.0;
			};
			name = Debug;
		};
		A10000000000000000000702 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CODE_SIGN_STYLE = Automatic;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 27.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				SDKROOT = iphoneos;
				STRING_CATALOG_GENERATE_SYMBOLS = YES;
				SWIFT_APPROACHABLE_CONCURRENCY = YES;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_VERSION = 6.0;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		A10000000000000000000711 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CURRENT_PROJECT_VERSION = 1;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = "Widget Lab SwiftUI";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = ( "$(inherited)", "@executable_path/Frameworks", );
				MARKETING_VERSION = 0.1.0;
				PRODUCT_BUNDLE_IDENTIFIER = jp.nimi.widgetLab.swiftui;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
				SWIFT_EMIT_LOC_STRINGS = YES;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		A10000000000000000000712 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				CURRENT_PROJECT_VERSION = 1;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = "Widget Lab SwiftUI";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = ( "$(inherited)", "@executable_path/Frameworks", );
				MARKETING_VERSION = 0.1.0;
				PRODUCT_BUNDLE_IDENTIFIER = jp.nimi.widgetLab.swiftui;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
				SWIFT_EMIT_LOC_STRINGS = YES;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
		A10000000000000000000721 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				GENERATE_INFOPLIST_FILE = YES;
				PRODUCT_BUNDLE_IDENTIFIER = jp.nimi.widgetLab.swiftui.tests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/WidgetLab.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/WidgetLab";
			};
			name = Debug;
		};
		A10000000000000000000722 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				GENERATE_INFOPLIST_FILE = YES;
				PRODUCT_BUNDLE_IDENTIFIER = jp.nimi.widgetLab.swiftui.tests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/WidgetLab.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/WidgetLab";
			};
			name = Release;
		};
		A10000000000000000000731 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				GENERATE_INFOPLIST_FILE = YES;
				PRODUCT_BUNDLE_IDENTIFIER = jp.nimi.widgetLab.swiftui.uitests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_TARGET_NAME = WidgetLab;
			};
			name = Debug;
		};
		A10000000000000000000732 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				GENERATE_INFOPLIST_FILE = YES;
				PRODUCT_BUNDLE_IDENTIFIER = jp.nimi.widgetLab.swiftui.uitests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_TARGET_NAME = WidgetLab;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		A10000000000000000000600 = {isa = XCConfigurationList; buildConfigurations = ( A10000000000000000000701, A10000000000000000000702, ); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; };
		A10000000000000000000601 = {isa = XCConfigurationList; buildConfigurations = ( A10000000000000000000711, A10000000000000000000712, ); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; };
		A10000000000000000000602 = {isa = XCConfigurationList; buildConfigurations = ( A10000000000000000000721, A10000000000000000000722, ); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; };
		A10000000000000000000603 = {isa = XCConfigurationList; buildConfigurations = ( A10000000000000000000731, A10000000000000000000732, ); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; };
/* End XCConfigurationList section */
	};
	rootObject = A10000000000000000000001 /* Project object */;
}
```

- [ ] **Step 3: 共有スキームを書く**

`swiftui/WidgetLab.xcodeproj/xcshareddata/xcschemes/WidgetLab.xcscheme`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion = "2700" version = "1.7">
   <BuildAction parallelizeBuildables = "YES" buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting = "YES" buildForRunning = "YES" buildForProfiling = "YES" buildForArchiving = "YES" buildForAnalyzing = "YES">
            <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "A10000000000000000000101" BuildableName = "WidgetLab.app" BlueprintName = "WidgetLab" ReferencedContainer = "container:WidgetLab.xcodeproj"></BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction buildConfiguration = "Debug" selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
         <TestableReference skipped = "NO" parallelizable = "YES">
            <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "A10000000000000000000102" BuildableName = "WidgetLabTests.xctest" BlueprintName = "WidgetLabTests" ReferencedContainer = "container:WidgetLab.xcodeproj"></BuildableReference>
         </TestableReference>
         <TestableReference skipped = "NO" parallelizable = "NO">
            <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "A10000000000000000000103" BuildableName = "WidgetLabUITests.xctest" BlueprintName = "WidgetLabUITests" ReferencedContainer = "container:WidgetLab.xcodeproj"></BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction buildConfiguration = "Debug" selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle = "0" useCustomWorkingDirectory = "NO" ignoresPersistentStateOnLaunch = "NO" debugDocumentVersioning = "YES" debugServiceExtension = "internal" allowLocationSimulation = "YES">
      <BuildableProductRunnable runnableDebuggingMode = "0">
         <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "A10000000000000000000101" BuildableName = "WidgetLab.app" BlueprintName = "WidgetLab" ReferencedContainer = "container:WidgetLab.xcodeproj"></BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction buildConfiguration = "Release" shouldUseLaunchSchemeArgsEnv = "YES" savedToolIdentifier = "" useCustomWorkingDirectory = "NO" debugDocumentVersioning = "YES">
      <BuildableProductRunnable runnableDebuggingMode = "0">
         <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "A10000000000000000000101" BuildableName = "WidgetLab.app" BlueprintName = "WidgetLab" ReferencedContainer = "container:WidgetLab.xcodeproj"></BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction buildConfiguration = "Debug"></AnalyzeAction>
   <ArchiveAction buildConfiguration = "Release" revealArchiveInOrganizer = "YES"></ArchiveAction>
</Scheme>
```

- [ ] **Step 4: 仮のアプリ・文言のカタログ・仮のテストを書く**

`swiftui/WidgetLab/App/WidgetLabApp.swift`（仮。Task 7 で置き換える）:

```swift
import SwiftUI

@main
struct WidgetLabApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Widget Lab")
        }
    }
}
```

`swiftui/WidgetLab/Localizable.xcstrings`:

```json
{
  "sourceLanguage" : "ja",
  "strings" : {

  },
  "version" : "1.0"
}
```

`swiftui/WidgetLabTests/SmokeTests.swift`（仮。Task 3 で消す）:

```swift
import Testing

@testable import WidgetLab

struct SmokeTests {
    @Test func appModuleLoads() {
        #expect(Bool(true))
    }
}
```

`swiftui/WidgetLabUITests/LaunchUITests.swift`（仮。Task 7 で置き換える）:

```swift
import XCTest

final class LaunchUITests: XCTestCase {
    @MainActor
    func testLaunch() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Widget Lab"].waitForExistence(timeout: 5))
    }
}
```

- [ ] **Step 5: プロジェクトが読めることを確かめる**

Run: `xcodebuild -list -project WidgetLab.xcodeproj`
Expected: Targets に `WidgetLab`・`WidgetLabTests`・`WidgetLabUITests`、Schemes に `WidgetLab` が出る

- [ ] **Step 6: 整形の点検とテストを実行する**

Run: `xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests && echo LINT-OK`
Expected: `LINT-OK`

テストを実行（Global Constraints のコマンド）。
Expected: `** TEST SUCCEEDED **`。`SmokeTests/appModuleLoads()` と `LaunchUITests testLaunch` が passed

- [ ] **Step 7: コミット**

```bash
git add swiftui/.gitignore swiftui/.swift-format swiftui/WidgetLab.xcodeproj swiftui/WidgetLab swiftui/WidgetLabTests swiftui/WidgetLabUITests
git status --short   # build/ が入っていないこと
git commit -m "chore: SwiftUI 版の Xcode のプロジェクトの土台を足す

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: manifest を作る道具と、生成した Topic・Manifest

リファレンスの JSON（`https://developer.apple.com/tutorials/data/documentation/swiftui.json` と、トピック・記号ごとの `.json`）を取り出し、spec の「数え方」で収録すべきものを数えて Swift のファイルに書き出す。通信する部分（`load`）と数える部分（`classify`）を分け、テストは数える部分だけを、手で作った小さな JSON で確かめる。

**Files:**
- Create: `swiftui/tools/make_manifest.py`、`swiftui/WidgetLab/Catalog/Model/EntryKind.swift`、`swiftui/WidgetLab/Catalog/Model/ManifestEntry.swift`
- Generate: `swiftui/WidgetLab/Catalog/Generated/Topic.swift`、`swiftui/WidgetLab/Catalog/Generated/Manifest.swift`
- Test: `swiftui/tools/test_make_manifest.py`

**Interfaces:**
- Produces（Swift）:
  - `nonisolated enum EntryKind: String { case view, modifier, propertyWrapper, gesture }`
  - `nonisolated struct ManifestEntry: Equatable { let id: String; let kind: EntryKind; let topic: Topic }`
  - 生成: `nonisolated enum Category: String, CaseIterable`（`.views`・`.viewLayout`・`.appStructure`・`.dataAndStorage`・`.eventHandling`・`.accessibility`。rawValue はリファレンスの英語の名前）
  - 生成: `nonisolated enum Topic: String, CaseIterable`（rawValue はトピックの slug。例: `.controlsAndIndicators = "controls-and-indicators"`、`.textInputAndOutput`、`.layoutFundamentals`、`.layoutAdjustments`）。`var title: String`・`var category: Category`
  - 生成: `nonisolated enum Manifest { static let entries: [ManifestEntry] }`
- Produces（Python）: `classify(root, topics, symbols) -> (topic_list, entries)`、`render_topics(topic_list) -> str`、`render_manifest(entries) -> str`、`topic_case(slug) -> str`

- [ ] **Step 1: 数え方のテストを書く**

`swiftui/tools/test_make_manifest.py`:

```python
"""make_manifest.py の数え方のテスト。swiftui/ で `python3 -m unittest discover tools` で実行する。"""
import unittest

import make_manifest as mm

ROOT = "/documentation/swiftui"


def symbol(title, kind, conforms=(), ios="17.0", deprecated=False, ios_missing=False):
    platforms = [] if ios_missing else [{"name": "iOS", "introducedAt": ios, "deprecated": deprecated}]
    return {
        "metadata": {"title": title, "symbolKind": kind, "platforms": platforms},
        "relationshipsSections": [
            {"type": "conformsTo", "identifiers": ["doc://x/" + c for c in conforms]}
        ],
    }


def topic(sections):
    """sections: [[(url, title), ...], ...]"""
    refs = {}
    topic_sections = []
    for items in sections:
        ids = []
        for url, title in items:
            refs["id:" + url] = {"url": url, "title": title, "role": "symbol"}
            ids.append("id:" + url)
        topic_sections.append({"title": "s", "identifiers": ids})
    return {"topicSections": topic_sections, "references": refs}


def root(categories):
    """categories: [(category, [(topic_url, title), ...]), ...]"""
    refs = {}
    sections = []
    for name, items in categories:
        ids = []
        for url, title in items:
            refs["id:" + url] = {"url": url, "title": title}
            ids.append("id:" + url)
        sections.append({"title": name, "identifiers": ids})
    return {"topicSections": sections, "references": refs}


class ClassifyTests(unittest.TestCase):
    def run_classify(self, sections, symbols, category="Views"):
        r = root([(category, [(ROOT + "/controls", "Controls")])])
        return mm.classify(r, {ROOT + "/controls": topic(sections)}, symbols)

    def test_view_section_modifiers_become_properties(self):
        symbols = {
            ROOT + "/button": symbol("Button", "struct", ["View"]),
            ROOT + "/view/buttonstyle(_:)": symbol("buttonStyle(_:)", "method"),
        }
        _, entries = self.run_classify(
            [[(ROOT + "/button", "Button"), (ROOT + "/view/buttonstyle(_:)", "buttonStyle(_:)")]], symbols
        )
        self.assertEqual(entries, [{"id": "Button", "kind": "view", "topic": "controls"}])

    def test_modifiers_without_view_are_entries_and_overloads_merge(self):
        symbols = {
            ROOT + "/view/padding(_:)": symbol("padding(_:)", "method"),
            ROOT + "/view/padding(_:_:)": symbol("padding(_:_:)", "method"),
        }
        _, entries = self.run_classify(
            [[(ROOT + "/view/padding(_:)", "padding(_:)"), (ROOT + "/view/padding(_:_:)", "padding(_:_:)")]],
            symbols,
        )
        self.assertEqual(entries, [{"id": "padding", "kind": "modifier", "topic": "controls"}])

    def test_excludes_newer_deprecated_missing_and_helper_types(self):
        symbols = {
            ROOT + "/new": symbol("NewView", "struct", ["View"], ios="27.1"),
            ROOT + "/old": symbol("OldView", "struct", ["View"], deprecated=True),
            ROOT + "/mac": symbol("MacView", "struct", ["View"], ios_missing=True),
            ROOT + "/anyview": symbol("AnyView", "struct", ["View"]),
            ROOT + "/style": symbol("BorderedButtonStyle", "struct", ["PrimitiveButtonStyle"]),
        }
        _, entries = self.run_classify([[(u, "x") for u in symbols]], symbols)
        self.assertEqual(entries, [])

    def test_property_wrappers_and_gestures(self):
        symbols = {
            ROOT + "/state": symbol("State", "struct", ["DynamicProperty"]),
            ROOT + "/tapgesture": symbol("TapGesture", "struct", ["Gesture"]),
        }
        _, entries = self.run_classify([[(u, "x") for u in symbols]], symbols)
        self.assertEqual(
            [(e["id"], e["kind"]) for e in entries], [("State", "propertyWrapper"), ("TapGesture", "gesture")]
        )

    def test_first_topic_wins_and_empty_topics_are_dropped(self):
        a, b, c = ROOT + "/a", ROOT + "/b", ROOT + "/c"
        r = root([("Views", [(a, "A"), (b, "B")]), ("Tool support", [(c, "C")])])
        text = ROOT + "/text"
        symbols = {text: symbol("Text", "struct", ["View"])}
        topics = {a: topic([[(text, "Text")]]), b: topic([[(text, "Text")]]), c: topic([[(text, "Text")]])}
        topic_list, entries = mm.classify(r, topics, symbols)
        self.assertEqual(topic_list, [{"slug": "a", "title": "A", "category": "Views"}])
        self.assertEqual(entries, [{"id": "Text", "kind": "view", "topic": "a"}])


class RenderTests(unittest.TestCase):
    def test_topic_case(self):
        self.assertEqual(mm.topic_case("Controls-and-indicators"), "controlsAndIndicators")
        self.assertEqual(mm.topic_case("View-layout"), "viewLayout")

    def test_render_manifest(self):
        text = mm.render_manifest([{"id": "Button", "kind": "view", "topic": "Controls-and-indicators"}])
        self.assertIn('ManifestEntry(id: "Button", kind: .view, topic: .controlsAndIndicators),', text)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: テストが落ちることを確かめる**

Run: `cd swiftui && python3 -m unittest discover tools`
Expected: `ModuleNotFoundError: No module named 'make_manifest'` で ERROR

- [ ] **Step 3: 道具を書く**

`swiftui/tools/make_manifest.py`:

```python
#!/usr/bin/env python3
"""SwiftUI のリファレンスの JSON から Topic.swift と Manifest.swift を作る。

数え方は docs/superpowers/specs/2026-10-31-swiftui-app-design.md の「数え方」のとおり。
使い方（swiftui/ で実行する）:
    python3 tools/make_manifest.py            # キャッシュになければ取り出してから作る
    python3 tools/make_manifest.py --refresh  # キャッシュを取り直してから作る
"""
import argparse
import json
import os
import re
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor

BASE_URL = "https://developer.apple.com/tutorials/data"
ROOT_URL = "/documentation/swiftui"
CATEGORIES = [
    "Views",
    "View layout",
    "App structure",
    "Data and storage",
    "Event handling",
    "Accessibility",
]
TARGET_IOS = (27, 0)
# 型の都合の型（書いて使うものではなく、modifier や型消去の結果の型）。収録しない
EXCLUDED_TYPES = {
    "AnyGesture",
    "AnyShape",
    "AnyView",
    "ButtonBorderShape",
    "DefaultButtonLabel",
    "DefaultDateProgressLabel",
    "DefaultDocumentGroupLaunchActions",
    "DefaultGlassEffectShape",
    "DefaultNewDocumentButtonLabel",
    "EditableCollectionContent",
    "EmptyView",
    "EquatableView",
    "FillShapeView",
    "GestureStateGesture",
    "GroupElementsOfContent",
    "GroupSectionsOfContent",
    "ModifiedContent",
    "OffsetShape",
    "PlaceholderContentView",
    "RotatedShape",
    "ScaledShape",
    "StrokeBorderShapeView",
    "StrokeShapeView",
    "SubscriptionView",
    "Subview",
    "SubviewsCollection",
    "SubviewsCollectionSlice",
    "TextInputBorderShape",
    "TransformedShape",
    "TupleContent",
    "TupleView",
}

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE_DIR = os.path.join(HERE, ".cache")
OUT_DIR = os.path.join(HERE, "..", "WidgetLab", "Catalog", "Generated")


# --- 数え方（通信しない。テストはここを確かめる） ---

def parse_version(text):
    parts = [int(p) for p in re.findall(r"\d+", text or "")]
    return tuple((parts + [0, 0])[:2])


def ios_available(symbol):
    """iOS で使え、非推奨でなく、導入の版が TARGET_IOS 以下なら True。"""
    for platform in symbol.get("metadata", {}).get("platforms", []):
        if platform.get("name") != "iOS":
            continue
        if platform.get("deprecated") or platform.get("unavailable"):
            return False
        return parse_version(platform.get("introducedAt")) <= TARGET_IOS
    return False


def conformances(symbol):
    names = []
    for section in symbol.get("relationshipsSections", []):
        if section.get("type") == "conformsTo":
            names += [i.split("/")[-1].lower() for i in section.get("identifiers", [])]
    return names


def kind_of(url, symbol):
    """収録の種類（"view" / "modifier" / "propertyWrapper" / "gesture"）か None。"""
    if not ios_available(symbol):
        return None
    meta = symbol.get("metadata", {})
    symbol_kind = meta.get("symbolKind")
    if symbol_kind == "method":
        return "modifier" if url.startswith(ROOT_URL + "/view/") else None
    if symbol_kind != "struct" or meta.get("title") in EXCLUDED_TYPES:
        return None
    conf = conformances(symbol)
    if "view" in conf:
        return "view"
    if "dynamicproperty" in conf:
        return "propertyWrapper"
    if "gesture" in conf:
        return "gesture"
    return None


def entry_id(kind, title):
    return title.split("(")[0] if kind == "modifier" else title


def topic_case(slug):
    words = re.split(r"[-_]", slug)
    return words[0].lower() + "".join(w[:1].upper() + w[1:] for w in words[1:])


def classify(root, topics, symbols):
    """リファレンスの JSON から、トピックの一覧と収録すべきものの一覧を返す。

    root: swiftui.json / topics: トピックの URL → JSON / symbols: 記号の URL → JSON
    戻り値: (topics, entries)
      topics: [{"slug", "title", "category"}]（収録が 1 件以上あるものだけ、リファレンスの順）
      entries: [{"id", "kind", "topic"}]（リファレンスの順）
    """
    refs = root.get("references", {})
    seen_urls = set()
    seen_ids = set()
    entries = []
    topic_list = []
    for section in root.get("topicSections", []):
        if section.get("title") not in CATEGORIES:
            continue
        for ident in section.get("identifiers", []):
            ref = refs.get(ident, {})
            topic_url = ref.get("url", "")
            topic = topics.get(topic_url)
            if topic is None:
                continue
            slug = topic_url.split("/")[-1]
            topic_refs = topic.get("references", {})
            count = 0
            for group in topic.get("topicSections", []):
                found = []
                for sym_ident in group.get("identifiers", []):
                    sym_ref = topic_refs.get(sym_ident, {})
                    url = sym_ref.get("url", "")
                    if sym_ref.get("role") != "symbol" or url in seen_urls:
                        continue
                    seen_urls.add(url)
                    symbol = symbols.get(url)
                    kind = kind_of(url, symbol) if symbol else None
                    if kind:
                        found.append((kind, entry_id(kind, symbol["metadata"]["title"])))
                has_view = any(kind == "view" for kind, _ in found)
                for kind, name in found:
                    if kind == "modifier" and has_view:
                        continue  # View の節の modifier は、その View のプロパティにする
                    if name in seen_ids:
                        continue
                    seen_ids.add(name)
                    entries.append({"id": name, "kind": kind, "topic": slug})
                    count += 1
            if count:
                topic_list.append(
                    {"slug": slug, "title": ref.get("title", slug), "category": section["title"]}
                )
    return topic_list, entries


# --- Swift のファイルを書く ---

HEADER = "// 生成: tools/make_manifest.py（手で直さない）\n\n"


def swift_string(text):
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


def render_topics(topic_list):
    lines = [HEADER.rstrip("\n"), "", "/// リファレンスの大分類。並びはホームに出す順"]
    lines.append("nonisolated enum Category: String, CaseIterable, Sendable {")
    for name in CATEGORIES:
        if any(t["category"] == name for t in topic_list):
            lines.append("    case {} = {}".format(topic_case(name.replace(" ", "-")), swift_string(name)))
    lines += ["}", "", "/// リファレンスのトピック（= ジャンル）。収録が 1 件以上あるものだけ。並びはリファレンスの順"]
    lines.append("nonisolated enum Topic: String, CaseIterable, Sendable {")
    for t in topic_list:
        lines.append("    case {} = {}".format(topic_case(t["slug"]), swift_string(t["slug"])))
    lines += ["", "    var title: String {", "        switch self {"]
    for t in topic_list:
        lines.append("        case .{}: {}".format(topic_case(t["slug"]), swift_string(t["title"])))
    lines += ["        }", "    }", "", "    var category: Category {", "        switch self {"]
    for t in topic_list:
        lines.append(
            "        case .{}: .{}".format(topic_case(t["slug"]), topic_case(t["category"].replace(" ", "-")))
        )
    lines += ["        }", "    }", "}", ""]
    return "\n".join(lines)


def render_manifest(entries):
    lines = [HEADER.rstrip("\n"), "", "/// 収録すべきものの一覧。Catalog.all と突き合わせる"]
    lines += ["nonisolated enum Manifest {", "    static let entries: [ManifestEntry] = ["]
    for e in entries:
        lines.append(
            "        ManifestEntry(id: {}, kind: .{}, topic: .{}),".format(
                swift_string(e["id"]), e["kind"], topic_case(e["topic"])
            )
        )
    lines += ["    ]", "}", ""]
    return "\n".join(lines)


# --- 取り出し（通信する） ---

def cache_path(url):
    return os.path.join(CACHE_DIR, re.sub(r"[^A-Za-z0-9._-]", "_", url.strip("/")) + ".json")


def load(url, refresh):
    path = cache_path(url)
    if refresh or not os.path.exists(path):
        with urllib.request.urlopen(BASE_URL + url.lower() + ".json", timeout=30) as response:
            data = response.read()
        with open(path, "wb") as f:
            f.write(data)
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def load_all(urls, refresh):
    with ThreadPoolExecutor(16) as pool:
        return dict(zip(urls, pool.map(lambda u: load(u, refresh), urls)))


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--refresh", action="store_true", help="キャッシュを取り直す")
    args = parser.parse_args(argv)
    os.makedirs(CACHE_DIR, exist_ok=True)

    root = load(ROOT_URL, args.refresh)
    refs = root.get("references", {})
    topic_urls = [
        refs[i]["url"]
        for s in root.get("topicSections", [])
        if s.get("title") in CATEGORIES
        for i in s.get("identifiers", [])
        if i in refs
    ]
    topics = load_all(topic_urls, args.refresh)
    symbol_urls = sorted(
        {
            r["url"]
            for t in topics.values()
            for r in t.get("references", {}).values()
            if r.get("role") == "symbol" and r.get("url", "").startswith(ROOT_URL + "/")
        }
    )
    symbols = load_all(symbol_urls, args.refresh)

    topic_list, entries = classify(root, topics, symbols)
    os.makedirs(OUT_DIR, exist_ok=True)
    with open(os.path.join(OUT_DIR, "Topic.swift"), "w", encoding="utf-8") as f:
        f.write(render_topics(topic_list))
    with open(os.path.join(OUT_DIR, "Manifest.swift"), "w", encoding="utf-8") as f:
        f.write(render_manifest(entries))
    counts = {}
    for e in entries:
        counts[e["kind"]] = counts.get(e["kind"], 0) + 1
    print("トピック {} 件 / 収録 {} 件 {}".format(len(topic_list), len(entries), counts))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
```

- [ ] **Step 4: テストが通ることを確かめる**

Run: `python3 -m unittest discover tools`
Expected: `Ran 7 tests` / `OK`

- [ ] **Step 5: 生成されたファイルが使う型を書く**

`swiftui/WidgetLab/Catalog/Model/EntryKind.swift`:

```swift
/// 収録の種類
nonisolated enum EntryKind: String, Sendable {
    case view
    case modifier
    case propertyWrapper
    case gesture
}
```

`swiftui/WidgetLab/Catalog/Model/ManifestEntry.swift`:

```swift
/// 収録すべきもの 1 件（Generated/Manifest.swift が並べる）
nonisolated struct ManifestEntry: Equatable, Sendable {
    let id: String
    let kind: EntryKind
    let topic: Topic
}
```

- [ ] **Step 6: 道具を実行して生成する**

Run: `python3 tools/make_manifest.py`
Expected: 1,500 件ほどの JSON を `tools/.cache/` に取り出したあと、`トピック 41 件 / 収録 458 件 {'propertyWrapper': 19, 'modifier': 354, 'view': 73, 'gesture': 12}` のように出る（リファレンスが更新されていれば数は少し変わってよい）。`WidgetLab/Catalog/Generated/Topic.swift` と `Manifest.swift` ができる

確かめ:
```bash
grep -E '"(Button|Text|VStack|padding)"' WidgetLab/Catalog/Generated/Manifest.swift
```
Expected（この 4 行が出ること。Task 4 の収録データはこのトピックに置く）:
```
        ManifestEntry(id: "Text", kind: .view, topic: .textInputAndOutput),
        ManifestEntry(id: "Button", kind: .view, topic: .controlsAndIndicators),
        ManifestEntry(id: "VStack", kind: .view, topic: .layoutFundamentals),
        ManifestEntry(id: "padding", kind: .modifier, topic: .layoutAdjustments),
```
もしトピックが違っていたら、Task 4 の収録データの `topic:` とフォルダを、生成された値に合わせる。

もう一度実行して、生成物が変わらないこと（キャッシュから同じものができること）を確かめる:
```bash
python3 tools/make_manifest.py && git status --short WidgetLab/Catalog/Generated
```
（まだコミット前なので `??` と出るだけでよい。`md5 -q WidgetLab/Catalog/Generated/*.swift` を 2 回の実行の前後で比べて同じなら OK）

- [ ] **Step 7: 整形の点検とテストを実行する**

Run: `xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests && echo LINT-OK`
Expected: `LINT-OK`（生成物も点検に通る形で出力される）

テストを実行。
Expected: `** TEST SUCCEEDED **`（生成物がビルドに入っても落ちない）

- [ ] **Step 8: コミット**

```bash
git add swiftui/tools/make_manifest.py swiftui/tools/test_make_manifest.py swiftui/WidgetLab/Catalog
git status --short   # tools/.cache/ と __pycache__ が入っていないこと
git commit -m "feat: SwiftUI のリファレンスから manifest を作る道具と生成物を足す

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: 収録データの型とコードの生成

**Files:**
- Create: `swiftui/WidgetLab/Catalog/Model/PropertySpec.swift`、`swiftui/WidgetLab/Catalog/Model/PropertyValues.swift`、`swiftui/WidgetLab/Catalog/Model/CodeTemplate.swift`、`swiftui/WidgetLab/Catalog/Model/CatalogEntry.swift`
- Delete: `swiftui/WidgetLabTests/SmokeTests.swift`
- Test: `swiftui/WidgetLabTests/Catalog/CodeGeneratorTests.swift`

**Interfaces:**
- Consumes: `EntryKind`・`Topic`（Task 2）
- Produces:
  - `PropertySpec`（`id`・`placement: Placement`・`control: PropertyControl`・`initiallyOn`・`isRequired`・`summary`・`displayName`）。`Placement` は `.argument(label: String?)` / `.modifier(name: String, label: String?)`
  - `static func PropertySpec.argument(_ id:, unlabeled: Bool = false, _ control:, on: Bool = false, required: Bool = false, summary:)`、`static func PropertySpec.modifier(_ name:, label: String? = nil, _ control:, on: Bool = false, summary:)`
  - `PropertyControl`: `.slider(range:step:initial:)`・`.toggle(initial:)`・`.choice([Choice], initial:)`・`.color(initial:)`・`.text(initial:)`・`.fixed(code:)`。`initialValue: PropertyValue`、`code(for: PropertyValue) -> String`
  - `Choice(_ label:, code:)` / `Choice(_ code:)`、`Palette.colors: [Palette.Entry]`（`name`・`code`・`color`。red・orange・yellow・green・blue・purple・pink・gray の順）
  - `PropertyValue`: `.number(Double)`・`.flag(Bool)`・`.choice(Int)`・`.color(Int)`・`.text(String)`
  - `PropertyValues`（`init(_ [String: PropertyValue])`・`subscript(id) -> PropertyValue?`（get/set）・`ids`・`number`・`flag`・`text`・`color`・`pick(_:from:)`）
  - `View.apply(_ value: T?, transform)`
  - `CodeTemplate(prefix:call:fixedArguments:trailing:suffix:)`、`CodeLine(text:propertyIDs:isChanged:)`、`CodeGenerator.lines(template:properties:values:changed:) -> [CodeLine]`
  - `DemoStage`（`.card`・`.full`・`.behavior`）、`CatalogEntry`（`id`・`kind`・`topic`・`summary`・`docURL`・`stage`・`properties`・`code`・`build: @MainActor @Sendable (PropertyValues) -> AnyView`・`displayName`・`initialValues`）

- [ ] **Step 1: コードの生成のテストを書く**

`swiftui/WidgetLabTests/Catalog/CodeGeneratorTests.swift`:

```swift
import Testing
@testable import WidgetLab

struct CodeGeneratorTests {
    private let properties: [PropertySpec] = [
        .argument("role", .choice([Choice(".destructive"), Choice(".cancel")], initial: 0), summary: ""),
        .argument("title", unlabeled: true, .text(initial: "保存"), required: true, summary: ""),
        .modifier("tint", .color(initial: 4), summary: ""),
        .modifier("disabled", .toggle(initial: true), summary: ""),
    ]

    @Test func fillsArgumentsAndModifiersInDefinitionOrder() {
        let template = CodeTemplate(call: "Button", fixedArguments: ["action: {}"])
        let values = PropertyValues([
            "role": .choice(1), "title": .text("OK"), "disabled": .flag(true), "tint": .color(0),
        ])
        let lines = CodeGenerator.lines(template: template, properties: properties, values: values)
        #expect(
            lines.map(\.text) == [
                "Button(action: {}, role: .cancel, \"OK\")",
                "    .tint(.red)",
                "    .disabled(true)",
            ])
        #expect(lines[0].propertyIDs == ["role", "title"])
    }

    @Test func omitsParenthesesWhenOnlyTrailingClosure() {
        let template = CodeTemplate(call: "VStack", trailing: " {\n    Text(\"A\")\n}")
        let lines = CodeGenerator.lines(template: template, properties: [], values: PropertyValues())
        #expect(lines.map(\.text) == ["VStack {", "    Text(\"A\")", "}"])
    }

    @Test func modifierEntryIndentsCallAfterPrefixAndAddsSuffix() {
        let template = CodeTemplate(prefix: ["Text(\"見本\")"], call: ".padding", suffix: [".background(.yellow)"])
        let lines = CodeGenerator.lines(template: template, properties: [], values: PropertyValues())
        #expect(lines.map(\.text) == ["Text(\"見本\")", "    .padding()", "    .background(.yellow)"])
    }

    @Test func marksChangedLines() {
        let template = CodeTemplate(call: "Button")
        let values = PropertyValues(["title": .text("OK"), "tint": .color(0)])
        let lines = CodeGenerator.lines(template: template, properties: properties, values: values, changed: ["tint"])
        #expect(lines.map(\.isChanged) == [false, true])
    }

    @Test func formatsValues() {
        #expect(PropertyControl.slider(range: 0...10, step: 1, initial: 0).code(for: .number(8)) == "8")
        #expect(PropertyControl.slider(range: 0...1, step: 0.1, initial: 0).code(for: .number(0.5)) == "0.5")
        #expect(PropertyControl.text(initial: "").code(for: .text("a\"b")) == "\"a\\\"b\"")
        #expect(PropertyControl.fixed(code: ".infinity").code(for: .flag(true)) == ".infinity")
    }
}
```

仮のテストを消す:
```bash
git rm swiftui/WidgetLabTests/SmokeTests.swift
```

- [ ] **Step 2: テストが落ちることを確かめる**

テストを実行（`-only-testing:WidgetLabTests/CodeGeneratorTests` を足してよい）。
Expected: ビルドが `cannot find 'PropertySpec' in scope` などで失敗する

- [ ] **Step 3: プロパティの定義の型を書く**

`swiftui/WidgetLab/Catalog/Model/PropertySpec.swift`:

```swift
import SwiftUI

/// 操作できるプロパティ 1 つの定義
nonisolated struct PropertySpec: Identifiable, Sendable {
    enum Placement: Equatable, Sendable {
        /// イニシャライザ（modifier の収録なら、その modifier）の引数。label が nil なら名前なしの引数
        case argument(label: String?)
        /// modifier。label が nil なら名前なしの引数
        case modifier(name: String, label: String?)
    }

    let id: String
    let placement: Placement
    let control: PropertyControl
    let initiallyOn: Bool
    /// OFF にできない（Text の文字など、省くとコードが成り立たない引数）
    var isRequired: Bool = false
    /// 一言の説明（日本語）
    let summary: String

    /// チップと編集パネルに出す名前（例: "role"、".tint"）
    var displayName: String {
        switch placement {
        case .argument: id
        case .modifier(let name, _): "." + name
        }
    }

    /// 引数のプロパティ。引数のラベルは id と同じ（unlabeled なら名前なし）。required ならいつも ON
    static func argument(
        _ id: String, unlabeled: Bool = false, _ control: PropertyControl, on: Bool = false, required: Bool = false,
        summary: String
    ) -> PropertySpec {
        PropertySpec(
            id: id, placement: .argument(label: unlabeled ? nil : id), control: control, initiallyOn: on || required,
            isRequired: required, summary: summary)
    }

    static func modifier(
        _ name: String, label: String? = nil, _ control: PropertyControl, on: Bool = false, summary: String
    ) -> PropertySpec {
        PropertySpec(
            id: name, placement: .modifier(name: name, label: label), control: control, initiallyOn: on,
            summary: summary)
    }
}

/// 操作部品の種類。値の型とコードの書き方を持つ
nonisolated enum PropertyControl: Sendable {
    case slider(range: ClosedRange<Double>, step: Double, initial: Double)
    case toggle(initial: Bool)
    case choice([Choice], initial: Int)
    case color(initial: Int)
    case text(initial: String)
    /// 値を変えられない。ON/OFF だけ切り替える
    case fixed(code: String)

    var initialValue: PropertyValue {
        switch self {
        case .slider(_, _, let initial): .number(initial)
        case .toggle(let initial): .flag(initial)
        case .choice(_, let initial): .choice(initial)
        case .color(let initial): .color(initial)
        case .text(let initial): .text(initial)
        case .fixed: .flag(true)
        }
    }

    /// 値を Swift のコードの文字列にする
    func code(for value: PropertyValue) -> String {
        switch (self, value) {
        case (.slider, .number(let n)):
            n.rounded() == n ? String(Int(n)) : String(format: "%.1f", n)
        case (.toggle, .flag(let b)):
            b ? "true" : "false"
        case (.choice(let choices, _), .choice(let i)):
            choices[i].code
        case (.color, .color(let i)):
            Palette.colors[i].code
        case (.text, .text(let s)):
            "\"" + s.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") + "\""
        case (.fixed(let code), _):
            code
        default:
            preconditionFailure("操作部品と値の種類が合わない: \(self) / \(value)")
        }
    }
}

/// 選択肢 1 つ。表示の名前とコードの文字列の組
nonisolated struct Choice: Sendable {
    let label: String
    let code: String

    init(_ label: String, code: String) {
        self.label = label
        self.code = code
    }

    /// 表示の名前とコードが同じもの（例: ".bordered"）
    init(_ code: String) {
        self.init(code, code: code)
    }
}

/// 色の操作部品で選べる色
nonisolated enum Palette {
    struct Entry: Sendable {
        let name: String
        let code: String
        let color: Color
    }

    static let colors: [Entry] = [
        Entry(name: "red", code: ".red", color: .red),
        Entry(name: "orange", code: ".orange", color: .orange),
        Entry(name: "yellow", code: ".yellow", color: .yellow),
        Entry(name: "green", code: ".green", color: .green),
        Entry(name: "blue", code: ".blue", color: .blue),
        Entry(name: "purple", code: ".purple", color: .purple),
        Entry(name: "pink", code: ".pink", color: .pink),
        Entry(name: "gray", code: ".gray", color: .gray),
    ]
}
```

- [ ] **Step 4: 値の型と apply を書く**

`swiftui/WidgetLab/Catalog/Model/PropertyValues.swift`:

```swift
import SwiftUI

/// プロパティ 1 つの値
nonisolated enum PropertyValue: Equatable, Sendable {
    case number(Double)
    case flag(Bool)
    /// 選択肢の番号
    case choice(Int)
    /// Palette.colors の番号
    case color(Int)
    case text(String)
}

/// ON のプロパティの値。入っていないプロパティは OFF
nonisolated struct PropertyValues: Equatable, Sendable {
    private var storage: [String: PropertyValue]

    init(_ storage: [String: PropertyValue] = [:]) {
        self.storage = storage
    }

    subscript(id: String) -> PropertyValue? {
        get { storage[id] }
        set { storage[id] = newValue }
    }

    var ids: Set<String> { Set(storage.keys) }

    func number(_ id: String) -> Double? {
        if case .number(let n) = storage[id] { n } else { nil }
    }

    func flag(_ id: String) -> Bool? {
        if case .flag(let b) = storage[id] { b } else { nil }
    }

    func text(_ id: String) -> String? {
        if case .text(let s) = storage[id] { s } else { nil }
    }

    func color(_ id: String) -> Color? {
        if case .color(let i) = storage[id] { Palette.colors[i].color } else { nil }
    }

    /// 選択肢の番号に合う値を options から取り出す（options は選択肢と同じ並び）
    func pick<T>(_ id: String, from options: [T]) -> T? {
        if case .choice(let i) = storage[id] { options[i] } else { nil }
    }
}

extension View {
    /// value が nil（プロパティが OFF）なら何もしない。ON なら transform をかける
    @ViewBuilder
    func apply<T, Content: View>(_ value: T?, @ViewBuilder _ transform: (Self, T) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}
```

- [ ] **Step 5: コードの形と生成を書く**

`swiftui/WidgetLab/Catalog/Model/CodeTemplate.swift`:

```swift
import Foundation

/// コードの形。CodeGenerator が、ON のプロパティを埋めてコードにする
///
/// 例: Button("保存", role: .destructive) { } に .tint(.red) が付くとき
///     call: "Button", fixedArguments: ["\"保存\""], trailing: " { }"
nonisolated struct CodeTemplate: Sendable {
    /// 呼び出しより前の行（modifier の収録で、かける相手の見本。例: ["Text(\"見本\")"]）
    var prefix: [String] = []
    /// 呼び出しの名前（例: "Button"、".padding"）
    var call: String
    /// いつも書く引数（ON の引数のプロパティより前に並ぶ）
    var fixedArguments: [String] = []
    /// 呼び出しのあとの末尾のクロージャ（例: " { }"。複数行は "\n" で区切る）
    var trailing: String = ""
    /// いちばん最後に付ける modifier の行（例: [".background(.yellow)"]）
    var suffix: [String] = []
}

/// コードの 1 行
nonisolated struct CodeLine: Equatable, Sendable {
    let text: String
    /// この行に書いたプロパティの id
    let propertyIDs: [String]
    /// 最初の値から変えたプロパティがこの行にあるか
    let isChanged: Bool
}

nonisolated enum CodeGenerator {
    /// ON のプロパティを埋めて、コードを行ごとに返す
    static func lines(
        template: CodeTemplate, properties: [PropertySpec], values: PropertyValues, changed: Set<String> = []
    ) -> [CodeLine] {
        let indent = template.prefix.isEmpty ? "" : "    "
        var result = template.prefix.map { CodeLine(text: $0, propertyIDs: [], isChanged: false) }

        var arguments = template.fixedArguments
        var argumentIDs: [String] = []
        for spec in properties {
            guard case .argument(let label) = spec.placement, let value = values[spec.id] else { continue }
            arguments.append(argument(label: label, code: spec.control.code(for: value)))
            argumentIDs.append(spec.id)
        }
        let parentheses =
            arguments.isEmpty && !template.trailing.isEmpty ? "" : "(" + arguments.joined(separator: ", ") + ")"
        let callLines = (indent + template.call + parentheses + template.trailing).components(separatedBy: "\n")
        let callChanged = !changed.isDisjoint(with: argumentIDs)
        result += callLines.enumerated().map { index, text in
            CodeLine(text: text, propertyIDs: index == 0 ? argumentIDs : [], isChanged: index == 0 && callChanged)
        }

        for spec in properties {
            guard case .modifier(let name, let label) = spec.placement, let value = values[spec.id] else { continue }
            let text = "    .\(name)(" + argument(label: label, code: spec.control.code(for: value)) + ")"
            result.append(CodeLine(text: text, propertyIDs: [spec.id], isChanged: changed.contains(spec.id)))
        }
        result += template.suffix.map { CodeLine(text: "    " + $0, propertyIDs: [], isChanged: false) }
        return result
    }

    private static func argument(label: String?, code: String) -> String {
        label.map { "\($0): \(code)" } ?? code
    }
}
```

- [ ] **Step 6: 収録 1 件の型を書く**

`swiftui/WidgetLab/Catalog/Model/CatalogEntry.swift`:

```swift
import SwiftUI

/// プレビューの出し方
nonisolated enum DemoStage: Sendable {
    /// 詳細のプレビューの枠に収まるもの
    case card
    /// 画面より大きいもの・sheet など。プレビューの「試す」から全画面で開く（Phase 3 で使う）
    case full
    /// 見た目を持たないもの。記録を出す（Phase 2 で使う）
    case behavior
}

/// 収録の 1 件。1 件 = 1 ファイル（Catalog/<トピック>/<名前>Entry.swift）
nonisolated struct CatalogEntry: Identifiable, Sendable {
    /// Manifest と照らすキー（例: "Button"、"padding"、"State"）
    let id: String
    let kind: EntryKind
    let topic: Topic
    /// 公式の要約（日本語）
    let summary: String
    let docURL: URL
    let stage: DemoStage
    let properties: [PropertySpec]
    let code: CodeTemplate
    let build: @MainActor @Sendable (PropertyValues) -> AnyView

    /// 一覧と見出しに出す名前（例: "Button"、".padding"、"@State"）
    var displayName: String {
        switch kind {
        case .view, .gesture: id
        case .modifier: "." + id
        case .propertyWrapper: "@" + id
        }
    }

    /// 最初の値（initiallyOn のプロパティだけ ON）
    var initialValues: PropertyValues {
        PropertyValues(
            Dictionary(uniqueKeysWithValues: properties.filter(\.initiallyOn).map { ($0.id, $0.control.initialValue) })
        )
    }
}
```

- [ ] **Step 7: 整形の点検とテストを実行する**

Run: `xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests && echo LINT-OK`
Expected: `LINT-OK`

テストを実行。
Expected: `** TEST SUCCEEDED **`。`CodeGeneratorTests` の 5 件が passed

- [ ] **Step 8: コミット**

```bash
git add swiftui/WidgetLab/Catalog/Model swiftui/WidgetLabTests
git commit -m "feat: 収録データの型とコードの生成を足す

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: 最初の 4 件の収録と、全件のテスト

**Files:**
- Create: `swiftui/WidgetLab/Catalog/ControlsAndIndicators/ButtonEntry.swift`、`swiftui/WidgetLab/Catalog/TextInputAndOutput/TextEntry.swift`、`swiftui/WidgetLab/Catalog/LayoutFundamentals/VStackEntry.swift`、`swiftui/WidgetLab/Catalog/LayoutAdjustments/PaddingEntry.swift`、`swiftui/WidgetLab/Catalog/Catalog.swift`
- Test: `swiftui/WidgetLabTests/Catalog/CatalogTests.swift`

**Interfaces:**
- Consumes: Task 3 の型すべて、`Manifest.entries`（Task 2）
- Produces: `CatalogEntry.button`・`.text`・`.vStack`・`.padding`、`Catalog.all: [CatalogEntry]`（この 4 件をこの順に）
  - `.text` のプロパティ: `content`（required の文字）・`font`・`foregroundStyle`・`lineLimit`
  - Task 6 のテストは `CatalogEntry.text` の `content` が required であることを使う

- [ ] **Step 1: 全件のテストを書く**

`swiftui/WidgetLabTests/Catalog/CatalogTests.swift`:

```swift
import SwiftUI
import Testing
@testable import WidgetLab

@MainActor
struct CatalogTests {
    @Test func idsAreUniqueAndListedInManifestWithSameKindAndTopic() {
        let ids = Catalog.all.map(\.id)
        #expect(Set(ids).count == ids.count, "id が重複している")
        let manifest = Dictionary(uniqueKeysWithValues: Manifest.entries.map { ($0.id, $0) })
        for entry in Catalog.all {
            let expected = manifest[entry.id]
            #expect(expected != nil, "\(entry.id) が Manifest にない")
            #expect(expected?.kind == entry.kind, "\(entry.id) の種類が Manifest と違う")
            #expect(expected?.topic == entry.topic, "\(entry.id) のトピックが Manifest と違う")
        }
        print("収録の進み具合: \(ids.count) / \(Manifest.entries.count)")
    }

    @Test func propertyIDsAreUniqueInEachEntry() {
        for entry in Catalog.all {
            let ids = entry.properties.map(\.id)
            #expect(Set(ids).count == ids.count, "\(entry.id) のプロパティの id が重複している")
        }
    }

    @Test(arguments: Catalog.all.map(\.id))
    func buildsAllCombinations(id: String) throws {
        let entry = try #require(Catalog.all.first { $0.id == id })
        for values in Self.combinations(of: entry) {
            let renderer = ImageRenderer(content: entry.build(values).frame(width: 320, height: 240))
            #expect(renderer.uiImage != nil, "\(id) を \(values) で描けない")
            _ = CodeGenerator.lines(template: entry.code, properties: entry.properties, values: values)
        }
    }

    /// 全部 OFF（required は ON）・全部 ON・選択肢ごと（ほかは最初の値）
    static func combinations(of entry: CatalogEntry) -> [PropertyValues] {
        let required = PropertyValues(
            Dictionary(
                uniqueKeysWithValues: entry.properties.filter(\.isRequired).map { ($0.id, $0.control.initialValue) }))
        let allOn = PropertyValues(
            Dictionary(uniqueKeysWithValues: entry.properties.map { ($0.id, $0.control.initialValue) }))
        var result = [required, allOn]
        for spec in entry.properties {
            guard case .choice(let choices, _) = spec.control else { continue }
            for i in choices.indices {
                var values = entry.initialValues
                values[spec.id] = .choice(i)
                result.append(values)
            }
        }
        return result
    }
}
```

- [ ] **Step 2: テストが落ちることを確かめる**

テストを実行（`-only-testing:WidgetLabTests/CatalogTests` を足してよい）。
Expected: ビルドが `cannot find 'Catalog' in scope` で失敗する

- [ ] **Step 3: 4 件の収録データを書く**

`swiftui/WidgetLab/Catalog/ControlsAndIndicators/ButtonEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let button = CatalogEntry(
        id: "Button",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "押したときに処理を行うコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/button")!,
        stage: .card,
        properties: [
            .argument(
                "role", .choice([Choice(".destructive"), Choice(".cancel")], initial: 0),
                summary: "ボタンの役割。destructive は削除などの取り消せない操作"),
            .modifier(
                "buttonStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".bordered"), Choice(".borderedProminent"), Choice(".borderless"),
                        Choice(".plain"), Choice(".glass"),
                    ],
                    initial: 2),
                on: true, summary: "ボタンの見た目のスタイル"),
            .modifier(
                "controlSize",
                .choice(
                    [Choice(".mini"), Choice(".small"), Choice(".regular"), Choice(".large"), Choice(".extraLarge")],
                    initial: 3),
                summary: "コントロールの大きさ"),
            .modifier("tint", .color(initial: 4), summary: "強調の色"),
            .modifier("disabled", .toggle(initial: true), summary: "押せなくする"),
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存\""], trailing: " { }"),
        build: { v in
            AnyView(
                ButtonDemo.button(role: v.pick("role", from: [ButtonRole.destructive, .cancel]))
                    .apply(v.pick("buttonStyle", from: ButtonDemo.Style.allCases)) { view, style in
                        ButtonDemo.styled(view, style)
                    }
                    .apply(v.pick("controlSize", from: [ControlSize.mini, .small, .regular, .large, .extraLarge])) {
                        $0.controlSize($1)
                    }
                    .apply(v.color("tint")) { $0.tint($1) }
                    .apply(v.flag("disabled")) { $0.disabled($1) }
            )
        }
    )
}

private enum ButtonDemo {
    enum Style: CaseIterable {
        case automatic, bordered, borderedProminent, borderless, plain, glass
    }

    @ViewBuilder
    static func button(role: ButtonRole?) -> some View {
        if let role {
            Button("保存", role: role) {}
        } else {
            Button("保存") {}
        }
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.buttonStyle(.automatic)
        case .bordered: view.buttonStyle(.bordered)
        case .borderedProminent: view.buttonStyle(.borderedProminent)
        case .borderless: view.buttonStyle(.borderless)
        case .plain: view.buttonStyle(.plain)
        case .glass: view.buttonStyle(.glass)
        }
    }
}
```

`swiftui/WidgetLab/Catalog/TextInputAndOutput/TextEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let text = CatalogEntry(
        id: "Text",
        kind: .view,
        topic: .textInputAndOutput,
        summary: "読み取り専用の文字を 1 行以上表示する View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/text")!,
        stage: .card,
        properties: [
            .argument(
                "content", unlabeled: true, .text(initial: "こんにちは、SwiftUI の世界"), required: true,
                summary: "表示する文字"),
            .modifier(
                "font",
                .choice(
                    [
                        Choice(".largeTitle"), Choice(".title"), Choice(".headline"), Choice(".body"),
                        Choice(".caption"),
                    ],
                    initial: 1),
                summary: "文字の大きさと太さ（Dynamic Type に合わせて変わる）"),
            .modifier("foregroundStyle", .color(initial: 4), summary: "文字の色"),
            .modifier("lineLimit", .slider(range: 1...3, step: 1, initial: 1), summary: "表示する行の数の上限"),
        ],
        code: CodeTemplate(call: "Text"),
        build: { v in
            AnyView(
                Text(v.text("content") ?? "")
                    .apply(v.pick("font", from: [Font.largeTitle, .title, .headline, .body, .caption])) { $0.font($1) }
                    .apply(v.color("foregroundStyle")) { $0.foregroundStyle($1) }
                    .apply(v.number("lineLimit")) { $0.lineLimit(Int($1)) }
            )
        }
    )
}
```

`swiftui/WidgetLab/Catalog/LayoutFundamentals/VStackEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let vStack = CatalogEntry(
        id: "VStack",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を縦に並べる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/vstack")!,
        stage: .card,
        properties: [
            .argument(
                "alignment", .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 0),
                on: true, summary: "子の横の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "子と子の間の距離"),
        ],
        code: CodeTemplate(
            call: "VStack", trailing: " {\n    Text(\"A\")\n    Text(\"BBBB\")\n    Text(\"CC\")\n}"),
        build: { v in
            AnyView(
                VStack(
                    alignment: v.pick("alignment", from: [HorizontalAlignment.leading, .center, .trailing]) ?? .center,
                    spacing: v.number("spacing").map { CGFloat($0) }
                ) {
                    Text("A")
                    Text("BBBB")
                    Text("CC")
                }
                .border(.secondary)
            )
        }
    )
}
```

`swiftui/WidgetLab/Catalog/LayoutAdjustments/PaddingEntry.swift`:

```swift
import SwiftUI

nonisolated extension CatalogEntry {
    static let padding = CatalogEntry(
        id: "padding",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View のまわりに余白を足す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/padding(_:_:)")!,
        stage: .card,
        properties: [
            .argument(
                "edges", unlabeled: true,
                .choice(
                    [Choice(".all"), Choice(".horizontal"), Choice(".vertical"), Choice(".top"), Choice(".leading")],
                    initial: 1),
                summary: "余白を足す辺"),
            .argument(
                "length", unlabeled: true, .slider(range: 0...48, step: 4, initial: 24), on: true,
                summary: "余白の大きさ（OFF なら環境に合わせた既定の大きさ）"),
        ],
        code: CodeTemplate(prefix: ["Text(\"見本\")"], call: ".padding", suffix: [".background(.yellow)"]),
        build: { v in
            let edges = v.pick("edges", from: [Edge.Set.all, .horizontal, .vertical, .top, .leading]) ?? .all
            return AnyView(
                Text("見本")
                    .padding(edges, v.number("length").map { CGFloat($0) })
                    .background(.yellow)
            )
        }
    )
}
```

- [ ] **Step 4: 全件の一覧を書く**

`swiftui/WidgetLab/Catalog/Catalog.swift`:

```swift
/// 収録の全件。収録データを足したら、ここに並べる
nonisolated enum Catalog {
    static let all: [CatalogEntry] = [
        .button,
        .text,
        .vStack,
        .padding,
    ]
}
```

- [ ] **Step 5: 整形の点検とテストを実行する**

Run: `xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests && echo LINT-OK`
Expected: `LINT-OK`

テストを実行。
Expected: `** TEST SUCCEEDED **`。`CatalogTests` の 3 つ（`buildsAllCombinations(id:)` は 4 件ぶん）が passed。ログに `収録の進み具合: 4 / 458` が出る

- [ ] **Step 6: コミット**

```bash
git add swiftui/WidgetLab/Catalog swiftui/WidgetLabTests/Catalog/CatalogTests.swift
git commit -m "feat: Button・Text・VStack・padding を収録する

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: Repository・クリップボードと、ホーム・トピックの ViewModel

**Files:**
- Create: `swiftui/WidgetLab/Core/Data/CatalogRepository.swift`、`swiftui/WidgetLab/Core/System/ClipboardClient.swift`、`swiftui/WidgetLab/Features/Catalog/ViewModel/CatalogViewModel.swift`
- Test: `swiftui/WidgetLabTests/Support/Fakes.swift`、`swiftui/WidgetLabTests/Features/Catalog/CatalogViewModelTests.swift`

**Interfaces:**
- Consumes: `CatalogEntry`・`Catalog.all`・`Category`・`Topic`
- Produces:
  - `protocol CatalogRepository: Sendable { func allEntries() -> [CatalogEntry] }`、`struct BundledCatalogRepository: CatalogRepository`
  - `protocol ClipboardClient: Sendable { func copy(_ text: String) }`、`struct SystemClipboard: ClipboardClient`
  - `CategorySection`（`category`・`topics: [TopicSummary]`）、`TopicSummary`（`topic`・`count`・`sampleNames`）
  - `@Observable final class CatalogViewModel`: `init(repository: any CatalogRepository)`・`var query: String`・`var sections: [CategorySection]`・`var results: [CatalogEntry]`・`func entries(in: Topic) -> [CatalogEntry]`・`func entry(id: String) -> CatalogEntry?`
  - テスト用: `FakeCatalogRepository(entries:)`・`FakeClipboard`（`copied: [String]`）・`CatalogEntry.fake(id:topic:)`（引数 `size`（初期 ON、slider 0...10、初期値 4）、modifier `tint`（color 0）・`hidden`（toggle true））

- [ ] **Step 1: fake とテストを書く**

`swiftui/WidgetLabTests/Support/Fakes.swift`:

```swift
import SwiftUI
@testable import WidgetLab

struct FakeCatalogRepository: CatalogRepository {
    let entries: [CatalogEntry]

    func allEntries() -> [CatalogEntry] {
        entries
    }
}

final class FakeClipboard: ClipboardClient, @unchecked Sendable {
    private(set) var copied: [String] = []

    func copy(_ text: String) {
        copied.append(text)
    }
}

extension CatalogEntry {
    /// テスト用の収録データ。引数 1 つ（size）と modifier 2 つ（tint・hidden）
    static func fake(id: String = "Sample", topic: Topic = .controlsAndIndicators) -> CatalogEntry {
        CatalogEntry(
            id: id,
            kind: .view,
            topic: topic,
            summary: "テスト用",
            docURL: URL(string: "https://example.com")!,
            stage: .card,
            properties: [
                .argument("size", .slider(range: 0...10, step: 1, initial: 4), on: true, summary: "大きさ"),
                .modifier("tint", .color(initial: 0), summary: "色"),
                .modifier("hidden", .toggle(initial: true), summary: "隠す"),
            ],
            code: CodeTemplate(call: id),
            build: { _ in AnyView(Text(id)) }
        )
    }
}
```

`swiftui/WidgetLabTests/Features/Catalog/CatalogViewModelTests.swift`:

```swift
import Testing
@testable import WidgetLab

@MainActor
struct CatalogViewModelTests {
    private func makeViewModel() -> CatalogViewModel {
        CatalogViewModel(
            repository: FakeCatalogRepository(entries: [
                .fake(id: "Button", topic: .controlsAndIndicators),
                .fake(id: "Toggle", topic: .controlsAndIndicators),
                .fake(id: "padding", topic: .layoutAdjustments),
            ]))
    }

    @Test func sectionsListOnlyTopicsWithEntriesInDeclarationOrder() {
        let sections = makeViewModel().sections
        #expect(sections.map(\.category) == [.views, .viewLayout])
        #expect(sections[0].topics.map(\.topic) == [.controlsAndIndicators])
        #expect(sections[0].topics[0].count == 2)
        #expect(sections[0].topics[0].sampleNames == ["Button", "Toggle"])
    }

    @Test func searchMatchesPartOfNameIgnoringCaseInAlphabeticalOrder() {
        let viewModel = makeViewModel()
        viewModel.query = "T"
        #expect(viewModel.results.map(\.id) == ["Button", "Toggle"])
        viewModel.query = "PAD"
        #expect(viewModel.results.map(\.id) == ["padding"])
    }

    @Test func emptyQueryHasNoResults() {
        let viewModel = makeViewModel()
        viewModel.query = "  "
        #expect(viewModel.results.isEmpty)
    }
}
```

- [ ] **Step 2: テストが落ちることを確かめる**

テストを実行（`-only-testing:WidgetLabTests/CatalogViewModelTests` を足してよい）。
Expected: ビルドが `cannot find type 'CatalogRepository' in scope` などで失敗する

- [ ] **Step 3: Repository とクリップボードを書く**

`swiftui/WidgetLab/Core/Data/CatalogRepository.swift`:

```swift
/// 収録データを読む窓口。UI と ViewModel は Catalog を直接読まず、ここを通す
protocol CatalogRepository: Sendable {
    func allEntries() -> [CatalogEntry]
}

/// アプリに同梱した収録データ（Catalog.all）を返す
struct BundledCatalogRepository: CatalogRepository {
    func allEntries() -> [CatalogEntry] {
        Catalog.all
    }
}
```

`swiftui/WidgetLab/Core/System/ClipboardClient.swift`:

```swift
import UIKit

/// クリップボードへの書き込み。テストでは fake に差し替える
protocol ClipboardClient: Sendable {
    func copy(_ text: String)
}

struct SystemClipboard: ClipboardClient {
    func copy(_ text: String) {
        UIPasteboard.general.string = text
    }
}
```

- [ ] **Step 4: ViewModel を書く**

`swiftui/WidgetLab/Features/Catalog/ViewModel/CatalogViewModel.swift`:

```swift
import Foundation
import Observation

/// ホームの大分類の節 1 つ
struct CategorySection: Identifiable, Equatable {
    let category: Category
    let topics: [TopicSummary]

    var id: Category { category }
}

/// ホームのトピックの行 1 つ
struct TopicSummary: Identifiable, Equatable {
    let topic: Topic
    let count: Int
    /// 代表の名前（最初の 3 件）
    let sampleNames: [String]

    var id: Topic { topic }
}

/// ホームとトピック画面の状態
@Observable
final class CatalogViewModel {
    var query = ""
    private let entries: [CatalogEntry]

    init(repository: any CatalogRepository) {
        entries = repository.allEntries()
    }

    /// 収録が 1 件以上あるトピックを、大分類ごとに並べる（並びは Category・Topic の宣言の順）
    var sections: [CategorySection] {
        Category.allCases.compactMap { category in
            let topics = Topic.allCases.filter { $0.category == category }.compactMap { topic -> TopicSummary? in
                let names = entries(in: topic).map(\.displayName)
                return names.isEmpty
                    ? nil : TopicSummary(topic: topic, count: names.count, sampleNames: Array(names.prefix(3)))
            }
            return topics.isEmpty ? nil : CategorySection(category: category, topics: topics)
        }
    }

    /// 検索の結果。query が空なら空。名前の部分一致（大文字・小文字を区別しない）で、id の ABC 順
    var results: [CatalogEntry] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        return
            entries
            .filter { $0.id.localizedCaseInsensitiveContains(trimmed) }
            .sorted { $0.id.localizedCaseInsensitiveCompare($1.id) == .orderedAscending }
    }

    func entries(in topic: Topic) -> [CatalogEntry] {
        entries.filter { $0.topic == topic }
    }

    func entry(id: String) -> CatalogEntry? {
        entries.first { $0.id == id }
    }
}
```

- [ ] **Step 5: 整形の点検とテストを実行する**

Run: `xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests && echo LINT-OK`
Expected: `LINT-OK`

テストを実行。
Expected: `** TEST SUCCEEDED **`。`CatalogViewModelTests` の 3 件が passed

- [ ] **Step 6: コミット**

```bash
git add swiftui/WidgetLab/Core swiftui/WidgetLab/Features swiftui/WidgetLabTests
git commit -m "feat: 収録データの窓口とホーム・トピックの ViewModel を足す

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: 詳細の ViewModel

**Files:**
- Create: `swiftui/WidgetLab/Features/Detail/ViewModel/DetailViewModel.swift`
- Test: `swiftui/WidgetLabTests/Features/Detail/DetailViewModelTests.swift`

**Interfaces:**
- Consumes: `CatalogEntry`・`PropertySpec`・`PropertyValue(s)`・`CodeGenerator`・`ClipboardClient`、テスト用の `CatalogEntry.fake()`・`FakeClipboard`・`CatalogEntry.text`
- Produces: `@Observable final class DetailViewModel`:
  - `init(entry: CatalogEntry, clipboard: any ClipboardClient)`、`let entry`
  - `var selectedID: String?`（最初は、最初の ON のプロパティ。なければ最初のプロパティ）、`var selected: PropertySpec?`
  - `var isComparing: Bool`、`var comparison: (without: PropertyValues, with: PropertyValues)?`
  - `func isOn(_:) -> Bool`、`func setOn(_:_:)`（required は OFF にしない）、`func value(_:) -> PropertyValue?`、`func setValue(_:_:)`（OFF なら ON にする）、`func reset()`
  - `var current: PropertyValues`、`func valueLabel(_:) -> String`（OFF なら `"OFF"`、文字はそのまま、ほかはコード）、`var changedIDs: Set<String>`
  - `var codeLines: [CodeLine]`、`var selectedLine: CodeLine?`、`var codeText: String`、`func copyCode()`、`private(set) var didCopy: Bool`

- [ ] **Step 1: テストを書く**

`swiftui/WidgetLabTests/Features/Detail/DetailViewModelTests.swift`:

```swift
import Testing
@testable import WidgetLab

@MainActor
struct DetailViewModelTests {
    private let clipboard = FakeClipboard()

    private func makeViewModel() -> DetailViewModel {
        DetailViewModel(entry: .fake(), clipboard: clipboard)
    }

    @Test func startsWithInitiallyOnPropertiesAndSelectsFirstOn() {
        let viewModel = makeViewModel()
        #expect(viewModel.current == PropertyValues(["size": .number(4)]))
        #expect(viewModel.selectedID == "size")
    }

    @Test func turningOffRemovesValueAndTurningOnRestoresLastValue() {
        let viewModel = makeViewModel()
        viewModel.setValue("size", .number(8))
        viewModel.setOn("size", false)
        #expect(viewModel.current["size"] == nil)
        #expect(viewModel.valueLabel("size") == "OFF")
        viewModel.setOn("size", true)
        #expect(viewModel.current["size"] == .number(8))
    }

    @Test func settingValueTurnsPropertyOn() {
        let viewModel = makeViewModel()
        viewModel.setValue("tint", .color(2))
        #expect(viewModel.current["tint"] == .color(2))
        #expect(viewModel.valueLabel("tint") == ".yellow")
    }

    @Test func resetRestoresInitialValuesAndStopsComparing() {
        let viewModel = makeViewModel()
        viewModel.setValue("size", .number(9))
        viewModel.setValue("hidden", .flag(false))
        viewModel.isComparing = true
        viewModel.reset()
        #expect(viewModel.current == PropertyValues(["size": .number(4)]))
        #expect(viewModel.isComparing == false)
    }

    @Test func comparisonDiffersOnlyInSelectedProperty() throws {
        let viewModel = makeViewModel()
        viewModel.setValue("tint", .color(1))
        viewModel.selectedID = "tint"
        viewModel.isComparing = true
        let pair = try #require(viewModel.comparison)
        #expect(pair.without == PropertyValues(["size": .number(4)]))
        #expect(pair.with == PropertyValues(["size": .number(4), "tint": .color(1)]))
    }

    @Test func comparisonIsNilWhenNotComparing() {
        #expect(makeViewModel().comparison == nil)
    }

    @Test func codeLinesMarkChangedAndSelectedLine() {
        let viewModel = makeViewModel()
        viewModel.setValue("tint", .color(0))
        viewModel.selectedID = "tint"
        #expect(viewModel.codeLines.map(\.text) == ["Sample(size: 4)", "    .tint(.red)"])
        #expect(viewModel.codeLines.map(\.isChanged) == [false, true])
        #expect(viewModel.selectedLine?.text == "    .tint(.red)")
    }

    @Test func requiredPropertyCannotBeTurnedOff() {
        let entry = CatalogEntry.text
        let viewModel = DetailViewModel(entry: entry, clipboard: clipboard)
        viewModel.setOn("content", false)
        #expect(viewModel.isOn("content"))
    }

    @Test func copyCodeWritesFullCodeToClipboard() {
        let viewModel = makeViewModel()
        viewModel.copyCode()
        #expect(clipboard.copied == ["Sample(size: 4)"])
        #expect(viewModel.didCopy)
    }
}
```

- [ ] **Step 2: テストが落ちることを確かめる**

テストを実行（`-only-testing:WidgetLabTests/DetailViewModelTests` を足してよい）。
Expected: ビルドが `cannot find 'DetailViewModel' in scope` で失敗する

- [ ] **Step 3: ViewModel を書く**

`swiftui/WidgetLab/Features/Detail/ViewModel/DetailViewModel.swift`:

```swift
import Foundation
import Observation

/// 詳細画面の状態（プロパティの値・選んでいるプロパティ・比べる）
@Observable
final class DetailViewModel {
    let entry: CatalogEntry
    /// 選んでいるプロパティの id
    var selectedID: String?
    var isComparing = false
    /// コードをコピーした直後に true
    private(set) var didCopy = false

    /// 全プロパティの今の値（OFF のものも、ON に戻したときのために値を覚えておく）
    private var values: [String: PropertyValue]
    private var enabled: Set<String>
    private let clipboard: any ClipboardClient

    init(entry: CatalogEntry, clipboard: any ClipboardClient) {
        self.entry = entry
        self.clipboard = clipboard
        values = Dictionary(uniqueKeysWithValues: entry.properties.map { ($0.id, $0.control.initialValue) })
        enabled = entry.initialValues.ids
        selectedID = entry.properties.first(where: \.initiallyOn)?.id ?? entry.properties.first?.id
    }

    var selected: PropertySpec? {
        entry.properties.first { $0.id == selectedID }
    }

    func isOn(_ id: String) -> Bool {
        enabled.contains(id)
    }

    func setOn(_ id: String, _ on: Bool) {
        guard entry.properties.first(where: { $0.id == id })?.isRequired != true else { return }
        if on { enabled.insert(id) } else { enabled.remove(id) }
    }

    func value(_ id: String) -> PropertyValue? {
        values[id]
    }

    /// 値を変える。OFF なら ON にする
    func setValue(_ id: String, _ value: PropertyValue) {
        values[id] = value
        enabled.insert(id)
    }

    func reset() {
        values = Dictionary(uniqueKeysWithValues: entry.properties.map { ($0.id, $0.control.initialValue) })
        enabled = entry.initialValues.ids
        isComparing = false
    }

    /// プレビューに渡す値（ON のものだけ）
    var current: PropertyValues {
        PropertyValues(values.filter { enabled.contains($0.key) })
    }

    /// 比べるときの 2 つ（選んでいるプロパティを付けない／付けた。ほかは同じ）
    var comparison: (without: PropertyValues, with: PropertyValues)? {
        guard isComparing, let id = selectedID else { return nil }
        var without = current
        var with = current
        without[id] = nil
        with[id] = values[id]
        return (without, with)
    }

    /// チップに出す今の値（OFF なら "OFF"）
    func valueLabel(_ id: String) -> String {
        guard let spec = entry.properties.first(where: { $0.id == id }), enabled.contains(id), let value = values[id]
        else { return "OFF" }
        if case .text(let s) = value { return s }
        return spec.control.code(for: value)
    }

    /// 最初の値から変えたプロパティ
    var changedIDs: Set<String> {
        let initial = entry.initialValues
        let now = current
        return Set(entry.properties.map(\.id).filter { initial[$0] != now[$0] })
    }

    var codeLines: [CodeLine] {
        CodeGenerator.lines(
            template: entry.code, properties: entry.properties, values: current, changed: changedIDs)
    }

    /// 選んでいるプロパティを書いた行。なければ呼び出しの行
    var selectedLine: CodeLine? {
        let lines = codeLines
        if let id = selectedID, let line = lines.first(where: { $0.propertyIDs.contains(id) }) { return line }
        return lines.first { $0.text.trimmingCharacters(in: .whitespaces).hasPrefix(entry.code.call) }
    }

    var codeText: String {
        codeLines.map(\.text).joined(separator: "\n")
    }

    func copyCode() {
        clipboard.copy(codeText)
        didCopy = true
    }
}
```

- [ ] **Step 4: 整形の点検とテストを実行する**

Run: `xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests && echo LINT-OK`
Expected: `LINT-OK`

テストを実行。
Expected: `** TEST SUCCEEDED **`。`DetailViewModelTests` の 9 件が passed

- [ ] **Step 5: コミット**

```bash
git add swiftui/WidgetLab/Features/Detail swiftui/WidgetLabTests/Features/Detail
git commit -m "feat: 詳細の ViewModel（値・比べる・コード・コピー）を足す

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 7: 3 画面と遷移、UI テスト

画面の形は Flutter 版の ADR-0004 と同じ（ホーム → トピック → 詳細。詳細は上にプレビューとコードの 1 行、チップの列、下半分に編集パネル。比べるは左に「付けない」、右に「付けた」を出して仕切りをドラッグ）。Phase 1 では `.card` の収録だけを扱う（`.full`・`.behavior` の表示は Phase 2・3）。

**Files:**
- Create: `swiftui/WidgetLab/Features/Catalog/UI/HomeScreen.swift`、`swiftui/WidgetLab/Features/Catalog/UI/TopicScreen.swift`、`swiftui/WidgetLab/Features/Detail/UI/DetailScreen.swift`、`swiftui/WidgetLab/Features/Detail/UI/PreviewArea.swift`、`swiftui/WidgetLab/Features/Detail/UI/PropertyChips.swift`、`swiftui/WidgetLab/Features/Detail/UI/EditorPanel.swift`、`swiftui/WidgetLab/Features/Detail/UI/CodeSheet.swift`
- Modify（全体を置き換え）: `swiftui/WidgetLab/App/WidgetLabApp.swift`、`swiftui/WidgetLabUITests/LaunchUITests.swift`

**Interfaces:**
- Consumes: `CatalogViewModel`・`DetailViewModel`・`BundledCatalogRepository`・`SystemClipboard`・`CatalogEntry`・`Palette`
- Produces: `HomeScreen(viewModel:onTopicTapped:onEntryTapped:)`、`TopicScreen(topic:entries:onEntryTapped:)`、`EntryRow(entry:)`、`DetailScreen(viewModel:)`、`RootView(repository:clipboard:)`、`enum Route: Hashable { case topic(Topic), entry(String) }`
- アクセシビリティの識別子（UI テストが使う）: `topic-<slug>`・`entry-<id>`・`code-strip`・`copy`・`compare`・`chip-<id>`・`editor-on`

- [ ] **Step 1: UI テストを書き換える**

`swiftui/WidgetLabUITests/LaunchUITests.swift`（全体を置き換え）:

```swift
import XCTest

final class LaunchUITests: XCTestCase {
    @MainActor
    func testSearchOpenDetailAndCopyCode() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["Widget Lab"].waitForExistence(timeout: 5))
        let search = app.searchFields.firstMatch
        search.tap()
        search.typeText("pad")
        app.buttons["entry-padding"].tap()

        XCTAssertTrue(app.navigationBars[".padding"].waitForExistence(timeout: 5))
        app.buttons["code-strip"].tap()
        app.buttons["copy"].tap()
        XCTAssertTrue(app.buttons["コピーしました"].waitForExistence(timeout: 5))
    }
}
```

- [ ] **Step 2: テストが落ちることを確かめる**

テストを実行（`-only-testing:WidgetLabUITests` を足してよい）。
Expected: `testSearchOpenDetailAndCopyCode` が failed（仮のアプリには ナビゲーションバー `Widget Lab` がない）

- [ ] **Step 3: ホームとトピック画面を書く**

`swiftui/WidgetLab/Features/Catalog/UI/HomeScreen.swift`:

```swift
import SwiftUI

/// ホーム。大分類ごとのトピックの行と、検索
struct HomeScreen: View {
    @Bindable var viewModel: CatalogViewModel
    let onTopicTapped: (Topic) -> Void
    let onEntryTapped: (String) -> Void

    var body: some View {
        List {
            if viewModel.query.trimmingCharacters(in: .whitespaces).isEmpty {
                ForEach(viewModel.sections) { section in
                    Section(section.category.rawValue) {
                        ForEach(section.topics) { summary in
                            Button {
                                onTopicTapped(summary.topic)
                            } label: {
                                TopicRow(summary: summary)
                            }
                            .accessibilityIdentifier("topic-\(summary.topic.rawValue)")
                        }
                    }
                }
            } else if viewModel.results.isEmpty {
                ContentUnavailableView.search(text: viewModel.query)
            } else {
                ForEach(viewModel.results) { entry in
                    Button {
                        onEntryTapped(entry.id)
                    } label: {
                        EntryRow(entry: entry)
                    }
                    .accessibilityIdentifier("entry-\(entry.id)")
                }
            }
        }
        .navigationTitle("Widget Lab")
        .searchable(text: $viewModel.query, prompt: "名前で探す")
    }
}

private struct TopicRow: View {
    let summary: TopicSummary

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(summary.topic.title)
                    .foregroundStyle(.primary)
                Text(summary.sampleNames.joined(separator: "・"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(summary.count)")
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .contentShape(.rect)
    }
}
```

`swiftui/WidgetLab/Features/Catalog/UI/TopicScreen.swift`:

```swift
import SwiftUI

/// トピック画面。収録したものの行（見本つき）
struct TopicScreen: View {
    let topic: Topic
    let entries: [CatalogEntry]
    let onEntryTapped: (String) -> Void

    var body: some View {
        List(entries) { entry in
            Button {
                onEntryTapped(entry.id)
            } label: {
                EntryRow(entry: entry)
            }
            .accessibilityIdentifier("entry-\(entry.id)")
        }
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// 収録 1 件の行。最初の値で組み立てて縮めた見本・名前・種類の印
struct EntryRow: View {
    let entry: CatalogEntry

    var body: some View {
        HStack(spacing: 12) {
            entry.build(entry.initialValues)
                .frame(width: 200, height: 120)
                .scaleEffect(0.4)
                .frame(width: 80, height: 48)
                .clipped()
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.displayName)
                    .foregroundStyle(.primary)
                Text(entry.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            KindBadge(kind: entry.kind)
        }
        .contentShape(.rect)
    }
}

private struct KindBadge: View {
    let kind: EntryKind

    var body: some View {
        Text(label)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.quaternary, in: .capsule)
    }

    private var label: String {
        switch kind {
        case .view: "View"
        case .modifier: "modifier"
        case .propertyWrapper: "@"
        case .gesture: "ジェスチャー"
        }
    }
}
```

- [ ] **Step 4: 詳細画面を書く**

`swiftui/WidgetLab/Features/Detail/UI/DetailScreen.swift`:

```swift
import SwiftUI

/// 詳細。上にプレビューとコードの 1 行、その下にチップの列、下半分に編集パネル
struct DetailScreen: View {
    @Bindable var viewModel: DetailViewModel
    @State private var showsInfo = false
    @State private var showsCode = false

    var body: some View {
        VStack(spacing: 0) {
            PreviewArea(viewModel: viewModel)
                .frame(maxWidth: .infinity)
                .frame(height: 280)
            CodeStrip(line: viewModel.selectedLine) { showsCode = true }
            PropertyChips(viewModel: viewModel)
            Divider()
            EditorPanel(viewModel: viewModel)
        }
        .navigationTitle(viewModel.entry.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("初期状態に戻す", systemImage: "arrow.counterclockwise") { viewModel.reset() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("説明", systemImage: "info.circle") { showsInfo = true }
            }
        }
        .sheet(isPresented: $showsInfo) {
            InfoSheet(entry: viewModel.entry)
        }
        .sheet(isPresented: $showsCode) {
            CodeSheet(viewModel: viewModel)
        }
    }
}

/// 選んでいるプロパティのコードの 1 行。押すと全文のシートを開く
private struct CodeStrip: View {
    let line: CodeLine?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(line?.text.trimmingCharacters(in: .whitespaces) ?? "")
                    .font(.system(.footnote, design: .monospaced))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.up")
                    .font(.footnote)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.fill.tertiary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("コードの全文を開く")
        .accessibilityIdentifier("code-strip")
    }
}

/// ⓘ から開く説明
private struct InfoSheet: View {
    let entry: CatalogEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(entry.summary)
                    Link("公式ドキュメントを開く", destination: entry.docURL)
                }
                Section("プロパティ") {
                    ForEach(entry.properties) { spec in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(spec.displayName).font(.system(.body, design: .monospaced))
                            Text(spec.summary).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(entry.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}
```

`swiftui/WidgetLab/Features/Detail/UI/PreviewArea.swift`:

```swift
import SwiftUI

/// プレビュー。比べるときは、左に「付けない」、右に「付けた」を出し、仕切りをドラッグして見比べる
struct PreviewArea: View {
    let viewModel: DetailViewModel
    /// 仕切りの位置（左端 0 〜 右端 1）
    @State private var split: CGFloat = 0.5

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let pair = viewModel.comparison {
                compare(pair.without, pair.with)
            } else {
                preview(viewModel.current)
            }
            if viewModel.selected != nil {
                Toggle("比べる", isOn: Binding(get: { viewModel.isComparing }, set: { viewModel.isComparing = $0 }))
                    .toggleStyle(.button)
                    .padding(12)
                    .accessibilityIdentifier("compare")
            }
        }
        .background(.background.secondary)
        .clipped()
    }

    private func preview(_ values: PropertyValues) -> some View {
        viewModel.entry.build(values)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func compare(_ without: PropertyValues, _ with: PropertyValues) -> some View {
        GeometryReader { geometry in
            let x = geometry.size.width * split
            ZStack(alignment: .topLeading) {
                preview(with)
                preview(without)
                    .background(.background.secondary)
                    .mask(alignment: .leading) { Rectangle().frame(width: x) }
                Rectangle()
                    .fill(.tint)
                    .frame(width: 2)
                    .offset(x: x - 1)
                HStack {
                    Text("付けない")
                    Spacer()
                    Text("付けた")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(8)
            }
            .contentShape(.rect)
            .gesture(
                DragGesture(minimumDistance: 0).onChanged { value in
                    split = min(max(value.location.x / geometry.size.width, 0), 1)
                }
            )
            .accessibilityElement(children: .contain)
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: split = min(split + 0.1, 1)
                case .decrement: split = max(split - 0.1, 0)
                @unknown default: break
                }
            }
        }
    }
}
```

`swiftui/WidgetLab/Features/Detail/UI/PropertyChips.swift`:

```swift
import SwiftUI

/// プロパティのチップの列（名前と今の値）。押すと選ぶ
struct PropertyChips: View {
    @Bindable var viewModel: DetailViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.entry.properties) { spec in
                    Button {
                        viewModel.selectedID = spec.id
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(spec.displayName)
                                .font(.system(.caption, design: .monospaced))
                            Text(viewModel.valueLabel(spec.id))
                                .font(.caption2)
                                .foregroundStyle(viewModel.isOn(spec.id) ? .primary : .secondary)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(minHeight: 44)
                        .background(
                            viewModel.selectedID == spec.id
                                ? AnyShapeStyle(.tint.opacity(0.2)) : AnyShapeStyle(.fill.tertiary),
                            in: .rect(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(viewModel.selectedID == spec.id ? .isSelected : [])
                    .accessibilityIdentifier("chip-\(spec.id)")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
```

`swiftui/WidgetLab/Features/Detail/UI/EditorPanel.swift`:

```swift
import SwiftUI

/// 選んでいるプロパティを大きく触る編集パネル。付ける／付けないのスイッチと、操作部品
struct EditorPanel: View {
    @Bindable var viewModel: DetailViewModel

    var body: some View {
        if let spec = viewModel.selected {
            Form {
                Section {
                    Toggle(
                        "付ける",
                        isOn: Binding(get: { viewModel.isOn(spec.id) }, set: { viewModel.setOn(spec.id, $0) })
                    )
                    .disabled(spec.isRequired)
                    .accessibilityIdentifier("editor-on")
                    control(spec)
                } header: {
                    Text(spec.displayName).font(.system(.body, design: .monospaced))
                } footer: {
                    Text(spec.summary)
                }
            }
        } else {
            ContentUnavailableView("操作できるプロパティはありません", systemImage: "slider.horizontal.3")
        }
    }

    @ViewBuilder
    private func control(_ spec: PropertySpec) -> some View {
        switch spec.control {
        case .slider(let range, let step, _):
            let value = Binding<Double>(
                get: { if case .number(let n) = viewModel.value(spec.id) { n } else { range.lowerBound } },
                set: { viewModel.setValue(spec.id, .number($0)) })
            LabeledContent {
                Slider(value: value, in: range, step: step)
                    .frame(maxWidth: 220)
            } label: {
                Text(spec.control.code(for: .number(value.wrappedValue))).monospacedDigit()
            }
        case .toggle:
            Toggle(
                "値",
                isOn: Binding(
                    get: { if case .flag(let b) = viewModel.value(spec.id) { b } else { false } },
                    set: { viewModel.setValue(spec.id, .flag($0)) }))
        case .choice(let choices, _):
            Picker(
                "値",
                selection: Binding(
                    get: { if case .choice(let i) = viewModel.value(spec.id) { i } else { 0 } },
                    set: { viewModel.setValue(spec.id, .choice($0)) })
            ) {
                ForEach(choices.indices, id: \.self) { i in
                    Text(choices[i].label).tag(i)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        case .color:
            ColorChoices(
                selected: { if case .color(let i) = viewModel.value(spec.id) { i } else { nil } }(),
                onSelect: { viewModel.setValue(spec.id, .color($0)) })
        case .text:
            TextField(
                "文字",
                text: Binding(
                    get: { if case .text(let s) = viewModel.value(spec.id) { s } else { "" } },
                    set: { viewModel.setValue(spec.id, .text($0)) }))
        case .fixed(let code):
            Text(code).font(.system(.body, design: .monospaced))
        }
    }
}

/// 色の見本を並べて選ぶ
private struct ColorChoices: View {
    let selected: Int?
    let onSelect: (Int) -> Void

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
            ForEach(Palette.colors.indices, id: \.self) { i in
                let entry = Palette.colors[i]
                Button {
                    onSelect(i)
                } label: {
                    Circle()
                        .fill(entry.color)
                        .frame(width: 44, height: 44)
                        .overlay {
                            if selected == i {
                                Image(systemName: "checkmark").foregroundStyle(.white).bold()
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(entry.name)
                .accessibilityAddTraits(selected == i ? .isSelected : [])
            }
        }
        .padding(.vertical, 4)
    }
}
```

`swiftui/WidgetLab/Features/Detail/UI/CodeSheet.swift`:

```swift
import SwiftUI

/// コードの全文。最初の値から変えた行に印を付ける。コピーのボタンを置く
struct CodeSheet: View {
    let viewModel: DetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView([.vertical, .horizontal]) {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(viewModel.codeLines.enumerated()), id: \.offset) { _, line in
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(line.isChanged ? AnyShapeStyle(.tint) : AnyShapeStyle(.clear))
                                .frame(width: 3)
                                .accessibilityHidden(true)
                            Text(line.text)
                                .font(.system(.body, design: .monospaced))
                                .accessibilityLabel(line.isChanged ? "変更あり: \(line.text)" : line.text)
                        }
                    }
                }
                .padding()
                .textSelection(.enabled)
            }
            .navigationTitle("コード")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.didCopy ? "コピーしました" : "コピー") { viewModel.copyCode() }
                        .accessibilityIdentifier("copy")
                }
            }
        }
    }
}
```

- [ ] **Step 5: アプリの入口と遷移を書く**

`swiftui/WidgetLab/App/WidgetLabApp.swift`（全体を置き換え）:

```swift
import SwiftUI

@main
struct WidgetLabApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(repository: BundledCatalogRepository(), clipboard: SystemClipboard())
        }
    }
}

/// 遷移先
enum Route: Hashable {
    case topic(Topic)
    case entry(String)
}

/// 画面を組み立てて遷移をつなぐ。ホームとトピック画面は押されたことを知らせるだけで、詳細はここで組み立てる
struct RootView: View {
    @State private var catalog: CatalogViewModel
    @State private var path: [Route] = []
    private let clipboard: any ClipboardClient

    init(repository: any CatalogRepository, clipboard: any ClipboardClient) {
        _catalog = State(initialValue: CatalogViewModel(repository: repository))
        self.clipboard = clipboard
    }

    var body: some View {
        NavigationStack(path: $path) {
            HomeScreen(
                viewModel: catalog,
                onTopicTapped: { path.append(.topic($0)) },
                onEntryTapped: { path.append(.entry($0)) }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .topic(let topic):
                    TopicScreen(
                        topic: topic, entries: catalog.entries(in: topic), onEntryTapped: { path.append(.entry($0)) })
                case .entry(let id):
                    if let entry = catalog.entry(id: id) {
                        DetailHost(entry: entry, clipboard: clipboard)
                    }
                }
            }
        }
    }
}

/// 詳細の ViewModel を、画面が出ているあいだ持つ
private struct DetailHost: View {
    @State private var viewModel: DetailViewModel

    init(entry: CatalogEntry, clipboard: any ClipboardClient) {
        _viewModel = State(initialValue: DetailViewModel(entry: entry, clipboard: clipboard))
    }

    var body: some View {
        DetailScreen(viewModel: viewModel)
    }
}
```

- [ ] **Step 6: 整形の点検とテストを実行する**

Run: `xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests && echo LINT-OK`
Expected: `LINT-OK`

テストを実行。
Expected: `** TEST SUCCEEDED **`。ユニットテスト 20 件ほどと `LaunchUITests testSearchOpenDetailAndCopyCode` が passed

- [ ] **Step 7: シミュレータで触って確かめる**

Xcode で `WidgetLab.xcodeproj` を開き、iPhone 17（iOS 27.0）で実行する（Xcode を使えない場合は、`xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/WidgetLab.app && xcrun simctl launch booted jp.nimi.widgetLab.swiftui` で起動し、`xcrun simctl io booted screenshot <path>` で画面を撮って確かめる）。次を確かめる:
- ホームに大分類の節（Views・View layout）とトピックの行（件数・代表の名前）が出る
- トピックの行 → トピック画面 → 行 → 詳細、と進める。検索に `pad` → `.padding` → 詳細、とも進める
- 詳細で、チップを押すと編集パネルが変わる。付ける／付けない・スライダー・選択・色・文字でプレビューが変わる
- 「比べる」で左右に分かれ、仕切りをドラッグできる
- コードの 1 行を押すと全文のシートが開き、変えた行に印が付き、コピーで「コピーしました」になる
- ⓘ で説明が開き、公式ドキュメントのリンクがある。初期状態に戻すで最初の値に戻る
- ダークモード（`xcrun simctl ui booted appearance dark`）でも文字が読める

- [ ] **Step 8: コミット**

```bash
git add swiftui/WidgetLab swiftui/WidgetLabUITests
git commit -m "feat: ホーム・トピック・詳細の画面と遷移を足す

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 8: 文書（CLAUDE.md・README・PRD・architecture・ADR）とルートの案内

**Files:**
- Create: `swiftui/CLAUDE.md`、`swiftui/README.md`、`swiftui/docs/PRD.md`、`swiftui/docs/architecture.md`、`swiftui/docs/adr/ADR-0001-project-structure-and-conventions.md`、`swiftui/docs/adr/ADR-0002-data-driven-demos.md`
- Modify: `README.md`（ルート）、`CLAUDE.md`（ルート）

- [ ] **Step 1: swiftui/ の CLAUDE.md と README を書く**

`swiftui/CLAUDE.md`:

````markdown
# Widget Lab SwiftUI

SwiftUI の API リファレンスに載る View・modifier・プロパティラッパー・ジェスチャーの型を、プロパティを付けた／付けないで触って比べられる iPhone のアプリ。要件は docs/PRD.md、構想はリポジトリのルートの ../docs/concept/brief.md（全体の決まりは ../CLAUDE.md）。

## スタック
- Xcode 27.0 / Swift 6（言語モード 6、既定の分離は MainActor）。外部のパッケージは使わない
- 状態: `@Observable` / 遷移: `NavigationStack` / 文言: String Catalog（日本語のみ）/ テスト: Swift Testing（UI テストだけ XCTest）
- 対象: iPhone、iOS 27.0 以上（iPad はスマホと同じ 1 カラム）。オフラインのみ

## コマンド
- コマンドはすべて `swiftui/` で実行する
- 確かめ:
  ```
  xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests \
    && python3 -m unittest discover tools \
    && xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
       -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
       -derivedDataPath build CODE_SIGNING_ALLOWED=NO
  ```
- 整形: `xcrun swift-format format -i -r WidgetLab WidgetLabTests WidgetLabUITests`
- manifest を作り直す: `python3 tools/make_manifest.py`（`--refresh` でリファレンスを取り直す）。生成した `WidgetLab/Catalog/Generated/` はコミットする
- 起動: Xcode で `WidgetLab.xcodeproj` を開いて実行する

## 規約
- 構成と依存の向き: docs/architecture.md
- 決めた理由: docs/adr/
- フォルダはファイルと同期する（Xcode 16 以降の同期グループ）。ファイルを足すときに project.pbxproj を直す必要はない
- 新しい画面は WidgetLab/Features/<機能>/{UI,ViewModel} に置き、WidgetLabTests/Features/<機能>/ にテストを置く
- 収録データは WidgetLab/Catalog/<トピック>/<名前>Entry.swift に置き、Catalog.swift の `all` に並べる。id・種類・トピックは Generated/Manifest.swift に合わせる
- 収録データの型（WidgetLab/Catalog/）は `nonisolated` にする。組み立ての関数だけが `@MainActor`

## 公開について
- リポジトリは public。署名鍵・ストアの認証情報・`.env` などをコミットしない（`.gitignore` で除外済み）
````

`swiftui/README.md`:

```markdown
# Widget Lab SwiftUI

SwiftUI の部品を、プロパティを付けた／付けないで触って比べる iPhone のアプリです。収録するのは、[SwiftUI の API リファレンス](https://developer.apple.com/documentation/swiftui) に載っていて iOS 27.0 で使える View・modifier・プロパティラッパー・ジェスチャーの型です。

- 要件: [docs/PRD.md](docs/PRD.md)
- 構成: [docs/architecture.md](docs/architecture.md)
- 決めたこと: [docs/adr/](docs/adr/)

## 動かし方
1. Xcode 27.0 以上で `WidgetLab.xcodeproj` を開く
2. スキーム `WidgetLab` を選び、iOS 27.0 以上のシミュレータで実行する

テストと manifest の作り直し方は [CLAUDE.md](CLAUDE.md) の「コマンド」にあります。
```

- [ ] **Step 2: PRD と architecture を書く**

`swiftui/docs/PRD.md`:

```markdown
# PRD: Widget Lab SwiftUI（SwiftUI のコンポーネントのカタログアプリ）

> **要約**
> - 結論: SwiftUI の API リファレンスのうち、iOS 27.0 で使える View・modifier・プロパティラッパー・ジェスチャーの型を全部収録し、プロパティを切り替えて触り、付けた／付けないを見比べられる iPhone のアプリを作る
> - 影響: リポジトリ `widget-lab` の `swiftui/` に置く。Flutter 版（`flutter/`）とは別のアプリ。収益は狙わない
> - お願い: なし（2026-10-31 オーナーが spec を承認）

## 概要

SwiftUI から離れたあとでも、部品の挙動を数十秒で思い出せる手元の辞書アプリ。Flutter 版と同じ使い方で、公式の要約を載せ、プロパティを実際に変えて触り、付けた場合と付けない場合を見比べられるようにする。

構想は Flutter 版と共通（../../docs/concept/brief.md）。3 つのアプリに分けた理由はルートの ../../docs/adr/ADR-0001-three-native-apps-in-one-repo.md、この PRD の元にした設計は superpowers/specs/2026-10-31-swiftui-app-design.md。

## 解くべき問い・課題

- 問い: SwiftUI で画面を作る人は、View や modifier を付けた／付けないで切り替えて実際に触れれば、ドキュメントを読むより早く挙動を思い出せるか
- 誰が・どんな状況で・何に困っているかは、Flutter 版の PRD（../../flutter/docs/PRD.md）と同じ。SwiftUI では、見た目の多くを modifier で変え、modifier の順番で結果が変わるので、触って確かめる価値が特に大きい

## ユーザーストーリー

- SwiftUI に久しぶりに戻った開発者として、View の modifier を変えてその場で見た目の変化を確かめたい。なぜならドキュメントを読むより早く思い出せるから。
- SwiftUI に久しぶりに戻った開発者として、ある modifier を付けた場合と付けない場合を見比べたい。なぜなら何が変わるのかを見落とさずに分かるから。
- SwiftUI に久しぶりに戻った開発者として、`@State` や `@Binding` のような見た目を持たないものの働きを目で確かめたい。なぜなら説明を読むだけでは、いつ body が評価し直されるかが分かりにくいから。
- SwiftUI に久しぶりに戻った開発者として、今の設定を再現する Swift のコードをコピーしたい。なぜならそのまま自分のコードで試せるから。
- SwiftUI に久しぶりに戻った開発者として、名前で探したい。なぜなら名前を覚えているときは一覧をたどるより早いから。

## 機能要件

### 収録の範囲
- SwiftUI の API リファレンスの 6 つの大分類（Views・View layout・App structure・Data and storage・Event handling・Accessibility）のトピックに載る記号のうち、iOS で使え、非推奨でなく、導入の版が 27.0 以下のもの
- 種類は 4 つ: View（`View` に準拠する struct）、modifier（`View` の拡張のメソッド）、プロパティラッパー（`DynamicProperty` に準拠する型）、ジェスチャーの型（`Gesture` に準拠する型）
- リファレンスの同じ節に View がある modifier は、その View のプロパティにする。View のいない節の modifier は 1 件ずつ収録する。オーバーロードは名前でまとめる
- 型の都合の型（`AnyView`・`ModifiedContent`・`TupleView` など）と、スタイル・設定の型は収録しない（スタイルの型はプロパティの選択肢にする）
- 数え方は tools/make_manifest.py が実装し、WidgetLab/Catalog/Generated/Manifest.swift に一覧を書き出す。2026-10-31 時点で 41 トピック・458 件

### 一覧（大分類 → トピック）
- ホームは大分類を節にし、その下にトピックの行（件数・代表の名前）を並べる
- トピック画面は、収録したものの行（縮めた見本・名前・種類の印）を並べる

### 検索
- 名前の部分一致で絞り込める（大文字・小文字を区別しない）。結果は名前の ABC 順

### 詳細: 説明
- 公式 API ドキュメントをもとにした短い要約（日本語）と、公式ページへのリンクを表示する
- 操作できる各プロパティに、一言の説明（日本語）を付ける

### 詳細: プレイグラウンド
- プロパティのチップの列（名前と今の値）から 1 つを選び、編集パネルで大きく触る
- プロパティごとに付ける／付けないを切り替えられる。付けないは「その modifier をかけない／その引数を省く」状態
- 付けるときは値を変えられる。操作部品はスライダー・スイッチ・選択・色・文字・固定の 6 種
- 省くとコードが成り立たない引数（Text の文字など）は、いつも付けた状態にする
- 複数のプロパティを同時に変えられ、プレビューにその場で反映される
- 初期状態に戻すボタンがある

### 詳細: 比べる
- 選んでいるプロパティについて、付けない状態を左、付けた状態を右に出し、仕切りをドラッグして見比べる
- それ以外のプロパティの設定は、両方に同じく反映される

### 見た目を持たないものの可視化（Phase 2）
- body が評価された回数、値の伝わり方、イベントのログ、VoiceOver の読み上げ文などを画面に出し、使った場合と使わない場合を比べられる

### コードの表示とコピー
- 今の設定を再現する Swift のコードを表示する。最初の値から変えた行に印を付ける
- コードをクリップボードにコピーできる

### デモの組み立て
- 各収録のデモは、プロパティの定義のデータと組み立ての関数から作る（ADR-0002）

## 非機能要件

- パフォーマンス: プロパティを変えたら、プレビューへの反映は体感で遅れない（目安 100ms 以内）
- オフライン: 全機能がオフラインで使える（公式ページへのリンクを開くときだけ通信する）
- アクセシビリティ: アプリ自体の UI は WCAG 2.2 AA を目安にする（コントラスト・タップ領域 44pt・VoiceOver のラベル・Dynamic Type）。収録する部品の見た目は SwiftUI のまま
- セキュリティ: 個人のデータ・アカウント・外部の API は扱わない。リポジトリは public のため、署名鍵・ストアの認証情報・`.env` などをコミットしない

## 受け入れ条件

- [ ] Manifest.swift の全件が、どれかのトピックの下に表示される（Phase 3 の終わり）
- [ ] 名前の一部（例: `pad`）を入れると、`.padding` など名前に含むものだけが残る
- [ ] 詳細で、プロパティを付けないにすると、プレビューがその modifier をかけない見た目になる
- [ ] 詳細で、スライダーを動かすとプレビューがその値で描き直される
- [ ] 詳細で、2 つ以上のプロパティを変えると、両方がプレビューに反映される
- [ ] 「比べる」を押すと、付けない状態と付けた状態が左右に並び、仕切りをドラッグできる
- [ ] 初期状態に戻すと、全プロパティが最初の値になる
- [ ] `@State` の詳細で、body が評価された回数が画面に表示される（Phase 2）
- [ ] コードの表示に、今の設定を再現する Swift のコードが出る
- [ ] コピーを押すと、表示中のコードがクリップボードに入る
- [ ] 機内モードでも、一覧・検索・詳細・比べる・コードの表示が使える
- [ ] 公式ページへのリンクを押すと、該当の API ドキュメントがブラウザで開く
- [ ] iOS 27.0 の iPhone（シミュレータを含む）で起動し、上の条件を満たす

## 確かめ方

- 課題が解けたと何で分かるか: 本人が 1 ヶ月使い、SwiftUI の挙動を確かめるために公式ドキュメントや試しのプロジェクトを開いた回数が減ったかを振り返る
- 作る前に小さく試す方法: なし（Phase 1 の数件を作った時点で本人が触って確かめる）

## 対象外スコープ

- サードパーティのライブラリの部品
- 自分のコンポーネントを登録する機能
- アカウント・同期・お気に入り
- 目的からの逆引き
- 説明文の独自執筆（公式 API ドキュメントの要約とリンクにとどめる）
- 英語など日本語以外の言語
- iPad 専用の画面・macOS・visionOS・watchOS
- modifier の順番を入れ替える操作（v2 の候補）
- 収益化（課金・広告）

## 未検証のイシュー

- 「どのくらい困っているか」（頻度）と、自分以外にも役立つか（Flutter 版と同じ）
- 458 件を収録しきれるか（Flutter 版の約 2 倍）
- iOS の版が上がるたびの保守の量（API の追加・非推奨化）。最低の版を上げたら manifest を作り直す
- 見た目を持たないもの（アクセシビリティ・イベント系）の見せ方
- ストア審査で、参照用アプリとして Apple のガイドライン 4.2（最低限の機能）に触れないか

## 技術的考慮事項

- スタック: Swift 6 / SwiftUI。外部のパッケージは使わない
- 対象: iPhone、iOS 27.0 以上
- bundle ID: `jp.nimi.widgetLab.swiftui`。表示名: `Widget Lab SwiftUI`
- アプリ自体の UI: iOS 標準の見た目（HIG）。標準の `List`・`NavigationStack`・`.searchable` で作る
- ダークモード: 対応する（標準の部品と意味の色を使うので、追加の手間がほぼない）
- 言語: 日本語のみ。API の名前は英語のまま
- 構成と依存の向き: architecture.md。決めた理由: adr/

## フェーズ計画

| Phase | 内容 |
|-------|------|
| Phase 1 | プロジェクトの土台、manifest を作る道具、デモの仕組み、3 画面を少数の収録（`Button`・`Text`・`VStack`・`padding`）で通す |
| Phase 2 | 見た目を持たないものの仕組み（`DemoRecorder`・`BodyCounter`・イベントのログ）を、`State`・`Binding`・`TapGesture` で通す |
| Phase 3 | 全トピックを収録する（トピックごと、または大分類ごとに PR を分ける） |
| Phase 4 | ストア公開の準備（アイコン・スクリーンショット・審査）。3 アプリの公開の順番は、アプリをまたぐ話として別に決める |
```

`swiftui/docs/architecture.md`:

````markdown
# アーキテクチャ

## 構成

```
WidgetLab.xcodeproj         Xcode のプロジェクト（フォルダと同期するグループ）
WidgetLab/
  App/WidgetLabApp.swift    アプリの入口。RootView が画面を組み立てて遷移をつなぐ（Route）
  Localizable.xcstrings     UI の文言（日本語のみ）
  Core/
    Data/                   CatalogRepository（収録データを読む窓口）
    System/                 OS の機能の包み（ClipboardClient）
  Catalog/
    Model/                  収録データの型（CatalogEntry・PropertySpec・PropertyControl・PropertyValues・CodeTemplate・CodeGenerator など）
    Generated/              tools/make_manifest.py の生成物（Topic.swift・Manifest.swift）。手で直さない
    Catalog.swift           全件の一覧（Catalog.all）
    <トピック>/             1 件 = 1 ファイルの収録データ（<名前>Entry.swift）
  Features/
    Catalog/{UI,ViewModel}  ホーム（大分類ごとのトピックと検索）とトピック画面
    Detail/{UI,ViewModel}   詳細（プレビュー・コードの 1 行・チップ・編集パネル・比べる・説明とコードのシート）
WidgetLabTests/             Swift Testing。WidgetLab と同じ形（Catalog/・Features/<機能>/）と、fake を置く Support/
WidgetLabUITests/           XCTest の UI テスト（起動 → 検索 → 詳細 → コピーの 1 本）
tools/                      manifest を作る道具（Python 3.9 以上、標準ライブラリだけ）とそのテスト
```

## 依存の向き
UI → ViewModel → Repository。逆向きと、機能をまたぐ直接の参照は禁止（共通のものは Core/ に置く）。

- `Catalog/` は収録データで、ViewModel は `Core/Data/CatalogRepository` を通して読む。UI は収録データの型（`CatalogEntry` の `build` など）を、プレビューを組み立てるためにだけ使う
- `Catalog/` から `Features/` と `Core/` は参照しない
- 収録データの型は UI の状態を持たないので `nonisolated` にする（プロジェクトの既定の分離は MainActor）。組み立ての関数 `build` だけが `@MainActor`

## 状態と依存の受け渡し
- ViewModel は `@Observable` のクラス（既定の分離で MainActor）。画面が `@State` で持つ
- 詳細のプロパティの値・選んでいるプロパティ・比べるかどうかは `DetailViewModel` に持つ（プレビュー・チップ・編集パネル・コードの 4 か所で共有するため）
- 比べるの仕切りの位置、シートを出しているかなど、画面の中だけの一時的な状態は View の `@State` に持つ
- Repository とクリップボードはプロトコルで受け取り、テストでは fake を渡す（WidgetLabTests/Support/Fakes.swift）

## 遷移
`NavigationStack(path:)` と値つきの `navigationDestination(for: Route.self)`。ホーム → トピック → 詳細、またはホームの検索の結果 → 詳細。
ホーム（`HomeScreen`）とトピック画面（`TopicScreen`）は行を押したことを `onTopicTapped` / `onEntryTapped` で知らせるだけで、詳細画面を直接参照しない。`DetailScreen` を組み立てるのは `RootView`。

## コードの生成
`CodeGenerator.lines` が、`CodeTemplate`（呼び出しの名前・いつも書く引数・末尾のクロージャ・前後の行）に、付けた引数と modifier を定義の順で埋めて、行ごと（`CodeLine`）に返す。最初の値から変えたプロパティの行には `isChanged` が付く。

決めた理由は docs/adr/ の ADR-0001（構成と規約）と ADR-0002（収録データから組み立てる）。
````

- [ ] **Step 3: ADR を書く**

`swiftui/docs/adr/ADR-0001-project-structure-and-conventions.md`:

```markdown
# ADR-0001: SwiftUI 版の構成と規約

> **要約**
> - 結論: Xcode のプロジェクトを手で書いた project.pbxproj（フォルダと同期するグループ）で作り、外部のパッケージなしの Swift 6・`@Observable`・`NavigationStack`・Swift Testing で組む。層は UI → ViewModel → Repository
> - 影響: `swiftui/` のすべて
> - お願い: なし（2026-10-31 オーナーが spec を承認）

## ステータス
承認済み（2026-10-31）

## 背景
ルートの ADR-0001 で、SwiftUI 版を別のネイティブアプリとして `swiftui/` に作ると決めた。Flutter 版（`flutter/docs/adr/ADR-0001-project-structure-and-conventions.md`）と同じく、構成・状態・遷移・テストの決まりを最初に決めておく。

## 決定
- Xcode のプロジェクトは `.xcodeproj` をそのままコミットする。フォルダと同期するグループ（`PBXFileSystemSynchronizedRootGroup`）を使い、ファイルを足しても project.pbxproj が変わらないようにする。スキームは共有（xcshareddata）にする
- Swift 6 の言語モード。既定の分離は MainActor（`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`）。UI の状態を持たない収録データの型は `nonisolated` にする
- 外部のパッケージは使わない
- 状態は `@Observable` の ViewModel。遷移は `NavigationStack(path:)` と値つきの `navigationDestination`
- 層は UI → ViewModel → Repository。機能（`Features/<機能>/{UI,ViewModel}`）をまたぐ参照はしない。共通のものは `Core/`
- 文言は String Catalog（日本語のみ。開発の言語を ja にする）
- テストは Swift Testing。UI テストだけ XCTest（Swift Testing は UI テストに対応していない）
- 整形と点検は Xcode に付いている swift-format（`.swift-format`、1 行 120 文字）
- 対象は iPhone の iOS 27.0 以上。iPad はスマホと同じ 1 カラム

## 選ばなかった案
| 案 | 選ばなかった理由 |
|---|---|
| XcodeGen・Tuist でプロジェクトを生成する | 同期するグループで project.pbxproj の競合の悩みはほぼなくなった。道具を 1 つ増やして保守する利点が小さい |
| ロジックをローカルの Swift Package に分ける | 1 アプリだけなので、パッケージの境界の手間に見合わない。テストは xcodebuild で十分に回せる |
| TCA など状態管理のライブラリ | 画面は 3 枚で、`@Observable` で足りる。外部の依存を持たない方針 |
| 既定の分離を nonisolated のままにする | ほとんどの型が UI から使われるので、MainActor を既定にしたほうが注釈が少なく済む |

## 結果
- ファイルを足すだけでビルドに入る。project.pbxproj を直すのはターゲットや設定を変えるときだけ
- 収録データの型に `nonisolated` を付け忘れると、テストの引数（`@Test(arguments:)`）から読めずにビルドが落ちる。CLAUDE.md の規約に書いておく
```

`swiftui/docs/adr/ADR-0002-data-driven-demos.md`:

```markdown
# ADR-0002: デモを収録データ（プロパティの定義と組み立ての関数）から作る

> **要約**
> - 結論: 収録 1 件を `CatalogEntry`（プロパティの定義の一覧・コードの形・組み立ての関数）で表し、操作パネル・プレビュー・比べる・コードを全部そこから作る
> - 影響: 収録するすべてのもの（`WidgetLab/Catalog/`）と、詳細画面のすべて
> - お願い: なし（2026-10-31 オーナーが spec を承認）

## ステータス
承認済み（2026-10-31）

## 背景
SwiftUI 版は、リファレンスから数えた 458 件を収録する（Flutter 版の約 2 倍）。1 件を足す手間が大きいと収録しきれない。Flutter 版では同じ問題を、プロパティの定義のデータから組み立てる仕組みで解いた（`flutter/docs/adr/ADR-0002-data-driven-widget-demos.md`）。

## 決定
- 収録データの型は `CatalogEntry`・`PropertySpec`・`PropertyControl`・`PropertyValues`・`CodeTemplate`（WidgetLab/Catalog/Model/）
- `PropertySpec` は置き場所（イニシャライザの引数か modifier か）と操作部品を持つ。`PropertyControl` は操作部品・値の型・コードの書き方を 1 つに持ち、種類はスライダー・スイッチ・選択・色・文字・固定の 6 種に絞る
- 省くとコードが成り立たない引数は `required` にし、いつも付けた状態にする
- 1 件 = 1 ファイル（`Catalog/<トピック>/<名前>Entry.swift`）。組み立ての関数だけは 1 件ずつ手で書く。付けない modifier は `apply` でかけず、付けない引数はその引数を省いたイニシャライザに分ける
- コードは `CodeGenerator` が `CodeTemplate` に付けたプロパティを定義の順で埋めて作る
- 全件の組み立て（全部付けない・全部付けた・選択肢ごと）と、manifest との突き合わせをテストで行う

## 選ばなかった案
| 案 | 選ばなかった理由 |
|---|---|
| 1 件ずつ手でデモの画面を書く（操作パネルとコードも 1 件ずつ） | 458 件で手間と見た目のばらつきが大きく、収録しきれない。比べるとコードの仕組みも 1 件ずつ書くことになる |
| Swift のマクロで、デモの関数から収録データを生成する | マクロのパッケージとビルドの仕組みが重く、Swift の版が変わると壊れやすい。操作部品・代表の値・日本語の説明は結局手で決める |

## 結果
- 1 件を足すのは、1 ファイルにプロパティの定義・コードの形・組み立ての関数を書き、`Catalog.all` に並べるだけになる。操作パネル・比べる・コード・テストは共通で動く
- 引き受けること: 組み立ての関数とプロパティの定義（選択肢の並び）を手で合わせる必要がある。選択肢は `PropertyValues.pick(_:from:)` に同じ並びの配列を渡して取り出す
- 見直すきっかけ: 型に載らないものが多く出てきたとき（複数の子の並べ替えが要るものなど）、`.full`・`.behavior` の収録で詳細画面の形が合わなくなったとき
```

- [ ] **Step 4: ルートの README と CLAUDE.md を直す**

`README.md`（ルート）の表の SwiftUI 版の行を、次に置き換える:
```
| SwiftUI 版 | [swiftui/](swiftui/README.md) | iOS | 作成中 |
```

`CLAUDE.md`（ルート）の次の行を:
```
- `swiftui/`: SwiftUI 版（iOS）。準備中
```
次に置き換える:
```
- `swiftui/`: SwiftUI 版（iOS）。作成中。作業の前に swiftui/CLAUDE.md を読む
```

- [ ] **Step 5: リンクが切れていないか確かめる**

Run（リポジトリのルートで）:
```bash
python3 - <<'EOF'
import os, re, subprocess
files = subprocess.run(["git", "-c", "core.quotepath=off", "ls-files", "*.md"], capture_output=True, text=True).stdout.split()
files += [f for f in ["swiftui/CLAUDE.md", "swiftui/README.md", "swiftui/docs/PRD.md", "swiftui/docs/architecture.md",
          "swiftui/docs/adr/ADR-0001-project-structure-and-conventions.md", "swiftui/docs/adr/ADR-0002-data-driven-demos.md"] if f not in files]
bad = []
for f in files:
    for link in re.findall(r"\]\(([^)#]+)", open(f, encoding="utf-8").read()):
        if link.startswith("http"):
            continue
        if not os.path.exists(os.path.normpath(os.path.join(os.path.dirname(f), link))):
            bad.append((f, link))
print(bad or "LINKS-OK")
EOF
```
Expected: `LINKS-OK`

- [ ] **Step 6: 全部の確かめを実行する**

Run（`swiftui/` で。`swiftui/CLAUDE.md` の「確かめ」と同じ）:
```bash
xcrun swift-format lint --strict -r WidgetLab WidgetLabTests WidgetLabUITests \
  && python3 -m unittest discover tools \
  && xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab \
     -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
     -derivedDataPath build CODE_SIGNING_ALLOWED=NO 2>&1 | tail -5
```
Expected: unittest が `OK`、最後に `** TEST SUCCEEDED **`

- [ ] **Step 7: コミット**

```bash
git add swiftui/CLAUDE.md swiftui/README.md swiftui/docs README.md CLAUDE.md
git commit -m "docs: SwiftUI 版の CLAUDE.md・README・PRD・architecture・ADR を足し、ルートの案内を直す

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```
