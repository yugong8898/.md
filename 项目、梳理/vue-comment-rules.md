# Vue 注释规范

## 核心原则

**注释的唯一价值是说出代码说不出的信息。**

- ✅ 写：业务约束、触发条件、非显然的取值含义、副作用、为什么这样写
- ❌ 不写：重复字段名/方法名、描述代码结构（如"第一行""右侧表单"）、显而易见的逻辑

快速判断：

```
这段代码，一个熟悉 Vue 和本项目的开发者，
不看注释能在 10 秒内理解吗？

  是 → 不写注释
  否 → 写注释，且只写看不出来的那部分
```

---

## 一、组件头部 JSDoc（强制）

**每个组件必须有**，位置在 `<script>` 内、`export default {` 或 `defineProps` 之前。

### Vue 2（Options API）

```javascript
/**
 * ComponentName - 一句话说明组件职责
 * 补充说明复杂逻辑、数据来源、渲染条件等背景（可选，多行）。
 *
 * 事件（有对外事件时必须列出）：
 *   event-name(param: type)   - 触发时机说明
 *
 * 用法示例（Props 较多或使用方式不直观时补充）：
 *   <ComponentName :prop-a="xxx" @event-name="handler" />
 */
export default {
  name: 'ComponentName',
```

### Vue 3（`<script setup>`）

```javascript
/**
 * ComponentName - 一句话说明组件职责
 * 补充说明复杂逻辑、数据来源、渲染条件等背景（可选，多行）。
 *
 * 事件（有对外事件时必须列出）：
 *   event-name(param: type)   - 触发时机说明
 *
 * 用法示例（Props 较多或使用方式不直观时补充）：
 *   <ComponentName :prop-a="xxx" @event-name="handler" />
 */

const props = defineProps({ ... })
const emit = defineEmits(['event-name'])
```

### 各栏填写条件

| 栏目 | 必填条件 |
|------|---------|
| 组件名 + 一句话职责 | 必填 |
| 补充背景说明 | 有复杂背景、特殊限制时写 |
| 事件列表 | 有 `$emit` / `emit` 时必须列出 |
| 用法示例 | Props ≥ 4 个或使用方式不直观时写 |

### 实际示例

```javascript
/**
 * SettlementInfo - 结算信息组件
 * 展示运单结算相关的表单字段（单价、重量、运费、结算主体、银行卡等）及装卸货磅单图片。
 *
 * 图片区域：左侧轮播展示磅单照片，切换装货/卸货 Tab，点击可全屏预览并下载。
 * 图片数据由组件内部根据 waybillId + detail.transportType 自动拉取，
 * 仅 transportType 在 WEIGH_BILL_STATUS_MAP 中的运输类型（1/2/3）有磅单。
 *
 * 事件：
 *   input-change(tip: string)     - 单价/结算数量/结算重量变更，父组件据此触发运费重算
 *   open-edit-load-weight         - 点击"修改重量"按钮
 *   open-confirm-loss             - 点击"确认亏吨货损"按钮
 *   load-more                     - 结算主体下拉触底，父组件加载下一页
 */
export default {
  name: 'SettlementInfo',
```

---

## 二、Props 注释规则

只在以下情况写注释，其余不写：

- prop 名称无法传达取值含义（枚举值、魔法数字）
- 有非显然的副作用或联动效果
- 有特殊的默认值约定

✅ 正确示例：

```javascript
props: {
  // isBindCard=false 时结算主体字段显示未绑卡样式（红色边框）
  bindCardInfo: {
    type: Object,
    default: () => ({ isBindCard: true, payeePhone: '' })
  },
  // splitFlag==='10' 时展示委托转账区域
  splitFlag: {
    type: String,
    default: ''
  },
  // 直接透传父组件 el-form 的 model，不做深拷贝
  formModel: {
    type: Object,
    default: () => ({})
  }
}
```

❌ 禁止写——名字本身已说明一切：

```javascript
props: {
  // 是否只读       ← 禁止
  readonly: { type: Boolean, default: false },
  // 加载状态       ← 禁止
  loading: { type: Boolean, default: false },
  // 运单 ID        ← 禁止
  waybillId: { type: String, default: '' }
}
```

---

## 三、模板注释规则

只注释以下情况：

- 元素位置/顺序有意为之的特殊原因
- 枚举值含义（魔法字符串）
- 渲染条件涉及多个业务状态的联合判断

✅ 正确示例：

```html
<!-- 放在 settlement-body 外，避免 flex 容器约束全屏效果 -->
<el-image-x v-show="false" ref="billPreviewRef" ... />

<!-- cargoCompensationConfirmFlag: 0-不处理 1-待处理 2-已确认 3-未超吨 -->
<el-tooltip :disabled="detail.cargoCompensationConfirmFlag !== '1' ...">

<!-- 已上报的运单（regulatoryReportingStatus=4 或 busStatus=320）不允许修改 -->
<el-button v-if="showEditActions && detail.regulatoryReportingStatus !== '4' ..." />
```

❌ 禁止写纯结构描述：

```html
<!-- 第一行 -->          ← 禁止
<!-- 右侧表单 -->        ← 禁止
<!-- 备注区域 -->        ← 禁止
<!-- 结算信息 -->        ← 禁止
<!-- Tab -->             ← 禁止
```

---

## 四、方法注释规则

### 行内单行注释

解释"为什么"，不解释"做什么"：

```javascript
// 铁路/水运等无磅单的运输类型不在 WEIGH_BILL_STATUS_MAP 中，直接重置
const statusConf = WEIGH_BILL_STATUS_MAP[transportType]
if (!statusConf) { ... }

// 40: 导航栏高度；60: 页面顶部固定头；20: 视觉留白
container.scrollTop = offset - 40 - 60 - 20
```

### 方法级 JSDoc

仅对工具函数、公共方法、逻辑复杂的私有方法写：

```javascript
/**
 * 累加目标元素相对于指定容器的 offsetTop，得到容器内绝对偏移量。
 * 不能用 getBoundingClientRect，因为容器内有 sticky 元素会影响计算。
 * @param {HTMLElement} el
 * @param {HTMLElement} container
 * @returns {number}
 */
const getOffsetToContainer = (el, container) => { ... }
```

❌ 禁止写叙述性注释：

```javascript
// 获取图片列表    ← 禁止
// 重置数据        ← 禁止
// 返回结果        ← 禁止
// 触发事件        ← 禁止
```

---

## 五、模块级常量注释

文件顶部的常量块，说明来源或枚举值含义：

```javascript
// 各运输类型对应的磅单查询运单状态，来源 imgCategories.js
// key = transportType，load/unload 分别对应装货和卸货的 waybillStatus
const WEIGH_BILL_STATUS_MAP = {
  '1': { load: '410', unload: '430' },
  '2': { load: '410', unload: '430' },
  '3': { load: '410', unload: '420' }
}

// 磅单附件类型（attachmentTypeMap 中 1=装货榜单 2=卸货榜单）
const WEIGH_BILL_ATTACHMENT_TYPE = {
  load: ['1'],
  unload: ['2']
}
```

---

## 六、data() 注释规则

只注释初始值含义不直观、或与业务状态强关联的字段：

```javascript
data() {
  return {
    // 'load' = 装货 | 'unload' = 卸货
    activeTab: 'load',
    // 全屏预览起始索引，点击缩略图时更新
    billPreviewIndex: 0,

    // 以下字段名已自说明，不写注释
    imgPanelVisible: true,
    loadImages: [],
    unloadImages: []
  }
}
```

---

## 七、watch / computed 注释规则

说明"为什么监听"或"为什么不用 immediate"等非显然的设计决策：

```javascript
watch: {
  // detail.transportType 变化时重新拉取图片
  // 不用 immediate，初始化统一在 mounted 触发，避免与 waybillId watch 并发双请求
  'detail.transportType'(val) { ... },

  waybillId(val) { ... }
}
```

computed 只在涉及业务判断逻辑时写注释，纯数据映射不写：

```javascript
computed: {
  // transportType 为 '4'/'5'（个人/挂靠）时无法选择结算主体
  isAccountNameDisabled() {
    return ['4', '5'].includes(this.detail.transportType)
  },

  // 以下纯映射，不写注释
  activeTabImages() {
    return this.activeTab === 'load' ? this.loadImages : this.unloadImages
  }
}
```

---

## 八、废弃/保留代码注释（强制）

配合「原内容保留规则」，废弃逻辑注释掉时必须附上需求号和原因：

```javascript
// [C149.5] 旧图片拉取方式，改为 blob URL 后废弃，保留供对照
// const [loadImages, unloadImages] = await Promise.all([
//   resolveAttachmentItemsBase64(...),
//   resolveAttachmentItemsBase64(...)
// ])
```

模板中废弃的区块同理：

```html
<!-- [C149.5] 旧入口按钮，改由 AnchorNav 替代，保留供对照 -->
<!-- <el-button @click="scrollToTop">回到顶部</el-button> -->
```

---

## 附：常见注释错误速查

| 错误类型 | 错误示例 | 修正方式 |
|---------|---------|---------|
| 复述方法名 | `// 获取图片列表` | 删除 |
| 复述结构 | `<!-- 第一行 -->` | 删除 |
| 复述 prop 名 | `// 是否只读` | 删除 |
| 枚举值未说明 | `v-if="status === '4'"` | 补注释说明 '4' 含义 |
| 魔法数字未说明 | `scrollTop = offset - 120` | 补注释说明各数值来源 |
| 废弃代码无标注 | 直接注释掉，无原因 | 补需求号和原因 |
| 方法级 JSDoc 滥用 | 每个方法都写 JSDoc | 只对工具函数/公共方法写 |

---

**文档版本**: v1.0
**最后更新**: 2026年07月
**整理人**: 王新骏
