# CostMessageDetails 第二表格数据与模板分离重构方案

## 一、背景与目标

### 当前问题

- `summariesFn` 方法 79 行代码，JSX 模板与业务逻辑混杂
- 条件判断（`companyType`、`fullProcessFlag`）在多个 column 分支中重复
- 新增/修改合计行需要同时修改数据计算、条件判断和 JSX 模板

### 重构目标

- **数据层分离**：合计行配置、金额计算提取到 `computed`
- **模板层分离**：使用标准 Vue 模板语法，`v-if` / `slot-scope` 替代 JSX
- **删除 `summariesFn`**：改用 `el-table` 的 `:data` 绑定

---

## 二、技术方案

### 方案概述

- 第二个表格从 `show-summary` + `:summary-method` 改为 `:data` 绑定
- 新增 `summaryTableData` computed 返回合计行数组
- 每行包含：`rowType`（行类型）、`costName`（费用名称）、`confirmMoney`（金额）、`confirmRemark`（备注）、`showTooltip`（是否显示提示）

---

## 三、详细设计

### 3.1 数据结构设计

**新增 computed**：

```javascript
computed: {
  // 合计金额计算
  summaryTotalAmount() {
    const sum = this.tableNewList.reduce((total, item) => {
      if (item.costName === '油气优惠') {
        const discountAmount = Number(item.confirmMoney)
        if (discountAmount !== -1) {
          total = total.minus(discountAmount)
        }
      } else {
        total = total.plus(+item.confirmMoney)
      }
      return total
    }, new BigNumber(0))
    return Number(sum) + this.subtotal
  },
  
  // 合计表格数据
  summaryTableData() {
    const rows = []
    const { companyType, fullProcessFlag, fpFreightDiffAmt, fpFreightDiffRate, payableFpFreight, bmsWaybillPoolExt } = this.detailObj || {}
    
    // 第一行：合计（B1公司不显示）
    if (companyType !== 1) {
      rows.push({
        rowType: 'total',
        costName: '合计',
        showTooltip: true,
        tooltipContent: '合计结果以现金账户支付测算得出，实际金额以申请付款时为准。',
        confirmMoney: this.summaryTotalAmount,
        confirmRemark: ''
      })
    }
    
    // 第二行：全流程运费差价
    if (fullProcessFlag === 10) {
      rows.push({
        rowType: 'fpFreightDiff',
        costName: '全流程运费差价',
        confirmMoney: fpFreightDiffAmt || 0,
        confirmRemark: `差价率：${this.BNumber((fpFreightDiffRate || 0) * 100).toFixed(2)}%`
      })
    }
    
    // 第三行：客户应付运费（B2公司）
    if (companyType === 2) {
      rows.push({
        rowType: 'payableFreight',
        costName: '客户应付运费',
        confirmMoney: payableFpFreight || 0,
        confirmRemark: `上游客户名称：${bmsWaybillPoolExt?.shipperFullName || ''}`
      })
    }
    
    // 第四行：应付承运商运费（B1公司）
    if (companyType === 1) {
      rows.push({
        rowType: 'payableFreight',
        costName: '应付承运商运费',
        confirmMoney: payableFpFreight || 0,
        confirmRemark: `承运商名称：${bmsWaybillPoolExt?.carrierFullName || ''}`
      })
    }
    
    return rows
  }
}
```

**新增 methods**：

```javascript
methods: {
  // 获取合计金额单位图标
  getSummaryUnit(amount) {
    return this.$unitComputed(amount)
  }
}
```

---

### 3.2 模板改造

**原模板**（第 119-148 行）：

```vue
<el-table ref="summaryTable" v-loading="tableLoading" :data="tableNewList" :show-header="false" :summary-method="summariesFn" show-summary border stripe>
  <el-table-column prop="index" label="序号" width="60" />
  <el-table-column prop="" label="费用类型" width="100" />
  <el-table-column prop="costName" label="费用项目" width="160">
    <template slot-scope="scope">
      <span>{{ scope.row.costName }}</span>
    </template>
  </el-table-column>
  <!-- ... 其他列 ... -->
</el-table>
```

**新模板**：

```vue
<el-table 
  ref="summaryTable" 
  v-loading="tableLoading" 
  :data="summaryTableData" 
  :show-header="false" 
  border 
  stripe
>
  <el-table-column label="序号" width="60" />
  <el-table-column label="费用类型" width="100" />
  
  <!-- 费用项目列 -->
  <el-table-column prop="costName" label="费用项目" width="160">
    <template slot-scope="scope">
      <span>{{ scope.row.costName }}</span>
      <el-tooltip 
        v-if="scope.row.showTooltip" 
        class="item" 
        effect="light" 
        placement="top"
      >
        <i class="el-icon-question" />
        <div slot="content" style="width: 210px; line-height: 20px">
          {{ scope.row.tooltipContent }}
        </div>
      </el-tooltip>
    </template>
  </el-table-column>
  
  <el-table-column label="原金额（元）" width="100" />
  <el-table-column label="调整金额（元）" width="110" />
  
  <!-- 确认金额列 -->
  <el-table-column prop="confirmMoney" label="确认金额（元）" width="200">
    <template slot-scope="scope">
      <!-- 合计行：大字体 + 单位图标 + 脱敏 -->
      <div v-if="scope.row.rowType === 'total'" class="summary-total-wrapper">
        <span class="unit"></span>
        <span class="total" v-mask-star>
          <img :src="getSummaryUnit(scope.row.confirmMoney)" class="img" />
          {{ parsePrice(scope.row.confirmMoney) }}
        </span>
      </div>
      <!-- 其他行：普通展示 + total样式 -->
      <span v-else class="total">
        {{ parsePrice(scope.row.confirmMoney) }}
      </span>
    </template>
  </el-table-column>
  
  <!-- 费用备注列 -->
  <el-table-column prop="confirmRemark" label="费用备注" min-width="250">
    <template slot-scope="scope">
      <span v-if="scope.row.confirmRemark">{{ scope.row.confirmRemark }}</span>
    </template>
  </el-table-column>
  
  <el-table-column label="附件" width="100" />
  <el-table-column label="操作人" min-width="120" />
  <el-table-column label="操作时间" width="150" />
  <el-table-column v-if="type === 'edit'" label="操作" width="150" />
</el-table>
```

---

### 3.3 删除代码

**删除 `summariesFn` 方法**（第 792-870 行）：

```javascript
// 完整删除，不保留注释
summariesFn(param) {
  // ... 79 行代码全部删除
}
```

---

## 四、改造对比

### 改造前（当前代码）

```javascript
// 数据计算、条件判断、JSX 模板混在一起
summariesFn(param) {
  const fpFreightDiffAmt = this.detailObj?.fpFreightDiffAmt || 0
  columns.forEach((column, index) => {
    if (column.property === 'costName') {
      sums[index] = <div class='custom-summary-rows'>
        {this.detailObj.companyType === 1 ? '' : <div>合计</div>}
        {this.detailObj.fullProcessFlag === 10 ? <div>全流程运费差价</div> : ''}
      </div>
    }
  })
}
```

### 改造后（新代码）

```javascript
// 数据层
computed: {
  summaryTableData() {
    const rows = []
    if (this.detailObj.companyType !== 1) {
      rows.push({ costName: '合计', confirmMoney: this.summaryTotalAmount })
    }
    return rows
  }
}

// 模板层
<template>
  <el-table-column prop="costName">
    <template slot-scope="scope">
      <span>{{ scope.row.costName }}</span>
    </template>
  </el-table-column>
</template>
```

---

## 五、兼容性说明

### 保持不变的部分

- ✅ 第一个表格（小计行）不变
- ✅ `tableNewList` computed 保持不变（被 `summaryTotalAmount` 依赖）
- ✅ 样式类名保持一致（`.total`、`.img`）
- ✅ 脱敏指令 `v-mask-star` 保持
- ✅ 单位图标逻辑 `$unitComputed` 保持

### 改动的部分

- ❌ 删除 `summariesFn` 方法
- ❌ 删除第二个表格的 `show-summary` / `:summary-method`
- ✅ 第二个表格从 `:data="tableNewList"` 改为 `:data="summaryTableData"`

---

## 六、文件清单

### 涉及文件

```
logisticsweb/src/views/userBase/waybillSettlement/components/CostMessageDetails.vue
```

### 改动统计

| 类型 | 位置 | 行数 | 说明 |
|------|------|------|------|
| **新增** | computed | +50 | `summaryTotalAmount`、`summaryTableData` |
| **新增** | methods | +5 | `getSummaryUnit` |
| **修改** | template | ~30 | 第二个 `el-table` 改用 `:data` 绑定 |
| **删除** | methods | -79 | `summariesFn` 整个方法 |
| **合计** | - | **-24 行** | 净减少代码 |

---

## 七、测试清单

### 功能验证

```
□ 合计金额计算正确（= 小计 + 运费差价 + 货物保障服务 - 油气优惠）
□ B1 公司不显示"合计"行
□ B2 公司显示"合计"行
□ 全流程运单显示"全流程运费差价"行
□ B2 公司显示"客户应付运费"行 + 上游客户名称
□ B1 公司显示"应付承运商运费"行 + 承运商名称
□ 差价率计算正确（百分比保留 2 位小数）
□ 油气优惠为 -1 时按 0 处理
```

### 样式验证

```
□ 合计金额大字体 + 单位图标显示正确
□ 脱敏指令生效（v-mask-star）
□ tooltip 提示正常显示
□ 表格列宽对齐无异常
□ 边框、斑马纹样式正常
```

### 边界验证

```
□ detailObj 为空时不报错
□ bmsWaybillPoolExt 为空时不报错
□ 金额为 0 时显示正常
□ 金额超大时单位图标切换正常
```

---

## 八、执行计划

### 实施步骤

1. **备份当前代码**（可选）
2. **新增 computed 属性**：`summaryTotalAmount`、`summaryTableData`
3. **新增 methods 方法**：`getSummaryUnit`
4. **修改模板**：第二个 `el-table` 改用 `:data="summaryTableData"`，删除 `show-summary` / `:summary-method`
5. **删除 `summariesFn` 方法**
6. **本地验证**：启动项目，测试不同场景
7. **提交代码**

### 预计耗时

- 编码：30 分钟
- 测试：30 分钟
- **总计**：1 小时

---

## 九、风险评估

### 技术风险

- **风险等级**：🟢 低
- **原因**：只是代码结构重构，不改变业务逻辑，不涉及接口调用

### 回滚方案

- Git 回退到改造前的 commit

---

## 十、后续优化建议

### 可选优化点

1. **提取行配置**：将 `summaryTableData` 的行配置提取到 `data` 或 `constants`，进一步提升可维护性
2. **单元测试**：为 `summaryTotalAmount`、`summaryTableData` 编写单元测试
3. **第一个表格重构**：`handleGetSummaries`（小计行）也可以用类似方式重构

---

## 附录：完整代码示例

### A1. computed 完整代码

```javascript
computed: {
  // ... 原有 computed 保持不变 ...
  
  // 🆕 合计金额计算
  summaryTotalAmount() {
    const sum = this.tableNewList.reduce((total, item) => {
      if (item.costName === '油气优惠') {
        const discountAmount = Number(item.confirmMoney)
        if (discountAmount !== -1) {
          total = total.minus(discountAmount)
        }
      } else {
        total = total.plus(+item.confirmMoney)
      }
      return total
    }, new BigNumber(0))
    return Number(sum) + this.subtotal
  },
  
  // 🆕 合计表格数据
  summaryTableData() {
    const rows = []
    const { companyType, fullProcessFlag, fpFreightDiffAmt, fpFreightDiffRate, payableFpFreight, bmsWaybillPoolExt } = this.detailObj || {}
    
    if (companyType !== 1) {
      rows.push({
        rowType: 'total',
        costName: '合计',
        showTooltip: true,
        tooltipContent: '合计结果以现金账户支付测算得出，实际金额以申请付款时为准。',
        confirmMoney: this.summaryTotalAmount,
        confirmRemark: ''
      })
    }
    
    if (fullProcessFlag === 10) {
      rows.push({
        rowType: 'fpFreightDiff',
        costName: '全流程运费差价',
        confirmMoney: fpFreightDiffAmt || 0,
        confirmRemark: `差价率：${this.BNumber((fpFreightDiffRate || 0) * 100).toFixed(2)}%`
      })
    }
    
    if (companyType === 2) {
      rows.push({
        rowType: 'payableFreight',
        costName: '客户应付运费',
        confirmMoney: payableFpFreight || 0,
        confirmRemark: `上游客户名称：${bmsWaybillPoolExt?.shipperFullName || ''}`
      })
    }
    
    if (companyType === 1) {
      rows.push({
        rowType: 'payableFreight',
        costName: '应付承运商运费',
        confirmMoney: payableFpFreight || 0,
        confirmRemark: `承运商名称：${bmsWaybillPoolExt?.carrierFullName || ''}`
      })
    }
    
    return rows
  }
}
```

### A2. methods 完整代码

```javascript
methods: {
  // ... 原有 methods 保持不变 ...
  
  // 🆕 获取合计金额单位图标
  getSummaryUnit(amount) {
    return this.$unitComputed(amount)
  }
}
```

---

## 十一、收益复盘与最终结论

### 11.1 实际代码量对比

#### 改造前
- `summariesFn`：79 行
- 模板：30 行（已有的 `el-table`）
- **总计**：79 行逻辑代码

#### 改造后
- `summaryTotalAmount` computed：15 行
- `summaryTableData` computed：50 行
- `getSummaryUnit` method：3 行
- 模板改造：40 行（新增 `v-if` 判断、tooltip 等）
- **总计**：108 行

**实际净增加：+29 行**（不是减少，反而增加了）

---

### 11.2 维护成本对比

#### 改造前（JSX 方式）

**新增一行"运费调整"**：
```javascript
// 需在 3 个 column.property 的 JSX 里各加一行
{this.detailObj.needAdjust ? <div>运费调整</div> : ''}
```
- 改动量：3 处（costName、confirmMoney、confirmRemark）
- 改动行数：~10 行

#### 改造后（computed + 模板）

**新增一行"运费调整"**：
```javascript
// 只需在 summaryTableData 里 push
if (this.detailObj.needAdjust) {
  rows.push({
    rowType: 'adjust',
    costName: '运费调整',
    confirmMoney: xxx,
    confirmRemark: xxx
  })
}
// 模板不用改（自动渲染）
```
- 改动量：1 处（summaryTableData）
- 改动行数：~8 行

**结论**：新增行的维护成本**略有下降**（从改 3 处变成改 1 处），但优势不明显。

---

### 11.3 真实收益评估

#### ✅ 有一定收益的点

1. **条件判断集中**：`companyType`、`fullProcessFlag` 只在 computed 里判断一次，不用在 3 个 column 里重复
2. **数据结构清晰**：`summaryTableData` 数组一眼能看出有几行，每行是什么
3. **模板可读性**：`slot-scope` 比 JSX 更符合 Vue 规范，团队更熟悉

#### ❌ 收益不明显的点

1. **代码量不减反增**：多了 29 行
2. **新增行维护成本降低有限**：从改 3 处变成改 1 处，但代码量差不多
3. **性能无明显提升**：computed 有缓存，但 JSX 的 `summariesFn` 本身也不慢

---

### 11.4 投入产出分析

| 维度 | 投入 | 产出 | 性价比 |
|------|------|------|--------|
| 时间成本 | 1.5 小时（编码 + 测试） | 维护成本略降 | ⚠️ 低 |
| 代码量 | 净增加 29 行 | 可读性略提升 | ⚠️ 低 |
| 风险 | 需完整回归测试 | 无功能增强 | ⚠️ 低 |
| 团队熟悉度 | 需重新熟悉写法 | 符合 Vue 规范 | ⚠️ 中 |

---

### 11.5 最终结论：**不推荐执行此重构**

#### 不推荐理由

1. **投入产出比低**
   - 改造耗时：1.5 小时
   - 收益：维护成本降低不明显，代码量反而增加

2. **当前代码可接受**
   - `summariesFn` 虽然 79 行，但逻辑清晰，都是条件判断 + JSX
   - 团队已经熟悉这种写法（项目里其他地方也有类似代码）
   - 没有明显的 bug 或性能问题

3. **重构风险不值得**
   - 虽然风险低，但需要完整回归测试（B1/B2、全流程、油气优惠等场景）
   - 改完后其他开发者需要重新熟悉新写法
   - 新增的 29 行代码反而增加了维护成本

---

### 11.6 更高价值的优化方向

如果要优化这个组件，建议优先做这些：

#### 方向 1：提取魔法数字

```javascript
// 定义常量
const COMPANY_TYPE = {
  B1: 1,  // 承运商
  B2: 2   // 货主
}

const FULL_PROCESS_FLAG = {
  YES: 10,  // 全流程
  NO: 20    // 非全流程
}

// 使用
if (this.detailObj.companyType === COMPANY_TYPE.B1) {
  // ...
}
```

**收益**：代码可读性提升，避免魔法数字，改动量小（约 10 行）

#### 方向 2：抽离计算逻辑

```javascript
methods: {
  // 合计金额计算逻辑单独抽成方法，便于单元测试
  calculateSummaryTotal(tableNewList, subtotal) {
    const sum = tableNewList.reduce((total, item) => {
      if (item.costName === '油气优惠') {
        const discountAmount = Number(item.confirmMoney)
        if (discountAmount !== -1) {
          total = total.minus(discountAmount)
        }
      } else {
        total = total.plus(+item.confirmMoney)
      }
      return total
    }, new BigNumber(0))
    return Number(sum) + subtotal
  }
}
```

**收益**：逻辑可测试，职责更清晰，改动量小（约 20 行）

#### 方向 3：优化第一个表格的 `handleGetSummaries`

- 第一个表格的小计行也有类似问题，而且被调用更频繁
- 优化它的收益比第二个表格更大
- 可以用同样的思路（提取计算逻辑、定义常量）

---

### 11.7 文档状态标识

**⚠️ 本方案不推荐执行**

- 原因：投入产出比低，代码量不减反增
- 建议：保持现状，优先优化更高价值的部分
- 文档保留价值：作为技术方案评估的案例参考

---

**文档版本**: v1.1（增加收益复盘与最终结论）  
**最后更新**: 2026年7月  
**整理人**: 王新骏
