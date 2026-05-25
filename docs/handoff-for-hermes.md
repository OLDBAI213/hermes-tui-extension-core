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

## 建议第一步

先做 fake module，不接真实业务：

1. 新增 `moduleStore`。
2. 新增 `TuiModuleHost`。
3. 新增 `tui.module.update`。
4. 新增 `/tui-doctor`。
5. fake module 验证 `loading/ok/stale/error/disabled`。
6. 跑完整无牺牲基线。

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

```powershell
pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-reverse-study\tools\run-no-regression-baseline.ps1 -Mode Full -RunZhVerify
```

最新通过报告：

```text
E:\AI\github\hermes-tui-reverse-study\tests\20260525-210539-no-regression-Full.txt
Failed: 0
```
