# 费用明细组件（CostMessageDetails）— 重构落地方案

> 范围：CostMessageDetails.vue 组件内部 + edit.vue 中直接操作费用明细数据的逻辑
>
> 目标：将费用明细从 1257 行"上帝组件"改造为职责清晰、计算可控、bug 清零的状态。
>
> 原则：每个 PR 只做一件事，改完当天能测完，出问题可秒回滚。所有改动不改变外部行为。

---

## 一、现状诊断

### 1.1 组件职责过载

CostMessageDetails.vue（1257 行）同时承担以下 7 项职责：

| # | 职责 | 涉及方法 | 行数占比 |
|---|------|---------|---------|
| 1 | 费用表格 CRUD | addTableRow / delTableRow / costTypeChange / handleSelect | ~25% |
| 2 | 费用汇总计算 | handleGetSummaries / summariesFn / calcSubtotal(待提取) | ~15% |
| 3 | 运费差价计算 | countMoney / count / getBit / formatService | ~10% |
| 4 | 抹零计算 | dealZeroModeFn / processNumber | ~10% |
| 5 | 油气优惠 | updateOilGasDiscountIfNeeded / calculateOilRebate | ~10% |
| 6 | 附件管理 | viewFiles / fileRemove / uploadSuccess / handleLookImg | ~15% |
| 7 | 数据校验与整理 | commit / formItemRules / mapObj | ~15% |

### 1.2 已知 Bug 清单

| # | Bug | 影响 | 根因 |
|---|-----|------|------|
| B1 | countMoney 硬编码 `newList[0]` | B1 企业（companyType=1）时金额写错行（写到货物保障行而非运费差价行） | `this.$set(this.newList[0], ...)` 不判断目标行身份 |
| B2 | `debounce(this.dealZeroModeFn(), 500)` 写法有误 | dealZeroModeFn 每次立即执行，debounce 完全无效，抹零计算未防抖 | `debounce()` 应包裹函数引用，而非调用结果 |
| B3 | `serviceRateMoney` 未在 data 中声明 | 非响应式隐式属性，模板不追踪变化 | `this.serviceRateMoney = ...` 直接赋值，未声明 |
| B4 | delTableRow 删除抹零行后 dealZeroModeFn 用旧数据算 | 删除抹零行走异步接口，接口成功后才 splice，此时 dealZeroModeFn 已经用旧数据算完了 | dealZeroModeFn 在 delTableRow 同步阶段调用，而非接口成功回调中 |
| B5 | commit() 重复编码校验 forEach bug | `return false` 对 forEach 无效，校验不通过时仍继续执行 | forEach 内嵌 `for...of map` 用 `return false` 试图中断 |
| B6 | 抹零弹窗取消后 costNewList 未清理（edit.vue 侧） | 下次保存抹零行重复计入 | edit.vue `dialogConfirmZeroInfo` 的 catch 空操作 |
| B7 | 保存前运费差价修正用 `newList[0]`（edit.vue 侧） | 与 B1 同类问题，B1 企业时取错行 | edit.vue `changeWaybillStatus` 中 `this.$refs.CostMessageDetails.newList[0]` |

### 1.3 结构性问题

| # | 问题 | 位置 | 影响 |
|---|------|------|------|
| S1 | newList 双重初始化 | mounted + detailObj watch | mounted 结果立刻被 watch 覆盖；两处全流程处理不一致（mounted 不强制 premiumAmount=0） |
| S2 | 小计在 summary-method 里赋值 | handleGetSummaries | el-table 渲染驱动调用，触发时机不可控；UI 渲染与业务计算混合 |
| S3 | 油气优惠每次 blur 调接口 | updateOilGasDiscountIfNeeded | 连续修改多行时大量无效请求；无竞态保护，旧请求可能覆盖新请求 |
| S4 | searchOptions 全组件共享 | data.searchOptions | 多行同时 focus 费用项目下拉时互相覆盖选项 |
| S5 | 父子通过 $refs 深度耦合 | edit.vue → CostMessageDetails | `ref.newList[0]` / `ref.commit()` / `ref.countMoney()` / `ref.dealZeroModeFn()` / `ref.subtotal` 5 处直接操作子组件内部 |
| S6 | count/formatService/getBit 重复 | CostMessageDetails + endOfCalculation.js | 同一计算逻辑两处维护，改一处忘改另一处 |

### 1.4 废弃代码

| 字段/方法 | 说明 |
|-----------|------|
| `total` | data 中声明，从未被赋值使用 |
| `arr` | data 中声明，从未使用 |
| `nowIcon` | data 中声明，从未使用 |
| `gxType` | computed 中声明，模板和 methods 均未使用 |
| `dialogImgVisible` | 已被 `el-image-x` 替代，但字段仍被 `handleLookImg` 写入 |
| `handleDialogClose` | 旧图片弹窗回调，已无调用方 |
| `display:black` | 原金额列 style 笔误，应为 `display:block` |

---

## 二、重构策略：三阶段渐进式

```
阶段一：修 Bug（P0，随时可做，互相独立）
  ↓ 修 7 个已知 bug，每个 ≤15 行
  ↓ 7 个 PR，可并行提测

阶段二：结构优化（P1，触碰文件时顺手做）
  ↓ 计算分离 + 初始化统一 + 废弃清理 + 接口防抖
  ↓ 6 个 PR，建议顺序执行

阶段三：解耦与提取（P2，专项排期）
  ↓ 父子通信改 emit + 纯函数提取 + 抹零单一来源
  ↓ 3 个 PR，需完整回归
```

---

## 三、阶段一：修 Bug（P0）

> 每个 PR 只改 1 个文件，改动量 ≤15 行，revert 成本为 1 个 commit。
> 互相独立，可并行提测。

### PR-1：countMoney 硬编码下标修复

**文件**：`CostMessageDetails.vue` | **改动量**：~5 行 | **修复 B1**

**现状**：L555~557，`countMoney` 通过 `this.newList[0]` 硬编码取第一行写入运费差价。当 `companyType=1`（B1 企业）时 `newList[0]` 是货物保障服务行，金额写错位置。

**改法**：
```js
// 改前（L555~557）
this.$set(this.newList[0], 'confirmMoney', this.serviceRateMoney)
this.$set(this.newList[0], 'confirmRemark', rate)

// 改后
const freightDiffRow = this.newList.find(i => i.costName === '运费差价')
if (freightDiffRow) {
  this.$set(freightDiffRow, 'confirmMoney', this.serviceRateMoney)
  this.$set(freightDiffRow, 'confirmRemark', rate)
}
```

**为什么安全**：`find` 找到的就是原来 `[0]` 指向的对象（普通运单），行为完全一致；B1 时 `find` 返回 undefined，`if` 保护不执行。

**验证**：
- □ 普通运单：修改确认金额 → 运费差价行联动更新
- □ B1 企业运单（companyType=1）：无运费差价行，控制台无报错
- □ 保存时运费差价值正确写入后端

---

### PR-2：debounce 写法修复

**文件**：`CostMessageDetails.vue` | **改动量**：~8 行 | **修复 B2**

**现状**：L588，`debounce(this.dealZeroModeFn(), 500)` 写法有误——`dealZeroModeFn()` 是**调用结果**（undefined），`debounce(undefined, 500)` 不产生任何效果，实际上 `dealZeroModeFn` 每次都立即执行。

**改法**：
```js
// 改前（L588）
debounce(this.dealZeroModeFn(), 500)

// 改后：在 created 中创建防抖函数，在 updBusCostInput 中调用
created() {
  this._debouncedDealZeroMode = debounce(() => {
    this.dealZeroModeFn()
  }, 500)
}

// updBusCostInput 中
this._debouncedDealZeroMode()
```

**为什么安全**：防抖只是延后执行，最终一定会执行一次；计算结果不变，只是减少了高频场景下的执行次数。

**验证**：
- □ 修改 1 行确认金额：500ms 后抹零行更新
- □ 连续修改 3 行：只有最后一次触发抹零计算
- □ 修改后立即点保存：debounce 未执行时保存行为正确（保存时 changeWaybillStatus 会独立计算）

---

### PR-3：serviceRateMoney 响应式声明

**文件**：`CostMessageDetails.vue` | **改动量**：1 行 | **修复 B3**

**现状**：L553，`this.serviceRateMoney = ...` 直接赋值，但 `serviceRateMoney` 未在 `data()` 中声明，是隐式非响应式属性。

**改法**：
```js
// data() 中新增
data() {
  return {
    // ... 原有字段 ...
    serviceRateMoney: 0  // ← 新增
  }
}
```

**为什么安全**：声明初始值不影响已有赋值逻辑；如果模板未使用此字段（当前未使用），声明只是让 Vue 追踪到它，无副作用。

**验证**：
- □ 运费差价计算正常
- □ Vue DevTools 中 serviceRateMoney 可见

---

### PR-4：delTableRow 异步时序修复

**文件**：`CostMessageDetails.vue` | **改动量**：~5 行 | **修复 B4**

**现状**：`delTableRow` 删除抹零行时走异步接口 `getZeroDelStatus`（调 `updateByBusId`），接口成功后才 splice 行。但 `delTableRow` 在调用 `getZeroDelStatus` 后**同步**执行了 `dealZeroModeFn()`，此时行还未真正删除，抹零计算用的是旧数据。

**改法**：
```js
// 改前：delTableRow 末尾同步调用
delTableRow(index) {
  // ...
  if ([101, 102].includes(row.orderNumber)) {
    this.getZeroDelStatus(index)  // 异步删除
  } else {
    this.params.model.splice(index, 1)
  }
  this.dealZeroModeFn()  // ← 此时异步删除还没完成，用的是旧数据
}

// 改后：抹零重算移到异步删除成功回调中
getZeroDelStatus(index) {
  // ... 调接口 ...
  if (res.success) {
    this.params.model.splice(index, 1)
    this.dealZeroModeFn()  // ← 移到这里，行已删除
    this.$emit('updateZeroType')
  }
}

delTableRow(index) {
  // ...
  if ([101, 102].includes(row.orderNumber)) {
    this.getZeroDelStatus(index)
  } else {
    this.params.model.splice(index, 1)
    this.dealZeroModeFn()  // 同步删除，立即重算
  }
  // 不再在这里统一调 dealZeroModeFn
}
```

**验证**：
- □ 删除抹零行后：抹零行消失，合计金额正确更新
- □ 删除普通费用行后：抹零计算正确
- □ 删除抹零行接口报错：行不被删除，抹零金额不变

---

### PR-5：commit() 重复编码校验修复

**文件**：`CostMessageDetails.vue` | **改动量**：~10 行 | **修复 B5**

**现状**：`commit()` 方法内用 `forEach` 遍历费用行，嵌套 `for...of map` 校验重复编码，发现重复时 `return false`。但 `return false` 对 `forEach` 无效（forEach 不中断），校验不通过时仍继续执行后续逻辑。

**改法**：
```js
// 改前：forEach + return false（无效）
params.model.forEach(item => {
  const map = new Map()
  for (let [key, val] of map) {
    if (val > 1) {
      this.$message.error('...')
      return false  // ← 对 forEach 无效！
    }
  }
})

// 改后：用 for...of 可中断循环
for (const item of params.model) {
  const map = new Map()
  for (const row of params.model) {
    if (row.costType === item.costType) {
      const key = row.costCode || row.costName
      map.set(key, (map.get(key) || 0) + 1)
    }
  }
  for (let [key, val] of map) {
    if (val > 1) {
      this.$message.error(`费用类型下存在重复费用编码：${key}`)
      return false  // ← 对外层方法 return，可正常中断
    }
  }
}
```

**验证**：
- □ 正常费用明细保存：校验通过，返回整理后的数组
- □ 存在重复编码：报错并返回失败标记
- □ 多组重复编码：只报第一个重复项（符合预期）

---

### PR-6：抹零取消后 costNewList 清理（edit.vue 侧）

**文件**：`edit.vue` | **改动量**：~5 行 | **修复 B6**

**现状**：`dialogConfirmZeroInfo` 弹窗的 `.catch()` 空操作，用户取消抹零后 `costNewList` 里已 push 的抹零行（orderNumber 101/102）未清理，下次保存重复计入。

**改法**：
```js
// 改前
.catch(() => { })

// 改后
.catch(() => {
  this.costNewList = this.costNewList.filter(i => ![101, 102].includes(i.orderNumber))
})
```

**验证**：
- □ 抹零弹窗点"确定"：正常保存
- □ 抹零弹窗点"取消"：不保存，再次保存时抹零行不重复
- □ 连续取消 3 次再确定：只有 1 行抹零行

---

### PR-7：保存前运费差价修正去硬编码（edit.vue 侧）

**文件**：`edit.vue` | **改动量**：~3 行 | **修复 B7** | **前置依赖**：PR-1

**现状**：`changeWaybillStatus` 中通过 `this.$refs.CostMessageDetails.newList[0]?.confirmRemark` 读取差价率，与 B1 同类问题。

**改法**：
```js
// 改前
const currentTaxRate = this.$refs.CostMessageDetails.newList[0]?.confirmRemark || this.detail.taxRate

// 改后
const freightDiffRow = this.$refs.CostMessageDetails.newList.find(i => i.costName === '运费差价')
const currentTaxRate = freightDiffRow?.confirmRemark || this.detail.taxRate
```

**验证**：
- □ 有抹零的运单保存：运费差价正确
- □ 无抹零的运单保存：运费差价不变
- □ B1 企业运单保存：不报错

---

### 阶段一交付顺序

```
第 1 批（互相独立，可并行提测）：
  PR-1  countMoney 下标修复（CostMessageDetails）
  PR-2  debounce 写法修复（CostMessageDetails）
  PR-3  serviceRateMoney 声明（CostMessageDetails）
  PR-4  delTableRow 时序修复（CostMessageDetails）
  PR-5  commit 校验修复（CostMessageDetails）
  PR-6  抹零取消清理（edit.vue）
  PR-7  保存前修正去硬编码（edit.vue，依赖 PR-1）

观察期：合入后观察 1~2 天
```

---

## 四、阶段二：结构优化（P1）

> 触碰 CostMessageDetails.vue 时顺手做。每个 PR 改完后独立可测。

### PR-8：油气优惠接口 debounce + 竞态保护

**文件**：`CostMessageDetails.vue` | **改动量**：~15 行 | **解决 S3**

**现状**：每次确认金额 blur 都调一次 `calculateOilRebate` 接口，连续修改多行时大量无效请求。无竞态保护，旧请求慢于新请求时覆盖新结果。

**改法**：
```js
// data 里加 _oilGasRequestId: 0
updateOilGasDiscountIfNeeded: debounce(async function() {
  if (this.detailObj.fullProcessFlag === 10) return
  const oilAmount = this.detailObj?.oilAmount || this.detailObj?.bmsWaybillPoolExt?.oilAmount
  if (!oilAmount || Number(oilAmount) <= 0) return

  const requestId = ++this._oilGasRequestId
  // ... 原有接口调用逻辑不变 ...
  if (requestId !== this._oilGasRequestId) return  // 旧请求丢弃
  // ... 原有更新逻辑不变 ...
}, 500)
```

**验证**：
- □ 修改 1 行 blur：油气优惠正常更新
- □ 连续修改 3 行 blur：只有最后一次触发接口（Network tab 验证）
- □ 全流程运单：油气优惠始终为 0，无接口调用

---

### PR-9：小计计算与 handleGetSummaries 分离

**文件**：`CostMessageDetails.vue` | **改动量**：~20 行 | **解决 S2**

**现状**：`handleGetSummaries` 是 el-table 的 summary-method，由 Vue 渲染驱动调用，触发时机不可控。方法内同时做 UI 渲染（返回 sums 数组）和业务计算（给 `this.subtotal` 赋值），职责混合。

**改法**：
```js
// 新增独立计算方法
calcSubtotal() {
  const sum = this.params.model.reduce((total, item) => {
    if ([101, 102].includes(item.orderNumber)) return total
    if (['200', '600'].includes(`${item.costType}`)) {
      return total.plus(+(item.updBusCost || 0))
    } else {
      return total.minus(+(item.updBusCost || 0))
    }
  }, new BigNumber(0))
  this.subtotal = Number(sum)
}

// handleGetSummaries 改为纯展示，读取已计算的 this.subtotal
// updBusCostInput 里显式调用 this.calcSubtotal()
```

**安全策略**：第一版两边都保留赋值（双写），验证一周后再删 handleGetSummaries 里的赋值。

**验证**：
- □ 进入编辑页：小计展示正确
- □ 修改确认金额：小计实时更新
- □ 新增/删除费用行：小计正确
- □ 运费差价联动：subtotal 变化 → countMoney 正确触发

---

### PR-10：newList 双重初始化消除

**文件**：`CostMessageDetails.vue` | **改动量**：删除 ~50 行 + 新增 ~20 行 | **解决 S1**

**现状**：`mounted`（L454~）初始化 `newList`（约 50 行），`detailObj` watch 再初始化一次。mounted 的结果是过渡态，几乎立刻被 watch 覆盖。两处在全流程运单时对 `premiumAmount` 的处理不一致。

**改法**：
```js
// mounted 里删除 newList 初始化代码，只做非业务初始化
mounted() {
  window.addEventListener('resize', this.handleResize)
  const { type } = this.$route.query
  this.type = type
  this.busBillId = this.params.busBillId
}

// detailObj watch 作为唯一入口
watch: {
  detailObj(val) {
    this.$nextTick(() => {
      if (this.newList.length === 0 || this.type !== 'edit') {
        this._buildNewList(val)       // 完整重建
      } else {
        this._updateOilGasOnly(val)   // 编辑模式：只更新油气行
      }
    })
  }
}
```

**验证**：
- □ 进入 edit 页面：运费差价/货物保障/油气优惠三行正常
- □ 全流程运单：货物保障服务金额显示 0
- □ companyType=1（B1）：只有货物保障行，无运费差价行
- □ 保存后刷新：newList 正确重建

---

### PR-11：废弃字段清理

**文件**：`CostMessageDetails.vue` | **改动量**：删除 ~15 行 | **无风险**

**清理清单**：

| 字段/方法 | 行号 | 操作 |
|-----------|------|------|
| `total` | data L276 | 删除声明 |
| `arr` | data L272 | 删除声明 |
| `nowIcon` | data L256 | 删除声明 |
| `gxType` | computed L306 | 删除整个 computed |
| `dialogImgVisible` | data L263 | 删除声明 + L758 赋值 |
| `handleDialogClose` | methods L763 | 删除方法 |
| `display:black` | 模板 L35 | 改为 `display:block` |

**验证**：
- □ 组件正常渲染，无报错
- □ 图片预览功能正常（el-image-x 替代）
- □ 原金额列展示正常

---

### PR-12：searchOptions 行级隔离

**文件**：`CostMessageDetails.vue` | **改动量**：~20 行 | **解决 S4**

**现状**：`searchOptions` 是全局 data 字段，多行同时 focus 费用项目下拉时互相覆盖。

**改法**：
```js
// 改前：data 中全局共享
data() { return { searchOptions: [] } }

// 改后：改为行级数据
// 在 params.model 每行增加 _searchOptions 字段（不影响提交，_ 前缀字段可过滤）
getSearchList(row) {
  // ... 拉取选项 ...
  this.$set(row, '_searchOptions', list)
}

// 模板改为读取行级选项
<el-option v-for="item in (scope.row._searchOptions || [])" ... />
```

**验证**：
- □ 单行 focus 费用项目下拉：选项正确
- □ 快速切换两行 focus：各自选项不互相覆盖
- □ 保存时 `_searchOptions` 不被提交（commit 中过滤）

---

### PR-13：commit() 返回值规范化

**文件**：`CostMessageDetails.vue` + `edit.vue` | **改动量**：~15 行

**现状**：`commit()` 返回整理好的数组（成功）或 `'1'`/`'2'`（失败），父组件需做多种类型判断。

**改法**：
```js
// CostMessageDetails commit() 改后
commit() {
  // ... 校验逻辑 ...
  if (校验失败) {
    return { valid: false, error: '重复编码' }
  }
  if (表单校验未通过) {
    return { valid: false, error: 'form' }
  }
  return { valid: true, data: 整理后的数组 }
}

// edit.vue 调用处改后
const result = this.$refs.CostMessageDetails.commit()
if (!result.valid) return
const costNewList = result.data
```

**前置确认**：搜索 `commit()` 的所有调用方（目前只有 edit.vue `changeWaybillStatus`），确保同步修改。

**验证**：
- □ 正常保存：返回 `{ valid: true, data: [...] }`
- □ 重复编码：返回 `{ valid: false, error: '...' }`，流程中止
- □ 表单校验不通过：返回 `{ valid: false, error: 'form' }`

---

### 阶段二交付顺序

```
第 2 批（互相独立）：
  PR-8   油气接口 debounce
  PR-9   小计与 UI 分离
  PR-10  双重初始化消除
  PR-11  废弃字段清理
  PR-12  searchOptions 行级隔离
  PR-13  commit() 返回值规范化

观察期：合入后观察 2~3 天
```

---

## 五、阶段三：解耦与提取（P2）

> 专项排期，需完整回归测试。改动量较大，建议单独拉分支。

### PR-14：父子通信改 emit + getter

**文件**：`CostMessageDetails.vue` + `edit.vue` | **改动量**：~40 行 | **解决 S5**

**现状**：edit.vue 通过 5 处 `$refs` 直接操作子组件内部：

| 调用 | 用途 |
|------|------|
| `ref.commit()` | 校验并获取费用数据 |
| `ref.subtotal` | 读取小计金额 |
| `ref.newList[0].confirmRemark` | 读取差价率 |
| `ref.countMoney(amount, rate)` | 重新计算运费差价 |
| `ref.dealZeroModeFn()` | 触发抹零计算 |

**改法**：

1. `commit()` → 保持（PR-13 已规范化返回值，作为对外 API 合理）
2. `subtotal` → 改为 `emit('subtotal-change', val)`，父组件监听
3. `newList[0].confirmRemark` → 改为 `emit('rate-change', rate)`，在 countMoney 中触发
4. `countMoney()` → 保持（作为对外 API，但改名 `recalcFreightDiff`）
5. `dealZeroModeFn()` → 保持（作为对外 API，但改名 `recalcZeroMode`）

```js
// CostMessageDetails
watch: {
  subtotal(val) {
    this.$emit('subtotal-change', val)
  }
}
countMoney(cost, rate) {
  // ... 原有计算 ...
  this.$emit('rate-change', rate)
  this.$emit('newServiceCharge', this.serviceRateMoney)
}

// edit.vue 模板
<CostMessageDetails
  @subtotal-change="onSubtotalChange"
  @rate-change="onRateChange"
  @new-service-charge="onServiceChargeChange"
/>
```

**验证**：
- □ 修改确认金额：subtotal-change 事件正确触发
- □ 运费差价变化：rate-change 和 newServiceCharge 事件正确
- □ 保存/提交：commit() 返回值正确
- □ 抹零计算：recalcZeroMode() 正常

---

### PR-15：提取纯计算函数到 utils/calculation.js

**文件**：新建 `utils/calculation.js` + 改动 `CostMessageDetails.vue` | **解决 S6**

**提取函数**：
```js
// utils/calculation.js（纯函数，无副作用，可单元测试）
import BigNumber from 'bignumber.js'

export function getBit(value, n) {
  let str = value.toFixed(n + 1).toString()
  str = str.split('.')[0] + '.' + str.split('.')[1].substring(0, n)
  return parseFloat(str)
}

export function formatService(num, n, type) {
  const typeObj = { '0': Math.ceil, '1': Math.floor, '4': Math.round }
  const fn = typeObj[type] || Math.ceil
  const newNum = fn(new BigNumber(num).multipliedBy(Math.pow(10, n)).toNumber())
  return new BigNumber(newNum).div(Math.pow(10, n)).toNumber()
}

export function calcTotal(amount, rate, roundingMode) {
  const divisor = getBit(1 - (parseFloat(rate) / 100), 7)
  let num = new BigNumber(amount).dividedBy(divisor).toFixed(7)
  return +formatService(+num, 2, roundingMode || 0)
}
```

CostMessageDetails 保留 `count` 方法作为薄代理：
```js
import { calcTotal } from '@/utils/calculation'
count(Amount, Rate) {
  return calcTotal(Amount, Rate, this.roundingMode)
}
```

`endOfCalculation.js` 暂不改，后续单独 PR 替换。

**验证**：
- □ 运费差价计算结果与改动前一致（对比 3 张不同运单）
- □ 不同 roundingMode（0/1/4）下结果一致
- □ 差价率为 0 时不报错

---

### PR-16（远期）：抹零计算单一来源

**文件**：`CostMessageDetails.vue` + `edit.vue` | **风险**：中高 | **前置依赖**：PR-9 + PR-2

**现状**：`dealZeroModeFn`（CostMessageDetails，实时预览）和 `changeWaybillStatus`（edit.vue，保存前）各自独立计算抹零，逻辑重复且可能不一致。

**目标**：`dealZeroModeFn` 作为抹零唯一计算来源，保存时直接使用 params.model 中已有的抹零行数据，不再在 edit.vue 中独立计算和 push。

**改法**：
```js
// edit.vue changeWaybillStatus 改后
const newlist = this.changeMoney(CostDetails)
this.costNewList = newlist  // 直接用，含 dealZeroModeFn 已追加的抹零行

// 检查是否有抹零行，有则弹窗确认
const zeroRow = this.costNewList.find(i => [101, 102].includes(i.orderNumber))
if (zeroRow && this.zeroByBusIdMode) {
  const confirmed = await this.confirmZeroDialog(zeroRow)
  if (!confirmed) return
}
this.beforeChangeWaybill()
```

**边界场景**：
- 费用明细为空时保存
- 抹零方式为"不抹零"
- 差额为 0（不应有抹零行）
- debounce 还没执行就点了保存

---

### 阶段三交付顺序

```
第 3 批：
  PR-14  父子通信改 emit
  PR-15  计算工具纯函数化

远期（需充分评估后执行）：
  PR-16  抹零单一来源

观察期：合入后观察 3~5 天
```

---

## 六、全局依赖关系图

```
阶段一（P0）：互相独立，可并行
  PR-1  countMoney 下标修复 ──────────→ PR-7（edit.vue 侧同类修复）
  PR-2  debounce 写法修复
  PR-3  serviceRateMoney 声明
  PR-4  delTableRow 时序修复
  PR-5  commit 校验修复
  PR-6  抹零取消清理（edit.vue）

阶段二（P1）：建议顺序执行
  PR-8   油气接口 debounce
  PR-9   小计与 UI 分离 ─────────→ PR-16（远期，依赖小计独立计算）
  PR-10  双重初始化消除
  PR-11  废弃字段清理
  PR-12  searchOptions 行级隔离
  PR-13  commit 返回值规范 ──────→ PR-14（父子通信改 emit 的前置）

阶段三（P2）：有依赖
  PR-14  父子通信改 emit
  PR-15  计算工具纯函数化
  PR-16  抹零单一来源（远期，依赖 PR-9 + PR-2）
```

---

## 七、收益总览

### 7.1 量化收益

| 维度 | 改前 | 全部完成后 |
|------|------|-----------|
| CostMessageDetails.vue 行数 | 1257 行 | ~800 行（-36%） |
| 已知 bug | 7 个（2 个用户可感知 + 5 个隐性） | 0 |
| 废弃字段/方法 | 7 处 | 0 |
| 父子 $refs 耦合点 | 5 处 | 1 处（commit API） |
| 计算函数重复 | CostMessageDetails + endOfCalculation 各一份 | utils/calculation.js 纯函数 |
| 抹零计算来源 | 2 处（dealZeroModeFn + changeWaybillStatus） | 1 处（dealZeroModeFn） |
| 小计计算触发 | el-table 渲染驱动（不可控） | 显式调用（可控） |
| 油气接口调用频率 | 每次 blur 1 次 | debounce 500ms，连续操作只调 1 次 |

### 7.2 开发体验收益

| 场景 | 改前痛点 | 改后体验 |
|------|---------|---------|
| 追费用计算 bug | 在 handleGetSummaries/countMoney/dealZeroModeFn 之间跳转 | calcSubtotal 断点精确，链路清晰 |
| B1 企业运单 | countMoney 写错行，保存前修正取错行 | 按名查找，B1 安全跳过 |
| 新增费用类型 | 不知道该改 mounted 还是 watch | _buildNewList 唯一入口 |
| 连续修改确认金额 | 油气接口大量调用，抹零每次立即执行 | debounce 保护，各只触发 1 次 |
| 删除抹零行 | 重算时序错误，用旧数据算 | 接口成功回调中重算 |
| Code Review commit() | 返回值类型不确定（数组/字符串） | `{ valid, data, error }` 结构清晰 |

---

## 八、风险控制策略

| 策略 | 说明 |
|------|------|
| 单文件单 PR | 每个 PR 只改 1 个文件（阶段一），revert 成本为 1 个 commit |
| 行为不变优先 | 先做"不改变任何计算结果"的重构，再做 bug 修复 |
| 双写过渡 | 小计分离保留旧代码注释，双写验证一周后再删 |
| 测试前置 | 每个 PR 附带手动验证 checklist，测试通过才合 |
| 渐进替换 | 父子通信改 emit 时不一次性替换所有调用点，逐个替换并验证 |
| 灰度观察 | 每批合入后观察 1~5 天（随阶段递增），出问题立即 revert |

---

## 九、测试回归总表

| 场景 | 涉及 PR | 验证点 |
|------|---------|--------|
| 普通运单修改确认金额 | 1/2/8/9 | 小计正确、运费差价正确、油气优惠更新、抹零行更新 |
| B1 企业运单 | 1/7 | 无运费差价行时不报错，货物保障行不被意外写入 |
| 全流程运单 | 8/10 | 货物保障=0，油气优惠=0，差价从接口获取 |
| 连续修改 5 行确认金额 | 2/8 | 抹零只算 1 次（debounce），油气接口只调 1 次 |
| 删除抹零行 | 4 | 抹零行消失，合计金额正确更新 |
| 删除普通费用行 | 4 | 抹零计算正确 |
| 保存（310） | 5/6/7/13 | commit 返回正确，抹零行不重复，运费差价正确 |
| 提交（320） | 5/6/7/13 | 同上 + 风控前费用数据正确 |
| 抹零弹窗取消 | 6 | costNewList 不残留抹零行 |
| 费用项目下拉 | 12 | 多行同时 focus 不互相覆盖 |
| 图片预览 | 11 | el-image-x 正常工作 |
| 原金额列展示 | 11 | display:block 正确 |
| 运费差价计算 | 15 | 不同 roundingMode 下结果一致 |

---

## 十、与已有文档的关系

| 已有文档 | 本方案对应 | 说明 |
|---------|-----------|------|
| components/CostMessageDetails.md | 全部 PR | 组件文档的 12 个重构风险点已全部覆盖 |
| 计算逻辑梳理与优化.md（方案 A~F） | PR-9/1/16/8/15 | 方案 A→PR-9, B→PR-1, C→PR-16, D→PR-8, E→PR-15 |
| 计算逻辑-安全交付方案.md（PR-1~8） | PR-1/8/9/6/15 | 原方案 8 个 PR 的费用明细部分 |
| 重构执行手册.md（T3/T4） | PR-1/10 | T3→PR-1, T4→PR-10 |
| xxx/优化方案.md（#9~#12） | PR-10/1 | #9~#11→PR-10, #12→PR-1 |

**增量内容**（本方案新增，已有文档未覆盖）：
- debounce 写法修复（PR-2）— 原文档未发现此 bug
- serviceRateMoney 响应式声明（PR-3）— 原文档已标注但未独立编号
- delTableRow 异步时序修复（PR-4）— 原文档已标注风险点 #9
- commit() 重复校验 forEach bug（PR-5）— 原文档已标注风险点 #7
- searchOptions 行级隔离（PR-12）— 原文档已标注风险点 #1
- commit() 返回值规范化（PR-13）— 原文档已标注风险点 #6
- 父子通信改 emit（PR-14）— 原文档已标注风险点 #10

---

**文档版本**: v2.0
**最后更新**: 2026年07月
**整理人**: 王新骏
