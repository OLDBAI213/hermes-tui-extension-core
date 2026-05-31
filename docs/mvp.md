# MVP 范围

## 目标

第一版不做真实业务模块，先证明扩展框架本身稳定。

通过后再接飞书状态、浏览器状态、股票、新闻。

## MVP 内容

### 1. slot 类型和配置

已新增：

- `TuiSlotId`
- `TuiModuleState`
- `TuiModuleSnapshot`
- module config normalize 对 slot/priority/minCols 生效

### 2. moduleStore

已新增独立 store：

- 保存 snapshots。
- 处理 update。
- 处理 expiresAt。
- gateway exit 时 stale all。
- config disabled 时隐藏。

### 3. TuiModuleHost

已新增组件：

- 按 slot 读模块。
- 按 priority 排序。
- 按 minCols 过滤。
- 容错单个模块 renderer。
- 用 theme token 渲染。

### 4. fake module / fake snapshot

当前用 fake snapshot 和 `/tui-module-smoke` 验证框架：

- 初始 `loading`。
- 收到 update 后 `ok`。
- 模拟提醒后 `warning`。
- 过期后 `stale`。
- 模拟错误后 `error`。
- 禁用后不显示。
- 不兼容时 `incompatible`。
- 清理时 `clear` 删除快照。

命令：

```text
/tui-module-smoke [ok|loading|warning|stale|error|disabled|incompatible|clear]
```

该命令只改本地运行态，不写入用户配置。

### 5. /tui-doctor

已新增本地 `/tui-doctor`，输出：

- core 状态。
- Hermes TUI 基础状态。
- slot 状态。
- 模块列表。
- 最近错误。
- 配置建议。

### 6. 后端 RPC

已新增：

- `tui.extension.version`：返回扩展内核名、版本、协议、slot、state、event。
- `tui.module.update`：校验 `session_id/id/state`，向目标 session 发出 `tui.module.update` event。

## 已落地文件

Hermes 本体：

- `ui-tui/src/domain/tuiModules.ts`
- `ui-tui/src/app/tuiModuleStore.ts`
- `ui-tui/src/app/tuiDoctor.ts`
- `ui-tui/src/components/tuiModuleHost.tsx`
- `ui-tui/src/components/appLayout.tsx`
- `ui-tui/src/app/createGatewayEventHandler.ts`
- `ui-tui/src/app/useMainApp.ts`
- `ui-tui/src/app/slash/commands/debug.ts`
- `ui-tui/src/app/slash/commands/core.ts`
- `ui-tui/src/gatewayTypes.ts`
- `tui_gateway/server.py`

新增/补充测试：

- `ui-tui/src/__tests__/tuiModules.test.ts`
- `ui-tui/src/__tests__/tuiModuleStore.test.ts`
- `ui-tui/src/__tests__/tuiModuleHost.test.tsx`
- `ui-tui/src/__tests__/createGatewayEventHandler.test.ts`
- `ui-tui/src/__tests__/createSlashHandler.test.ts`
- `tests/test_tui_gateway_server.py`

## 不做

MVP 不做：

- 飞书业务模块。
- 股票/新闻数据源。
- 动态 JS 插件加载。
- 输入框增强。
- 滚动重写。
- 主消息正文重排。
- 外部 dashboard。

## 通过标准

必须满足：

- fake module 能显示。
- `/tui-module-smoke` 能触发每个状态并能清理。
- `tui.extension.version` 能返回协议 `1` 和版本 `0.2.0`。
- `tui.module.update` RPC 能按 session 发出事件，错误参数会拒绝。
- fake module 失败不影响 TUI。
- fake module 过期显示 stale。
- `/tui-doctor` 能看到原因。
- 关闭 cockpit 后原生 TUI 能用。
- 完整无牺牲基线通过。

完整基线：

```powershell
pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-reverse-study\tools\run-no-regression-baseline.ps1 -Mode Full -RunZhVerify
```
