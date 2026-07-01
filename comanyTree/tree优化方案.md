# 万级数据量 + 多层级企业树优化方案

## 问题分析

当前方案在数据量上万、层级深的场景下存在以下瓶颈：

1. **接口响应慢**：一次性返回完整树，后端查询和序列化耗时长，响应体积大
2. **前端渲染卡顿**：el-tree 一次性渲染上万 DOM 节点，页面卡死
3. **内存占用高**：完整树数据常驻内存，多个页面各存一份
4. **默认回显依赖全量数据**：当前逻辑需要拿到完整树后才能确定默认选中节点

---

## 方案总览

采用 **懒加载 + 节点路径回显 + 搜索辅助 + Vuex 缓存** 的组合方案。

```
┌───────────────────────────────────────────────┐
│              前端架构                           │
├───────────────────────────────────────────────┤
│  Vuex Store (companyTree module)              │
│  ├─ nodeCache: Map<id, nodeInfo>              │
│  ├─ childrenCache: Map<parentId, children[]>  │
│  └─ defaultNode: { id, label, path[] }        │
│           │                                   │
│           ▼                                   │
│  CompanyTreeSelect 公共组件                    │
│  (懒加载 el-tree + 远程搜索 + 回显)           │
└───────────────────────────────────────────────┘
           │
           ▼
┌───────────────────────────────────────────────┐
│              后端接口（4个）                    │
├───────────────────────────────────────────────┤
│ 1. /companyTreeChildren/{parentId}            │
│ 2. /companyTreeNode/{nodeId}                  │
│ 3. /companyTreeSearch?keyword=xxx             │
│ 4. /companyTreeDefault/{companyId}            │
└───────────────────────────────────────────────┘
```

---

## 一、后端接口设计

### 接口 1：获取子节点（懒加载核心）

```
GET /DmsPlatformUmCompany/companyTreeChildren/{parentId}
```

| 参数 | 类型 | 说明 |
|------|------|------|
| parentId | String | 父节点ID，传root或公司ID获取第一层 |

响应：
```json
{
  "succeed": true,
  "model": [
    { "id": "1001", "label": "华东分公司", "parentId": "root", "isLeaf": false, "childCount": 56 },
    { "id": "1003", "label": "独立站点A", "parentId": "root", "isLeaf": true, "childCount": 0 }
  ]
}
```

- `isLeaf`：前端据此决定是否显示展开箭头
- `childCount`：可选，展示子节点数量提示

### 接口 2：获取节点详情 + 祖先路径（回显专用）

```
GET /DmsPlatformUmCompany/companyTreeNode/{nodeId}
```

响应：
```json
{
  "succeed": true,
  "model": {
    "id": "3001",
    "label": "杭州子公司",
    "parentId": "1001",
    "isLeaf": true,
    "ancestors": [
      { "id": "root", "label": "总公司" },
      { "id": "1001", "label": "华东分公司" },
      { "id": "3001", "label": "杭州子公司" }
    ]
  }
}
```

用途：根据已保存的 nodeId 回显完整路径，无需加载整棵树。

### 接口 3：搜索节点

```
GET /DmsPlatformUmCompany/companyTreeSearch?keyword=杭州&limit=20
```

响应：
```json
{
  "succeed": true,
  "model": [
    {
      "id": "3001",
      "label": "杭州子公司",
      "fullPath": "总公司 / 华东分公司 / 杭州子公司",
      "ancestors": ["root", "1001", "3001"]
    }
  ]
}
```

### 接口 4：获取默认节点 + 首层数据（合并请求）

```
GET /DmsPlatformUmCompany/companyTreeDefault/{companyId}
```

响应：
```json
{
  "succeed": true,
  "model": {
    "defaultNode": {
      "id": "1001",
      "label": "华东分公司",
      "parentId": "root",
      "isLeaf": false
    },
    "rootChildren": [
      { "id": "1001", "label": "华东分公司", "isLeaf": false, "childCount": 56 },
      { "id": "1002", "label": "华南分公司", "isLeaf": false, "childCount": 38 }
    ]
  }
}
```

用途：一个请求同时拿到默认选中节点和第一层树数据。

详细实现见 [tree优化方案-实现.md](./tree优化方案-实现.md)
