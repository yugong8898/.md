# 企业树接口梳理

## 一、接口定义

### 1. PlatformUmCompany/companyTreeList（baseUrl）

**定义位置：** `src/api/login.js` — `getOrganizationTreeList`

```js
export function getOrganizationTreeList(payload) {
  return request({
    url: baseUrl + '/PlatformUmCompany/companyTreeList'
  })
}
```

- 不传参数，直接获取当前登录用户所属公司的完整组织树
- 注释中有旧写法 `'/PlatformUmCompany/companyTreeList/' + payload.companyCode`，已弃用

---

### 2. DmsPlatformUmCompany/companyTreeList（dmsUrl）

**定义位置：**
- `src/api/businessOwnershipWaybill.js`
- `src/api/WaybillData.js`

```js
export function companyTreeList(data, id) {
  return request({
    url: dmsUrl + '/DmsPlatformUmCompany/companyTreeList' + id,
    method: 'get',
    params: data
  })
}
```

- 需要传入 `/{companyId}` 作为路径参数
- 两个 api 文件中定义完全一致（重复定义）

---

## 二、使用页面汇总

| 接口 | 使用位置 | 调用方式 | 用途 |
|------|----------|----------|------|
| PlatformUmCompany/companyTreeList | `src/vuex/modules/app.js` → action `getChildCompany` | Vuex 全局状态 | 存入 `state.childCompanyList` |
| PlatformUmCompany/companyTreeList | `src/utils/useMainProps.js` → `loadMicroAppStore` | 微前端初始化时 dispatch | 应用启动加载一次 |
| PlatformUmCompany/companyTreeList | `src/layout/components/Header.vue` | getter `get_childCompany` | 顶部导航组织机构切换树 |
| PlatformUmCompany/companyTreeList | `src/views/userBase/businessOwnershipWaybill/tree.vue` | getter `get_childCompany` | computed 中引用全局状态（未在模板中直接使用，疑似预留） |
| DmsPlatformUmCompany/companyTreeList | `src/views/userBase/businessOwnershipWaybill/index.vue` | 组件本地调用 | 业务归属运单 - 业务归属下拉树（默认第0个） |
| DmsPlatformUmCompany/companyTreeList | `src/views/userBase/businessOwnershipWaybill/tree.vue` | 组件本地调用 | 业务归属运单 - 左侧树（已注释不用） |
| DmsPlatformUmCompany/companyTreeList | `src/views/userBase/WaybillData/index.vue` | 组件本地调用 | 运单汇总（旧版）- 业务归属下拉树(默认数据id为2的第0个) |
| DmsPlatformUmCompany/companyTreeList | `src/views/userBase/WaybillDataNew/index.vue` | 组件本地调用 | 运单汇总（新版）- 业务归属下拉树(默认数据id为2的第0个) |

---

## 三、全局状态分析

### PlatformUmCompany/companyTreeList — 走 Vuex 全局状态

**调用链路：**

```
应用启动 / 微前端初始化
  → router beforeEach / loadMicroAppStore
    → store.dispatch('app/getChildCompany')
      → getOrganizationTreeList()
        → commit('SET_CHILD_COMPANY', data.model)
          → state.childCompanyList
```

**消费方：**
- `Header.vue` 通过 `mapGetters({ childCompany: 'app/get_childCompany' })` 获取
- watch `childCompany` 变化后调用 `getCompanyTree()` 渲染到 tabs 中的 "child" 选项卡

### DmsPlatformUmCompany/companyTreeList — 不走全局状态

每个页面在 `activated` 生命周期中独立调用 `getTree()`，数据存在组件本地 `data.treeList` 中。

**问题：**
- 每次进入页面都会重复请求
- 页面之间不共享树数据
- 同一个接口在两个 api 文件中重复定义

---

## 四、默认回显逻辑

### 1. Header.vue（全局状态）

```
childCompany 数据加载完成
  → watch 触发 init()
    → getCompanyTree(childCompany, agemcyChildCompany, organizationControl)
      → 根据权限 btnEnter 判断是否展示 "child" tab
      → 根据权限 btnAgemcy 判断是否展示 "agemcy" tab
      → 默认激活第一个有数据的 tab
      → 默认展示第一个 tab 的 treeList
```

不做默认选中节点，仅展示树结构供用户手动切换。

### 2. businessOwnershipWaybill/index.vue

```
activated
  → getTree()
    → companyTreeList({}, `/${companyId}`)
      → 返回 data.model[0]
        → 默认回显：companyName = data.model[0].label（根节点名称）
        → 默认选中：companyId = data.model[0].id（根节点 ID）
        → 保存副本：companyNameCopy / companyIdCopy（用于重置）
        → treeList = data.model[0].children（子节点作为下拉树数据）
        → 如果 children 为空，tableList = true（隐藏树，显示"无"）
```

**重置逻辑：** 点击"重置"按钮时恢复为 `companyNameCopy` 和 `companyIdCopy`（即根节点）。

### 3. WaybillData/index.vue 和 WaybillDataNew/index.vue

```
activated
  → getTree()
    → companyTreeList({}, `/${companyId}`)
      → 返回 data.model[0]
        → 判断 data.model[0].id === '2'
          → 是：treeList = data.model[0].children，默认选中 children[0]
          → 否：treeList = data.model，默认选中 model[0]
        → 默认回显：realityCompanyName = 选中节点的 label
        → 默认选中：realityCompanyId = 选中节点的 id
        → 保存副本：realityCompanyNameCopy / realityCompanyIdCopy（用于重置）
        → keyArr = 选中节点的 id（用于树高亮）
```

**特殊逻辑：** 当根节点 id 为 '2' 时，跳过根节点，直接取 children 的第一个作为默认选中。

---

## 五、是否能支持树结构的懒加载？

### 当前现状

**不支持懒加载。** 所有调用都是一次性获取完整树（包含所有层级的 children），前端直接渲染完整嵌套结构。

### 改造方案

#### 后端需要

- 提供按层级加载的接口，如 `companyTreeList/{parentId}?lazy=true`，只返回当前层级子节点
- 返回数据增加 `isLeaf` 字段标识是否为叶子节点
- 或增加 `level` 参数控制展开深度

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
    // 加载根节点
    companyTreeList({}, `/${companyId}`).then(data => {
      resolve(data.model)
    })
  } else {
    // 加载子节点
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
2. **全局缓存**：DMS 接口的树数据可以考虑放入 Vuex，避免多个页面重复请求
3. **默认回显兼容**：如果改为懒加载，默认回显逻辑需要调整——首次只加载根节点，默认选中根节点即可，不再依赖 `children[0]`

---

## 六、万级数据量优化方案（详见独立文档）

针对数据量上万、多层级的场景，完整优化方案拆分为两个文档：

- [tree优化方案.md](./tree优化方案.md) — 问题分析 + 后端接口设计
- [tree优化方案-实现.md](./tree优化方案-实现.md) — 前端 Vuex/API/组件/回显方案完整实现
