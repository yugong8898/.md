# driverChecking 页面 selectList 数据结构梳理

## 概述

本文档梳理了 `logisticsweb/src/views/userBase/driverChecking/index.vue` 页面中 503-515 行统计区域的数据结构和计算逻辑。

## 页面位置

文件路径：`logisticsweb/src/views/userBase/driverChecking/index.vue`

代码行号：503-515 行（选中运单统计信息展示区域）

## 数据结构定义

### `selectList` 对象（第 774 行定义）

```javascript
selectList: {
  selectNum: 0,          // 选中运单数量
  totalAmount: 0,        // 应付金额
  totalDriverAmount: 0,  // 司机运费
  totalFreightDiffAmt: 0, // 运费差价
  quantity: []           // 装卸货数量数组
}
```

### `quantity` 数组元素结构

```javascript
{
  loadQuantity: Number,       // 装货数量（累加值）
  unloadQuantity: Number,     // 卸货数量（累加值）
  settlementType: String,     // 结算类型（key）
  settlementTypeText: String  // 结算类型文本（吨/车/方/节/件）
}
```

## 字段来源与计算逻辑

### 1. `selectNum`（选中运单数量）

**来源**：`selection.length`

**计算**：直接取选中数组的长度

```javascript
this.selectList.selectNum = this.selection.length
```

### 2. `totalDriverAmount`（司机运费）

**来源字段**：`item.receivableTotalCost`

**计算逻辑**：使用 BigNumber 累加所有选中运单的 `receivableTotalCost`

```javascript
this.selectList.totalDriverAmount = this.selection.reduce((total, item) => {
  return total.plus(+item.receivableTotalCost)
}, new BigNumber(0))
```

### 3. `totalFreightDiffAmt`（运费差价）

**来源字段**：`item.serviceCharge`

**计算逻辑**：累加所有选中运单的 `serviceCharge`，但有特殊规则：
- 全流程（`fullProcessFlag === 10`）且 B1 类型（`companyType === 1`）时排除，不参与统计

```javascript
this.selectList.totalFreightDiffAmt = this.selection.reduce((total, item) => {
  return item.fullProcessFlag === 10 && item.companyType === 1 
    ? total 
    : total.plus(item.serviceCharge || 0)
}, new BigNumber(0)).toNumber()
```

### 4. `totalAmount`（应付金额）

**来源字段**：
- 全流程：`item.payableFpFreight`
- 非全流程：`item.waybillToConsignorPrice`

**计算逻辑**：根据第一条选中运单的 `fullProcessFlag` 判断场景

```javascript
if (this.selectedFullProcessFlag === 10) {
  // 全流程场景
  this.selectList.totalAmount = this.selection.reduce((total, item) => {
    return total.plus(+item.payableFpFreight)
  }, new BigNumber(0))
} else {
  // 非全流程场景
  this.selectList.totalAmount = this.selection.reduce((total, item) => {
    return total.plus(+item.waybillToConsignorPrice || 0)
  }, new BigNumber(0))
}
```

**注意**：后端已包含油气优惠的扣除，前端无需再次计算

### 5. `quantity[]`（装卸货数量）

**来源字段**：
- `item.loadQuantity` → 装货数量
- `item.unloadQuantity` → 卸货数量
- `item.settlementType` → 结算类型

**计算逻辑**：
1. 按 `settlementType` 分组
2. 相同类型的装/卸货数量累加
3. 按固定顺序排序：`['吨', '车', '方', '节', '件']`
4. 未在列表中的类型排在末尾

```javascript
this.selection.forEach(item => {
  let quantityIndex = null
  const quantity = quantityArr.filter((q, qIndex) => {
    if (q.settlementType === item.settlementType) {
      quantityIndex = qIndex
      return q
    }
  })
  if (quantity.length) {
    // 已存在该类型，累加数量
    const initData = {
      loadQuantity: this.BNumber(quantity[0].loadQuantity).plus(item.loadQuantity || 0),
      unloadQuantity: this.BNumber(quantity[0].unloadQuantity).plus(item.unloadQuantity || 0),
      settlementType: quantity[0].settlementType,
      settlementTypeText: this.exGetUnitName(quantity[0].settlementType)
    }
    this.$set(quantityArr, quantityIndex, initData)
  } else {
    // 新类型，初始化
    const initData = {
      loadQuantity: item.loadQuantity || 0,
      unloadQuantity: item.unloadQuantity || 0,
      settlementType: item.settlementType,
      settlementTypeText: this.exGetUnitName(item.settlementType)
    }
    if (sortArr.indexOf(initData.settlementTypeText) > -1) {
      this.$set(quantityArr, sortArr.indexOf(initData.settlementTypeText), initData)
    } else {
      this.$set(quantityArr, sortNumber, initData)
      sortNumber++
    }
  }
})
this.$set(this.selectList, 'quantity', quantityArr)
```

## 页面展示逻辑

### HTML 模板（503-515 行）

```vue
<div class="select-box-sum">
  选中<span class="red-number">{{ selectList.selectNum }}</span>单&nbsp;
  
  装货数量<span v-if="!selectList.selectNum" class="red-number">0</span>
  <span v-for="(item, index) in selectList.quantity" :key="index">
    <span v-if="item && (item.loadQuantity || item.loadQuantity === 0)">
      <span class="red-number">{{ item.loadQuantity }}</span>{{ item.settlementTypeText }}&nbsp;
    </span>
  </span>
  
  卸货数量<span v-if="!selectList.selectNum" class="red-number">0</span>
  <span v-for="(item, index) in selectList.quantity" :key="index+'12345'">
    <span v-if="item && (item.unloadQuantity || item.unloadQuantity === 0)">
      <span class="red-number">{{ item.unloadQuantity }}</span>{{ item.settlementTypeText }}&nbsp;
    </span>
  </span>
  
  应付<span class="red-number">{{ parsePrice(selectList.totalAmount) }}</span>元&nbsp;
  含司机运费<span class="red-number">{{ parsePrice(selectList.totalDriverAmount) }}</span>元
  运费差价<span class="red-number">{{ parsePrice(selectList.totalFreightDiffAmt) }}</span>元
</div>
```

### 展示规则

1. **选中运单数**：直接显示 `selectNum`
2. **装/卸货数量**：
   - 当 `selectNum === 0` 时，直接显示 `0`
   - 否则遍历 `quantity` 数组，按结算类型分别展示："数值+单位"
   - 示例：`5吨 2车 10方`
3. **应付金额**：使用 `parsePrice()` 格式化金额，保留两位小数
4. **司机运费**：使用 `parsePrice()` 格式化金额
5. **运费差价**：使用 `parsePrice()` 格式化金额

## 数据更新时机

**监听器**：`selection` 数组变化时触发（第 991 行）

```javascript
selection: {
  handler(val, oldVal) {
    // 重新计算 selectList 所有字段
  },
  deep: true,
  immediate: true
}
```

**触发场景**：
- 勾选/取消勾选运单
- 批量全选/取消全选
- 筛选条件变化导致运单列表更新

## 字段映射汇总表

| 展示字段 | 数据来源 | 计算方式 | 特殊规则 |
|---------|---------|---------|---------|
| 选中运单数 | `selection.length` | 直接取值 | — |
| 装货数量 | `item.loadQuantity` | 按 `settlementType` 分组累加 | 按固定顺序排序 |
| 卸货数量 | `item.unloadQuantity` | 按 `settlementType` 分组累加 | 按固定顺序排序 |
| 应付金额 | `item.payableFpFreight` 或 `item.waybillToConsignorPrice` | BigNumber 累加 | 全流程/非全流程取不同字段 |
| 司机运费 | `item.receivableTotalCost` | BigNumber 累加 | — |
| 运费差价 | `item.serviceCharge` | BigNumber 累加 | 全流程 B1 类型排除 |

## 注意事项

1. **精度问题**：金额计算使用 `BigNumber` 避免 JavaScript 浮点数精度问题
2. **全流程判断**：`selectedFullProcessFlag` 取第一条选中运单的 `fullProcessFlag`
3. **油气优惠**：后端已扣除，前端不再重复计算
4. **数量单位排序**：固定顺序为 `['吨', '车', '方', '节', '件']`，未知单位排在末尾
5. **空值处理**：使用 `|| 0` 避免 `null` 或 `undefined` 导致计算错误

## 相关方法

- `parsePrice()`：金额格式化，保留两位小数
- `BNumber()`：创建 BigNumber 实例
- `exGetUnitName()`：根据 `settlementType` 获取单位文本

---

**文档版本**: v1.0

**最后更新**: 2026年06月

**整理人**: 王新骏
