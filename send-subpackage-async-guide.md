# 发货页微信小程序分包异步化 — 完整实施手册

> **用途说明：** 本文档面向「从零复现」场景。假设当前代码已回退到改造前状态（`pages/send/send.vue` 为完整业务页，无 `sendPages` 分包），按本文档步骤执行即可完成功能等价的改造。

---

## 0. 改造目标与约束

### 目标

- **微信小程序**：将 TabBar 发货页 `pages/send/send` 的业务代码移出主包，减小主包体积
- **H5 / App**：功能与体验不变
- **路由不变**：所有跳转仍使用 `/pages/send/send`

### 硬约束（必须遵守）

1. **TabBar 页必须在主包** — 不能将 `pages/send/send` 整页移入分包
2. **不能改全局路由** — `util/navigation.js` 的 `SEND: '/pages/send/send'` 及所有 `uni.navigateTo` / `switchTab` 路径保持原样
3. **微信小程序 TabBar 页引用分包组件** — 需使用「分包异步化」：`usingComponents` + `componentPlaceholder`
4. **uni-app 生命周期命名冲突** — 组件 `methods` 中**禁止**使用 `onLoad` / `onShow` / `onTabItemTap` 等与页面生命周期同名的方法，必须改为 `handlePageLoad` 等

---

## 1. 改造前基线（原始结构）

```
pages/send/
├── send.vue                    ← 完整业务页（约 2000+ 行，含 template/script/style）
├── const.js                    ← 常量、枚举、defaultForm
├── rules.js                    ← 表单校验规则
├── unitInputRules.js
├── networkMainBodyFreightDifferentialRate.js
└── components/
    ├── common/                 ← 通用表单组件（formInput、formSubsection、tag、thePicker 等）
    ├── goodsQRCode/            ← 首页 index.vue 引用，必须留主包
    ├── priceMode/selectLinkPerson.vue
    ├── alias/aliasName.vue
    ├── custom/customName.vue
    ├── goodsInfo/              ← selectGoods、addGoods
    └── send/                   ← 业务 UI 子组件（地址、货物、价格、调度等）
        ├── selectAddrPart.vue
        ├── goodsInfoPart.vue
        ├── pricePart/
        ├── dispatchPart/
        ├── lostTon.vue
        ├── customerNamePart.vue
        ├── navBar.vue
        ├── foot.vue
        └── ...
```

TabBar 配置（`pages.json`）中已有：

```json
{ "pagePath": "pages/send/send", ... }
```

---

## 2. 改造后目标结构

```
pages/send/
├── send.vue                    ← 【重写】轻量壳页（约 62 行）
├── const.js                    ← 【保留主包】
├── rules.js                    ← 【保留主包】
├── unitInputRules.js           ← 【保留主包】
├── networkMainBodyFreightDifferentialRate.js
├── components/
│   ├── common/                 ← 【保留主包】
│   ├── goodsQRCode/            ← 【保留主包】首页 index.vue 依赖
│   └── priceMode/selectLinkPerson.vue  ← 【保留主包】分包通过 @/pages/send/ 引用
│   └── send/ ...               ← 【可选清理】迁移后可删重复副本

sendPages/                      ← 【新建分包根目录】
├── pages/stub/index.vue        ← 分包占位页，确保 send-core 被打包
└── send/
    ├── send-core.vue           ← 【迁移】原 send.vue 全部业务逻辑
    └── components/             ← 【迁移】原 pages/send/components 下业务组件
        ├── send/               ← selectAddrPart、goodsInfoPart 等
        ├── goodsInfo/          ← selectGoods、addGoods
        ├── alias/              ← aliasName
        ├── custom/             ← customName
        └── goodsQRCode/        ← 分包内副本（主包仍保留给 index 用）
```

---

## 3. 分步实施指南

### 步骤 1：创建分包目录并迁移业务代码

#### 1.1 新建目录

```bash
mkdir -p sendPages/send/components
mkdir -p sendPages/pages/stub
```

#### 1.2 复制（或移动）以下目录/文件到 `sendPages/send/`

| 源路径 | 目标路径 |
|--------|----------|
| `pages/send/send.vue` | `sendPages/send/send-core.vue`（后续再改，先复制） |
| `pages/send/components/send/` | `sendPages/send/components/send/` |
| `pages/send/components/goodsInfo/` | `sendPages/send/components/goodsInfo/` |
| `pages/send/components/alias/` | `sendPages/send/components/alias/` |
| `pages/send/components/custom/` | `sendPages/send/components/custom/` |

**不要移入主包共享模块：**

- `pages/send/const.js`
- `pages/send/rules.js`
- `pages/send/unitInputRules.js`
- `pages/send/networkMainBodyFreightDifferentialRate.js`
- `pages/send/components/common/` 整个目录
- `pages/send/components/goodsQRCode/`（`pages/index/index.vue` 引用：`import goodsQRCode from '../send/components/goodsQRCode/goodsQRCode.vue'`）
- `pages/send/components/priceMode/selectLinkPerson.vue`

#### 1.3 修正 `send-core.vue` 内的 import 路径

`send-core.vue` 与子组件之间的相对引用保持不变（目录层级与原来一致）：

```javascript
// sendPages/send/send-core.vue
import selectAddrPart from './components/send/selectAddrPart'
import goodsInfoPart from './components/send/goodsInfoPart'
import pricePart from './components/send/pricePart'
import dispatchPart from './components/send/dispatchPart/index'
import lostTon from './components/send/lostTon'
import customerNamePart from './components/send/customerNamePart'
import navBar from './components/send/navBar'
import foot from './components/send/foot'
```

**主包共享模块继续用绝对路径 `@/pages/send/...`：**

```javascript
import { defaultForm, ... } from '@/pages/send/const'
import { rulesFn, customRules, watchFormRules } from '@/pages/send/rules'
import { getFreightDifferRateDetail } from '@/pages/send/networkMainBodyFreightDifferentialRate.js'
```

**子组件内引用规则（迁移后核对）：**

| 引用类型 | 路径写法 | 示例 |
|----------|----------|------|
| 主包共享 | `@/pages/send/...` | `@/pages/send/components/common/form/formInput` |
| 分包内同级 | `./` 或 `../` | `import selectGoods from '../goodsInfo/selectGoods'` |
| 分包内 send 子目录 | `./selectAddrPart/...` | `import formNetWorkBody from './selectAddrPart/formNetWorkBody'` |

**常见路径错误（必须避免）：**

- `./const` → 应改为 `@/pages/send/const`
- `customerNamePart` 引用 alias/custom → `../alias/aliasName.vue`、`../custom/customName.vue`

---

### 步骤 2：改造 `send-core.vue`（从页面变为组件）

在 `sendPages/send/send-core.vue` 的 `export default` 中做以下修改：

#### 2.1 删除页面级生命周期

**删除**（若存在）：

```javascript
onLoad(options) { ... },
onShow() { ... },
onTabItemTap() { ... },
onBackPress() { ... },
```

将其逻辑分别迁移到对应 `methods`：

| 原生命周期 | 新方法名 | 原逻辑 |
|-----------|---------|--------|
| `onLoad` | `handlePageLoad(options)` | 调用 `this.loadMenu(options)` |
| `onShow` | `handlePageShow()` | `loadCompanyRoundMode()`、`addListeners()`、`getCompanyInfoByCondition()`、`getSystemTime()` |
| `onTabItemTap` | `handleTabItemTap()` | `uni.$wlydTrack.track('owner_delivery')` |
| `onBackPress` | `handlePageBackPress()` | `this.goBack()` |

#### 2.2 新增 props 与桥接逻辑

在 `export default` 顶部增加：

```javascript
export default {
  name: 'SendCore',
  options: {
    styleIsolation: 'shared'   // 见步骤 7 样式章节
  },
  props: {
    pageOptions: { type: Object, default: null },
    showCount: { type: Number, default: 0 },
    tabTapCount: { type: Number, default: 0 },
    backPressCount: { type: Number, default: 0 }
  },
  // ...
}
```

`data` 中增加：

```javascript
_pageLoaded: false,
```

`methods` 中增加初始化链：

```javascript
onSendPageLoad(options) {
  this.tryInitPage(options)
},
tryInitPage(forcedOptions) {
  if (this._pageLoaded) return
  let options = forcedOptions
  if (options === undefined || options === null) {
    options = this.pageOptions
  }
  if (options === null || options === undefined) {
    const pages = getCurrentPages()
    const cur = pages[pages.length - 1]
    options = (cur && cur.options) || {}
  }
  this._pageLoaded = true
  this.handlePageLoad(options)
},
handlePageLoad(options) {
  this.loadMenu(options)
},
handlePageShow() { /* 原 onShow 逻辑 */ },
handleTabItemTap() { /* 原 onTabItemTap 逻辑 */ },
handlePageBackPress() { /* 原 onBackPress 逻辑 */ },
```

#### 2.3 小程序专用生命周期桥接

```javascript
// #ifdef MP-WEIXIN
lifetimes: {
  attached() {
    this.$nextTick(() => {
      this.tryInitPage()
    })
  }
},
// #endif

created() {
  // #ifdef MP-WEIXIN
  uni.$on('SEND_PAGE_LOAD', this.onSendPageLoad)
  uni.$on('SEND_PAGE_SHOW', this.handlePageShow)
  uni.$on('SEND_TAB_TAP', this.handleTabItemTap)
  // #endif
},
beforeDestroy() {
  // #ifdef MP-WEIXIN
  uni.$off('SEND_PAGE_LOAD', this.onSendPageLoad)
  uni.$off('SEND_PAGE_SHOW', this.handlePageShow)
  uni.$off('SEND_TAB_TAP', this.handleTabItemTap)
  // #endif
},
mounted() {
  // #ifdef MP-WEIXIN
  this.$nextTick(() => {
    this.tryInitPage()
  })
  // #endif
},
```

#### 2.4 合并 watch（关键：只能有一个 watch 对象）

**错误写法（会导致 H5 空白）：**

```javascript
watch: { pageOptions: {...} },
watch: { ...watchFormRules }  // 后者覆盖前者！
```

**正确写法：**

```javascript
watch: {
  pageOptions: {
    handler(val) {
      if (val !== null && val !== undefined && !this._pageLoaded) {
        this.tryInitPage(val)
      }
    },
    immediate: true
  },
  showCount: {
    handler(val) {
      if (val > 0) this.handlePageShow()
    },
    immediate: true
  },
  tabTapCount(val) {
    if (val > 0) this.handleTabItemTap()
  },
  backPressCount(val) {
    if (val > 0) this.handlePageBackPress()
  },
  ...watchFormRules,
  // 其余业务 watch 保持不变...
},
```

---

### 步骤 3：重写主包壳页 `pages/send/send.vue`

**完整替换**为以下内容（原 send.vue 业务已全部在 send-core）：

```vue
<template>
  <view class="send-page-wrapper">
    <send-core
      :page-options="pageOptions"
      :show-count="showCount"
      :tab-tap-count="tabTapCount"
      :back-press-count="backPressCount"
    />
  </view>
</template>

<script>
import SendCore from '@/sendPages/send/send-core.vue'

const SEND_PAGE_LOAD = 'SEND_PAGE_LOAD'
const SEND_PAGE_SHOW = 'SEND_PAGE_SHOW'
const SEND_TAB_TAP = 'SEND_TAB_TAP'

export default {
  components: {
    SendCore
  },
  data() {
    return {
      pageOptions: null,
      showCount: 0,
      tabTapCount: 0,
      backPressCount: 0
    }
  },
  onLoad(options) {
    uni.hideTabBar()
    this.pageOptions = options || {}
    // #ifdef MP-WEIXIN
    uni.$emit(SEND_PAGE_LOAD, this.pageOptions)
    // #endif
  },
  onShow() {
    uni.hideTabBar()
    this.showCount++
    // #ifdef MP-WEIXIN
    uni.$emit(SEND_PAGE_SHOW)
    // #endif
  },
  onTabItemTap() {
    this.tabTapCount++
    // #ifdef MP-WEIXIN
    uni.$emit(SEND_TAB_TAP)
    // #endif
  },
  onBackPress() {
    this.backPressCount++
  }
}
</script>

<style lang="scss">
.send-page-wrapper {
  min-height: 100vh;
}
</style>
```

**说明：**

- H5/App：通过 props 传递生命周期
- 小程序：props + `uni.$emit` 双通道（应对异步组件加载时序）
- 小程序端壳页**也必须** `import SendCore` 并注册 `components`，不能仅依赖 `usingComponents`

---

### 步骤 4：创建分包占位页

新建 `sendPages/pages/stub/index.vue`：

```vue
<template>
  <view style="display: none">
    <send-core />
  </view>
</template>

<script>
import SendCore from '@/sendPages/send/send-core.vue'

export default {
  components: {
    SendCore
  }
}
</script>
```

**作用：** 让 webpack 将 `send-core` 及其依赖打入 `sendPages` 分包；无此页，分包可能为空。

---

### 步骤 5：修改 `pages.json`

#### 5.1 注册 sendPages 分包

在 `subPackages` 数组**最前面**（或任意位置）添加：

```json
{
  "root": "sendPages",
  "pages": [
    {
      "path": "pages/stub/index",
      "style": {
        "navigationStyle": "custom",
        "navigationBarTitleText": ""
      }
    }
  ]
}
```

#### 5.2 发货 Tab 页配置分包异步组件（仅小程序）

找到 `pages/send/send` 的 style 配置，**按以下格式**添加（注意逗号与条件编译）：

```json
{
  "path": "pages/send/send",
  "style": {
    "navigationStyle": "custom",
    "navigationBarTitleText": "发货"
    // #ifdef MP-WEIXIN
    ,
    "usingComponents": {
      "send-core": "/sendPages/send/send-core"
    },
    "componentPlaceholder": {
      "send-core": "view"
    }
    // #endif
  }
}
```

**⚠️ 逗号陷阱：**

- `usingComponents` 前的逗号**必须**放在 `// #ifdef MP-WEIXIN` 块内
- 若整块 `#ifdef` 被去掉后留下 `"发货",` 尾随逗号，H5 会 JSON 解析失败

#### 5.3 配置预下载规则

在 `preloadRule` 中添加/修改：

```json
"preloadRule": {
  "pages/send/send": {
    "network": "all",
    "packages": [
      "sendPages",
      "goodsPages"
    ]
  },
  "pages/index/index": {
    "network": "all",
    "packages": [
      "pagesC",
      "sendPages"
    ]
  }
}
```

`goodsPages` 预下载原因：发货页会跳转到地址选择、调度配置、货物新增等 `goodsPages` 分包页面。

---

### 步骤 6：修改 `manifest.json`（微信小程序）

在 `mp-weixin` 节点确认存在：

```json
"optimization": {
  "subPackages": true
},
"lazyCodeLoading": "requiredComponents"
```

---

### 步骤 7：样式隔离修复（白色卡片背景）

#### 问题现象

小程序中 `.floor-child` 白色圆角卡片背景消失，H5/App 正常。

#### 原因

分包异步组件默认 `styleIsolation: 'isolated'`，`send-core.vue` 中 `/deep/ .floor-child` 无法穿透子组件。

#### 修复（最小改动，不要用 scss @import 相对路径）

在以下 8 个文件的 `export default` 中添加（`navBar.vue` 若已有则跳过）：

```javascript
options: {
  styleIsolation: 'shared'
},
```

| 文件 |
|------|
| `sendPages/send/send-core.vue` |
| `sendPages/send/components/send/selectAddrPart.vue` |
| `sendPages/send/components/send/goodsInfoPart.vue` |
| `sendPages/send/components/send/pricePart/index.vue` |
| `sendPages/send/components/send/dispatchPart/index.vue` |
| `sendPages/send/components/send/lostTon.vue` |
| `sendPages/send/components/send/customerNamePart.vue` |
| `sendPages/send/components/send/navBar.vue` |

`send-core.vue` 中保留原有样式（无需修改）：

```scss
/deep/ {
  .floor-child {
    background: #ffffff;
    border-radius: 20rpx;
    position: relative;
  }
}
```

**❌ 不要采用：** 新建 `floor-card.scss` + `@import '../../styles/floor-card.scss'` — 小程序分包环境下相对路径 sass import 会编译失败。

---

### 步骤 8：goodsPages 分包关联修复（若编译/运行报错）

发货页跳转大量 `goodsPages` 页面。若出现 vendor.js 或组件找不到：

1. **`selectDriverPopup.vue`** 应位于 `goodsPages/components/schedulingInfo/selectDriverPopup.vue`，由 `goodsPages/schedulingInfo/schedulingIDriverinfo.vue` 引用：

   ```javascript
   import selectPopup from '../components/schedulingInfo/selectDriverPopup.vue'
   ```

2. **`goodsPopus.vue`、`carPicker.vue`** 同理放在 `goodsPages/components/schedulingInfo/`

3. 若组件根节点用 `<div>` 导致小程序模板报错，改为 `<view>` 或使用 `u-popup` 作为根节点

4. `preloadRule` 中 `pages/send/send` 需包含 `goodsPages` 分包

---

## 4. 路由与引用清单（改造后无需修改）

以下路径**保持不变**：

| 文件 | 路径 |
|------|------|
| `util/navigation.js` | `SEND: '/pages/send/send'` |
| `pages/index/tobePublished/tobePublished.vue` | `url: '/pages/send/send?params=' + ...` |
| `minePages/mine/mySource/goodsList.vue` | `url: "/pages/send/send?params=" + ...` |
| `minePages/mine/enRoute/enRouteList.vue` | `url: '/pages/send/send'` |
| `send-core.vue` 提交成功跳转 | `url: '/pages/send/send'` |
| `pages.json` tabBar | `"pagePath": "pages/send/send"` |

---

## 5. 生命周期数据流（理解用）

```
用户打开 Tab 发货页
        │
        ▼
pages/send/send.vue（主包壳页）
  onLoad  → pageOptions = options
         → uni.$emit('SEND_PAGE_LOAD', options)  [MP]
  onShow  → showCount++
         → uni.$emit('SEND_PAGE_SHOW')          [MP]
  onTabItemTap → tabTapCount++                  [MP]
        │
        │ props 传递 + uni.$emit 双通道
        ▼
sendPages/send/send-core.vue（分包异步组件）
  watch pageOptions → tryInitPage()
  uni.$on SEND_PAGE_LOAD → tryInitPage()
  lifetimes.attached / mounted → tryInitPage()  [兜底]
  tryInitPage → getCurrentPages() 读 options   [最终兜底]
        │
        ▼
  handlePageLoad → loadMenu(options)  // 权限、解析 params、初始化表单
  handlePageShow → 刷新数据、注册监听
  handleTabItemTap → 埋点
```

`_pageLoaded` 标志确保 `loadMenu` 只执行一次。

---

## 6. 完整文件清单（sendPages 分包内）

```
sendPages/
├── pages/stub/index.vue
└── send/
    ├── send-core.vue
    └── components/
        ├── alias/aliasName.vue
        ├── custom/customName.vue
        ├── goodsInfo/addGoods.vue
        ├── goodsInfo/selectGoods.vue
        ├── goodsQRCode/goodsQRCode.vue          ← 分包副本，主包仍保留
        └── send/
            ├── batchPaymentSwitch.vue
            ├── customerNamePart.vue
            ├── dispatchPart/
            │   ├── goodsPopus.vue
            │   ├── index.vue
            │   └── pickerContainerType.vue
            ├── foot.vue
            ├── goodsInfoPart.vue
            ├── goodsInfoPart/unitPicker.vue
            ├── lostTon.vue
            ├── navBar.vue
            ├── pickerDeductibleType.vue
            ├── pricePart/
            │   ├── formAssuranceServices.vue
            │   ├── formPriceMode.vue
            │   ├── index.vue
            │   ├── pickerBargainConfig.vue
            │   └── protocol.vue
            ├── selectAddrPart.vue
            └── selectAddrPart/
                ├── formCompanyTransportationType.vue
                ├── formDriverTransportationType.vue
                ├── formNetWorkBody.vue
                ├── pickerNetWorkBody.vue
                └── pickerTransportType.vue
```

---

## 7. 主包保留文件清单

```
pages/send/
├── send.vue                         ← 壳页（重写）
├── const.js
├── rules.js
├── unitInputRules.js
├── networkMainBodyFreightDifferentialRate.js
└── components/
    ├── common/                      ← 全部保留
    ├── goodsQRCode/goodsQRCode.vue  ← index.vue 依赖，必须主包
    └── priceMode/selectLinkPerson.vue
```

迁移完成后，`pages/send/components/send/` 下的旧副本**可择机删除**（确认无其他引用后），进一步减小主包。

---

## 8. 已知问题与精确修复对照表

| # | 现象 | 根因 | 修复 |
|---|------|------|------|
| 1 | H5 编译 JSON 报错 | `#ifdef MP-WEIXIN` 去掉后 `"发货",` 尾随逗号 | 逗号放进条件编译块内 |
| 2 | H5 页面空白 | 两个 `watch` 对象，后者覆盖前者 | 合并为一个 `watch`，含 `...watchFormRules` |
| 3 | H5 报错 `onTabItemTap is not a function` | methods 中方法与 uni 生命周期同名 | 改名为 `handleTabItemTap` 等 |
| 4 | 小程序 `$refs` 报错 | 异步组件未就绪访问 `$refs` | 生命周期用 props + 事件，不用 `$refs` 桥接 |
| 5 | 小程序页面空白 | 壳页未 import 组件；props 时序不可靠 | 壳页 import + 注册；`lifetimes.attached` + `tryInitPage()` |
| 6 | 文件找不到 `./const` | const 留主包 | 改为 `@/pages/send/const` |
| 7 | customerNamePart 路径错误 | 组件迁移后相对路径变化 | 用 `../alias/`、`../custom/` |
| 8 | goodsQRCode 主包找不到 | 被误移分包 | 主包 `pages/send/components/goodsQRCode/` 必须保留 |
| 9 | goodsPages vendor 报错 | selectDriverPopup 位置不对 | 移到 `goodsPages/components/schedulingInfo/` |
| 10 | 小程序白卡片无背景 | 样式隔离 | 8 个组件加 `styleIsolation: 'shared'` |
| 11 | scss import 编译失败 | 分包相对路径不可解析 | 不用独立 scss import，用 styleIsolation 方案 |

---

## 9. 验证清单

### 微信小程序

- [ ] 微信开发者工具 → 清缓存 → 重新编译
- [ ] 详情 → 本地代码 → 确认主包体积下降，`sendPages` 分包存在
- [ ] 发货 Tab 正常展示，非空白
- [ ] 地址区、货物信息区等 **白色圆角卡片** 背景正常
- [ ] 顶部渐变背景、底部固定 foot 栏正常
- [ ] 带参跳转：再来一单 / 去发布（`?params=...`）
- [ ] 提交成功后跳转
- [ ] 地址簿、调度配置、货物新增等 `goodsPages` 跳转正常

### H5

- [ ] 发货 Tab 非空白，表单可交互
- [ ] Tab 反复切换无报错
- [ ] 无 `onTabItemTap is not a function`
- [ ] 提交流程正常

### App

- [ ] 同 H5 验证项

### 路由

- [ ] 全局搜索确认无 `/sendPages/send/send-core` 作为页面路径跳转（仅作组件引用）
- [ ] 所有发货入口仍为 `/pages/send/send`

---

## 10. 实施顺序建议（给新 Agent 的执行 Checklist）

```
□ 1.  创建 sendPages 目录结构
□ 2.  复制 send.vue → send-core.vue，复制 components 业务目录
□ 3.  修正 send-core 及子组件 import 路径（@/pages/send/ 引用主包共享模块）
□ 4.  send-core：删页面生命周期，加 props/watch/tryInitPage/桥接方法
□ 5.  send-core：合并 watch（含 watchFormRules）
□ 6.  send-core：加 styleIsolation: 'shared'
□ 7.  6 个 floor-child 子组件加 styleIsolation: 'shared'
□ 8.  重写 pages/send/send.vue 为壳页
□ 9.  创建 sendPages/pages/stub/index.vue
□ 10. pages.json：注册 sendPages 分包 + usingComponents + componentPlaceholder
□ 11. pages.json：preloadRule 加 sendPages、goodsPages
□ 12. manifest.json：确认 lazyCodeLoading
□ 13. 确认 goodsQRCode 留主包
□ 14. 处理 goodsPages 组件路径问题（如有）
□ 15. 三端编译验证
□ 16. （可选）删除 pages/send/components/send 重复副本
```

---

## 11. 架构示意

```
┌──────────────────────────────────────────────────────────────┐
│  主包                                                         │
│  pages/send/send.vue（TabBar 入口，~62行）                    │
│    ├── import SendCore（H5/App/MP 同步引用）                  │
│    ├── props: pageOptions / showCount / tabTapCount           │
│    └── MP: uni.$emit 事件广播                                 │
│                                                               │
│  pages/send/const.js、rules.js、components/common/（共享）    │
│  pages/send/components/goodsQRCode/（index 页依赖）           │
└───────────────────────────┬──────────────────────────────────┘
                            │ usingComponents（仅 MP）
                            │ /sendPages/send/send-core
                            ▼
┌──────────────────────────────────────────────────────────────┐
│  分包 sendPages                                               │
│  pages/stub/index.vue（占位，确保打包）                       │
│  send/send-core.vue（原 send.vue 全部业务）                   │
│  send/components/（UI 子组件）                                │
└──────────────────────────────────────────────────────────────┘
                            │ navigateTo
                            ▼
┌──────────────────────────────────────────────────────────────┐
│  分包 goodsPages（地址、调度、货物等二级页）                   │
└──────────────────────────────────────────────────────────────┘
```

---

## 12. 使用说明

将本文档交给新 Agent 时，只需说明：

> **「按 `docs/send-subpackage-async-guide.md` 从零实施，当前代码为改造前基线。」**

即可独立复现全部改造。若某步遇到具体报错，可对照第 8 节问题表逐项排查。
