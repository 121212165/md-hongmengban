# Reconstruction Plan

## What gets deleted
- `.github/workflows/ci.yml` — generic CI for a nonexistent project
- README boilerplate — rewrite to actual project docs

## What gets created

### Root config
- `build-profile.json5` — project build profile
- `oh-package.json5` — root package descriptor
- `hvigorfile.ts` — root build script

### entry module
- `entry/oh-package.json5` — entry module package
- `entry/hvigorfile.ts` — entry build script
- `entry/build-profile.json5` — entry build profile
- `entry/src/main/module.json5` — module descriptor
- `entry/src/main/ets/entryability/EntryAbility.ets` — ability entry
- `entry/src/main/ets/pages/Index.ets` — main page (TextInput + Web preview)
- `entry/src/main/resources/base/element/string.json` — string resources
- `entry/src/main/resources/base/profile/main_pages.json` — page routing
- `entry/src/main/resources/rawfile/index.html` — WebView HTML with marked.js

### README
- Rewrite to reflect actual HarmonyOS Markdown editor

## Architecture
Single page: ArkTS `TextInput` (left/top) + `Web` component (right/bottom).
WebView loads `index.html` which uses marked.js to render Markdown in real-time.
Communication via `WebviewController.postMessage`.
