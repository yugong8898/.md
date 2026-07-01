# platformweb 项目文档

## 项目概述

**项目名称**: 万联易达-无车承运人平台项目 (PC端 4PL)

**项目版本**: 1.0.20

**开发环境地址**: http://10.38.16.179:9203

**测试环境地址**: http://10.242.130.68:9203

## 技术栈

### 核心框架
- **Vue 2.6.11** - 前端框架
- **Vue Router 3.1.6** - 路由管理
- **Vuex 3.4.0** - 状态管理
- **Element UI 2.13.1** - UI组件库

### 主要依赖
- **axios 0.19.2** - HTTP请求库
- **@wlydfe/core 2.1.10** - 万联易达核心库
- **@wlydfe/http 10.0.0** - 万联易达HTTP封装
- **@wlydfe/track-js 0.1.5** - 埋点追踪
- **echarts 4.6.0** - 数据可视化
- **@jiaminghi/data-view 2.10.0** - 大屏数据展示
- **@wangeditor/editor 5.1.1** - 富文本编辑器
- **vue-ueditor-wrap 2.4.1** - 百度富文本编辑器
- **bignumber.js 9.0.0** - 大数计算
- **crypto-js 4.0.0** - 加密工具
- **js-cookie 2.2.1** - Cookie操作
- **dayjs 1.11.13** - 日期处理
- **html2canvas 1.4.1** - 页面截图
- **print-js 1.6.0** - 打印功能
- **sortablejs 1.15.0** - 拖拽排序
- **screenfull 6.0.2** - 全屏功能

### 开发工具
- **@vue/cli-service 4.3.0** - Vue CLI服务
- **webpack 4.43.0** - 模块打包
- **babel** - JavaScript编译
- **eslint** - 代码检查
- **sass/scss** - CSS预处理器
- **mockjs 1.1.0** - 数据模拟

## 项目结构

```
platformweb/
├── build/                      # 构建配置
│   ├── proxy.js               # 代理配置
│   └── serverMap.js           # 服务器映射
├── mock/                       # Mock数据
│   ├── data/                  # 各模块mock数据
│   ├── index.js
│   └── mock-server.js
├── nginx/                      # Nginx配置文件
│   ├── default-dev.conf       # 开发环境
│   ├── default-test.conf      # 测试环境
│   ├── default-prerelease.conf # 预发布环境
│   └── default-release.conf   # 生产环境
├── public/                     # 静态资源
│   ├── ueditor/               # 百度富文本编辑器
│   ├── pdfjs/                 # PDF预览
│   ├── m/                     # 移动端资源
│   ├── mp/                    # 小程序相关
│   ├── env.js                 # 环境配置
│   ├── favicon.ico
│   └── index.html
├── scripts/                    # 脚本文件
│   ├── verify-commit-msg.js   # Git提交信息校验
│   └── zip.js                 # 打包压缩
├── src/                        # 源代码目录
│   ├── api/                   # API接口定义
│   ├── assets/                # 静态资源(图片等)
│   ├── common/                # 公共模块
│   ├── components/            # 公共组件
│   │   ├── AddressSelect/     # 地址选择器
│   │   ├── ElPaginationNew/   # 分页组件
│   │   ├── ExportBtn/         # 导出按钮
│   │   ├── Ocr/               # OCR识别
│   │   ├── OperationRecord/   # 操作记录
│   │   ├── ReasonManagement/  # 原因管理
│   │   ├── ScrollPane/        # 滚动面板
│   │   ├── Selectmore/        # 增强Select(支持分页)
│   │   ├── TreeTable/         # 树形表格
│   │   └── Upload/            # 文件上传
│   ├── config/                # 配置文件
│   │   ├── index.js           # 全局配置
│   │   ├── regulatory.js      # 业务类型代码
│   │   ├── enumeration.js     # 枚举值配置
│   │   ├── ueditorConfig.js   # 富文本配置
│   │   └── actionHistory.js   # 操作记录配置
│   ├── directive/             # 自定义指令
│   ├── icons/                 # 图标库(iconfont)
│   ├── layout/                # 页面布局
│   │   ├── components/        # 布局组件
│   │   │   ├── AppMain.vue    # 主内容区
│   │   │   ├── Breadcrumb.vue # 面包屑
│   │   │   ├── Header.vue     # 头部
│   │   │   └── Sidebar.vue    # 侧边栏
│   │   ├── Layout.vue         # 主布局
│   │   └── Page.vue           # 页面布局
│   ├── mixins/                # 混入
│   │   ├── channelMixin.js    # 渠道混入
│   │   ├── emitter.js         # 事件发射器
│   │   ├── exportMixin.js     # 导出混入
│   │   ├── fullScreen.js      # 全屏混入
│   │   ├── insurance.js       # 保险混入
│   │   ├── loadMap.js         # 地图加载
│   │   └── passwordRules.js   # 密码规则
│   ├── router/                # 路由配置
│   │   ├── index.js           # 路由入口
│   │   └── routers.js         # 路由定义
│   ├── scss/                  # 样式文件
│   ├── styles/                # 公共样式
│   │   ├── base.scss          # 基础样式
│   │   ├── common.scss        # 公共样式
│   │   ├── public.scss        # 公用样式
│   │   ├── reset.scss         # 重置样式
│   │   └── element-overwrite.scss # Element UI覆盖
│   ├── utils/                 # 工具函数
│   │   ├── auth.js            # Token操作
│   │   ├── errMsg.js          # 错误码
│   │   ├── index.js           # 公共函数
│   │   ├── extends.js         # 全局扩展
│   │   ├── func.js            # 功能函数
│   │   ├── regexp.js          # 正则表达式
│   │   ├── request.js         # Ajax请求封装
│   │   ├── secret.js          # 加密工具
│   │   ├── validate.js        # 表单验证
│   │   └── ...                # 其他工具
│   ├── views/                 # 页面视图
│   │   ├── costManagement/    # 成本管理
│   │   ├── creditCenter/      # 信用中心
│   │   ├── features/          # 特性页面(401/404)
│   │   ├── infolook/          # 信息查看
│   │   ├── matching/          # 撮合
│   │   ├── member/            # 会员管理
│   │   ├── public/            # 公共页面
│   │   ├── superviseNM/       # 监管
│   │   ├── taxdocking/        # 税务对接
│   │   ├── transaction/       # 交易
│   │   └── login.vue          # 登录页
│   ├── vuex/                  # Vuex状态管理
│   │   ├── modules/           # 模块
│   │   │   ├── app.js         # 应用状态
│   │   │   ├── enumeration.js # 枚举值
│   │   │   └── public.js      # 公共状态
│   │   └── index.js           # Store入口
│   ├── App.vue                # 根组件
│   └── main.js                # 入口文件
├── .browserslistrc            # 浏览器兼容配置
├── .editorconfig              # 编辑器配置
├── .env.development           # 开发环境变量
├── .env.production            # 生产环境变量
├── .env.test                  # 测试环境变量
├── .eslintrc.js               # ESLint配置
├── .gitignore                 # Git忽略文件
├── .prettierrc.json           # Prettier配置
├── babel.config.js            # Babel配置
├── Dockerfile                 # Docker配置
├── Jenkinsfile                # Jenkins配置
├── jsconfig.json              # JS配置
├── package.json               # 项目依赖
├── README.md                  # 项目说明
└── vue.config.js              # Vue CLI配置

```

## 环境配置与运行

### 1. 环境要求

- **Node.js**: v8.9+ (推荐 v10+)
- **npm** 或 **yarn**

### 2. 安装依赖

```bash
# 安装全局Vue CLI
npm install -g @vue/cli

# 进入项目目录
cd platformweb

# 安装项目依赖
npm install
```

如果npm访问超时,配置淘宝镜像源:

```bash
npm config set registry https://registry.npm.taobao.org
```

### 3. 开发命令

```bash
# 启动开发服务器(带模块热重载)
npm run dev

# 快速启动(关闭source-map,加快编译)
npm run dev:fast

# 最大内存启动(处理大型项目)
npm run dev:max

# 生产环境打包
npm run build

# 测试环境打包
npm run test

# ESLint代码检查
npm run lint

# ESLint检查并自动修复
npm run lint:fix
npm run eslint

# 清理缓存
npm run clean:cache

# 清理zip文件
npm run clean:zip
```

### 4. 代理配置

在 `build/proxy.js` 中配置代理:

```javascript
module.exports = {
  '/gateway': {
    target: 'http://10.38.16.179:9202',
    changeOrigin: true,
    pathRewrite: {
      '^/gateway': '/'
    }
  }
}
```

本地环境变量配置(`.env.development.local`):

```
VUE_APP_PROXY_API='dev_4pldelta'
```

## 核心功能模块

### 1. 成本管理 (costManagement)
- 服务费结算
- 账单报表
- 生成报表
- 运单管理
- 客户成本差率

### 2. 信用中心 (creditCenter)
- 信用评估
- 信用管理

### 3. 信息查看 (infolook)
- 聚合分析
- 数据大屏(LSD)
- 客户聚合
- 合同管理
- 运单数据
- 统计分析
- 运输监控

### 4. 撮合管理 (matching)
- 货源撮合
- 车源撮合

### 5. 会员管理 (member)
- 企业认证审核
- 司机认证审核
- 车辆认证审核
- 挂车认证审核
- 实名认证审核
- 黑名单管理
- 省级联系人管理
- 设备管理
- 证件自动审核配置

### 6. 公共模块 (public)
- 应用管理
- 基础配置
- 内容管理
- 评价管理
- 装货管理
- 消息管理
- 运营参数设置
- 系统管理

### 7. 监管模块 (superviseNM)
- 监管数据上报
- 监管查询

### 8. 税务对接 (taxdocking)
- 税务数据对接
- 税务报表

### 9. 交易管理 (transaction)
- 订单管理
- 运单管理
- 支付管理

## 技术架构详解

### 1. 接口返回格式

```javascript
{
  errCode: "",      // 错误码
  errMsg: "",       // 错误信息
  model: [],        // 返回数据实体
  succeed: true,    // 请求成功状态
  total: 1          // 分页总条数
}
```

### 2. 接口地址说明

- **统一前缀**: `/gateway` - 用于nginx层拦截转发
- **服务标识**: 如 `/gateway/crm` 中的 `crm` 代表CRM服务
- **接口定义**: 所有接口请求在 `src/api/*.js` 目录下

主要服务接口前缀:
- `BASE_API` - 基础服务
- `CRM_API` - 客户关系管理
- `BMS_API` - 业务管理系统
- `TMS_API` - 运输管理系统
- `OMS_API` - 订单管理系统
- `MSG_API` - 消息服务
- `EVAL_API` - 评价服务
- `LSDS_API` - 物流数据服务
- `GPS_APT` - GPS定位服务
- `CONT_API` - 合同服务
- `TAX_API` - 税务服务

### 3. 登录状态管理

- **Token存储**: Cookie
- **Token Key**: `EL-ADMIN-TOEKN-4PL`
- **过期时间**: 1天(可配置)
- **配置文件**: `src/config/index.js`

### 4. Vuex状态管理

#### app.js 模块
- `user` - 用户登录信息
- `menu` - 菜单信息
- `userTelphone` - 用户手机号
- `selectMenu` - 当前面包屑菜单
- `oldMenu` - 菜单缓存
- `hash` - 菜单hash表

#### enumeration.js 模块
- 提供 `getDirctionaryIds` action获取枚举值

#### public.js 模块
- `cityData` - 城市数据
- `cityDataOption` - 城市树结构
- `cityDataObj` - 城市hash表

### 5. 路由配置

#### 静态路由
在 `src/router/routers.js` 中配置非用户中心路由

#### 动态路由(用户中心)
通过后台配置系统动态生成:
1. 访问 `域名/function` 进入路由配置页面
2. 找到对应父菜单,点击 + 号
3. 填写表单:
   - **功能函数中文名**: 页面名称
   - **接口方法名称**: 路由地址
   - **中文描述简写**: 字母简写
   - **公开接口路径**: 页面模板路径
   - **选择类型**: 菜单
   - **菜单层级**: 根据实际层级填写
   - **排序**: 功能函数排序

### 6. 按钮权限配置

通过后台配置系统管理按钮权限:
1. 访问 `域名/function` 进入配置页面
2. 找到对应页面,点击 + 号
3. 填写表单:
   - **功能函数中文名**: 按钮名称
   - **接口方法名称**: 按钮点击后访问的路由
   - **中文描述简写**: 字母简写
   - **公开接口路径**: 页面模板路径
   - **样式表名称**: 按钮英文名称(存储在router.meta中)
   - **选择类型**: 按钮
   - **层级关系**: 根据实际层级填写

#### 页面中使用按钮权限

```javascript
// 在页面中获取按钮权限
Object.keys(this.$route.meta).forEach(v => {
  this.$set(this.controlBtn, v, this.$route.meta[v])
})

// controlBtn 即为当前页面所有按钮权限对象
```

### 7. 页面路由命名规则

- **列表页**: `模块英文名`
- **新增页**: `模块名/add`
- **编辑页**: `模块名/edit/:id`
- **详情页**: `模块名/view/:id`

部分模块新增/编辑使用同一模板,通过路由路径区分操作类型。

### 8. 省市区选择器

```javascript
// 加载城市数据
this.$store.dispatch('public/loadCityData').then(list => {
  // list 即为地址选择器所需数据
})
```

### 9. 地图集成

- **地图服务**: 高德地图
- **加载方式**: 动态添加script标签引入
- **使用场景**: 位置选择、轨迹展示、区域分析

### 10. 富文本编辑器

#### 百度UEditor
- **配置文件**: `public/ueditor/ueditor.config.js`
- **Vue组件**: `vue-ueditor-wrap`
- **官方文档**: http://fex.baidu.com/ueditor/

#### WangEditor
- **版本**: 5.1.1
- **Vue组件**: `@wangeditor/editor-for-vue`

### 11. 环境配置

在 `config/index.js` 中区分环境:

```javascript
const isDevelopment = process.env.NODE_ENV === 'development'
export default isDevelopment ? developmentConfig : productConfig
```

## 构建配置

### vue.config.js 关键配置

```javascript
{
  publicPath: '/',
  outputDir: 'dist',
  assetsDir: 'assets',
  productionSourceMap: false,
  filenameHashing: true,
  parallel: true,  // 多进程构建
  lintOnSave: true,
  devServer: {
    open: true,
    host: '0.0.0.0',
    port: 9203,
    hot: true,
    https: false,
    proxy: require('./build/proxy')
  }
}
```

### 性能优化配置

- **快速模式**: `FAST=true` 关闭source-map和部分插件
- **内存优化**: `--max-old-space-size=8192` 增加Node内存
- **多进程编译**: 根据CPU核心数自动开启
- **代码分割**: 按路由懒加载
- **版本控制**: 文件名包含chunkhash

## 代码规范

### ESLint配置
- 基于 `@vue/eslint-config-airbnb`
- 支持Vue文件检查
- 配置文件: `.eslintrc.js`

### Git Hooks
- **pre-commit**: 自动执行lint-staged
- **commit-msg**: 校验提交信息格式

### Lint-staged
对暂存的 `.vue`, `.js`, `.jsx`, `.ts`, `.tsx` 文件执行ESLint修复

## 部署配置

### Docker支持
- **Dockerfile**: 项目根目录
- **多环境配置**: nginx目录下各环境配置文件

### Jenkins CI/CD
- **Jenkinsfile**: 项目根目录
- 支持自动构建、测试、部署

### Nginx配置
- `default-dev.conf` - 开发环境
- `default-test.conf` - 测试环境
- `default-prerelease.conf` - 预发布环境
- `default-release.conf` - 生产环境

## 常见问题

### 1. 内存溢出
使用 `npm run dev:max` 增加Node内存限制

### 2. 编译速度慢
使用 `npm run dev:fast` 关闭source-map加速编译

### 3. 代理配置不生效
检查 `.env.development.local` 中的 `VUE_APP_PROXY_API` 配置

### 4. 路由404
确认路由是否在后台配置系统中正确配置

### 5. 按钮权限不显示
检查路由meta信息和按钮权限配置

## 开发建议

1. **组件复用**: 优先使用 `src/components` 下的公共组件
2. **样式管理**: 使用SCSS变量和混入,避免重复样式
3. **API管理**: 按模块在 `src/api` 下组织接口
4. **状态管理**: 合理使用Vuex,避免过度使用
5. **代码规范**: 提交前确保通过ESLint检查
6. **性能优化**: 使用路由懒加载,避免首屏加载过大
7. **错误处理**: 统一使用 `utils/errMsg.js` 处理错误信息
8. **工具函数**: 复用 `utils` 下的工具函数,避免重复造轮

## 相关链接

- **Vue官方文档**: https://cn.vuejs.org/
- **Element UI文档**: https://element.eleme.cn/
- **Vue CLI文档**: https://cli.vuejs.org/zh/
- **百度UEditor**: http://fex.baidu.com/ueditor/
- **高德地图API**: https://lbs.amap.com/

---

**文档更新时间**: 2025年
**项目维护**: 万联易达技术团队
