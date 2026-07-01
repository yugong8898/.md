# 项目 Vuex 工作流总结

以 `childCompanyList`（子公司列表）为例，说明本项目中 Vuex 的完整数据流。

## 整体数据流

```
组件 dispatch('app/getChildCompany')
        │
        ▼
   Action: getChildCompany
        │  调用 API: getOrganizationTreeList()
        │  等待异步响应
        ▼
   commit('SET_CHILD_COMPANY', data.model)
        │
        ▼
   Mutation: SET_CHILD_COMPANY
        │  state.childCompanyList = value
        ▼
   State 更新 → Getter 响应式更新 → 组件视图自动刷新
```

## 各层职责

### 1. State — 定义数据

```js
// src/vuex/modules/app.js
const state = {
  childCompanyList: [], // 子公司列表，初始为空数组
}
```

State 是数据的唯一来源（Single Source of Truth）。

### 2. Getters — 对外暴露数据

```js
const getters = {
  get_childCompany: state => state.childCompanyList,
}
```

组件通过 `this.$store.getters['app/get_childCompany']` 或 `mapGetters` 读取数据。Getter 具有响应式特性，state 变化时自动更新。

### 3. Mutations — 修改数据的唯一入口

```js
const mutations = {
  SET_CHILD_COMPANY: (state, value) => {
    state.childCompanyList = value
  },
}
```

- Mutation 必须是**同步**的
- 是唯一能直接修改 state 的地方
- 便于 DevTools 追踪状态变更

### 4. Actions — 处理异步逻辑

```js
const actions = {
  getChildCompany({ commit, state }, payload) {
    getOrganizationTreeList({
      companyCode: state.companyId
    }).then(data => {
      if (data.succeed) {
        commit('SET_CHILD_COMPANY', data.model)
      }
    })
  },
}
```

- Action 负责调用 API、处理异步逻辑
- 拿到结果后通过 `commit` 触发 mutation 写入 state
- Action 可以读取 `state` 获取当前状态作为请求参数

### 5. 组件中触发

```js
// 在组件中 dispatch action
this.$store.dispatch('app/getChildCompany')
```

## 模块化

本项目使用了 `namespaced: true`，所以：

- dispatch 时需要带模块前缀：`dispatch('app/getChildCompany')`
- getter 访问时也需要前缀：`getters['app/get_childCompany']`
- mutation 在模块内部 commit 时不需要前缀

## 设计原则

| 原则 | 说明 |
|------|------|
| 单向数据流 | 组件 → dispatch → action → commit → mutation → state → 组件 |
| 状态可追踪 | 所有修改必须经过 mutation，DevTools 可记录每次变更 |
| 异步隔离 | 异步操作只在 action 中进行，mutation 保持同步纯函数 |
| 模块化 | 通过 namespaced 模块划分职责，避免命名冲突 |
