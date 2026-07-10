# 技术栈：Vue2 + uni-app（货主端）

## 适用项目
- `wlyd-app-consigner`：万联通货主端 App（H5 / 微信小程序 / APP 三端）

## 技术栈
- **框架**：Vue 2 + JavaScript
- **跨端方案**：uni-app（HBuilderX / CLI）
- **UI 组件库**：uView
- **状态管理**：Vuex
- **样式**：SCSS（rpx 单位）
- **HTTP**：`@wlydfe/uni_http`

## 多端支持
| 端 | 标识 | 说明 |
|----|------|------|
| H5 | `H5` | 浏览器端，支持 `window`/`document` |
| 微信小程序 | `MP-WEIXIN` | 不支持 DOM 操作 |
| APP | `APP-PLUS` | 原生能力通过 plus API 调用 |

## 条件编译（强制使用）

差异逻辑必须用条件编译，禁止运行时平台判断：

```javascript
// ✅ 正确
// #ifdef H5
const isOwnerH5 = uni.getStorageSync('isOwnerH5')
// #endif

// ❌ 错误
if (process.env.UNI_PLATFORM === 'h5') { ... }
```

模板中：
```html
<!-- #ifdef H5 -->
<view>H5 专属</view>
<!-- #endif -->
```

样式中：
```scss
/* #ifdef H5 */
.container { padding-top: 0; }
/* #endif */
```

## 代码规范要点

### 生命周期
- `onLoad`：获取页面参数、初始化（只触发一次）
- `onShow`：刷新数据（返回页面会再次触发）
- `onReady`：操作 DOM、获取节点（只触发一次）

### 导航 API
- `uni.navigateTo()`：保留当前页跳转
- `uni.redirectTo()`：关闭当前页跳转
- `uni.reLaunch()`：关闭所有页跳转
- `uni.switchTab()`：跳转 tabBar 页面
- `uni.navigateBack()`：返回上一页

### 页面通信
```javascript
// 发送
uni.$emit('update', { data: 'xxx' })
// 监听
uni.$on('update', (data) => {})
// 卸载时必须移除
onUnload() { uni.$off('update') }
```

### 样式规范
- 单位：`rpx`（750rpx = 屏幕宽度）
- 样式穿透：`::v-deep`
- 小程序不支持本地路径 `background-image`，用网络图片或 base64
- SCSS 必须嵌套，不得平铺

### 不支持的特性
- 小程序不支持 `window`/`document`（需条件编译）
- 小程序包大小限制：主包 2M，分包总大小 20M
- 无 Composition API（无 `setup`）

## ESLint 验证命令
```bash
cd wlyd-app-consigner
npx eslint src/path/to/file.vue --fix
```
