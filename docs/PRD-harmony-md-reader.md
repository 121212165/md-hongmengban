# harmony-md-reader 产品需求文档 (PRD)

> 基于 GitHub 仓库 [121212165/harmony-md-reader](https://github.com/121212165/harmony-md-reader) 当前代码状态编写。
> 日期：2026-06-19

---

## 1. 产品概述

### 1.1 产品名称

`harmony-md-reader` — 鸿蒙手机/平板 HTML+Markdown 阅读器

### 1.2 一句话描述

一个极简的鸿蒙原生文件阅读器，通过系统分享打开 `.md` / `.html` 文件，在 WebView 中渲染显示。

### 1.3 产品定位

**阅读器，不是编辑器。**

与 `hongmengMD`（内容接力工作台）不同，本产品不承担编辑、工作区管理、导出等创作能力。它只做一件事：把手机上收到的 Markdown 或 HTML 文件渲染成可读内容。

核心价值链：

```
收到文件 → 系统分享打开 → 即时渲染 → 阅读
```

### 1.4 设计哲学

本项目经过 Elon Musk 首要原则重构（2026-06-14），从 ~5,000 行自研解析管线精简至 ~450 行。核心洞察：

> 鸿蒙手机已有浏览器引擎。ArkUI Web 组件原生渲染 HTML。整个自研解析管线解决的是平台已经解决的问题。

最终实现仅 5 个文件：

| 文件 | 职责 | 行数 |
|------|------|------|
| `EntryAbility.ets` | 应用入口，处理文件 URI 提取 | ~60 |
| `HomePage.ets` | 首页占位，监听文件到达并跳转 | ~55 |
| `ReaderPage.ets` | 核心页面：读取文件 → 注入 WebView | ~120 |
| `web-template.html` | 渲染引擎：marked.js + highlight.js + KaTeX + Mermaid | ~160 |
| `module.json5` | 模块配置与文件关联声明 | ~80 |

---

## 2. 目标用户与场景

### 2.1 目标用户

- 鸿蒙手机/平板用户
- 需要在移动端快速查看 `.md` 或 `.html` 文件的人
- 从聊天工具、邮件、网盘等渠道收到文档需要即时预览的用户

### 2.2 核心场景

**场景 1：聊天中收到 Markdown 文件**

用户在微信/飞书/邮件中收到一个 `.md` 文件 → 点击 → 系统分享面板出现 "MD Reader" → 打开 → 立即看到渲染后的文档。

**场景 2：本地 HTML 文件预览**

用户在文件管理器中找到一个 `.html` 文件 → 选择 "打开方式" → 用 MD Reader 打开 → 看到完整渲染的网页。

**场景 3：含代码/数学/图表的学术/技术文档**

用户收到一份包含代码块、LaTeX 公式、Mermaid 流程图的技术文档 → 通过 MD Reader 打开 → 代码高亮、公式渲染、图表绘制全部正常显示。

### 2.3 不在范围内

| 能力 | 状态 | 说明 |
|------|------|------|
| Markdown 编辑 | 不做 | 编辑功能属于 hongmengMD |
| 文件管理/工作区 | 不做 | 阅读器不管理文件 |
| 导出 | 不做 | 只读 |
| 多设备接力 | 不做 | 超出阅读器定位 |
| 离线渲染 | 部分 | marked.js 已本地化，其余 CDN 依赖 |

---

## 3. 功能需求

### 3.1 文件关联注册

**当前实现状态：已实现**

应用通过 `module.json5` 注册为以下文件类型的处理器：

| Scheme | 扩展名 |
|--------|--------|
| `file://` | `.md`, `.markdown`, `.html`, `.htm` |
| `content://` | `.md`, `.markdown`, `.html`, `.htm` |

权限：`ohos.permission.READ_MEDIA`

**验收标准：**
- 在文件管理器中点击 `.md` 文件，系统分享面板中出现 MD Reader
- 从聊天工具分享 `.md` / `.html` 文件到 MD Reader，应用能正确接收

### 3.2 文件打开与内容读取

**当前实现状态：已实现**

`ReaderPage.ets` 通过 `@ohos.file.fs` 读取文件内容：

1. 获取文件 URI（从 `Want` 参数或 `AppStorage`）
2. `fs.statSync()` 检查文件大小
3. `fs.openSync()` + `fs.readSync()` 读取二进制内容
4. `util.TextDecoder` 解码为 UTF-8 字符串
5. 根据扩展名判断 HTML/Markdown 类型
6. 通过 `runJavaScript` 注入 WebView

**验收标准：**
- 能读取 UTF-8 编码的 `.md` 和 `.html` 文件
- 空文件显示提示文案
- 读取失败显示错误信息，不白屏
- 文件名在导航栏正确显示

### 3.3 Markdown 渲染

**当前实现状态：已实现**

`web-template.html` 使用 CDN 加载的客户端库：

| 库 | 版本 | 用途 |
|----|------|------|
| marked.js | 12.0.0 | Markdown → HTML 解析 |
| highlight.js | 11.9.0 | 代码语法高亮 |
| KaTeX | 0.16.9 | LaTeX 数学公式渲染 |
| Mermaid | 10.9.0 | 流程图/时序图/甘特图渲染 |

支持的 Markdown 特性：

- GFM（GitHub Flavored Markdown）
- 换行符转换（`breaks: true`）
- 任务列表（`- [x]` / `- [ ]`）
- 行内数学公式 `$...$` 和块级公式 `$$...$$`
- Mermaid 图表（` ```mermaid ` 代码块）
- 代码语法高亮（自动语言检测）

**验收标准：**
- 标准 Markdown 语法正确渲染（标题、段落、列表、引用、表格、图片、链接）
- 代码块有语法高亮（atom-one-dark 主题）
- LaTeX 公式正确显示（行内和块级）
- Mermaid 流程图正确绘制
- 任务列表显示为 checkbox

### 3.4 HTML 渲染

**当前实现状态：已实现**

`.html` / `.htm` 文件直接通过 `innerHTML` 注入 WebView 容器。

**验收标准：**
- 静态 HTML 文件正确显示
- HTML 内的样式正常生效
- 图片、链接等元素正常工作

### 3.5 页面导航

**当前实现状态：已实现**

- `HomePage`：启动首页，显示 "打开一个文件" 提示
- `ReaderPage`：阅读页面，顶部导航栏显示文件名和返回按钮
- 返回按钮调用 `router.back()` 回到首页
- 系统分享文件时自动从首页跳转到阅读页

**验收标准：**
- 应用冷启动显示首页
- 通过分享打开文件时自动跳转阅读页
- 点击返回按钮回到首页
- 阅读页导航栏正确显示当前文件名（超长截断）

### 3.6 Web 交互能力

**当前实现状态：已配置**

WebView 配置：

| 能力 | 状态 |
|------|------|
| JavaScript 访问 | 开启 |
| DOM Storage | 关闭 |
| 缩放 | 开启 |
| 图片加载 | 开启 |
| 混合模式 | Compatible |

**验收标准：**
- WebView 内部链接可以点击跳转
- 图片可以正常加载和缩放
- 页面可以手势缩放

---

## 4. 非功能需求

### 4.1 性能

| 指标 | 目标 |
|------|------|
| 冷启动到首页 | < 1s |
| 文件打开到渲染完成 | < 2s（不含 CDN 加载） |
| APK 体积 | < 5MB |

**已知限制：** KaTeX、highlight.js、Mermaid 通过 CDN 加载，首次打开含这些特性的文件需要网络。marked.js 和基础样式内嵌在 `web-template.html` 中。

### 4.2 兼容性

| 维度 | 要求 |
|------|------|
| SDK 版本 | HarmonyOS 5.0.0 (API 12) |
| 设备类型 | 手机（当前配置） |
| 分辨率 | 适配主流手机屏幕 |

### 4.3 安全

- 不访问网络（除 CDN 资源加载）
- 不写入用户文件
- 不收集用户数据
- 不使用 DOM Storage

### 4.4 可靠性

- 文件读取失败时显示错误信息，不崩溃
- WebView JS 执行异常有 try/catch 保护
- Mermaid 渲染失败回退为纯文本代码显示
- KaTeX 渲染失败回退为原始 LaTeX 文本

---

## 5. 技术架构

### 5.1 整体架构

```
┌─────────────────────────────────┐
│         HarmonyOS App           │
│  ┌───────────────────────────┐  │
│  │      EntryAbility          │  │
│  │  (Want → 文件 URI 提取)    │  │
│  └──────────┬────────────────┘  │
│             │                   │
│  ┌──────────▼────────────────┐  │
│  │      HomePage              │  │
│  │  (等待文件到达 → 路由跳转) │  │
│  └──────────┬────────────────┘  │
│             │                   │
│  ┌──────────▼────────────────┐  │
│  │      ReaderPage            │  │
│  │  fs.readSync → 文本解码    │  │
│  │  → runJavaScript 注入      │  │
│  └──────────┬────────────────┘  │
│             │                   │
│  ┌──────────▼────────────────┐  │
│  │    web-template.html       │  │
│  │  marked.js → HTML          │  │
│  │  hljs → 代码高亮           │  │
│  │  KaTeX → 数学公式          │  │
│  │  Mermaid → 图表            │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
```

### 5.2 文件生命周期

```
系统分享 / 文件管理器打开
        │
        ▼
EntryAbility.extractFileFromWant()
  → AppStorage.set('pendingFileUri', uri)
        │
        ▼
onWindowStageCreate() → loadContent('HomePage')
        │
        ▼
HomePage.aboutToAppear()
  → 检测 pendingFileUri 非空
  → router.pushUrl('ReaderPage')
        │
        ▼
ReaderPage.aboutToAppear()
  → 读取 router.getParams() 或 AppStorage
        │
        ▼
Web.onPageEnd() → loadFileContent()
  → fs.statSync + fs.readSync
  → TextDecoder.decodeWithStream
  → sendToWebView(content, isHtml)
        │
        ▼
window._renderContent(content, isHtml)
  → marked.parse() 或 innerHTML
  → hljs.highlightElement()
  → mermaid.render()
  → katex.render()
```

### 5.3 CI/CD

GitHub Actions 工作流（`.github/workflows/ci.yml`）：

| Job | 触发条件 | 内容 |
|-----|---------|------|
| check | push / PR | 项目结构验证、.ets 文件统计、代码基础检查、生成报告 |
| release | push to main | 自动生成版本号、变更日志、创建 GitHub Release |

---

## 6. 项目历史

| 日期 | 事件 |
|------|------|
| 2026-06-04 | 仓库创建，初始提交 |
| 2026-06-05 | 添加 CI/CD 工作流 |
| 2026-06-13 | 首要原则分析文档 |
| 2026-06-14 | **首要原则重构**：删除 30 个文件（~4,800 行），用 WebView 方案重建（~450 行） |

---

## 7. 与 hongmengMD 的关系

| 维度 | harmony-md-reader | hongmengMD |
|------|-------------------|------------|
| 定位 | 文件阅读器 | 内容工作台 |
| 核心能力 | 只读渲染 | 编辑 + 预览 + 导出 + 分享 |
| 代码规模 | ~450 LOC | ~5,000+ LOC |
| 架构 | 3 页 + WebView | 三页式 + 服务层 + 数据层 |
| 文件关联 | 注册为 .md/.html handler | 无文件关联 |
| 目标场景 | 快速查看收到的文件 | 创作、管理、发布内容 |

两个项目定位互补，不重叠。

---

## 8. 已知限制与后续优化方向

### 8.1 当前限制

| 问题 | 影响 | 优先级 |
|------|------|--------|
| CDN 依赖 | 无网络时 KaTeX/Mermaid/highlight.js 主题不可用 | HIGH |
| 大文件性能 | `runJavaScript` 传输大文件内容可能卡顿 | MEDIUM |
| 编码支持 | 仅 UTF-8，GBK 等编码的文件会乱码 | LOW |
| 设备支持 | 仅注册 phone，平板未声明 | LOW |
| 安全性 | HTML 文件直接 innerHTML 注入，存在 XSS 风险 | MEDIUM |

### 8.2 可优化方向（不在当前版本承诺中）

| 方向 | 说明 |
|------|------|
| 本地化 CDN 资源 | 将 KaTeX/Mermaid/highlight.js 打包到 rawfile，消除网络依赖 |
| 大文件分段渲染 | 对超长文件分块注入 WebView |
| 主题切换 | 支持暗色模式阅读 |
| 文件编码检测 | 自动检测 GBK/GB2312 等编码 |
| 平板适配 | 在 module.json5 中添加 tablet 设备类型 |
| HTML 净化 | 对 HTML 内容做 sanitize 处理 |
| 阅读进度 | 记住上次阅读位置 |

---

## 9. 验收检查清单

- [ ] 从文件管理器打开 `.md` 文件，内容正确渲染
- [ ] 从文件管理器打开 `.html` 文件，内容正确显示
- [ ] 从聊天工具分享 `.md` 到 MD Reader，能正常打开
- [ ] 代码块有语法高亮
- [ ] LaTeX 行内公式 `$...$` 正确渲染
- [ ] LaTeX 块级公式 `$$...$$` 正确渲染
- [ ] Mermaid 流程图正确绘制
- [ ] 任务列表 `- [x]` 显示为 checkbox
- [ ] 表格正确渲染
- [ ] 空文件显示提示
- [ ] 文件名在导航栏正确显示
- [ ] 返回按钮工作正常
- [ ] 应用冷启动不白屏
- [ ] 阅读页手势缩放可用
