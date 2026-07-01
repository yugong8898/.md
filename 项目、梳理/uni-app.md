# uni-app 开发文档

## 目录

- [生命周期](#生命周期)
- [条件编译](#条件编译)
- [API 使用规范](#api-使用规范)
- [样式规范](#样式规范)
- [数据绑定](#数据绑定)
- [事件处理](#事件处理)
- [页面通信](#页面通信)
- [性能优化](#性能优化)
- [跨平台兼容](#跨平台兼容)
- [常见问题](#常见问题)

---

## 生命周期

### 应用生命周期（App.vue）

```javascript
export default {
  onLaunch(options) {
    // 应用初始化完成时触发（全局只触发一次）
    console.log('App Launch', options)
  },
  onShow(options) {
    // 应用启动，或从后台进入前台显示
    console.log('App Show', options)
  },
  onHide() {
    // 应用从前台进入后台
    console.log('App Hide')
  },
  onError(err) {
    // 应用报错时触发
    console.log('App Error', err)
  }
}
```

### 页面生命周期

```javascript
export default {
  onLoad(options) {
    // 页面加载时触发，只触发一次
    // 用途：获取页面参数、初始化数据
    console.log('Page Load', options)
  },
  
  onShow() {
    // 页面显示/切入前台时触发（会多次触发）
    // 用途：刷新数据（因为可能从其他页面返回）
    console.log('Page Show')
  },
  
  onReady() {
    // 页面初次渲染完成时触发，只触发一次
    // 用途：操作 DOM、获取节点信息
    console.log('Page Ready')
  },
  
  onHide() {
    // 页面隐藏/切入后台时触发
    console.log('Page Hide')
  },
  
  onUnload() {
    // 页面卸载时触发
    // 用途：清理定时器、移除事件监听
    console.log('Page Unload')
  },
  
  onPullDownRefresh() {
    // 用户下拉刷新
    // 记得调用 uni.stopPullDownRefresh() 停止刷新
  },
  
  onReachBottom() {
    // 页面滚动到底部
    // 用途：加载更多数据
  },
  
  onPageScroll(e) {
    // 页面滚动时触发
    // 注意：避免在此执行复杂操作，影响性能
    console.log('Scroll Top:', e.scrollTop)
  },
  
  onShareAppMessage() {
    // 用户点击右上角分享（小程序）
    return {
      title: '分享标题',
      path: '/pages/index/index'
    }
  },
  
  onTabItemTap(item) {
    // 点击 tab 时触发
    console.log('Tab Item Tap', item)
  }
}
```

### 组件生命周期（Vue）

```javascript
export default {
  beforeCreate() {
    // 实例初始化之后，数据观测和事件配置之前
  },
  created() {
    // 实例创建完成，数据观测和事件配置完成
    // 用途：初始化数据、调用方法
  },
  beforeMount() {
    // 挂载开始之前
  },
  mounted() {
    // 挂载完成
    // 用途：操作 DOM、访问 $refs
  },
  beforeUpdate() {
    // 数据更新时，DOM 更新之前
  },
  updated() {
    // 数据更新后，DOM 更新完成
  },
  beforeDestroy() {
    // 实例销毁之前
    // 用途：清理定时器、移除事件监听
  },
  destroyed() {
    // 实例销毁完成
  }
}
```

### 生命周期执行顺序

**首次进入页面：**

```
onLoad → onShow → onReady → beforeCreate → created → beforeMount → mounted
```

**离开页面：**

```
onHide → onUnload → beforeDestroy → destroyed
```

**再次进入页面（从页面栈返回）：**

```
onShow
```

---

## 条件编译

### 为什么必须使用条件编译

在 uni-app 中，当需要针对不同平台编写不同逻辑时，**必须使用条件编译指令**，而不是运行时判断。

**❌ 错误示例：**

```javascript
showBackButton() {
  const isOwnerH5 = uni.getStorageSync('isOwnerH5')
  return isOwnerH5 ? false : true
  return true  // 这行代码永远不会执行（Dead Code）
}
```

**✅ 正确示例：**

```javascript
showBackButton() {
  // #ifdef H5  
  const isOwnerH5 = uni.getStorageSync('isOwnerH5')
  return isOwnerH5 ? false : true
  // #endif
  // #ifndef H5
  return true
  // #endif
}
```

### 条件编译指令

- `#ifdef` - 如果定义了某个平台
- `#ifndef` - 如果没有定义某个平台
- `#endif` - 结束条件编译块

### 平台标识

- `H5` - H5 平台
- `MP-WEIXIN` - 微信小程序
- `MP-ALIPAY` - 支付宝小程序
- `APP-PLUS` - App
- `APP-PLUS-NVUE` - App nvue 页面

### 工作原理

条件编译是**编译时**处理，不是运行时判断：

**编译为 H5 时**，编译器会移除 `#ifndef H5` 部分：

```javascript
showBackButton() {
  const isOwnerH5 = uni.getStorageSync('isOwnerH5')
  return isOwnerH5 ? false : true
}
```

**编译为小程序/APP 时**，编译器会移除 `#ifdef H5` 部分：

```javascript
showBackButton() {
  return true
}
```

### 在不同位置使用条件编译

**在 JavaScript 中：**

```javascript
// #ifdef H5
console.log('这是 H5 平台')
// #endif

// #ifdef MP-WEIXIN
console.log('这是微信小程序')
// #endif

// #ifndef H5
console.log('这不是 H5 平台')
// #endif
```

**在 template 中：**

```vue
<!-- #ifdef H5 -->
<view>这是 H5 专属内容</view>
<!-- #endif -->

<!-- #ifndef H5 -->
<view>这是非 H5 平台内容</view>
<!-- #endif -->

<!-- #ifdef MP-WEIXIN -->
<button open-type="share">分享</button>
<!-- #endif -->
```

**在 style 中：**

```scss
/* #ifdef H5 */
.container {
  padding: 20px;
}
/* #endif */

/* #ifndef H5 */
.container {
  padding: 10px;
}
/* #endif */
```

### 注意事项

1. 条件编译指令必须顶格写，注释符号后面有一个空格
2. 每个 `#ifdef` 或 `#ifndef` 必须有对应的 `#endif`
3. 可以嵌套使用，但要注意可读性
4. 条件编译会在编译时完全移除不匹配的代码块，不会增加运行时开销

---

## API 使用规范

### 路由跳转

```javascript
// 保留当前页面，跳转到应用内的某个页面
uni.navigateTo({
  url: '/pages/detail/detail?id=1'
})

// 关闭当前页面，跳转到应用内的某个页面
uni.redirectTo({
  url: '/pages/index/index'
})

// 关闭所有页面，打开到应用内的某个页面
uni.reLaunch({
  url: '/pages/index/index'
})

// 跳转到 tabBar 页面，并关闭其他所有非 tabBar 页面
uni.switchTab({
  url: '/pages/home/home'
})

// 关闭当前页面，返回上一页面或多级页面
uni.navigateBack({
  delta: 1 // 返回的页面数，默认为 1
})
```

### 数据存储

```javascript
// 同步存储
uni.setStorageSync('key', 'value')
const value = uni.getStorageSync('key')
uni.removeStorageSync('key')
uni.clearStorageSync()

// 异步存储
uni.setStorage({
  key: 'key',
  data: 'value',
  success() {
    console.log('存储成功')
  }
})

uni.getStorage({
  key: 'key',
  success(res) {
    console.log(res.data)
  }
})
```

### 网络请求

```javascript
uni.request({
  url: 'https://api.example.com/data',
  method: 'GET',
  data: {
    id: 1
  },
  success(res) {
    console.log(res.data)
  },
  fail(err) {
    console.error(err)
  }
})
```

### 提示框

```javascript
// 显示消息提示框
uni.showToast({
  title: '成功',
  icon: 'success',
  duration: 2000
})

// 显示加载提示框
uni.showLoading({
  title: '加载中'
})
uni.hideLoading()

// 显示模态对话框
uni.showModal({
  title: '提示',
  content: '确定要删除吗？',
  success(res) {
    if (res.confirm) {
      console.log('用户点击确定')
    }
  }
})
```

---

## 样式规范

### 尺寸单位

- 使用 `rpx` 作为响应式单位（750rpx = 屏幕宽度）
- `px` 为固定像素单位
- 推荐使用 `rpx` 实现跨平台适配

```scss
.container {
  width: 750rpx;  // 屏幕宽度
  height: 100rpx;
  padding: 20rpx;
}
```

### 样式注意事项

1. **避免使用 `*` 选择器**，影响性能
2. **小程序不支持 `background-image` 使用本地路径**，需要使用网络图片或 base64
3. **不同平台的导航栏、状态栏高度不同**，需要动态获取

```javascript
// 获取系统信息
uni.getSystemInfo({
  success(res) {
    console.log('状态栏高度：', res.statusBarHeight)
    console.log('导航栏高度：', res.navigationBarHeight)
  }
})
```

### 使用 SCSS

```scss
// 变量
$primary-color: #007aff;

.button {
  background-color: $primary-color;
  
  // 嵌套
  &:hover {
    opacity: 0.8;
  }
  
  .icon {
    margin-right: 10rpx;
  }
}
```

---

## 数据绑定

### 基本绑定

```vue
<template>
  <view>
    <!-- 文本绑定 -->
    <text>{{ message }}</text>
    
    <!-- 属性绑定 -->
    <image :src="imageUrl" />
    
    <!-- 类名绑定 -->
    <view :class="{ active: isActive }"></view>
    <view :class="['item', { active: isActive }]"></view>
    
    <!-- 样式绑定 -->
    <view :style="{ color: textColor, fontSize: fontSize + 'px' }"></view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      message: 'Hello',
      imageUrl: '/static/logo.png',
      isActive: true,
      textColor: '#333',
      fontSize: 14
    }
  }
}
</script>
```

### 列表渲染

```vue
<template>
  <view>
    <!-- v-for 必须绑定 :key -->
    <view v-for="(item, index) in list" :key="item.id">
      {{ index }}. {{ item.name }}
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      list: [
        { id: 1, name: '张三' },
        { id: 2, name: '李四' }
      ]
    }
  }
}
</script>
```

### 条件渲染

```vue
<template>
  <view>
    <!-- v-if：条件为 false 时不渲染 -->
    <view v-if="show">显示内容</view>
    
    <!-- v-show：条件为 false 时隐藏（display: none） -->
    <!-- 注意：小程序中 v-show 性能优于 v-if -->
    <view v-show="visible">可见内容</view>
    
    <!-- v-else -->
    <view v-if="type === 'A'">A</view>
    <view v-else-if="type === 'B'">B</view>
    <view v-else>其他</view>
  </view>
</template>
```

### 注意事项

- `v-for` 必须绑定 `:key`，且 key 值应该是唯一的
- 避免在模板中使用复杂的表达式，应该使用计算属性
- 小程序中 `v-show` 性能优于 `v-if`（频繁切换时）

---

## 事件处理

### 事件绑定

```vue
<template>
  <view>
    <!-- 基本事件 -->
    <button @click="handleClick">点击</button>
    
    <!-- 传递参数 -->
    <button @click="handleClick(item, $event)">点击</button>
    
    <!-- 阻止冒泡 -->
    <view @click.stop="handleClick">阻止冒泡</view>
    
    <!-- 事件修饰符 -->
    <view @touchmove.prevent="handleMove">阻止默认行为</view>
  </view>
</template>

<script>
export default {
  methods: {
    handleClick(item, e) {
      console.log('点击事件', item, e)
    },
    handleMove(e) {
      console.log('移动事件', e)
    }
  }
}
</script>
```

### 常用事件

- `@click` / `@tap` - 点击事件
- `@longpress` - 长按事件
- `@touchstart` - 触摸开始
- `@touchmove` - 触摸移动
- `@touchend` - 触摸结束
- `@input` - 输入事件
- `@change` - 值改变事件
- `@submit` - 表单提交

---

## 页面通信

### 方法1：使用事件总线

```javascript
// 页面 A：发送事件
uni.$emit('update', { data: 'xxx' })

// 页面 B：监听事件
export default {
  onLoad() {
    uni.$on('update', this.handleUpdate)
  },
  onUnload() {
    // 记得移除监听，避免内存泄漏
    uni.$off('update', this.handleUpdate)
  },
  methods: {
    handleUpdate(data) {
      console.log('收到数据：', data)
    }
  }
}
```

### 方法2：使用 getCurrentPages

```javascript
// 获取页面栈
const pages = getCurrentPages()

// 获取上一个页面
const prevPage = pages[pages.length - 2]

// 调用上一个页面的方法
prevPage.$vm.refreshData()

// 修改上一个页面的数据
prevPage.$vm.someData = 'new value'
```

### 方法3：使用 Vuex

```javascript
// store/index.js
import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    userInfo: null
  },
  mutations: {
    setUserInfo(state, userInfo) {
      state.userInfo = userInfo
    }
  },
  actions: {
    updateUserInfo({ commit }, userInfo) {
      commit('setUserInfo', userInfo)
    }
  }
})

// 使用
this.$store.commit('setUserInfo', userInfo)
this.$store.dispatch('updateUserInfo', userInfo)
```

---

## 性能优化

### 1. 避免在 onPageScroll 中执行复杂操作

```javascript
// ❌ 不推荐
onPageScroll(e) {
  // 复杂计算
  this.list.forEach(item => {
    // ...
  })
}

// ✅ 推荐：使用节流
onPageScroll(e) {
  if (this.scrollTimer) return
  this.scrollTimer = setTimeout(() => {
    // 执行操作
    this.scrollTimer = null
  }, 100)
}
```

### 2. 长列表优化

- 使用分页加载
- 使用虚拟列表（如 `uview-ui` 的 `u-list`）
- 避免一次性渲染大量数据

### 3. 图片优化

```vue
<template>
  <!-- 使用懒加载 -->
  <image :src="imageUrl" lazy-load mode="aspectFill" />
  
  <!-- 指定图片尺寸 -->
  <image :src="imageUrl" style="width: 200rpx; height: 200rpx;" />
</template>
```

### 4. 合理使用 setData（小程序）

```javascript
// ❌ 不推荐：频繁调用
for (let i = 0; i < 100; i++) {
  this.setData({ count: i })
}

// ✅ 推荐：批量更新
let count = 0
for (let i = 0; i < 100; i++) {
  count = i
}
this.setData({ count })
```

---

## 跨平台兼容

### 1. 平台判断

```javascript
// #ifdef H5
// H5 平台可以使用 window、document
window.localStorage.setItem('key', 'value')
// #endif

// #ifdef MP-WEIXIN
// 微信小程序特有 API
wx.getSystemInfo()
// #endif

// #ifdef APP-PLUS
// App 特有 API
plus.runtime.version
// #endif
```

### 2. 包大小限制

- 小程序主包限制：2M
- 小程序分包总大小限制：20M
- 使用分包加载优化

```json
{
  "pages": [],
  "subPackages": [
    {
      "root": "pagesA",
      "pages": [
        "pages/detail/detail"
      ]
    }
  ]
}
```

### 3. API 差异处理

```javascript
// 封装统一的 API
export function getLocation() {
  return new Promise((resolve, reject) => {
    // #ifdef H5
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        position => resolve(position),
        error => reject(error)
      )
    }
    // #endif
    
    // #ifndef H5
    uni.getLocation({
      success: res => resolve(res),
      fail: err => reject(err)
    })
    // #endif
  })
}
```

---

## 常见问题

### 1. 页面返回时数据不刷新

**解决方案：在 onShow 中刷新数据**

```javascript
export default {
  onShow() {
    // 每次页面显示时都会执行
    this.loadData()
  }
}
```

### 2. 小程序中图片不显示

**原因：小程序不支持本地背景图**

```scss
// ❌ 不支持
.bg {
  background-image: url('/static/bg.png');
}

// ✅ 使用网络图片或 base64
.bg {
  background-image: url('https://example.com/bg.png');
}
```

### 3. 跨域问题（H5）

**解决方案：配置代理**

```javascript
// manifest.json -> h5 -> devServer
{
  "h5": {
    "devServer": {
      "proxy": {
        "/api": {
          "target": "https://api.example.com",
          "changeOrigin": true,
          "pathRewrite": {
            "^/api": ""
          }
        }
      }
    }
  }
}
```

### 4. 页面栈超出限制

**原因：使用 navigateTo 跳转次数过多（最多 10 层）**

**解决方案：使用 redirectTo 或 reLaunch**

```javascript
// 替换当前页面
uni.redirectTo({
  url: '/pages/detail/detail'
})

// 关闭所有页面
uni.reLaunch({
  url: '/pages/index/index'
})
```

---

## 参考资料

- [uni-app 官方文档](https://uniapp.dcloud.net.cn/)
- [uni-app 条件编译](https://uniapp.dcloud.net.cn/tutorial/platform.html)
- [uni-app API](https://uniapp.dcloud.net.cn/api/)
- [uView UI 组件库](https://www.uviewui.com/)
