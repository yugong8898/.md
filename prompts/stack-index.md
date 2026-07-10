# 项目技术栈速查（内部参考，供角色文件引用）

## 项目对应关系

| 项目目录 | 技术栈 | UI库 | 样式编译 | 特殊规范 |
|---------|--------|------|---------|---------|
| `logisticsweb` | Vue2 + JS | Element UI | node-sass | 新代码用 `::v-deep`，存量代码有改动时顺手迁移 |
| `platformweb` | Vue2 + JS | Element UI | dart-sass | 强制 `::v-deep`，禁止 `/deep/` 或 `>>>` |
| `bdbl-admin` | Vue2 + JS | Element UI | node-sass | 新代码用 `::v-deep` |
| `wlyd-app-consigner` | Vue2 + uni-app + JS | uView | SCSS | 条件编译、rpx 单位、多端（H5/小程序/APP） |
| `fe-match-end/match-owner-pc` | Vue3 + TS + Vite | 待确认 | SCSS/CSS | Composition API、script setup、`:deep()` |
