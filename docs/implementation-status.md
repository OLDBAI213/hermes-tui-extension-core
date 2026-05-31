# 实现状态

日期：2026-05-25

## 2026-05-29 复审

当前 Hermes 源码是 `E:\AI\hermes\hermes-agent`，版本 `Hermes Agent v0.15.1 (2026.5.29)`。

结论：本项目 v0.2 MVP 仍适配当前 Hermes。

已补齐并验证：

- 后端 `tui.extension.version` RPC。
- 后端 `tui.module.update` RPC，按 `session_id` 发出 `tui.module.update` event，并拒绝缺失 session 和未知 state。
- 前端 `createGatewayEventHandler` 接收 `tui.module.update` 并写入独立 module store。
- `useConfigSync` 同步 `display.tui_modules`。
- 网关退出时模块状态转为 `stale`。
- `/tui-doctor` 和 `/tui-module-smoke [state|clear]` 本地命令。

复审验证：

- `pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-extension-core\verify.ps1`：通过，`Summary failed: 0`。
- Hermes 主仓定向后端测试：8 通过。
- Hermes 主仓定向前端测试：5 个测试文件，144 通过。

## 当前结论

`hermes-tui-extension-core` v0.2 已经开始进入 Hermes 本体，但还不是独立安装包。

默认 TUI 不会新增可见内容；只有模块事件进入并且对应 `display.tui_modules` 开启后，模块才会显示。

## 已完成

- `TuiSlotId`、`TuiModuleState`、`TuiModuleSnapshot` 类型。
- `display.tui_modules` 继续兼容 boolean/object/旧 `position` 配置。
- 独立 `moduleStore`，不污染 `TurnState` 和 transcript。
- `tui.module.update` 前端事件接入。
- `TuiModuleHost` 按 slot/priority/minCols/enabled 过滤显示。
- 网关退出时模块状态转为 `stale`。
- `/tui-doctor` 本地诊断页。
- TUI 补全和命令目录包含 `/tui-doctor`。
- 后端 `tui.extension.version` RPC。
- 后端 `tui.module.update` RPC，会按 `session_id` 发出 `tui.module.update` event。
- `/tui-module-smoke [state|clear]` 本地烟测命令，不写入用户配置。
- TUI 补全和命令目录包含 `/tui-module-smoke`。

## 当前未完成

- 独立发布包。
- 真实业务模块，例如飞书状态、浏览器状态、股票、新闻。
- Hermes 更新后的兼容检查脚本。

## 验证记录

已通过：

- `npm --prefix E:\AI\hermes\hermes-agent\ui-tui run type-check`
- `npm --prefix E:\AI\hermes\hermes-agent\ui-tui test -- src/__tests__/tuiModules.test.ts src/__tests__/tuiModuleStore.test.ts src/__tests__/tuiModuleHost.test.tsx src/__tests__/createGatewayEventHandler.test.ts src/__tests__/createSlashHandler.test.ts`
- `uv run python -m pytest -n0 --timeout-method=thread tests\test_tui_gateway_server.py::test_tui_extension_version_rpc_reports_protocol tests\test_tui_gateway_server.py::test_tui_module_update_emits_scoped_snapshot tests\test_tui_gateway_server.py::test_tui_module_update_accepts_top_level_snapshot_fields tests\test_tui_gateway_server.py::test_tui_module_update_rejects_missing_session_id tests\test_tui_gateway_server.py::test_tui_module_update_rejects_unknown_state tests\test_tui_gateway_server.py::test_complete_slash_includes_tui_module_smoke_command tests\test_tui_gateway_server.py::test_commands_catalog_includes_tui_module_smoke_command -q`
- `npx eslint ...`，结果 0 errors。
- `pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-reverse-study\tools\run-no-regression-baseline.ps1 -Mode Full -RunZhVerify`

完整基线通过报告：

- `E:\AI\github\hermes-tui-reverse-study\tests\20260526-003332-no-regression-Full.txt`
- `Failed: 0`
- 统一基线已经覆盖 `tuiModuleStore.test.ts` 和 `tuiModuleHost.test.tsx`。

## 本轮修过的返工点

首次完整基线在 Windows ConPTY smoke 报 React #185。  
原因是组件 selector 每次返回新数组，造成 React 认为外部 store 快照一直变化。

已修复为：

- `TuiModuleHost` 直接订阅 `$tuiModuleState`。
- 用 `useMemo` 从稳定 state 派生 slot 模块列表。
- 删除容易误用的 `useTuiModuleSelector`。

## 给后续接力的注意点

- 不要把业务模块直接写进 `appLayout.tsx` 或状态栏。
- 不要让模块组件自己发网络请求。
- 不要改输入框、滚动容器、主消息正文。
- 新模块先发 snapshot，再由 `TuiModuleHost` 按 slot 显示。
- 外部模块先调用 `tui.extension.version` 确认协议，再调用 `tui.module.update` 上报状态。
- 本地手动验证先跑 `/tui-module-smoke warning` 和 `/tui-doctor`，确认能看到快照和版本。
- 任一模块失败只能表现为自己的 `error/stale`，不能影响主 TUI。
