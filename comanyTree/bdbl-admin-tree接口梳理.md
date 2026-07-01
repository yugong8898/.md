# billing 平台（bdbl-admin）企业树接口梳理

## 一、接口定义

**只有一个接口：`PlatformUmCompany/companyTreeList`（baseUrl）**

**定义位置：** `src/api/login.js` — `getOrganizationTreeList`

```js
// 根据公司编码获取该公司下所有子集公司接口【大藩-林枫】
export function getOrganizationTreeList(payload) {
  return request({
    url: baseUrl + '/PlatformUmCompany/companyTreeList'
    // url: baseUrl + '/PlatformUmCompany/companyTreeList/' + payload.companyCode
  })
}
```

- 不传参数，直接获取当前登录用户所属公司的完整组织树
- 注释中有旧写法 `'/PlatformUmCompany/companyTreeList/' + payload.companyCode`，已弃用
- 与 3PL（logisticsweb）的 `getOrganizationTreeList` 定义完全一致

---

## 二、使用页面汇总

| 接口 | 使用位置 | 调用方式 | 用途 |
|------|---------|---------|------|
| PlatformUmCompany/companyTreeList | `src/vuex/modules/app.js` → action `getChildCompany` | Vuex 全局状态 | 存入 `state.childCompanyList` |
| PlatformUmCompany/companyTreeList | `src/router/index.js` → `loadMenus` | ~~应用启动时 dispatch~~（**已注释**） | 原本在路由初始化时调用，现已注释掉 |
| PlatformUmCompany/companyTreeList | `src/layout/components/Header.vue` | getter `get_childCompany` | 顶部导航组织机构切换树 |

---

## 三、全局状态分析

### PlatformUmCompany/companyTreeList — 走 Vuex 全局状态

**调用链路（当前实际状态）：**

```
❌ 应用启动时（router/index.js loadMenus）
   → store.dispatch('app/getChildCompany')   ← 已被注释，不再触发
   → store.dispatch('app/getAgencyTreeList') ← 已被注释，不再触发
```

> `src/router/index.js` 中的两行 dispatch 均已注释掉，意味着**当前应用启动时不会主动加载企业树数据**。

**Vuex action 定义（app.js）：**

```js
getChildCompany({ commit, state }, payload) {
  getOrganizationTreeList({
    companyCode: state.companyId
  }).then((data) => {
    if (data.succeed) {
      commit('SET_CHILD_COMPANY', data.model)
    }
  })
}
```

**消费方：**

`Header.vue` 通过 `mapGetters({ childCompany: 'app/get_childCompany' })` 获取，watch `childCompany` 变化后调用 `getCompanyTree()` 渲染到顶部下拉面板的 "业务归属" tab。

---

## 四、Header.vue 默认回显逻辑

```
childCompany / agemcyChildCompany / organizationControl 任意变化
  → watch 触发 init()
    → getCompanyTree(childCompany, agemcyChildCompany, organizationControl)
      → 根据权限 btnEnter 判断是否展示 "child"（业务归属）tab
      → 根据权限 btnAgemcy 判断是否展示 "agemcy"（组织机构）tab
      → hasData = 是否有任意 tab 有数据
      → 默认激活第一个有数据的 tab
      → treeList = 第一个有数据 tab 的 data
```

不做默认选中节点，仅展示树结构供用户手动点击"进入"切换公司。

**切换公司逻辑：**

```
点击树节点"进入"按钮
  → handleChildCompanyEnter(data)
    → changeChildCompany(data.id)
      → switchCompanyId({ companyId, openMenuType: 'child'=1 / 'agemcy'=2 })
        → 获取新 token → setToken → setSwitchCompanyId
          → location.href = '/yw/'（刷新跳转）
```

---

## 五、与 3PL / 4PL 的对比

| 对比项 | 3PL（logisticsweb） | 4PL（platformweb） | billing（bdbl-admin） |
|-------|---------------------|-------------------|-----------------------|
| 接口 | `PlatformUmCompany` + `DmsPlatformUmCompany` | 仅 `DmsPlatformUmCompany` | 仅 `PlatformUmCompany` |
| Vuex 全局状态 | 有，应用启动预加载 | 无 | 有，但**预加载已注释** |
| 应用启动预加载 | 有（router beforeEach） | 无 | **已注释，不触发** |
| Header 树展示 | 有 | 有 | 有，支持"业务归属"+"组织机构"双 tab |
| 切换公司入口 | Header 树节点 | 无独立切换入口 | Header 树节点"进入"按钮 |
| 切换公司方式 | `switchCompanyId` | — | `switchCompanyId`（同接口） |
| 页面级本地调用 | 有（多个页面独立调用 DMS 接口） | 有（多个页面独立调用 DMS 接口） | **无**，仅走全局状态 |

---

## 六、存在的问题

1. **预加载已注释，树数据无法加载**：`router/index.js` 中 `getChildCompany` 和 `getAgencyTreeList` 两行 dispatch 均已注释，导致应用启动后 `childCompanyList` 始终为空数组，Header 的企业切换树**实际无数据展示**。若此功能仍需使用，需恢复这两行调用。

2. **`agencyTreeList` 有定义但效果同上**：`getAgencyTreeList` action 也走同样路径（`agencyTreeList` 接口），同样因注释而不触发。

3. **`getOrganizationTreeList` 传参但接口不用**：action 中传入了 `{ companyCode: state.companyId }`，但接口实现中 `payload` 完全没有被用到（URL 写死，不拼接 companyCode），注释中的旧写法已被废弃，当前等同于无参请求。

---

**文档版本**: v1.0

**最后更新**: 2026年06月

**整理人**: 王新骏
