# 验证方案

## 核心口径

不能只验证新模块能显示。

必须同时验证：

- 原生 TUI 能启动。
- 输入框可见。
- 滚轮滚对话区。
- 工具调用顺序不变。
- reasoning 显示不乱。
- slash 命令可用。
- 网关退出有提示。
- 汉化没有回潮。
- 模块失败隔离。

## 自动化

使用研究仓库里的统一基线：

```powershell
pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-reverse-study\tools\run-no-regression-baseline.ps1 -Mode Full -RunZhVerify
```

当前已知最新通过报告：

```text
E:\AI\github\hermes-tui-reverse-study\tests\20260525-210539-no-regression-Full.txt
Failed: 0
```

## 新增测试方向

MVP 实现时需要补：

- `moduleStore` update/stale/error/disabled 单测。
- `TuiModuleHost` slot/priority/minCols 单测。
- `createGatewayEventHandler` 处理 `tui.module.update` 单测。
- gateway exit 后 stale all 单测。
- `/tui-doctor` 输出快照测试。
- fake module smoke。

## 人工验收

实现后手动确认：

- 正常启动。
- 全屏和退出全屏。
- 窄屏。
- 鼠标滚轮。
- 输入中文。
- 触发工具调用。
- 打开 `/tui-doctor`。
- 模拟模块过期。
- 模拟模块错误。
- 关闭模块。

## 失败处理

如果新模块正常但原生能力退化，结论是失败。

如果模块失败会污染主对话，结论是失败。

如果必须改输入、滚动、主消息正文才能完成 MVP，方案要退回重审。
