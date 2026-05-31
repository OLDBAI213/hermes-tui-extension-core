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

一键检查：

```powershell
pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-extension-core\verify.ps1
pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-extension-core\verify.ps1 -RunTests
```

已跑过的定向验证：

```powershell
npm --prefix E:\AI\hermes\hermes-agent\ui-tui run type-check
npm --prefix E:\AI\hermes\hermes-agent\ui-tui test -- src/__tests__/tuiModules.test.ts src/__tests__/tuiModuleStore.test.ts src/__tests__/tuiModuleHost.test.tsx src/__tests__/createGatewayEventHandler.test.ts src/__tests__/createSlashHandler.test.ts
uv run python -m pytest -n0 --timeout-method=thread tests\test_tui_gateway_server.py::test_complete_slash_includes_tui_doctor_command tests\test_tui_gateway_server.py::test_commands_catalog_includes_tui_mouse_command -q
npx eslint src/domain/tuiModules.ts src/app/tuiModuleStore.ts src/app/tuiDoctor.ts src/components/tuiModuleHost.tsx src/components/appLayout.tsx src/app/createGatewayEventHandler.ts src/app/useMainApp.ts src/app/slash/commands/debug.ts src/app/slash/commands/core.ts src/__tests__/tuiModules.test.ts src/__tests__/tuiModuleStore.test.ts src/__tests__/tuiModuleHost.test.tsx src/__tests__/createGatewayEventHandler.test.ts src/__tests__/createSlashHandler.test.ts
```

v0.2 追加定向验证：

```powershell
uv run python -m pytest -n0 --timeout-method=thread tests\test_tui_gateway_server.py::test_tui_extension_version_rpc_reports_protocol tests\test_tui_gateway_server.py::test_tui_module_update_emits_scoped_snapshot tests\test_tui_gateway_server.py::test_tui_module_update_accepts_top_level_snapshot_fields tests\test_tui_gateway_server.py::test_tui_module_update_rejects_missing_session_id tests\test_tui_gateway_server.py::test_tui_module_update_rejects_unknown_state tests\test_tui_gateway_server.py::test_complete_slash_includes_tui_module_smoke_command tests\test_tui_gateway_server.py::test_commands_catalog_includes_tui_mouse_command -q
npm --prefix E:\AI\hermes\hermes-agent\ui-tui test -- src\__tests__\tuiModules.test.ts src\__tests__\tuiModuleStore.test.ts src\__tests__\tuiModuleHost.test.tsx src\__tests__\createGatewayEventHandler.test.ts src\__tests__\createSlashHandler.test.ts
```

当前结果：

- TypeScript：通过。
- 前端定向测试：5 个文件，110 个测试通过。
- Python 网关 v0.2 定向测试：7 个测试通过。
- ESLint：0 errors。
- 完整基线：通过，报告 `E:\AI\github\hermes-tui-reverse-study\tests\20260526-003332-no-regression-Full.txt`，`Failed: 0`。
- 统一基线已把 `tuiModuleStore.test.ts` 和 `tuiModuleHost.test.tsx` 纳入 cockpit/gateway state 分组。

本轮发现并修复过一个真实问题：

- 首次完整基线在 Windows ConPTY smoke 阶段触发 React #185。
- 原因是 `TuiModuleHost` 通过 `useSyncExternalStore` selector 返回新数组，导致 React 认为快照不断变化。
- 修复方式：组件直接订阅 `$tuiModuleState`，再用 `useMemo` 派生 slot 列表。

使用研究仓库里的统一基线：

```powershell
pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-reverse-study\tools\run-no-regression-baseline.ps1 -Mode Full -RunZhVerify
```

当前已知最新通过报告：

```text
E:\AI\github\hermes-tui-reverse-study\tests\20260526-003332-no-regression-Full.txt
Failed: 0
```

## 新增测试方向

已补：

- `moduleStore` update/stale/error/disabled 单测。
- `moduleStore` remove 单测。
- `TuiModuleHost` slot/priority/minCols 单测。
- `createGatewayEventHandler` 处理 `tui.module.update` 单测。
- gateway exit 后 stale all 单测。
- `/tui-doctor` 输出快照测试。
- `/tui-module-smoke` 本地命令测试。
- `tui.extension.version` RPC 测试。
- `tui.module.update` RPC 成功/失败路径测试。

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
