# md-hongmengban

HarmonyOS Markdown editor. Edit on the left, preview on the right.

## Architecture

```
┌──────────────┬──────────────┐
│  TextInput   │    Web       │
│  (ArkTS)     │  (WebView)   │
│              │  marked.js   │
└──────┬───────┴──────────────┘
       │ postMessage
       └── real-time preview
```

## Stack

- ArkTS (Stage Model)
- ArkWeb WebView
- marked.js for rendering

## Build

Open in DevEco Studio 5.0+, sync, and run on emulator or device.

## License

MIT
