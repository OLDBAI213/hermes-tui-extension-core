# 架构方案

## 总体结构

```text
Gateway
  emits tui.module.update

TUI
  createGatewayEventHandler
    -> moduleStore
      -> TuiModuleHost(slot)
        -> module renderer
```

## 核心原则

### 原生主路径不动

不改：

- `TextInput`
- `ScrollBox`
- `useVirtualHistory`
- `TurnController` 工具主流程
- `MessageLine` 主消息正文
- `GatewayClient` transport

原因：这些负责 Hermes TUI 最基础的可用性，曾经出现过滚轮、全屏、输入区和工具显示问题。

### 模块状态独立

新增 `moduleStore`，不把模块状态塞进：

- `UiState`
- `TurnState`
- transcript message
- tool trail

模块状态应该是自己的 snapshot。

### 渲染只消费 snapshot

模块 renderer 不能：

- 发网络请求。
- 读写文件。
- 调 gateway RPC。
- 修改原生状态。

它只能消费当前 snapshot 和 theme token。

## Slot 第一版

| Slot | 用途 | 约束 |
| --- | --- | --- |
| `intro.summary` | 欢迎区一行概要 | 短文本 |
| `intro.detail` | 欢迎区详情 | 可折叠 |
| `status.left` | 状态栏左侧 | 极短，原生状态优先 |
| `status.right` | 状态栏右侧 | 极短，可隐藏 |
| `transcript.live_tail` | 当前回合只读摘要 | 不改工具顺序 |
| `overlay.panel` | doctor/module 详情 | 用户主动打开 |

## Module Snapshot

```ts
type TuiModuleState =
  | 'disabled'
  | 'loading'
  | 'ok'
  | 'warning'
  | 'stale'
  | 'error'
  | 'incompatible'

interface TuiModuleSnapshot {
  id: string
  title?: string
  state: TuiModuleState
  summary?: string
  detail?: string
  slot?: TuiSlotId
  priority?: number
  minCols?: number
  updatedAt?: number
  expiresAt?: number
  version?: string
  data?: Record<string, unknown>
  error?: {
    code?: string
    message: string
    hint?: string
  }
}
```

## Gateway 协议

已新增：

- `tui.extension.version`
- `tui.module.update`

已新增 event：

```json
{
  "type": "tui.module.update",
  "payload": {
    "id": "fake_clock",
    "state": "ok",
    "summary": "模块正常",
    "updatedAt": 1770000000
  }
}
```

后续再考虑：

- `tui.modules`
- `tui.module.status`
- `tui.module.refresh`
- `tui.doctor`

## 降级规则

宽度不足时：

1. 缩短 `summary`。
2. 隐藏低优先级模块。
3. 提示模块在 overlay 查看。
4. doctor 说明隐藏原因。

不能挤压输入框，不能让状态栏变多行。
