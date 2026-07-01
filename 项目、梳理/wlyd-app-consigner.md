# 万连通货主移动端项目文档

## 项目概述

**项目名称**: 万连通货主端 (wlyd-app-consigner)

**项目类型**: 基于 uni-app 的跨端应用

**支持平台**: 
- 微信小程序
- Android APP
- iOS APP (配置中)
- H5 Web应用

**当前版本**: v2.0.115

**AppID**: `__UNI__CA441EF`

## 技术栈

### 核心框架
- **uni-app**: 跨端开发框架
- **Vue 2.x**: 前端框架
- **Vuex**: 状态管理
- **uView UI**: UI组件库
- **wlyd-ui**: 自定义组件库

### 主要依赖
```json
{
  "@dcloudio/uni-webview-js": "^0.0.3",
  "@wlydfe/uni_http": "^3.0.0",
  "bignumber.js": "^9.1.2",
  "crypto-js": "^4.1.1",
  "custom-vue-inset-loader": "^1.2.6",
  "mockjs": "^1.1.0",
  "moment": "^2.29.4",
  "umtrack-wx": "^2.8.0"
}
```

### 开发工具
- **HBuilderX**: v4.23 (必需版本)
- **Node.js**: 用于依赖管理和构建

## 项目结构

```
wlyd-app-consigner/
├── api/                          # API接口定义
├── common/                       # 公共资源
│   ├── api.js                   # API配置
│   ├── config.js                # 基础配置
│   ├── mixin.js                 # 全局混入
│   └── dict.js                  # 字典数据
├── components/                   # 公共组件
│   ├── w-navbar/                # 导航栏组件
│   ├── w-toast/                 # 提示组件
│   ├── w-checkbox/              # 复选框组件
│   ├── upload-image/            # 图片上传
│   ├── upload-file/             # 文件上传
│   └── share-popup/             # 分享弹窗
├── config/                       # 配置文件
│   └── env.js                   # 环境配置（重要）
├── hooks/                        # 自定义Hooks
│   ├── useRouter.js             # 路由Hook
│   └── useUpload.js             # 上传Hook
├── pages/                        # 主包页面
│   ├── index/                   # 首页
│   ├── mine/                    # 我的
│   ├── send/                    # 发货
│   ├── order/                   # 订单
│   └── settlement/              # 结算
├── loginPages/                   # 登录分包
├── goodsPages/                   # 货物管理分包
├── orderPages/                   # 订单管理分包
├── settlementPages/              # 结算管理分包
├── minePages/                    # 个人中心分包
├── agreementPages/               # 协议页面分包
├── router/                       # 路由配置
│   └── index.js                 # 路由拦截器
├── store/                        # Vuex状态管理
│   ├── index.js                 # Store入口
│   ├── common.js                # 公共状态
│   ├── mine.js                  # 个人中心状态
│   └── ad.js                    # 广告状态
├── util/                         # 工具函数
│   ├── request/                 # 请求封装
│   ├── statistics/              # 统计埋点
│   ├── location/                # 定位相关
│   └── tools/                   # 通用工具
├── static/                       # 静态资源
├── uni_modules/                  # uni-app插件
│   ├── uview-ui/                # uView UI库
│   └── wlyd-ui/                 # 自定义UI库
├── main.js                       # 应用入口
├── pages.json                    # 页面配置
├── manifest.json                 # 应用配置
├── vue.config.js                 # Vue配置
└── package.json                  # 依赖配置
```

## 核心功能模块

### 1. 登录认证
- 企业选择登录
- 协议确认
- 中台SSO集成

### 2. 货物管理
- 发货下单
- 货物信息录入
- 地址选择（高德地图集成）
- 历史货物查询
- 批量支付配置

### 3. 订单管理
- 订单列表
- 订单详情
- 订单编辑
- 订单评价
- 订单溯源码

### 4. 结算管理
- 结算信息处理
- 运费结算
- 结算详情
- 风险预警
- 异常处理
- 车辆归属证明

### 5. 个人中心
- 用户信息
- 企业切换
- 设置管理
- 在线客服

## 环境配置

### 环境变量 (config/env.js)

项目支持多环境配置，通过 `devUrlMap()` 函数管理：

```javascript
{
  prod: 'https://www.10000da.cn',              // 生产环境
  uat_3u: 'https://3u.wanlianyida.com',        // UAT环境
  dev_3pldelta: 'https://3pldelta.10000da.vip', // 结算开发环境
  dev_3plbeta: 'https://3plbeta.10000da.vip',   // 集成开发环境
  dev_3plalpha: 'https://3plalpha.10000da.vip', // Alpha环境
  // ... 更多环境
}
```

### 关键配置项

- **baseURL**: API网关地址
- **tradeBizGateway**: 交易业务网关
- **middlePlatformBaseURL**: 中台域名
- **HI_NA_CLOUD_SDK**: 海纳嗨数统计配置

## 打包发布流程

### 前置准备

1. **HBuilderX版本**: 确保使用 v4.23
2. **账号权限**: 需要HBuilder账号并由【孔昭远】添加项目权限
3. **上线通知**: 提前告知【孔昭远】，合并master后再次通知

### 分支管理

**冲突合并流程**:
```
开发分支 (F-69.8) → 目标分支 (release)

无冲突: 直接合并后基于release打包

有冲突:
1. release → release_merge_69.8-0422 (切新分支)
2. F-69.8 → release_merge_69.8-0422 (合并开发代码)
3. release_merge_69.8-0422 → release (合并回主分支)
```

---

## H5 打包流程

### 1. 修改环境配置

**文件**: `config/env.js`

```javascript
// 修改为H5配置
const preFix = location.origin
```

### 2. 确认manifest配置

**文件**: `manifest.json`

检查以下配置:
- `h5.router.mode`: hash
- `h5.router.base`: /yw/m/uniapp-oner/

### 3. 构建H5包

在HBuilderX中:
1. 点击 `发行` → `网站-H5手机版`
2. 版本号统一由【孔昭远】处理，无需个人修改
3. 不需填写截图中未填写的内容

### 4. 上传部署

**目标项目**: logisticsweb (万连通PC端)

```bash
# a. 基于release切H5包替换分支
release → release_replace-unioner-0422

# b. 替换H5内容
目录: logisticsweb/public/m/uniapp-oner/
提交到: release_replace-unioner-0422

# c. 合并分支，等待流水线
release_replace-unioner-0422 → release
```

---

## APP 打包流程 (Android)

### 1. 恢复环境配置

**重要**: 如果之前打包H5修改过配置，必须全部恢复

**文件**: `config/env.js`

```javascript
// 恢复为APP配置
const preFix = uni.getStorageSync('wlyd_owner_url') || devUrlMap().dev_3pldelta
```

### 2. 配置APP图标

**文件**: `manifest.json` → App图标配置

Logo图片路径: `static/app-plus/images/logo.png`

注: 一般配置一次即可，无需每次修改

### 3. 云打包

在HBuilderX中选择 `发行` → `原生App-云打包`

**Android配置**:
```
包名: com.wanlianyida.consignor.app
证书别名: owneralias
证书密码: 123456
证书文件: 联系【孔昭远】或【杨雅苹】获取
```

**打包选项**:
- 仅打包Android
- 使用云端证书
- 正式版

---

## 小程序打包流程

### 发布流程

```bash
# 1. 合并开发分支到develop
开发分支 → develop

# 2. 基于develop分支发行
HBuilderX → 发行 → 小程序-微信

# 3. 设置为体验版本
在微信小程序后台设置为体验版
```

### 注意事项
- 小程序使用develop分支
- 发布前确保代码已合并
- 发布后在微信公众平台设置体验版

---

## 关键技术点

### 1. 路由管理

使用自定义Router类实现路由拦截:

```javascript
// router/index.js
import Router from '@/hooks/useRouter'

const router = new Router()

router.beforeEach((to, from) => {
  // 路由前置守卫
})

router.afterEach((to, from) => {
  // 路由后置守卫 - 埋点统计
  appViewScreenHina()
})
```

### 2. 请求封装

基于 `@wlydfe/uni_http` 封装:

```javascript
// GET请求
uni.$u.http.get(url, params).then(res => {
  // 无需处理错误，已在request中统一处理
})

// POST请求
uni.$u.http.post(url, params).then(res => {
  // 无需处理错误，已在request中统一处理
})
```

参考实例: `loginPages/login/login.vue`

### 3. 全局组件注入

使用 `custom-vue-inset-loader` 自动注入全局组件:

```json
// pages.json
{
  "insetLoader": {
    "config": {
      "wToast": "<wToast ref='wToast'></wToast>",
      "floatingBackButton": "<floating-back-button></floating-back-button>"
    },
    "label": ["wToast", "floatingBackButton"],
    "rootEle": "view"
  }
}
```

### 4. 统计埋点

集成多个统计平台:
- **海纳嗨数**: 用户行为分析
- **友盟统计**: 移动统计

```javascript
// 页面浏览统计
uni.$wlydTrack.track('H_AppViewScreen', {
  H_screen_name: '页面名称',
  H_title: '页面标题',
  H_url: '页面路径'
})
```

### 5. 地图集成

使用高德地图SDK:
- 定位服务
- 地址选择
- 路线规划

配置在 `manifest.json` 中:
```json
{
  "geolocation": {
    "amap": {
      "appkey_ios": "30fd46861342b37e31d5b8004ed84678",
      "appkey_android": "30fd46861342b37e31d5b8004ed84678"
    }
  }
}
```

### 6. 分包加载

采用分包策略优化首屏加载:

```json
{
  "subPackages": [
    { "root": "loginPages" },
    { "root": "goodsPages" },
    { "root": "orderPages" },
    { "root": "settlementPages" },
    { "root": "minePages" },
    { "root": "agreementPages" }
  ]
}
```

## 开发规范

### 1. 代码规范
- 使用ESLint进行代码检查
- 遵循Airbnb JavaScript规范
- 组件命名采用PascalCase
- 文件命名采用kebab-case

### 2. 提交规范
```bash
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式调整
refactor: 重构
test: 测试相关
chore: 构建/工具链相关
```

### 3. 分支规范
- `master`: 生产环境分支
- `release`: 预发布分支
- `develop`: 开发环境分支（小程序）
- `F-xxx`: 功能开发分支

## 常见问题

### 1. H5打包后env.js配置问题
**问题**: 打包H5后忘记恢复配置导致APP打包失败

**解决**: 打包APP前务必检查 `config/env.js` 中的 `preFix` 配置

### 2. 证书文件获取
**问题**: 云打包时缺少证书文件

**解决**: 联系【孔昭远】或【杨雅苹】获取最新证书

### 3. 版本号管理
**问题**: 不清楚如何更新版本号

**解决**: 版本号统一由【孔昭远】管理，开发人员无需修改

### 4. 环境切换
**问题**: 本地开发时需要切换不同环境

**解决**: 
```javascript
// 使用setEnv方法切换环境
import { setEnv } from '@/config/env.js'
setEnv('https://3pldelta.10000da.vip')
```

## 联系人

- **项目负责人**: 孔昭远
- **证书管理**: 孔昭远、杨雅苹
- **技术支持**: 开发团队

## 相关链接

- **生产环境**: https://www.10000da.cn
- **UAT环境**: https://3u.wanlianyida.com
- **开发环境**: https://3pldelta.10000da.vip
- **uView文档**: https://www.uviewui.com

---

**最后更新**: 2025-01-17

**文档维护**: 开发团队
