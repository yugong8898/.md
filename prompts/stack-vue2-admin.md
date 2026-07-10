# 技术栈：Vue2 后台管理系统

## 适用项目
- `logisticsweb`：物流后台（node-sass）
- `platformweb`：平台后台（dart-sass）
- `bdbl-admin`：百搭百联后台（node-sass）

## 技术栈
- **框架**：Vue 2.6 + JavaScript
- **路由**：Vue Router 3
- **状态管理**：Vuex 3
- **UI 组件库**：Element UI 2.x
- **构建工具**：Vue CLI 4 + Webpack 4
- **样式**：SCSS

## 样式穿透规则（重要）

### platformweb（dart-sass）
- 必须使用 `::v-deep`
- 禁止使用 `/deep/` 或 `>>>`（dart-sass 不支持，会导致编译报错）

### logisticsweb / bdbl-admin（node-sass）
- 新代码统一使用 `::v-deep`
- 存量代码有改动时顺手迁移，不强制全量替换

## 代码规范要点

### Options API 写法
```javascript
export default {
  name: 'ComponentName',
  components: {},
  props: {},
  data() { return {} },
  computed: {},
  watch: {},
  created() {},
  mounted() {},
  methods: {}
}
```

### 常用 API
- 路由跳转：`this.$router.push()` / `this.$router.replace()`
- 状态：`this.$store.dispatch()` / `this.$store.commit()`
- 弹窗：`this.$message()` / `this.$confirm()` / `this.$alert()`（Element UI）
- 请求：`axios`（封装在 `@wlydfe/http`）

### 样式单位
- PC 端使用 `px`，不使用 `rpx`

### 不支持的特性
- 无 Composition API（无 `setup`、`ref`、`reactive`）
- 无 `$set` 替代方案外的响应式新增属性（须用 `this.$set`）
- 无 TypeScript

## ESLint 验证命令
```bash
# logisticsweb
cd logisticsweb && npx eslint src/path/to/file.vue --no-eslintrc -c .eslintrc.js

# platformweb
cd platformweb && npx eslint src/path/to/file.vue --no-eslintrc -c .eslintrc.js

# 自动修复
npx eslint src/path/to/file.vue --no-eslintrc -c .eslintrc.js --fix
```
