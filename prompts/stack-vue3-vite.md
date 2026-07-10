# 技术栈：Vue3 + TypeScript + Vite（撮合PC端）

## 适用项目
- `fe-match-end/match-owner-pc`：货主撮合PC端（monorepo 多包）

## 技术栈
- **框架**：Vue 3.5 + TypeScript 5
- **构建工具**：Vite 7
- **包结构**：monorepo（app-base / app-core / app-dispatch / app-main）
- **样式**：CSS / SCSS
- **HTTP**：待确认

## 核心写法差异（对比 Vue2）

### Composition API 优先
```typescript
// ✅ Vue3 写法
import { ref, reactive, computed, onMounted, watch } from 'vue'

const count = ref(0)
const state = reactive({ name: '' })
const double = computed(() => count.value * 2)

onMounted(() => {
  // 初始化
})
```

### defineComponent / script setup
```typescript
// 推荐 script setup 写法
<script setup lang="ts">
import { ref } from 'vue'

const props = defineProps<{ title: string }>()
const emit = defineEmits<{ change: [value: string] }>()

const count = ref(0)
</script>
```

### 响应式
- `ref()`：基础类型响应式，访问值用 `.value`
- `reactive()`：对象响应式
- 不需要 `this.$set()`，直接赋值即可响应
- 模板中 `ref` 自动解包，不需要 `.value`

### 生命周期对应
| Vue2 | Vue3 (setup 内) |
|------|----------------|
| `created` | `setup()` 直接执行 |
| `mounted` | `onMounted()` |
| `updated` | `onUpdated()` |
| `beforeDestroy` | `onBeforeUnmount()` |
| `destroyed` | `onUnmounted()` |

### 路由
```typescript
import { useRouter, useRoute } from 'vue-router'
const router = useRouter()
const route = useRoute()
router.push('/path')
```

### 状态管理（Pinia 或 Vuex4，以项目实际为准）
```typescript
// Pinia 写法
import { defineStore } from 'pinia'
export const useUserStore = defineStore('user', () => {
  const name = ref('')
  return { name }
})
```

## TypeScript 规范要点

- 接口用 `interface`，类型别名用 `type`
- 避免使用 `any`，用 `unknown` + 类型收窄替代
- Props 类型用泛型定义，不用 `PropType`
- API 返回值定义接口类型

```typescript
interface UserInfo {
  id: number
  name: string
  role: 'admin' | 'user'
}

async function fetchUser(id: number): Promise<UserInfo> {
  return request.get(`/user/${id}`)
}
```

## 样式规范
- 单位：`px`（PC端）
- 样式穿透（Vue3）：`:deep(.class-name)`，不用 `::v-deep`
- 推荐 CSS Modules 或 scoped

```scss
// Vue3 样式穿透写法
:deep(.el-input__inner) {
  color: #333;
}
```

## 注意事项
- 无条件编译（纯 Web 项目）
- 无 `this`（Composition API 中不用 `this`）
- `v-model` 语法变化：Vue3 默认 `modelValue` + `update:modelValue`
- 多个 `v-model`：`v-model:title="xxx"` / `v-model:content="yyy"`

## ESLint 验证命令
```bash
cd fe-match-end/match-owner-pc/app-main
npx eslint src/path/to/file.vue --fix
```
