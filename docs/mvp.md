# MVP 范围

## 目标

第一版不做真实业务模块，只做 fake module，证明扩展框架本身稳定。

通过后再接飞书状态、浏览器状态、股票、新闻。

## MVP 内容

### 1. slot 类型和配置

新增：

- `TuiSlotId`
- `TuiModuleState`
- `TuiModuleSnapshot`
- module config normalize 对 slot/priority/minCols 生效

### 2. moduleStore

新增独立 store：

- 保存 snapshots。
- 处理 update。
- 处理 expiresAt。
- gateway exit 时 stale all。
- config disabled 时隐藏。

### 3. TuiModuleHost

新增组件：

- 按 slot 读模块。
- 按 priority 排序。
- 按 minCols 过滤。
- 容错单个模块 renderer。
- 用 theme token 渲染。

### 4. fake module

fake module 用于验证框架：

- 初始 `loading`。
- 收到 update 后 `ok`。
- 过期后 `stale`。
- 模拟错误后 `error`。
- 禁用后不显示。

### 5. /tui-doctor

输出：

- core 状态。
- Hermes TUI 基础状态。
- slot 状态。
- 模块列表。
- 最近错误。
- 配置建议。

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
- fake module 失败不影响 TUI。
- fake module 过期显示 stale。
- `/tui-doctor` 能看到原因。
- 关闭 cockpit 后原生 TUI 能用。
- 完整无牺牲基线通过。

完整基线：

```powershell
pwsh -ExecutionPolicy Bypass -File E:\AI\github\hermes-tui-reverse-study\tools\run-no-regression-baseline.ps1 -Mode Full -RunZhVerify
```
