# hermes-tui-extension-core

Hermes TUI Cockpit Layer 的扩展内核方案仓库。

当前状态：v0.2 已开始落到 `E:\AI\hermes\hermes-agent` 本体代码，尚不是独立可安装包。

2026-05-29 复审：当前 Hermes Agent v0.15.1 仍适配本项目 v0.2 MVP。快速验收 `pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-extension-core\verify.ps1` 通过，`Summary failed: 0`。本轮也在 Hermes 主仓补齐了后端 `tui.module.update` RPC、前端事件接入、`display.tui_modules` 配置同步和 `/tui-module-smoke` 本地命令。

## 它要解决什么

Hermes 原生 TUI 已经有输入、滚动、对话、工具流、reasoning、session、gateway、skin 和部分 `display.tui_modules` 能力。

但它还没有稳定的第三方 TUI 模块框架。  
如果直接把飞书状态、股票、新闻、浏览器状态硬塞进 `AppLayout` 或状态栏，短期能显示，长期会破坏升级、滚动、输入、布局和错误隔离。

`hermes-tui-extension-core` 的目标是补一层小而稳定的扩展内核：

```text
Hermes 原生 TUI
  + Cockpit Layer core
    + independent extension packs
```

## 不是什么

它不是：

- 新 TUI。
- Hermes 替代品。
- 飞书汉化包。
- 皮肤包。
- 股票/新闻模块。
- 外挂终端框架。

它只负责让这些扩展以后能安全共存。

## 已落地能力

当前已经落到 Hermes 本体的第一刀：

- `slot registry`
- `moduleStore`
- `TuiModuleHost`
- `tui.module.update` event
- `tui.extension.version` RPC
- `tui.module.update` RPC
- `/tui-module-smoke` 本地烟测命令
- `/tui-doctor` 本地诊断命令
- 模块 `loading/ok/stale/error/disabled/incompatible` 状态模型
- 模块按 `slot/priority/minCols/enabled` 过滤显示
- 网关退出时模块状态自动转为 `stale`

还没落地：

- 独立安装包
- 真实飞书/股票/新闻业务模块
- Hermes 更新后的自动兼容检查脚本

## 第一版边界

第一版不开放这些扩展点：

- 输入框。
- 滚动容器。
- 主消息正文。
- 工具调用主流程。
- reasoning 主流程。
- GatewayClient transport。

这些属于 Hermes 原生主路径，不能作为早期扩展点。

## 项目关系

```text
hermes-tui-reverse-study
  研究资料和理论来源

hermes-tui-extension-core
  本仓库，负责扩展内核方案和后续实现

hermes-tui-zh
  只做 TUI 汉化

hermes-tui-skins
  后续皮肤包

hermes-tui-module-feishu
  后续飞书状态模块
```

## 当前决策

采用：

```text
原生 TUI 主路径不动
扩展状态独立 moduleStore
模块只能进入固定 slot
模块数据只能通过 snapshot
模块失败只影响自己
doctor 负责发现问题
完整基线负责防退化
```

不采用：

```text
重写 TUI
解析屏幕文本
把模块塞进 TurnState
让组件 render 时发网络请求
把业务模块直接写进状态栏
```

## 来源

主要依据：

- `E:\AI\github\hermes-tui-reverse-study\2026-05-25-hermes-tui-cockpit-theory.md`
- `E:\AI\github\hermes-tui-reverse-study\2026-05-25-hermes-native-tui-extension-source-audit.md`
- `E:\AI\github\hermes-tui-reverse-study\2026-05-25-hermes-tui-cockpit-layer-contract.md`
- `E:\AI\github\hermes-tui-reverse-study\2026-05-25-hermes-tui-no-regression-baseline-matrix.md`

## 当前验收口径

现在的验收不是“安装成功”，而是：

- 默认 TUI 没有额外可见变化。
- 收到 `tui.module.update` 后能进入独立 `moduleStore`。
- 外部调用 `tui.module.update` RPC 后能按 session 发出同名事件。
- `/tui-module-smoke` 能本地触发 `ok/loading/warning/stale/error/disabled/incompatible/clear` 状态。
- 启用对应 `display.tui_modules` 后，模块能在固定 slot 显示。
- `/tui-doctor` 能反查配置、快照和显示状态。
- 新增功能不能影响输入框、滚动区、工具调用、reasoning、slash 命令。

必须跑：

```powershell
pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-extension-core\verify.ps1 -RunTests
pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-reverse-study\tools\run-no-regression-baseline.ps1 -Mode Full -RunZhVerify
```

日常快速确认只跑：

```powershell
pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-extension-core\verify.ps1
```

最新完整通过报告：

```text
E:\AI\github\hermes-tui-reverse-study\tests\20260526-003332-no-regression-Full.txt
Failed: 0
```
