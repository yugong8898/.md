# 企业树懒加载改造估时文档

## 一、背景说明

三个平台（3PL/4PL/billing）的企业树当前均为**一次性加载完整树结构**，存在首屏数据量大、多页面重复请求的问题。

本次改造方案：**后端接口不变、不增加字段**，前端一次性拿完整树数据后，改用 `el-tree` 的 `render-after-expand` 模式，展开节点时才渲染子节点 DOM，减少初始渲染量。

> **叶子节点说明**：由于后端不新增 `isLeaf` 字段，前端在数据加载完成后，根据每个节点的 `children` 是否为空来判断叶子节点，有 children 才显示展开箭头，无 children 不显示。逻辑在 `getTree` 处理数据时一并处理，不依赖后端字段。

---

## 二、改造范围总览

| 平台 | 接口 | 涉及文件数 | 是否有全局状态 |
|------|------|-----------|--------------|
| logisticsweb（3PL） | `PlatformUmCompany` + `DmsPlatformUmCompany` | 5 个 | 有（Vuex app.js） |
| platformweb（4PL） | `DmsPlatformUmCompany` | 4 个 | 无 |
| bdbl-admin（billing） | `PlatformUmCompany` | 2 个 | 有（Vuex app.js，预加载已注释） |

---

## 三、详细估时

> 说明：自测时间已包含在各任务工时内，不单独体现。

### 3.1 logisticsweb（3PL）

| # | 任务 | 说明 | 工时 |
|---|------|------|------|
| 1 | `WaybillData/index.vue` 树改造 | 改 `getTree` 数据处理（补充叶子节点判断）+ `el-tree` 改 `render-after-expand` 模式 + 默认回显调整（id=2 跳根节点逻辑）+ 自测 | 0.5 人天 |
| 2 | `WaybillDataNew/index.vue` 树改造 | 结构与 WaybillData 基本一致，参照上条改造 + 自测 | 0.5 人天 |
| 3 | `businessOwnershipWaybill/index.vue` 树改造 | 改 `getTree` + `el-tree` 渲染模式 + 默认回显（无 id=2 判断，逻辑略简单）+ 自测 | 0.5 人天 |
| 4 | `Header.vue` 全局树改造 | 走 Vuex 全局状态，双 tab（业务归属 + 组织机构），结构比页面级复杂 + 自测 | 1 人天 |

**小计：2.5 人天**

---

### 3.2 platformweb（4PL）

| # | 任务 | 说明 | 工时 |
|---|------|------|------|
| 1 | `businessOwnershipWaybill/index.vue` 树改造 | 与 3PL 对应页面结构相同，参照 3PL 改造 + 自测 | 0.5 人天 |
| 2 | `energyOrderManagement/index.vue` 改造 | 树打平为一维列表的特殊逻辑，渲染模式调整后打平逻辑需同步处理 + 自测 | 0.5 人天 |
| 3 | `Selectmore/selsectTree.vue` 通用组件改造 | 权限判断（`ywgsBtn`）+ 跳根节点逻辑 + 叶子节点判断 + 影响所有使用该组件的页面 + 自测 | 0.5 人天 |

**小计：1.5 人天**

---

### 3.3 bdbl-admin（billing）

| # | 任务 | 说明 | 工时 |
|---|------|------|------|
| 1 | 确认功能是否启用 + `Header.vue` 改造 | `router/index.js` 中预加载已注释，需先确认 Header 企业树是否实际在用；双 tab 结构与 3PL Header 类似 + 自测 | 0.5 人天 |

> 若确认功能未启用，可跳过 bdbl-admin，节省 0.5 人天。

**小计：0.5 人天**

---

## 四、汇总

| 平台 | 工时 |
|------|------|
| logisticsweb（3PL） | **2.5 人天** |
| platformweb（4PL） | **1.5 人天** |
| bdbl-admin（billing） | **0.5 人天** |
| **合计** | **4.5 人天** |

---

## 五、风险说明

| 风险点 | 说明 | 影响 |
|--------|------|------|
| 叶子节点判断 | 后端不新增 `isLeaf` 字段，前端根据 `children` 是否为空判断，需保证每个节点数据的 children 字段完整返回 | 若后端 children 为 null 而非空数组，需前端做兼容处理 |
| 通用组件影响面广 | `Selectmore/selsectTree.vue` 是通用组件，改造会波及所有使用方 | 需要完整回归测试 |
| energyOrderManagement 扁平化逻辑 | 当前递归打平整棵树，渲染模式调整后打平逻辑需同步确认是否受影响 | 可能需要额外沟通确认 |
| bdbl-admin 功能状态不明 | 预加载已注释，功能可能未启用，需先确认再决定是否改造 | 可能节省 0.5 人天 |

---

## 六、实施建议

### 优先级

1. **logisticsweb（3PL）** — 页面最多、使用最频繁，优先改造
2. **platformweb（4PL）** — 有通用组件，需要谨慎测试
3. **bdbl-admin（billing）** — 最后改，先确认功能是否在用

### 分阶段实施

**阶段一（0.5 人天）：** 确认叶子节点兼容方案，封装统一的 `isLeaf` 判断工具函数，供各页面复用

**阶段二（3 人天）：** 逐页面改造，优先 3PL 三个业务页面，再改 Header，最后处理 4PL 及通用组件

**阶段三（1 人天）：** 全平台冒烟验证，重点覆盖通用组件使用方、默认回显、重置、叶子节点展示

---

## 七、需确认事项

在开始实施前，需先确认以下问题：

1. **bdbl-admin 企业树切换功能是否在用？** 如不在用可跳过，节省 0.5 人天
2. **后端 children 字段为空时是 `null` 还是 `[]`？** 影响叶子节点判断兼容写法
3. **energyOrderManagement 的扁平化列表是否可改为树形下拉？** 若可改，改造更简单，风险更低

---

**文档版本**: v1.2

**最后更新**: 2026年06月

**整理人**: 王新骏
