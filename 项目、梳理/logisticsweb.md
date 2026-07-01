# logisticsweb 项目梳理

## 项目概览

**项目名称**: `app-3pl` (万联易达物流平台 - 3PL 三方物流)

**技术栈**:
- Vue 2.6 + Vue Router 3 + Vuex 3
- Element UI 2.x (组件库)
- Vue CLI 4 (构建工具，基于 Webpack 4)
- SCSS (样式预处理)
- Axios (HTTP 请求)
- qiankun 微前端架构 (作为子应用接入)
- **node v14 强制**

**运行端口**: 9202，路由 base 路径为 `/yw/`

---

## 核心架构特点

### 1. 微前端子应用

项目是 qiankun 微前端架构中的一个子应用。`main.js` 中暴露了 `bootstrap`、`mount`、`unmount` 生命周期，可以独立运行也可以被主应用加载。webpack 输出配置为 UMD 格式。

### 2. 动态路由 + 权限控制

路由分两部分：
- **静态路由** (`src/router/routers.js`): 登录、注册、找回密码、404 等公共页面
- **动态路由** (`src/router/index.js`): 登录后通过接口拉取用户菜单，动态生成 `/userBase/*` 下的业务路由，实现按权限控制页面访问

页面组件通过 `import('@/views/userBase/${path}')` 动态加载。

---

## 目录结构说明

```
src/
├── api/              # 接口层，按业务模块拆分 (80+ 文件)
├── assets/           # 静态资源
├── components/       # 公共组件 (上传、分页、弹窗、表格拖拽等)
├── config/           # 全局配置 (枚举、logo、工作台配置)
├── constants/        # 常量定义
├── directive/        # 自定义指令
├── icons/            # iconfont 图标
├── layout/           # 布局组件 (Layout.vue 主框架)
├── mixins/           # 公共 mixins (计算、校验、字典等)
├── router/           # 路由配置 + 路由守卫
├── scss/             # 页面级样式
├── styles/           # 全局样式 (主题、重置、Element 覆盖)
├── utils/            # 工具函数 (请求封装、鉴权、格式化等)
├── vendor/           # 第三方工具 (Excel 导出)
├── views/            # 页面视图
│   ├── login/        # 登录
│   ├── register/     # 注册
│   ├── findpwd/      # 找回密码
│   └── userBase/     # 核心业务页面 (100+ 模块)
├── vuex/             # 状态管理
│   └── modules/      # Vuex 模块 (app、workspace、payment 等)
├── App.vue           # 根组件
├── main.js           # 入口文件
└── public-path.js    # qiankun publicPath 设置
```

---

## 核心业务模块 (views/userBase)

| 模块 | 说明 |
|------|------|
| `workspace/` | 工作台 (首页) |
| `orderTransportOrderManagement/` | 运输订单管理 |
| `waybillCollection/` | 运单管理 |
| `transportSendManagement/` | 运输派单管理 |
| `payment/` / `paymentTob/` | 付款管理 |
| `waybillSettlement/` | 运单结算 |
| `customerManagement/` | 客户管理 |
| `supplierManagement/` | 供应商管理 |
| `drivermanagement/` | 司机管理 |
| `carsmanagement/` | 车辆管理 |
| `contractManagement/` | 合同管理 |
| `invoice/` | 发票管理 |
| `logisticsTrack/` | 物流追踪 |
| `oilGasListManagement/` | 油气管理 |
| `risk/` | 风控管理 |
| `commonlines/` | 常用线路 |
| `receivablesTob/` | 应收管理 |
| `supplierSettlement/` | 供应商结算 |
| `customerSettlement/` | 客户结算 |
| `shipmentMatch/` | 货源匹配 |
| `vehicleMonitoring/` | 车辆监控 |

---

## 关键文件指引

| 文件 | 作用 |
|------|------|
| `src/main.js` | 应用入口，qiankun 生命周期 |
| `src/router/index.js` | 路由守卫，动态菜单加载逻辑 |
| `src/router/routers.js` | 静态路由定义 |
| `src/router/micro-router.js` | 微前端模式路由创建 |
| `src/utils/request.js` | Axios 请求封装 |
| `src/utils/auth.js` | Token 管理 |
| `src/utils/useMainProps.js` | 微前端 props 管理、路由创建 |
| `src/utils/actions.js` | 微前端主子应用通信 |
| `src/utils/microAppDialog.js` | 微前端弹窗挂载修复 |
| `src/vuex/modules/app.js` | 核心 store (用户信息、菜单、权限) |
| `vue.config.js` | Webpack/开发服务器配置 |
| `build/proxy.js` | 开发环境接口代理配置 |
| `.env.*` | 各环境变量配置 |

---

## 开发命令

```bash
npm run dev          # 本地开发 (端口 9202)
npm run build:uat    # 构建 UAT 环境
npm run build:prod   # 构建生产环境
npm run lint:fix     # ESLint 修复
```

---

## qiankun 微前端详解

### 角色定位

`logisticsweb` (app-3pl) 是 qiankun 微前端架构中的**子应用**，不是主应用。支持两种运行模式：
1. **独立运行** — 直接访问 `localhost:9202/yw/`，自行管理登录、菜单、权限
2. **被主应用加载** — 作为微前端子应用嵌入，登录态和路由由主应用控制

### 关键实现

#### 1. publicPath 动态设置 (`src/public-path.js`)

被 qiankun 加载时，通过 `window.__INJECTED_PUBLIC_PATH_BY_QIANKUN__` 动态设置 webpack publicPath，确保静态资源路径正确。

#### 2. 生命周期暴露 (`src/main.js`)

暴露三个标准生命周期：
- `bootstrap` — 子应用初始化（只调用一次）
- `mount` — 子应用挂载（每次激活时调用）
- `unmount` — 子应用卸载（切走时调用）

独立运行时通过 `!window.__POWERED_BY_QIANKUN__` 判断，直接调用 `render()`。

#### 3. mount 阶段做的事

- 通过 `props.getToken()` 获取主应用的 token 并写入本地 cookie
- 从 `props.userStore` 获取用户信息、企业信息，写入 Vuex store
- 通过 `actions.onGlobalStateChange` 订阅主应用的全局状态变化
- 调用 `render(props)` 启动 Vue 实例

#### 4. UMD 输出格式 (`vue.config.js`)

```javascript
configureWebpack: {
  output: {
    jsonpFunction: `webpackJsonp_${name}`,
    library: `${name}-[name]`,
    libraryTarget: 'umd'
  }
}
```

qiankun 要求子应用打包为 UMD 格式，主应用通过 library 名称找到生命周期函数。

#### 5. 两套路由模式 (`src/utils/useMainProps.js`)

- **独立运行**: 使用 `src/router/routers.js` 静态路由 + `src/router/index.js` 动态路由
- **微前端模式**: 使用 `microRoutes(props)` — 路由由主应用下发，通过 `src/router/micro-router.js` 的 `createRouter` 创建

微前端模式下，主应用传入 `routerBase` 和 `routes`，子应用据此创建路由实例，不再自己管理菜单权限。

#### 6. 通信机制 (`src/utils/actions.js`)

通过 qiankun 的 `globalState` API 实现主子应用通信：
- `setGlobalState` — 子应用向主应用发消息
- `onGlobalStateChange` — 监听主应用状态变化

#### 7. 弹窗挂载修复 (`src/utils/microAppDialog.js`)

重写 `document.body.appendChild`，将 Element UI 弹窗 (Dialog/Message/Notification 等) 挂载到子应用容器内而非 body，解决微前端环境下弹窗样式隔离问题。

### 数据流总结

```
主应用
  ├── 注册子应用 (app-3pl, entry: /yw/)
  ├── mount 时传入 props:
  │     ├── container (DOM 容器)
  │     ├── routerBase (路由前缀)
  │     ├── routes (路由列表)
  │     ├── getToken() (获取 token)
  │     ├── userStore (用户/企业信息)
  │     └── actions (全局状态通信)
  │
  └── 子应用 (logisticsweb)
        ├── 设置 token → 本地 cookie
        ├── 设置用户信息 → Vuex store
        ├── 创建路由 → 基于主应用下发的 routes
        └── 挂载 Vue 实例 → 到主应用指定的 container
```

---

## 需要注意的点

1. **动态路由**: 所有业务页面的路由不是写死的，而是后端接口返回菜单数据后动态注册的，所以在 `routers.js` 里看不到业务页面的路由定义。
2. **微前端模式**: 项目既可以独立运行，也可以作为 qiankun 子应用被主应用加载，token 和用户信息可以从主应用传入。
3. **API 命名规范**: 接口文件以 `userBase.` 为前缀按模块命名。
4. **Mock 数据**: `mock/` 目录有 mock server，开发时可以用。
5. **多环境部署**: 通过 `.env.*` 文件和 `nginx/` 下的配置区分 dev/test/prerelease/release 环境。
6. **publicPath**: 所有资源路径以 `/yw/` 为前缀，路由也使用 history 模式 + `/yw/` base。
7. **Element UI 全局 size**: 全局设置为 `mini`，所有组件默认使用最小尺寸。
8. **弹窗样式隔离**: 微前端模式下 Element UI 弹窗会被重定向挂载到子应用容器，unmount 时恢复。
