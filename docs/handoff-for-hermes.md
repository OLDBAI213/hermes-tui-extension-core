# 给 Hermes 的接手说明

## 当前结论

TUI 个性化不要继续散改。

推荐路线是：

```text
Hermes 原生 TUI
  + Cockpit Layer core
    + independent extension packs
```

## 为什么

原生 TUI 已经有稳定主路径：

- 输入。
- 滚动。
- 对话。
- 工具。
- reasoning。
- session。
- gateway。

这些不能被扩展包接管。

但原生 TUI 目前没有完整模块宿主。  
`display.tui_modules` 能解析配置，但还不能渲染任意模块。

## 当前已完成第一步

已经在 `E:\AI\hermes\hermes-agent` 做了：

1. 新增 `moduleStore`。
2. 新增 `TuiModuleHost`。
3. 新增 `tui.module.update` 前端事件处理。
4. 新增 `/tui-doctor` 本地诊断命令。
5. 新增 `tui.extension.version` 后端 RPC。
6. 新增 `tui.module.update` 后端 RPC，按 `session_id` 发 `tui.module.update` event。
7. 新增 `/tui-module-smoke [state|clear]` 本地烟测命令，不写入配置。
8. 用 fake snapshot 验证 `ok/loading/warning/stale/error/disabled/incompatible` 等状态。
9. 补前端和网关定向测试。

## 下一步

还需要：

1. 跑完整基线并确认报告。
2. 再拆真实业务模块，不要先接飞书、股票、新闻。
3. 后续做兼容检查脚本，用于 Hermes 更新后快速确认扩展面还可用。

## 不要先做

不要先做：

- 股票模块。
- 新闻模块。
- 飞书状态模块。
- 输入框增强。
- 滚动重写。
- 主消息正文重排。

否则会再次出现“新功能看起来能用，但原生能力坏了”的返工。

## 必须跑的基线

先跑扩展核心自检：

```powershell
pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-extension-core\verify.ps1 -RunTests
```

再跑完整无退化基线：

```powershell
pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-reverse-study\tools\run-no-regression-baseline.ps1 -Mode Full -RunZhVerify
```

最新通过报告：

```text
E:\AI\github\hermes-tui-reverse-study\tests\20260526-003332-no-regression-Full.txt
Failed: 0
```

## 本地烟测命令

TUI 内可运行：

```text
/tui-module-smoke warning
/tui-doctor
/tui-module-smoke clear
```

期望：

- `warning` 后能看到 `TUI 模块烟测` 快照。
- `/tui-doctor` 里能看到扩展内核版本 `0.2.0`。
- `clear` 后快照消失，不写入用户 `config.yaml`。

## 本轮特别注意

不要在 `useSyncExternalStore` 的 snapshot/selector 里直接返回新数组或新对象。  
这会在 ConPTY smoke 里触发 React #185。
