# 企业树优化方案 - 前端实现

## 二、前端 Vuex 缓存层

新增 `src/vuex/modules/companyTree.js`：

```js
import {
  fetchTreeChildren, fetchTreeNode, searchTreeNodes, fetchTreeDefault
} from '@/api/companyTree'

const state = {
  childrenCache: {},    // parentId → children[]
  nodeCache: {},        // nodeId → nodeInfo
  defaultNode: null,
  rootChildren: []
}

const mutations = {
  SET_CHILDREN(state, { parentId, children }) {
    state.childrenCache = { ...state.childrenCache, [parentId]: children }
    children.forEach(node => {
      state.nodeCache = { ...state.nodeCache, [node.id]: node }
    })
  },
  SET_NODE(state, node) {
    state.nodeCache = { ...state.nodeCache, [node.id]: node }
  },
  SET_DEFAULT(state, { defaultNode, rootChildren }) {
    state.defaultNode = defaultNode
    state.rootChildren = rootChildren
    if (defaultNode) {
      state.nodeCache = { ...state.nodeCache, [defaultNode.id]: defaultNode }
    }
  },
  CLEAR_CACHE(state) {
    state.childrenCache = {}
    state.nodeCache = {}
    state.defaultNode = null
    state.rootChildren = []
  }
}

const actions = {
  // 获取子节点（带缓存）
  async getChildren({ commit, state }, parentId) {
    if (state.childrenCache[parentId]) return state.childrenCache[parentId]
    const { model } = await fetchTreeChildren(parentId)
    commit('SET_CHILDREN', { parentId, children: model })
    return model
  },
  // 获取节点详情（回显用）
  async getNodeDetail({ commit, state }, nodeId) {
    if (state.nodeCache[nodeId]?.ancestors) return state.nodeCache[nodeId]
    const { model } = await fetchTreeNode(nodeId)
    commit('SET_NODE', model)
    return model
  },
  // 搜索
  async searchNodes(_, keyword) {
    const { model } = await searchTreeNodes(keyword)
    return model
  },
  // 初始化：获取默认节点 + 首层数据
  async initTree({ commit, state }, companyId) {
    if (state.defaultNode && state.rootChildren.length) {
      return { defaultNode: state.defaultNode, rootChildren: state.rootChildren }
    }
    const { model } = await fetchTreeDefault(companyId)
    commit('SET_DEFAULT', model)
    commit('SET_CHILDREN', { parentId: 'root', children: model.rootChildren })
    return model
  },
  // 切换企业时清除缓存
  clearTreeCache({ commit }) { commit('CLEAR_CACHE') }
}

export default { namespaced: true, state, mutations, actions }
```

---

## 三、前端 API 层

新增 `src/api/companyTree.js`（统一入口，替代重复定义）：

```js
import request from '@/utils/request'
import config from '@/config'
const { dmsUrl } = config

export function fetchTreeChildren(parentId) {
  return request({
    url: `${dmsUrl}/DmsPlatformUmCompany/companyTreeChildren/${parentId}`,
    method: 'get'
  })
}

export function fetchTreeNode(nodeId) {
  return request({
    url: `${dmsUrl}/DmsPlatformUmCompany/companyTreeNode/${nodeId}`,
    method: 'get'
  })
}

export function searchTreeNodes(keyword, limit = 20) {
  return request({
    url: `${dmsUrl}/DmsPlatformUmCompany/companyTreeSearch`,
    method: 'get',
    params: { keyword, limit }
  })
}

export function fetchTreeDefault(companyId) {
  return request({
    url: `${dmsUrl}/DmsPlatformUmCompany/companyTreeDefault/${companyId}`,
    method: 'get'
  })
}
```

---

## 四、公共组件 CompanyTreeSelect.vue

```vue
<template>
  <el-select
    v-model="displayLabel"
    placeholder="请选择业务归属"
    filterable
    remote
    :remote-method="handleSearch"
    :loading="searching"
    clearable
    @clear="handleClear"
    @visible-change="handleVisibleChange"
  >
    <!-- 搜索结果模式 -->
    <template v-if="searchMode">
      <el-option
        v-for="item in searchResults"
        :key="item.id"
        :value="item.id"
        :label="item.label"
      >
        <span>{{ item.label }}</span>
        <span class="tree-path-hint">{{ item.fullPath }}</span>
      </el-option>
    </template>

    <!-- 树模式 -->
    <template v-else>
      <el-option :value="selectTree" class="setstyle">
        <el-tree
          ref="tree"
          lazy
          :load="loadNode"
          :props="treeProps"
          node-key="id"
          highlight-current
          :default-expanded-keys="expandedKeys"
          @node-click="handleNodeClick"
        />
      </el-option>
    </template>
  </el-select>
</template>

<script>
import { mapActions, mapState } from 'vuex'
import { debounce } from 'lodash'

export default {
  name: 'CompanyTreeSelect',
  props: {
    value: { type: String, default: '' },
    label: { type: String, default: '' }
  },
  data() {
    return {
      displayLabel: this.label,
      selectTree: '',
      searchMode: false,
      searchResults: [],
      searching: false,
      expandedKeys: [],
      treeProps: { children: 'children', label: 'label', isLeaf: 'isLeaf' }
    }
  },
  computed: {
    ...mapState('companyTree', ['defaultNode', 'rootChildren'])
  },
  watch: {
    label(val) { this.displayLabel = val }
  },
  created() {
    this.handleSearch = debounce(this._doSearch, 300)
  },
  methods: {
    ...mapActions('companyTree', ['getChildren', 'searchNodes', 'getNodeDetail']),

    // el-tree 懒加载回调
    async loadNode(node, resolve) {
      if (node.level === 0) { resolve(this.rootChildren); return }
      const children = await this.getChildren(node.data.id)
      resolve(children)
    },

    // 节点点击
    handleNodeClick(data) {
      this.displayLabel = data.label
      this.$emit('input', data.id)
      this.$emit('change', { id: data.id, label: data.label })
    },

    // 远程搜索
    async _doSearch(keyword) {
      if (!keyword) { this.searchMode = false; this.searchResults = []; return }
      this.searchMode = true
      this.searching = true
      try { this.searchResults = await this.searchNodes(keyword) }
      finally { this.searching = false }
    },

    // 下拉框展开/收起
    handleVisibleChange(visible) {
      if (visible) { this.searchMode = false; this.searchResults = [] }
    },

    // 清除
    handleClear() {
      this.displayLabel = ''
      this.$emit('input', '')
      this.$emit('change', { id: '', label: '' })
    },

    // 外部调用：根据 nodeId 回显
    async echoByNodeId(nodeId) {
      if (!nodeId) return
      const nodeDetail = await this.getNodeDetail(nodeId)
      this.displayLabel = nodeDetail.label
      if (nodeDetail.ancestors) {
        this.expandedKeys = nodeDetail.ancestors.map(a => a.id)
      }
      this.$emit('input', nodeDetail.id)
      this.$emit('change', { id: nodeDetail.id, label: nodeDetail.label })
    }
  }
}
</script>

<style scoped>
.setstyle {
  height: auto;
  padding: 0 10px 0 0 !important;
  margin: 0;
  cursor: default !important;
  font-weight: 500;
}
.tree-path-hint {
  float: right;
  color: #999;
  font-size: 12px;
}
</style>
```

---

## 五、页面改造示例（WaybillDataNew）

```vue
<template>
  <CompanyTreeSelect
    ref="companyTree"
    v-model="realityCompanyId"
    :label="realityCompanyName"
    @change="handleCompanyChange"
  />
</template>

<script>
import CompanyTreeSelect from '@/components/CompanyTreeSelect.vue'

export default {
  components: { CompanyTreeSelect },
  async activated() {
    await this.initDefaultCompany()
  },
  methods: {
    async initDefaultCompany() {
      const companyId = this.$store.state.app.userInfo.companyId
      const { defaultNode } = await this.$store.dispatch('companyTree/initTree', companyId)
      if (defaultNode) {
        this.realityCompanyId = defaultNode.id
        this.realityCompanyName = defaultNode.label
        this.realityCompanyIdCopy = defaultNode.id
        this.realityCompanyNameCopy = defaultNode.label
      }
    },
    handleCompanyChange({ id, label }) {
      this.realityCompanyId = id
      this.realityCompanyName = label
    },
    handleReset() {
      this.realityCompanyId = this.realityCompanyIdCopy
      this.realityCompanyName = this.realityCompanyNameCopy
      this.$refs.companyTree.echoByNodeId(this.realityCompanyIdCopy)
    }
  }
}
</script>
```

---

## 六、回显方案详解

### 场景 1：页面首次进入

```
页面 activated
  → dispatch('companyTree/initTree', companyId)
    → 请求 /companyTreeDefault/{companyId}
      → 后端返回 { defaultNode, rootChildren }
        → 前端拿到默认节点，直接回显 label
        → rootChildren 作为树第一层数据
        → 无需加载完整树即可完成回显
```

### 场景 2：用户选择了深层节点后刷新页面

```
页面 activated
  → 从 URL query / sessionStorage 读取上次选中的 nodeId
    → dispatch('companyTree/getNodeDetail', nodeId)
      → 请求 /companyTreeNode/{nodeId}
        → 后端返回节点信息 + ancestors 路径
          → 前端回显 label
          → 设置 expandedKeys = ancestors.map(a => a.id)
          → el-tree 懒加载逐层展开到该节点
```

### 场景 3：用户点击"重置"

```
handleReset()
  → 恢复 realityCompanyId = copy 值
  → 调用 $refs.companyTree.echoByNodeId(copyId)
    → nodeCache 中有 → 直接回显（无请求）
    → nodeCache 中无 → 请求 /companyTreeNode/{nodeId} → 回显
```

### 场景 4：用户搜索

```
用户输入关键字
  → debounce 300ms
    → 请求 /companyTreeSearch?keyword=xxx
      → 返回匹配节点列表（含 fullPath）
        → 展示为平铺的 option 列表
        → 用户选中后，切回树模式时自动展开到该节点
```

---

## 七、性能对比

| 指标 | 改造前（全量加载） | 改造后（懒加载） |
|------|-------------------|-----------------|
| 首次请求体积 | 数 MB（万级节点完整 JSON） | ~10KB（首层 + 默认节点） |
| 首屏渲染节点数 | 10000+ DOM 节点 | 20~50 DOM 节点 |
| 内存占用 | 完整树常驻 × 页面数 | 按需缓存，Vuex 共享 |
| 展开子节点 | 无延迟（已加载） | ~100ms（单层请求） |
| 搜索 | 前端全量过滤（卡顿） | 后端搜索（快速精准） |
| 回显 | 依赖全量数据 | 单节点路径请求 |

---

## 八、实施步骤

| 阶段 | 内容 | 前/后端 |
|------|------|---------|
| 1 | 后端新增 4 个接口 | 后端 |
| 2 | 前端新增 `src/api/companyTree.js` | 前端 |
| 3 | 前端新增 `src/vuex/modules/companyTree.js` | 前端 |
| 4 | 前端封装 `CompanyTreeSelect.vue` | 前端 |
| 5 | 改造 WaybillDataNew 页面（试点） | 前端 |
| 6 | 验证通过后，改造其余 3 个页面 | 前端 |
| 7 | 旧接口保留兼容 | 前端 |

---

## 九、降级与兼容

- **旧接口不删除**：Header.vue 的全局状态树如果数据量不大，可以保持现状
- **接口降级**：如果新接口未就绪，CompanyTreeSelect 可 fallback 到旧的全量加载模式
- **渐进式迁移**：先改造数据量最大的页面，逐步替换
