# 项目技术栈索引

根据项目目录找到对应技术栈文件，再引用该文件获取完整规范。

## 项目 → 技术栈文件

| 项目目录 | 技术栈文件 | UI库 | 样式编译 | 特殊规范 |
|---------|----------|------|---------|---------|
| `logisticsweb` | [stack-vue2-admin.md](stack-vue2-admin.md) | Element UI | node-sass | 新代码用 `::v-deep`，存量代码有改动时顺手迁移 |
| `platformweb` | [stack-vue2-admin.md](stack-vue2-admin.md) | Element UI | dart-sass | 强制 `::v-deep`，禁止 `/deep/` 或 `>>>` |
| `bdbl-admin` | [stack-vue2-admin.md](stack-vue2-admin.md) | Element UI | node-sass | 新代码用 `::v-deep` |
| `wlyd-app-consigner` | [stack-vue2-uniapp.md](stack-vue2-uniapp.md) | uView | SCSS | 条件编译、rpx 单位、多端（H5/小程序/APP） |
| `fe-match-end/match-owner-pc` | [stack-vue3-vite.md](stack-vue3-vite.md) | 待确认 | SCSS/CSS | Composition API、script setup、`:deep()` |
