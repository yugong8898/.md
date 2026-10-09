# DeptHierarchyTreeSelect 组件分析文档

## 一、组件概述

**组件路径**: `platformweb/src/views/costManagement/serviceFeeSettlement/billStatement/components/DeptHierarchyTreeSelect.vue`

**组件名称**: DeptHierarchyTreeSelect (业务归属公司树形选择器)

**组件类型**: 公共业务组件

**核心功能**: 基于用户权限展示业务归属公司的树形选择器,支持一级公司和二级公司的层级结构

---

## 二、当前使用范围分析

### 2.1 已确认使用的页面

根据代码搜索结果,该组件目前在以下 **4个页面** 中使用:

| 序号 | 页面路径 | 页面名称 | 使用场景 |
|-----|---------|---------|---------|
| 1 | `src/views/costManagement/customerCostDiffRate.vue` | 客户成本差价率 | 查询条件 - 业务归属公司筛选 |
| 2 | `src/views/costManagement/serviceFeeSettlement/waybill/index.vue` | 服务费结算-按运单 | 查询条件 - 业务归属公司筛选 |
| 3 | `src/views/costManagement/serviceFeeSettlement/billStatement/index.vue` | 服务费结算-按对账单 | 查询条件 - 业务归属公司筛选 |
| 4 | `src/views/public/system/userManagementDetail.vue` | 用户管理详情 | 用户配置 - 业务归属公司权限配置 |

### 2.2 影响范围评估

**核心影响**: 
- 成本管理模块的3个页面 (本次需求直接涉及)
- 用户管理模块的1个页面 (权限配置,间接影响)

**风险等级**: 🔴 **高风险**

**原因**:
1. 该组件是成本管理模块的核心查询组件
2. 用户管理模块依赖此组件配置权限
3. 修改会影响所有使用该组件的页面
4. 涉及权限控制逻辑,影响数据安全

---

## 三、组件当前设计分析

### 3.1 组件结构

```vue
<template>
  <el-select + el-tree 组合>
    - el-select: 提供下拉框和搜索功能
    - el-tree: 提供树形结构展示
</template>
```

### 3.2 核心功能

#### 3.2.1 数据获取

**接口**: `getLecUserCompanyRelByUserBaseId`

**接口路径**: `/PlatformUmUserbaseinfo/getLecUserCompanyRelByUserBaseId`

**请求参数**:
```javascript
{
  userBaseId: string  // 用户基础ID
}
```

**返回数据结构**:
```javascript
{
  model: [
    {
      companyId: string,        // 公司ID
      companyName: string,      // 公司名称
      companyLv: number,        // 公司层级: 11=一级公司, 10=二级公司
      parentCompanyId: string   // 父公司ID
    }
  ]
}
```

#### 3.2.2 树形结构构建逻辑

```javascript
function buildTree(list) {
  // 1. 遍历数据,创建节点Map
  // 2. 根据 companyLv 判断层级:
  //    - companyLv = 11: 一级公司,作为根节点
  //    - companyLv = 10: 二级公司,挂载到 parentCompanyId 对应的父节点
  // 3. 找不到父节点的,兜底为根节点
  // 4. 返回树形结构
}
```

#### 3.2.3 事件回传

**事件名**: `treeEvent`

**回传参数**:
```javascript
this.$emit('treeEvent', 
  [selectedName, selectedId],  // 参数1: [公司名称, 公司ID]
  selectedInfo,                 // 参数2: 选中节点的完整信息
  selectedParentInfo            // 参数3: 选中节点的父节点信息
)
```

**特殊处理**:
- 当选中"集团本部"时,回传的 `selectedName` 和 `selectedId` 都为空字符串
- 集团本部的 `selectedInfo` 回传空对象 `{}`

### 3.3 组件Props

| 属性 | 类型 | 默认值 | 说明 |
|-----|------|-------|------|
| clearable | Boolean | false | 是否可清空 |
| needDefault | Boolean | true | 是否需要默认选中第一项 |

### 3.4 组件特性

1. **权限控制**: 根据当前登录用户的 `userBaseId` 获取可选的业务归属公司
2. **搜索过滤**: 支持按公司名称搜索过滤
3. **默认选中**: 默认选中第一个节点(可通过 `needDefault` 控制)
4. **清空操作**: 清空时会重新选中第一个节点(如果 `needDefault=true`)
5. **Keep-alive**: 使用时通常配合 `<keep-alive>` 保持状态

---

## 四、本次需求调整方案

### 4.1 需求变更点

**核心变更**: 业务归属公司从单一字段拆分为 **一级公司 + 二级公司** 两个级联字段

**变更前**:
```
业务归属公司: [下拉树形选择器]
```

**变更后**:
```
业务归属一级公司: [下拉选择器]
业务归属二级公司: [下拉选择器] (级联)
```

### 4.2 设计方案对比

#### 方案一: 改造现有组件 (不推荐)

**方案描述**: 将 `DeptHierarchyTreeSelect` 改造为支持级联的双选择器

**优点**:
- 只需修改一个组件
- 组件引用路径不变

**缺点**:
- ❌ 组件职责不清晰(既是树形选择器,又是级联选择器)
- ❌ 用户管理页面不需要级联功能,会受影响
- ❌ 改造成本高,需要大幅修改组件逻辑
- ❌ 向后兼容性差,可能影响其他未知使用场景
- ❌ 测试成本高,需要回归测试所有使用页面

#### 方案二: 新建级联组件 (推荐) ⭐

**方案描述**: 新建 `DeptHierarchyCascadeSelect` 组件,专门处理一级/二级公司级联选择

**优点**:
- ✅ 职责单一,专门处理级联场景
- ✅ 不影响现有组件和用户管理页面
- ✅ 可以针对级联场景优化交互
- ✅ 向后兼容性好,风险可控
- ✅ 便于后续维护和扩展

**缺点**:
- 需要新建组件
- 需要修改3个成本管理页面的引用

**结论**: **推荐方案二**

---

## 五、级联组件设计方案

### 5.1 组件命名

**组件名称**: `DeptHierarchyCascadeSelect`

**组件路径**: `src/components/DeptHierarchyCascadeSelect/index.vue`

**说明**: 放在 `src/components` 下,作为全局公共组件

### 5.2 组件结构

```vue
<template>
  <div class="dept-hierarchy-cascade-select">
    <!-- 一级公司选择器 -->
    <el-select
      v-model="primaryCompanyId"
      placeholder="请选择业务归属一级公司"
      clearable
      filterable
      @change="handlePrimaryChange"
    >
      <el-option
        v-for="item in primaryCompanyOptions"
        :key="item.id"
        :label="item.name"
        :value="item.id"
      />
    </el-select>

    <!-- 二级公司选择器 -->
    <el-select
      v-model="secondaryCompanyId"
      placeholder="请选择业务归属二级公司"
      clearable
      filterable
      :disabled="!primaryCompanyId || primaryCompanyId === 'GROUP_HQ'"
      @change="handleSecondaryChange"
    >
      <el-option
        v-for="item in secondaryCompanyOptions"
        :key="item.id"
        :label="item.name"
        :value="item.id"
      />
    </el-select>
  </div>
</template>
```

### 5.3 数据结构设计

#### 5.3.1 一级公司选项

```javascript
primaryCompanyOptions: [
  { id: 'GROUP_HQ', name: '集团本部', level: 0 },
  { id: '1001', name: '华东公司', level: 11 },
  { id: '1002', name: '华南公司', level: 11 },
  // ...
]
```

#### 5.3.2 二级公司选项 (动态)

```javascript
secondaryCompanyOptions: [
  { id: 'ALL', name: '全部', special: true },
  { id: 'NONE', name: '暂无', special: true },
  { id: '2001', name: '上海分公司', level: 10, parentId: '1001' },
  { id: '2002', name: '杭州分公司', level: 10, parentId: '1001' },
  // ...
]
```

### 5.4 级联逻辑

```javascript
methods: {
  handlePrimaryChange(primaryId) {
    // 1. 清空二级公司选择
    this.secondaryCompanyId = ''
    
    // 2. 根据一级公司ID更新二级公司选项
    if (primaryId === 'GROUP_HQ') {
      // 集团本部: 二级公司只能选"全部"且禁用
      this.secondaryCompanyOptions = [
        { id: 'ALL', name: '全部', special: true }
      ]
      this.secondaryCompanyId = 'ALL'
      this.secondaryDisabled = true
    } else if (primaryId) {
      // 选中某个一级公司: 显示"全部"、"暂无"、该一级公司下的所有二级公司
      this.secondaryCompanyOptions = [
        { id: 'ALL', name: '全部', special: true },
        { id: 'NONE', name: '暂无', special: true },
        ...this.getSecondaryByPrimary(primaryId)
      ]
      this.secondaryDisabled = false
    } else {
      // 未选中: 清空二级选项
      this.secondaryCompanyOptions = []
      this.secondaryDisabled = true
    }
    
    // 3. 触发change事件
    this.emitChange()
  },
  
  handleSecondaryChange() {
    this.emitChange()
  },
  
  emitChange() {
    this.$emit('change', {
      primaryCompanyId: this.primaryCompanyId,
      primaryCompanyName: this.getPrimaryName(this.primaryCompanyId),
      secondaryCompanyId: this.secondaryCompanyId,
      secondaryCompanyName: this.getSecondaryName(this.secondaryCompanyId)
    })
  }
}
```

### 5.5 权限控制逻辑

```javascript
computed: {
  // 根据用户配置过滤一级公司选项
  primaryCompanyOptions() {
    const userConfig = this.userCompanyConfig // 从store获取
    
    if (userConfig.includes('GROUP_HQ')) {
      // 用户配置为集团本部: 可选集团本部 + 所有一级公司
      return [
        { id: 'GROUP_HQ', name: '集团本部' },
        ...this.allPrimaryCompanies
      ]
    } else if (userConfig.some(c => c.level === 11)) {
      // 用户配置为一级公司: 只能选配置的一级公司
      return this.allPrimaryCompanies.filter(c => 
        userConfig.includes(c.id)
      )
    } else if (userConfig.some(c => c.level === 10)) {
      // 用户配置为二级公司: 只能选配置的二级公司对应的一级公司
      const parentIds = userConfig
        .filter(c => c.level === 10)
        .map(c => c.parentId)
      return this.allPrimaryCompanies.filter(c => 
        parentIds.includes(c.id)
      )
    } else {
      // 混合配置: 一级公司 + 二级公司对应的一级公司
      const primaryIds = userConfig
        .filter(c => c.level === 11)
        .map(c => c.id)
      const parentIds = userConfig
        .filter(c => c.level === 10)
        .map(c => c.parentId)
      const allIds = [...new Set([...primaryIds, ...parentIds])]
      return this.allPrimaryCompanies.filter(c => 
        allIds.includes(c.id)
      )
    }
  },
  
  // 根据选中的一级公司和用户配置过滤二级公司选项
  secondaryCompanyOptions() {
    if (!this.primaryCompanyId) return []
    
    if (this.primaryCompanyId === 'GROUP_HQ') {
      return [{ id: 'ALL', name: '全部' }]
    }
    
    const userConfig = this.userCompanyConfig
    const allSecondary = this.getSecondaryByPrimary(this.primaryCompanyId)
    
    // 根据用户配置过滤
    let filteredSecondary = allSecondary
    if (!userConfig.includes('GROUP_HQ')) {
      // 非集团本部用户,需要过滤
      const configSecondaryIds = userConfig
        .filter(c => c.level === 10 && c.parentId === this.primaryCompanyId)
        .map(c => c.id)
      
      if (configSecondaryIds.length > 0) {
        // 有配置的二级公司,只显示配置的
        filteredSecondary = allSecondary.filter(c => 
          configSecondaryIds.includes(c.id)
        )
      }
    }
    
    return [
      { id: 'ALL', name: '全部', special: true },
      { id: 'NONE', name: '暂无', special: true },
      ...filteredSecondary
    ]
  }
}
```

### 5.6 组件Props

```javascript
props: {
  // 是否可清空
  clearable: {
    type: Boolean,
    default: true
  },
  // 是否需要默认选中
  needDefault: {
    type: Boolean,
    default: false
  },
  // 一级公司默认值
  defaultPrimaryId: {
    type: String,
    default: ''
  },
  // 二级公司默认值
  defaultSecondaryId: {
    type: String,
    default: ''
  }
}
```

### 5.7 组件Events

```javascript
// change事件
this.$emit('change', {
  primaryCompanyId: string,      // 一级公司ID
  primaryCompanyName: string,    // 一级公司名称
  secondaryCompanyId: string,    // 二级公司ID (可能为'ALL'/'NONE')
  secondaryCompanyName: string   // 二级公司名称
})
```

---

## 六、用户管理页面的业务归属公司组件

### 6.1 问题分析

**问题**: `/public/system/userManagementDetail?action=add` 页面的业务归属公司是否使用同一个组件?

**答案**: 根据代码搜索结果,该页面 **不使用** `DeptHierarchyTreeSelect` 组件

**证据**:
1. 搜索结果中只有4个文件引用了 `DeptHierarchyTreeSelect`
2. `userManagementDetail.vue` 中搜索到"业务归属公司"文字,但未搜索到组件引用
3. 该页面的业务归属公司可能使用了其他组件或自定义实现

### 6.2 用户管理页面的业务归属公司功能

**功能说明**: 
- 用于配置用户可以访问哪些业务归属公司的数据
- 提示文字: "业务归属公司用于网货客户成本差价管理相关数据管控,无关人员无需配置"
- 配置后会影响用户在成本管理页面看到的数据范围

**与本次需求的关系**:
- 用户管理页面配置的业务归属公司权限,会影响 `DeptHierarchyTreeSelect` 组件的可选项
- 本次需求调整后,用户管理页面的配置逻辑 **不需要修改**
- 新的级联组件会读取用户配置的权限,自动过滤可选项

### 6.3 建议

**短期**: 保持用户管理页面不变,只调整成本管理页面的查询组件

**长期**: 考虑统一用户管理页面的业务归属公司配置方式,也改为一级/二级公司的配置方式

---

## 七、实施方案

### 7.1 实施步骤

#### 阶段一: 新建级联组件 (1-2天)

1. 创建 `src/components/DeptHierarchyCascadeSelect/index.vue`
2. 实现级联选择逻辑
3. 实现权限控制逻辑
4. 编写组件文档和使用示例
5. 单元测试

#### 阶段二: 替换成本管理页面 (2-3天)

1. 替换客户成本差价率页面
   - 修改查询条件
   - 修改列表字段
   - 修改查询接口参数
   - 新增导出功能

2. 替换服务费结算-按运单页面
   - 修改查询条件
   - 修改列表字段
   - 新增业务类型字段
   - 实现按一级公司生成对账单功能

3. 替换服务费结算-按对账单页面
   - 修改查询条件
   - 修改列表字段
   - 新增导出功能

#### 阶段三: 生成对账单和详情页面 (1-2天)

1. 修改生成对账单页面
2. 修改对账单详情页面

#### 阶段四: 历史数据处理 (1-2天)

1. 编写数据迁移脚本
2. 测试环境验证
3. 生产环境执行

#### 阶段五: 测试和上线 (3-5天)

1. 功能测试
2. 权限测试
3. 性能测试
4. 回归测试
5. 上线部署

**总计**: 8-14个工作日

### 7.2 风险控制

#### 风险1: 权限逻辑复杂,容易出错

**应对措施**:
- 详细的权限矩阵测试用例
- 多种用户配置场景的测试
- 代码Review重点关注权限逻辑

#### 风险2: 历史数据迁移失败

**应对措施**:
- 数据迁移前做好备份
- 编写数据校验脚本
- 灰度发布,先在测试环境验证

#### 风险3: 性能问题

**应对措施**:
- 级联选择器使用虚拟滚动(如果选项过多)
- 接口增加缓存
- 数据库查询优化

#### 风险4: 用户体验下降

**应对措施**:
- 保持默认选中逻辑
- 提供清空快捷操作
- 增加操作提示

---

## 八、组件对比表

| 对比项 | DeptHierarchyTreeSelect (现有) | DeptHierarchyCascadeSelect (新建) |
|-------|-------------------------------|----------------------------------|
| 组件类型 | 树形选择器 | 级联选择器 |
| 选择方式 | 单选(树形结构) | 两级级联选择 |
| 适用场景 | 单一业务归属公司选择 | 一级/二级公司分别选择 |
| 权限控制 | 基于用户配置过滤树节点 | 基于用户配置过滤两级选项 |
| 交互方式 | 下拉树 | 两个下拉框 |
| 搜索功能 | 支持树节点搜索 | 支持两级分别搜索 |
| 默认选中 | 默认选中第一个节点 | 可配置是否默认选中 |
| 清空操作 | 清空后重新选中第一个 | 清空后两级都为空 |
| 回传数据 | [name, id], info, parentInfo | { primary, secondary } |
| 使用页面 | 4个页面 | 3个页面(成本管理) |
| 维护成本 | 低(已稳定) | 中(新组件) |

---

## 九、测试用例

### 9.1 级联逻辑测试

| 测试场景 | 一级公司选择 | 二级公司可选项 | 二级公司状态 |
|---------|------------|--------------|------------|
| 场景1 | 未选择 | 空 | 禁用 |
| 场景2 | 集团本部 | 仅"全部" | 禁用,自动选中"全部" |
| 场景3 | 华东公司 | 全部、暂无、上海分公司、杭州分公司 | 启用 |
| 场景4 | 华东公司 → 清空 | 空 | 禁用 |
| 场景5 | 华东公司 → 华南公司 | 全部、暂无、广州分公司、深圳分公司 | 启用,二级公司重置 |

### 9.2 权限控制测试

| 用户配置 | 一级公司可选 | 选中华东公司时二级公司可选 |
|---------|------------|------------------------|
| 集团本部 | 集团本部、所有一级公司 | 全部、暂无、所有二级公司 |
| 华东公司 | 仅华东公司 | 全部、暂无、所有二级公司 |
| 上海分公司 | 仅华东公司 | 仅上海分公司 |
| 华东公司+广州分公司 | 华东公司、华南公司 | 华东:全部二级; 华南:仅广州 |

### 9.3 数据回传测试

| 操作 | 回传数据 |
|-----|---------|
| 选择集团本部 | { primaryId: 'GROUP_HQ', primaryName: '集团本部', secondaryId: 'ALL', secondaryName: '全部' } |
| 选择华东公司+全部 | { primaryId: '1001', primaryName: '华东公司', secondaryId: 'ALL', secondaryName: '全部' } |
| 选择华东公司+暂无 | { primaryId: '1001', primaryName: '华东公司', secondaryId: 'NONE', secondaryName: '暂无' } |
| 选择华东公司+上海分公司 | { primaryId: '1001', primaryName: '华东公司', secondaryId: '2001', secondaryName: '上海分公司' } |

---

## 十、总结与建议

### 10.1 核心结论

1. **组件使用范围**: `DeptHierarchyTreeSelect` 目前在4个页面使用,其中3个是本次需求涉及的成本管理页面

2. **用户管理页面**: 不使用 `DeptHierarchyTreeSelect` 组件,有独立的业务归属公司配置实现

3. **推荐方案**: 新建 `DeptHierarchyCascadeSelect` 级联组件,替换成本管理页面的查询条件

### 10.2 实施建议

1. **优先级**: 先实现级联组件,再逐个替换页面,最后处理历史数据

2. **测试策略**: 重点测试权限控制逻辑和级联交互,确保各种用户配置场景都能正常工作

3. **上线策略**: 灰度发布,先在测试环境充分验证,再上生产环境

4. **文档完善**: 编写详细的组件使用文档和权限配置说明

### 10.3 后续优化

1. **性能优化**: 如果公司数量很多,考虑使用虚拟滚动或分页加载

2. **用户体验**: 增加快捷选择功能,如"选择我的公司"、"最近使用"等

3. **统一改造**: 长期考虑将用户管理页面的业务归属公司配置也改为级联方式

4. **组件库**: 将级联组件沉淀到公司组件库,供其他项目使用

---

**文档版本**: v1.0

**编写时间**: 2025年

**编写人**: AI助手

**审核状态**: 待审核
