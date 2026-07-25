# 费用明细重构落地方案技术文档

> 整理人：王新骏  
> 范围：仅限费用明细（CostMessageDetails.vue 及其直接交互的 edit.vue / read.vue 费用明细部分）  
> 目标：降低开发与维护成本，分批次可验证

---

## 一、范围界定

### 核心文件

| 文件路径 | 行数 | 职责 |
|---------|------|------|
| `logisticsweb/src/views/userBase/waybillSettlement/components/CostMessageDetails.vue` | 1257 | 费用明细核心组件：表格 CRUD + 汇总计算 + 抹零 + 油气优惠 + 运费差价 + 附件管理 |
| `logisticsweb/src/views/userBase/waybillSettlement/components/add.conf.js` | 17 | 配置 mixin（弹窗按钮） |
| `logisticsweb/src/views/userBase/waybillSettlement/edit.vue` | 1689 | 编辑页：费用明细模板(145-162行)、updBusCostInput(1084-1106行)、changeWaybillStatus(1220-1278行)、newServiceCharge(1333-1335行) |
| `logisticsweb/src/views/userBase/waybillSettlement/read.vue` | 947 | 查看页：费用明细模板(121-128行) |

### 不在本次范围内

- read/edit 页面级 mixin 提取（运单信息、结算信息、操作记录等）
- 风控预警逻辑
- 附件预览组件
- 亏吨弹窗
- 装卸重量编辑弹窗

---

## 二、问题清单

### 安全缺陷（P0）

| # | 问题 | 位置 | 影响 |
|---|------|------|------|
| 1 | `serviceRateMoney` 未在 data() 声明，直接 `this.serviceRateMoney =` 赋值 | CostMessageDetails.vue 第 553 行 | Vue2 中非响应式，运费差价不会触发视图更新 |
| 2 | `debounce(this.dealZeroModeFn(), 500)` 传参方式错误 | CostMessageDetails.vue 第 588 行、edit.vue 第 1103 行 | `dealZeroModeFn()` 立即执行，debounce 无效，等于无防抖 |
| 3 | `updBusCostComputed` 是无 setter 的 computed，却用于 `v-model` | CostMessageDetails.vue 第 50 行(模板)、第 281-285 行(computed) | Vue2 控制台报错，input 赋值时静默失败 |
| 4 | `this.$forceUpdate()` 作为响应式补救 | CostMessageDetails.vue 第 742 行 | 掩盖 newList 响应式缺陷，全组件重渲染性能浪费 |

### 结构缺陷（P1-P2）

| # | 问题 | 影响 |
|---|------|------|
| 5 | 油气优惠判断逻辑 `hasValidOilData` + `shouldShowOilGas` 在 mounted(467-486)、detailObj watcher 首次构建(395-433)、detailObj watcher 已有数据分支(344-383) 中重复 3 次 | 改规则需改 3 处，漏改概率高 |
| 6 | newList 构建（运费差价 + 货物保障 + 油气优惠）逻辑在 mounted 和 detailObj watcher 中各写一遍 | 首次加载与 watcher 触发时可能不一致 |
| 7 | 费用计算纯逻辑（countMoney/count/getBit/formatService/dealZeroModeFn 核心）混在组件 methods 中 | 无法脱离组件单测，1200 行组件内找计算 bug 困难 |
| 8 | 第二张汇总表（summaryTable + summariesFn + newList + tableNewList）占约 250 行，与主表格 CRUD 无关 | 职责混杂，改汇总行要翻过大量无关代码 |

### 通信缺陷（P3，可选）

| # | 问题 | 位置 | 影响 |
|---|------|------|------|
| 9 | edit.vue 通过 `$refs` 直接读/写 CostMessageDetails 内部状态 | edit.vue 第 1102-1103、1224、1261-1263 行 | 父子深度耦合，组件不可复用 |
| 10 | CostMessageDetails 通过 `$emit('newServiceCharge')` 向上传递差价，但差价率却靠 `$refs.CostMessageDetails.newList[0].confirmRemark` 反向读取 | edit.vue 第 1261 行 | 数据流双向混乱 |

---

## 三、横向影响检查

| 检查项 | 是否涉及 | 文件/说明 |
|--------|---------|----------|
| 调整页（edit.vue） | 是 | 费用明细模板、保存/提交流程中的费用校验与抹零 |
| 查看页（read.vue） | 是 | 费用明细模板（只读模式） |
| 列表页 | 否 | 不涉及费用明细组件 |
| 对账页 | 否 | 不涉及费用明细组件 |
| 付款页 | 否 | 不涉及费用明细组件 |
| 移动端对应页面 | 否 | 货主移动端无费用明细编辑功能 |
| 公共组件 | 是 | CostMessageDetails.vue 本身是公共组件，被 edit/read 共用 |
| 接口封装 | 否 | 本次不改动接口调用逻辑 |

---

## 四、P0 批次：安全修复（4 个任务，独立可交付）

> 目标：修复 4 个确认 bug，不改变任何业务行为，每个任务独立提交独立验证。

### 任务 P0-1：声明 serviceRateMoney 为响应式

**改哪里**：CostMessageDetails.vue data()，第 250-278 行

**做什么**：在 data() return 中新增 `serviceRateMoney: 0`

**关键逻辑说明**：
- 触发条件：`countMoney()` 方法执行时 `this.serviceRateMoney = new BigNumber(...).toFixed(2)`
- 处理步骤：Vue2 中未在 data() 声明的属性不具备响应式，赋值后不会触发视图更新。声明后即可正常驱动 `this.$set(this.newList[0], 'confirmMoney', this.serviceRateMoney)` 的视图刷新

**验证**：
- 编辑页修改运费确认金额，失焦后运费差价行是否实时更新
- 查看页运费差价是否正常展示
- companyType=1（不显示运费差价）时是否无异常

### 任务 P0-2：修复 debounce 调用方式

**改哪里**：CostMessageDetails.vue 第 588 行、edit.vue 第 1103 行

**做什么**：
- CostMessageDetails.vue：在 `created()` 中预创建防抖函数 `this._debouncedDealZero = debounce(() => this.dealZeroModeFn(), 500)`，`updBusCostInput` 中将 `debounce(this.dealZeroModeFn(), 500)` 改为 `this._debouncedDealZero()`
- edit.vue：`debounce(this.$refs.CostMessageDetails.dealZeroModeFn(), 500)` 改为 `this.$refs.CostMessageDetails.dealZeroModeFn()`（保持原有效行为：立即执行）

**关键逻辑说明**：
- 原代码 `debounce(this.dealZeroModeFn(), 500)` 传入了函数执行结果（undefined）而非函数引用，导致 `dealZeroModeFn()` 立即执行且 debounce 完全无效
- 预创建方式确保多次调用共享同一个 timer，真正实现防抖

**验证**：
- 编辑页快速连续修改确认金额，抹零行不应每次都触发，应防抖后统一计算
- 修改后失焦，抹零金额是否正确

### 任务 P0-3：修复 updBusCostComputed 的 v-model 问题

**改哪里**：CostMessageDetails.vue 第 48-56 行模板

**做什么**：将 `v-model.trim="updBusCostComputed"` 改为 `:value="updBusCostComputed"`

**关键逻辑说明**：
- F10102（按比例固定扣款）的 input 始终为 `:disabled` 状态
- computed 属性没有 setter，`v-model` 尝试写入时 Vue2 控制台报错
- 改为 `:value` 单向绑定后，展示值仍由 computed 驱动，行为不变

**验证**：
- 控制台不再有 computed setter 警告
- F10102 费项行的确认金额是否正确展示（= 运费 x 系数）
- 修改运费确认金额，F10102 行是否联动更新

### 任务 P0-4：移除 $forceUpdate，修复 newList 响应式

**改哪里**：CostMessageDetails.vue `updateOilGasDiscountIfNeeded` 方法，第 742 行

**做什么**：将 `this.$forceUpdate()` 改为 `this.$nextTick(() => { this.$refs.summaryTable && this.$refs.summaryTable.doLayout() })`

**关键逻辑说明**：
- `$set` 更新 `newList[oilGasIndex].confirmMoney` 后，el-table 的 `summary-method` 不会自动重算
- 代码中已有用 `doLayout()` 触发重算的先例（detailObj watcher 第 388-390 行）
- `doLayout()` 会触发 el-table 重新调用 `summariesFn`，效果与 `$forceUpdate` 一致但更精准

**验证**：
- 编辑页修改司机运费，油气优惠行金额是否实时更新（不依赖 $forceUpdate）
- 有油气费 / 无油气费 / 全流程(fullProcessFlag=10) 三种场景分别验证

---

## 五、P1 批次：结构收拢（3 个任务，依赖 P0 完成）

> 目标：消除重复逻辑，不拆组件，不改变对外接口。

### 任务 P1-1：提取油气优惠判断 + 行构建为单一方法

**改哪里**：CostMessageDetails.vue

**做什么**：
1. 新增方法 `getOilGasConfig(detailObj)`，返回 `{ shouldShow, oilAmount, oilDiscountAmount }`
   - 收录 `hasValidOilData` 判断逻辑
   - 收录 `fullProcessFlag === 10` 覆盖逻辑（强制显示，金额置 0）
2. 新增方法 `buildOilGasItem(detailObj)`，返回 `{ costName: '油气优惠', confirmMoney, confirmRemark }` 或 `null`
   - `confirmMoney` 统一为 `detailObj.fullProcessFlag === 10 ? 0 : (oilDiscountAmount || 0)`
3. 替换三处重复：
   - mounted（约 20 行）：原内联判断改为调用 `buildOilGasItem`
   - detailObj watcher 已有数据分支（约 40 行）：用 `getOilGasConfig` 获取 `shouldShow`，用 `buildOilGasItem` 构建新行
   - detailObj watcher 首次构建分支（约 25 行）：调用 `buildOilGasItem`

**行为差异说明**：
- mounted 原来不处理 `fullProcessFlag === 10`，统一后 mounted 也会处理。但 watcher 随后触发时会检测到已存在油气优惠行而不重复添加，因此最终结果一致，仅消除了 mounted 首帧的短暂缺失

**验证**：
- 有油气费运单：查看/编辑页油气优惠行正常展示，金额正确
- 无油气费运单：不展示油气优惠行
- 全流程运单(fullProcessFlag=10)：油气优惠展示为 0
- 编辑页修改运费后：油气优惠金额通过接口实时更新

**收益**：油气优惠判断从 3 处重复变为 1 处，规则变更只改 1 处

### 任务 P1-2：提取 newList 构建为 buildNewList 方法

**改哪里**：CostMessageDetails.vue

**做什么**：
1. 新增方法 `buildNewList(detailObj)`，统一构建 newList（运费差价 + 货物保障服务 + 油气优惠）
   - 处理 `companyType === 1` 不显示运费差价
   - 处理 `fullProcessFlag === 10` 时货物保障服务金额为 0
   - 调用 `buildOilGasItem` 添加油气优惠行（依赖 P1-1 完成）
2. mounted 中的 newList 初始化改为调用 `this.buildNewList(this.detailObj)`
3. detailObj watcher 首次构建分支改为调用 `this.buildNewList(this.detailObj)`

**验证**：
- 查看页：运费差价行、货物保障服务行、油气优惠行正常展示
- companyType=1：不显示运费差价行
- companyType=2：显示运费差价行
- premiumBuyerType='10'：tableNewList 过滤掉货物保障服务行
- 编辑页保存后重新加载：newList 正确重建

**收益**：newList 构建逻辑从 2 处重复变为 1 处，消除首次加载与 watcher 不一致风险

### 任务 P1-3：提取费用计算纯函数到 costCalculation.js

**改哪里**：新增 `mixins/costCalculation.js`，修改 CostMessageDetails.vue

**做什么**：
将以下方法从组件 methods 迁移到 mixin（保持方法签名不变，组件内引用不变）：
- `countMoney(cost, rate)` -- 运费差价计算
- `count(Amount, Rate)` -- 差价核心公式
- `getBit(value, n)` -- 截取精度
- `formatService(num, n, type)` -- 取整方式
- `dealZeroModeFn()` 中的核心计算部分 -- 提取为 `calcZeroAmount(model, zeroByBusIdMode)` 纯函数

**验证**：
- 编辑页修改确认金额，小计、合计是否实时更新
- 抹零模式=不抹零(0)，无抹零行
- 抹零模式=小数抹零，抹零行金额正确，方向（应收/应付）正确
- 抹零模式=个位抹零，同上
- 保存时费用数据与页面展示一致

**收益**：计算逻辑可脱离 Vue 组件单测；CostMessageDetails 减少约 100 行

---

## 六、P2 批次：组件拆分（2 个任务，依赖 P1 完成）

> 目标：拆分 CostMessageDetails 职责，不改父子通信方式。

### 任务 P2-1：拆出 CostSummaryTable.vue（汇总副表）

**改哪里**：新增 `components/CostSummaryTable.vue`，修改 CostMessageDetails.vue

**做什么**：
1. 将 CostMessageDetails 中第二个 `el-table`（summaryTable，第 116-149 行）迁移到新组件
2. 迁移 `summariesFn` 方法（第 862-940 行）
3. 迁移 `newList`、`tableNewList` computed、`subtotal` watch 中的 newList 重建逻辑
4. CostMessageDetails 通过 props 传递 `detailObj`、`subtotal`、`partPayData` 给 CostSummaryTable
5. CostSummaryTable 通过 `emit('newServiceCharge')` 和 `emit('updateDetail')` 向上传递

**验证**：
- 合计行金额正确（小计 + 运费差价 + 货物保障 - 油气优惠）
- companyType=1：合计行不显示，仅显示应付承运商运费
- companyType=2：合计行显示，显示客户应付运费
- fullProcessFlag=10：显示全流程运费差价行 + 差价率
- 分次支付运单：小计行的分次支付信息正常展示
- premiumBuyerType='20'：小计行展示"含司机购买货物保障服务金额"
- 编辑页修改运费，合计行联动更新
- 编辑页保存，保存数据中运费差价与页面一致

**收益**：CostMessageDetails 从约 1100 行（P1 后）降到约 850 行；汇总表独立维护

### 任务 P2-2：拆出附件管理逻辑到 useAttachment.js

**改哪里**：新增 `mixins/useAttachment.js`，修改 CostMessageDetails.vue

**做什么**：
将附件相关方法迁移到独立 mixin：
- `viewFiles(index, fileList)` -- 打开附件弹窗
- `uploadSuccess({ response, file, fileList })` -- 上传成功回调
- `beforeUpload(val)` / `handleError()` -- 上传状态管理
- `fileRemove(file, fileList)` -- 删除附件
- `closeDialog()` -- 关闭弹窗
- `handleLookImg(item)` -- 查看附件图片预览
- `handleDialogClose()` -- 关闭图片预览
- 相关 data：`fileList`、`activeIndex`、`upLoading`、`show.dialog`、`imgList`、`imgListTableUrl`

**验证**：
- 编辑页点击"上传附件"，弹窗正常打开
- 上传图片，成功添加到对应费用行
- 删除附件，从费用行移除
- 查看页点击"查看附件"，图片预览正常
- 保存时费用行的 attachmentList 包含正确附件数据

**收益**：CostMessageDetails 再减约 80 行；附件逻辑集中，便于后续维护

---

## 七、P3 批次：通信解耦（1 个任务，可选，高风险）

> 目标：消除 $refs 耦合。仅在 P0-P2 全部完成且稳定后执行。

### 任务 P3-1：edit.vue 与 CostMessageDetails 通信改为 props/emit

**改哪里**：edit.vue + CostMessageDetails.vue

**做什么**：
1. `this.$refs.CostMessageDetails.commit()` 改为 CostMessageDetails `emit('commit', dataList)`，edit.vue 在事件回调中获取
2. `this.$refs.CostMessageDetails.dealZeroModeFn()` 改为通过 prop `zeroTrigger` 变化触发 watch 执行
3. `this.$refs.CostMessageDetails.newList[0]?.confirmRemark` 改为 CostMessageDetails `emit('rateChange', rate)`
4. `this.$refs.CostMessageDetails.countMoney(amount, rate)` 改为 CostMessageDetails `emit('subtotalChange', subtotal)`，edit.vue 通过 prop 传回 rate
5. `this.$refs.CostMessageDetails.subtotal` 改为 `emit('subtotalChange', subtotal)`

**验证**（完整回归）：
- 编辑页完整保存流程：点保存 - 校验 - 抹零弹窗 - 确认 - 接口调用
- 编辑页完整提交流程：点提交 - 校验 - 风控弹窗 - 确认 - 接口调用
- 运费差价率调整，合计是否正确
- 抹零三种模式 x 有无油气费 的组合验证
- 查看页费用明细展示是否不受影响（read.vue 不涉及 $refs）

**收益**：CostMessageDetails 可独立复用；数据流单向清晰，可独立测试

**风险**：保存/提交流程贯穿父子，任何事件遗漏都会导致流程断裂。建议做完后由测试同学完整回归

---

## 八、数据结构设计

### 本次无新增/修改字段

所有重构任务均不改变接口入参和出参，不改变 data 结构（仅在 data() 中补充声明已有的隐式属性 `serviceRateMoney`）。

### 接口入参/出参变化

无。所有接口调用逻辑保持不变。

---

## 九、开发顺序建议

1. **先做 P0（4 个 bug 修复）**，原因：独立性强、风险低、每个任务可单独提交验证
2. **再做 P1（3 个结构收拢）**，原因：依赖 P0 完成，消除重复逻辑为 P2 拆分做准备
3. **然后做 P2（2 个组件拆分）**，原因：依赖 P1 的方法提取，拆分后职责清晰
4. **最后做 P3（通信解耦，可选）**，原因：风险最高，需 P0-P2 全部稳定后执行

---

## 十、风险点

| 风险 | 影响范围 | 建议 |
|------|---------|------|
| P0-2 debounce 修复后防抖生效，可能导致某些快速操作下抹零计算延迟 | 编辑页费用明细 | 验证快速连续修改后最终抹零金额是否正确 |
| P1-1 统一油气优惠逻辑后 mounted 行为微调（增加 fullProcessFlag 处理） | 编辑/查看页首次渲染 | watcher 随后会修正，最终结果一致 |
| P2-1 拆出汇总表后 props/emit 链路可能遗漏 | 汇总行展示 | 重点验证合计行联动更新 |
| P3-1 $refs 改 props/emit 影响面大 | 保存/提交流程 | 完整回归保存+提交路径 |

---

## 十一、不确定项

- 无。所有任务均基于源码分析，不涉及猜测字段或接口路径。

---

## 十二、执行约束

1. **行为不变原则**：每个任务完成后，费用明细的展示和交互必须与重构前完全一致
2. **一次一个任务**：每个任务改完输出自检，等确认后再进入下一个
3. **旧代码注释保留**：替换旧写法时用 `// [重构前] xxx` 注释，不直接删除
4. **不引入新依赖**：不新增 npm 包，不引入新组件库
5. **收益必须具体**：不写"可维护性提升"，写"从改 3 处变改 1 处"、"从 1200 行降到 850 行"

---

## 十三、验收标准

| 批次 | 验收方式 | 通过标准 |
|------|---------|---------|
| P0 | 逐任务验证 + 控制台无报错 | 4 个 bug 修复，控制台无 Vue warning |
| P1 | 逐任务验证 + 对比重构前后行为 | 油气优惠/newList/计算逻辑行为完全一致 |
| P2 | 逐任务验证 + 完整页面回归 | 汇总行、附件功能行为完全一致 |
| P3 | 完整保存/提交流程回归 | 所有费用相关流程与重构前一致 |

---

## 十四、条件编译说明

本项目为 `logisticsweb`（Vue2 + JS + Element UI），不涉及多端差异，无需条件编译。

---

## 十五、不会改动的部分

- 接口调用逻辑不变（postSaveWaybill、postWaybillDetails 等）
- 费用类型/费用项目的下拉选项数据来源不变
- 风控预警逻辑不变
- 亏吨弹窗逻辑不变
- 操作记录分页逻辑不变
- edit.vue 的保存/提交/风控流程整体结构不变（P3 仅改通信方式，不改流程）
