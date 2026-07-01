# 4PL（platformweb）企业树接口梳理

## 一、接口定义

**只有一个接口：`DmsPlatformUmCompany/companyTreeList`（DMS_API）**

> 注意：4PL 不存在 3PL 那种 `PlatformUmCompany/companyTreeList` + Vuex 全局状态的机制，所有页面均本地调用同一个接口。

**定义位置（重复定义，共 2 个文件）：**

- `src/api/transaction/businessOwnershipWaybill.js`
- `src/views/infolook/api/public/WaybillData.js`

```js
export function companyTreeList(data, id) {
  return request({
    url: DMS_API + '/DmsPlatformUmCompany/companyTreeList' + id,
    method: 'get',
    params: data
  })
}
```

- 需要传入 `/{companyId}` 作为路径参数
- 返回完整树形结构（含所有层级 children）
- 两个文件中定义完全一致（重复定义）

---

## 二、使用页面汇总

| 使用位置 | 引入来源 | 调用方式 | 传参 | 用途 |
|---------|---------|---------|------|------|
| `src/views/transaction/businessOwnershipWaybill/index.vue` | `@/api/transaction/businessOwnershipWaybill` | 组件本地调用 | `/2`（固定） | 业务归属运单 - 搜索栏业务归属下拉树 |
| `src/views/transaction/businessOwnershipWaybill/tree.vue` | `@/api/transaction/businessOwnershipWaybill` | 组件本地调用（**已注释不用**） | `/${companyId}`（动态） | 业务归属运单 - 左侧树（已废弃） |
| `src/views/taxdocking/energyOrderManagement/index.vue` | `@/api/transaction/businessOwnershipWaybill` | 组件本地调用 | `/2`（固定） | 能源订单管理 - 业务归属公司下拉列表（**树结构扁平化后使用**） |
| `src/components/Selectmore/selsectTree.vue` | `@/views/infolook/api/public/WaybillData.js` | 组件本地调用 | `/2`（固定） | 通用企业树选择组件 |

---

## 三、全局状态分析

### DmsPlatformUmCompany/companyTreeList — 不走全局状态

4PL 中该接口**完全不经过 Vuex**，每个页面在 `activated` 生命周期中独立调用 `getTree()`，数据存在组件本地 `data.treeList` 中。

**存在的问题：**
- 每次进入页面都会重复请求
- 页面之间不共享树数据
- 同一个接口在两个 api 文件中重复定义

---

## 四、各页面默认回显逻辑

### 1. businessOwnershipWaybill/index.vue

```
activated
  → getTree()
    → companyTreeList({}, `/2`)  // 原为动态 /${companyId}，已改为固定 /2
      → 返回 data.model[0]
        → 默认回显：companyName = data.model[0].label（根节点名称）
        → 默认选中：companyId = data.model[0].id（根节点 ID）
        → 保存副本：companyNameCopy / companyIdCopy（用于重置）
        → treeList = data.model[0].children（子节点作为下拉树数据）
        → 如果 children 为空，tableList = true（隐藏树，显示"无"）
```

**重置逻辑：** 点击"重置"按钮时恢复为 `companyNameCopy` 和 `companyIdCopy`（即根节点）。

> 代码中有注释掉的旧写法 `companyTreeList({}, \`/${this.$store.state.app.user.companyId}\`)`，说明原本是动态传当前用户 companyId，**现已改为固定传 `/2`**。

### 2. businessOwnershipWaybill/tree.vue（已废弃）

```
activated
  → getTree()
    → companyTreeList({}, `/${this.$store.state.app.userInfo.companyId}`)  // 动态传 companyId
      → 返回 data.model[0]
        → treeList = data.model[0].children
```

**现状：** 该组件虽然还存在，但在 `index.vue` 中已被注释掉（`<!-- <TREE @handleSearch="handleSearch" /> -->`），实际不再调用。且其传参逻辑（动态 companyId）与 index.vue 当前逻辑（固定 /2）已不一致，容易产生误导。

### 3. energyOrderManagement/index.vue

```
activated（与其他接口并行调用）
  → getBusinessCompany()
    → companyTreeList({}, '/2')
      → 返回 data.model[0]
        → 将树形结构递归扁平化为一维列表
          flattenTree(node) → [{ name: node.label, id: node.id }, ...子节点]
        → businessCompanyOptions = flattenTree(data.model[0])
```

**与其他页面的区别：** 不展示树形下拉，而是将树打平为列表用于普通的 `el-select` 下拉框（`allow-create`，支持手动输入）。最终搜索时以字符串名称 `carrierCompanyName` 传给后端，**不传 id**。

### 4. Selectmore/selsectTree.vue（通用企业树选择组件）

```
activated
  → getTree()
    → companyTreeList({}, `/${2}`)
      → 返回 data.model[0]
        → 判断权限 controlBtn.ywgsBtn 且根节点 id === '2'
          → 是（有权限 or 根节点非2）：treeList = data.model，默认选中 data.model[0]
          → 否（无权限 且 根节点id=2）：treeList = data.model[0].children，默认选中 children[0]
        → 默认回显：realityCompanyName = 选中节点的 label
        → 默认选中：realityCompanyId = 选中节点的 id
        → keyArr = 选中节点的 id（用于树高亮展开）
        → $emit('treeEvent', [label, id])（通知父组件默认选中值）
```

**权限控制逻辑：** 根据路由 meta 中的 `ywgsBtn` 权限决定是否跳过根节点（id=2）展示。与 3PL 的 `WaybillData/index.vue` 逻辑一致。

---

## 五、与 3PL 的对比差异

| 对比项 | 3PL（logisticsweb） | 4PL（platformweb） |
|-------|---------------------|-------------------|
| 接口数量 | 2 个（`PlatformUmCompany` + `DmsPlatformUmCompany`） | **1 个**（只有 `DmsPlatformUmCompany`） |
| Vuex 全局状态 | 有，`PlatformUmCompany` 走 Vuex 全局缓存 | **无**，全部页面本地调用 |
| 应用启动预加载 | 有（router beforeEach / loadMicroAppStore） | **无** |
| tree.vue 左侧树 | 使用中（通过 getter 读 Vuex） | **已注释废弃** |
| 传参方式 | 动态 `/${companyId}` 或固定 `/2` | **全部固定为 `/2`**（tree.vue 除外，但已废弃） |
| 树数据用途 | 仅用于树形下拉 | 树形下拉 + **扁平化列表**（energyOrder） |
| API 重复定义 | 有（2 个文件各定义一次） | 有（2 个文件各定义一次，问题相同） |
| 每次进页重复请求 | 是 | 是 |

---

## 六、存在的问题汇总

1. **API 重复定义**：`businessOwnershipWaybill.js` 和 `infolook/api/public/WaybillData.js` 中各有一份 `companyTreeList` 定义，逻辑完全一致，建议合并到一处统一导出

2. **无全局缓存**：每次进入页面都在 `activated` 中独立请求，4 个使用方之间不共享数据，存在多次重复请求

3. **传参硬编码**：大部分地方固定传 `/2`，含义不清晰，建议提取为命名常量并加注释说明

4. **tree.vue 残留**：废弃的 `tree.vue` 组件仍然存在，其中的传参逻辑（动态 companyId）与 `index.vue` 当前逻辑（固定 /2）不一致，建议清理

---

## 七、是否能支持树结构的懒加载？

### 当前现状

**不支持懒加载。** 所有调用都是一次性获取完整树（包含所有层级的 children），前端直接渲染完整嵌套结构。

### 改造方案

#### 后端需要

- 提供按层级加载的接口，如 `companyTreeList/{parentId}?lazy=true`，只返回当前层级子节点
- 返回数据增加 `isLeaf` 字段标识是否为叶子节点

#### 前端改造

el-tree 原生支持懒加载：

```vue
<el-tree
  lazy
  :load="loadNode"
  :props="{ children: 'children', label: 'label', isLeaf: 'isLeaf' }"
/>
```

```js
loadNode(node, resolve) {
  if (node.level === 0) {
    companyTreeList({}, `/2`).then(data => {
      resolve(data.model)
    })
  } else {
    companyTreeList({}, `/${node.data.id}`).then(data => {
      resolve(data.model || [])
    })
  }
}
```

#### 改造建议

| 场景 | 建议 |
|------|------|
| 树节点 < 500 | 维持现状，一次性加载即可，懒加载收益有限 |
| 树节点 500~2000 | 建议懒加载 + 首层数据缓存到 Vuex |
| 树节点 > 2000 | 必须懒加载 + 搜索接口配合 |

#### 额外优化建议

1. **统一 api 定义**：`businessOwnershipWaybill.js` 和 `WaybillData.js` 中的 `companyTreeList` 重复定义，建议合并到一处
2. **全局缓存**：树数据可以考虑放入 Vuex，避免多个页面重复请求
3. **默认回显兼容**：如果改为懒加载，默认回显逻辑需要调整——首次只加载根节点，默认选中根节点即可，不再依赖 `children[0]`

---

**文档版本**: v1.0

**最后更新**: 2026年06月

**整理人**: 王新骏
