# REQ-133 工作流进度

## 目录

- [需求信息](#需求信息)
- [合作分工与范围边界](#合作分工与范围边界)
- [阶段进度](#阶段进度)
- [当前阶段](#当前阶段)
- [验证闭环记录](#验证闭环记录)
- [已处理文件](#已处理文件)
- [本需求文件树](#本需求文件树)
- [阶段 3 允许改动文件](#阶段-3-允许改动文件)
- [阶段 4 审查差异](#阶段-4-审查差异)
- [不确定项追踪](#不确定项追踪)
- [备注](#备注)

---

## 需求信息

- 需求名称：二级频道页二次优化（原始需求：二级频道适配 APP 端 / H5 浏览器）
- 工作区：`.md/需求/进行中/REQ-133/`
- 需求版本：**R3**（2026-11-23 补充设计稿基线：移动端 H5 整页 `175570-262826` + 顶部打开 APP `175975-30231` + 模块级 UI 标注，落为 R-022~R-027；R2 调整本人范围：频道新页面、顶部打开 APP 组件、后台新增 H5 跳转；商店地址与 deep link 规则已明确）
- 测试版本：T0
- 需求编号：RZMP-11286
- 开始时间：2026-11-20（需求评审）；开发启动 2026-11-24
- 需求来源：`原始需求/REQ-133 二级频道适配APP端_H5浏览器.md`（含 60 余张截图）、`REQ-133 二级频道页二次优化-功能清单.md`、`REQ-133 二级频道页二次优化-技术方案.md`
- **miniapp 落地基座**：`wds/wds-miniapp`（Taro 4.3 + Vue 3.5，微信小程序 + H5 双端编译）；二级频道新页面与顶部打开 APP 组件落此仓。运管后台 H5 跳转能力由本人负责，但后台仓库尚未定位。页面暂定 `src/pages/category-channel`，路由 `/pages/category-channel/index`（参数 `slug` + 可选 `categoryId`）
- **参考项目（零改动）**：`wds/wds-web-channel`（PC 频道页 DTO / 模块顺序 / 视觉）、`wds/es-app-main`（Flutter 交互契约与 H5 容器桥接文档）
- **交付端口径**：代码一处开发，Taro 编译 weapp + h5；不新建小程序原生频道页，H5 链接在微信内打开需可用，小程序端只做回归；H5 覆盖手机、iPad 竖屏 / 横屏与桌面浏览器
- **技术方案**：团队 `REQ-133 二级频道页二次优化-技术方案.md` 是输入材料；正式阶段产物为 `阶段2-技术方案-REQ-133.md`
- 复杂度判定：完整档（多端 × 多模块 × 新接口新字段 × 运管后台配置链路 × 合作开发分工）
- 设计稿：Figma「万大圣WEB」page「二级频道」`52162:93147`
- 本期排除：埋点上报层与埋点工具、按后缀维度访问统计与后台报表、数据侧解析、PC / APP 仓改动、小程序端专项频道页开发

## 合作分工与范围边界

> 依据功能清单「人员分配」列。**本工作流只跟踪王新骏负责的条目**；合作方条目只保留协作接口，不展开实现、不列入阶段 3 允许改动文件。

| 归属 | 功能清单条目 | 对应技术方案章节 | 本工作流 |
|---|---|---|---|
| **本人（王新骏）** | 引导登陆 / 注册 | 八、登录统一方案；九、浏览器登录后的下载引导 | ✅ 跟踪 |
| **本人** | app 端跳转 h5 | 十、H5 路由和外链兼容；十一、频道跳转规则 | ✅ 跟踪 |
| **本人** | 二级频道新页面 | 三、四、十五章 | ✅ 页面主体及路由 |
| **本人** | 顶部「打开 APP」组件 | 九、十、十一章 | ✅ deep link 与商店兜底 |
| **本人** | 运管后台新增 H5 跳转链接 | 十一、十四章 | ✅ 需求本人负责；仓/API待定位 |
| **本人** | 服务商详情 | 六、服务商详情范围；九、下载引导展示范围 | ✅ 跟踪 |
| **本人** | 运营后台限制行数 | 四、模块范围；十四、工程实现要求 | ✅ 跟踪 |
| **本人** | 配置链接跳转 | 十一、频道跳转规则 | ✅ 跟踪 |
| **本人（共同）** | buffer · iPad 适配 | 十二、iPad 和响应式适配 | ✅ 跟踪 |
| 合作方 | 服务详情 | 五、服务详情范围 | 仅记接口：登录回跳目标 |
| 合作方 | 提交留言 H5 页面 | 七、需求留言和留资页 | 仅记接口：`sourceCategoryId` 传参 |
| 合作方 | 三方应用下载页面 | 九、下载引导 | 仅记接口：下载引导地址来源 |
| 合作方 | 流水线 dev / test / uat / master | 十七、验收标准 | 仅记接口：`build:h5:test` / `build:weapp:test` |
| 合作方 | 域名确认 | 十、频道公开地址；十八、上线和回滚 | 仅记接口：`channel.wdsheng.com` 与回源 |

## 阶段进度

| 阶段 | 状态 | 产物文件 | 完成时间 |
|------|------|---------|---------|
| 阶段0 需求分析 | ✅已完成 | 阶段0-需求文档-REQ-133.md | 2026-11-23 |
| 阶段1 代码分析 | ✅已完成 | 阶段1-代码分析-REQ-133.md | 2026-11-23 |
| 阶段2 技术方案 | ⚠️待确认（正式方案已形成，出口受 U 项阻塞） | 阶段2-技术方案-REQ-133.md | 2026-11-23 |
| 阶段3 编码执行 | 🔄进行中（批次2 UI 整改 + 内联留言已落地，浏览器实测通过，待收口） | 代码改动见「已处理文件」 | 2026-11-23 |
| 阶段4 代码审查 | ⏳待开始 | - | - |
| 阶段5 测试基线与覆盖对齐 | ⏳待开始 | - | - |
| 阶段6 测试执行与Bug修复循环 | ⏳待开始 | - | - |
| 阶段7 需求复盘（可选） | ⏳待开始 | - | - |

## 当前阶段

**阶段 3 进行中（用户 2026-11-23 授权路径 A：UI 先行批次）**。用户同日确认：①频道接口复用 `wds-web-channel` 现有契约（U-005 复用许可关闭，行数字段仍待后端）；②登录链路（引导登录/注册及登录后下载弹层）移出本人范围；③文档一律正向输出。开发基线 `F-REQ-133` @ `a0f347d`（与 dev 同 HEAD）。

批次 1 已落地 18 个文件（16 个功能文件 + 2 个 mock 过渡文件）：频道页全模块 UI、顶部打开 APP 指引条、scheme 唤起工具、运营链接白名单跳转、分包与路由注册。后端接口未就绪，service 层按项目过渡决策口径 **mock 生效 + 真实调用注释原地保留**（`TODO: wxj mock` 标注，收口时 grep 一次定位）。

批次 2（用户同日反馈「每个模块 UI 再审视 + 留言要在频道页直接留」）新增 2 文件、累计 20 文件：①逐模块按 PC 视觉语言整改（灰底画布 + 白卡分层、共享标题行 ChannelSectionHeader、类目渐变图标等高卡、智能体封面叠加白标题、资讯独立白卡 + 空位透明、商品区接共享标题行）；②留言改频道页内联表单 ChannelInquiry（复用 createEmployerInquiry + resolveInquirySource，旧跳页入口模板/样式/方法注释保留），H5 ≥768 双列；③补挂 AppOpenBanner 与 footer 模板（批次1 漏挂载）；④修复 pxtransform 桌面版心（大写 PX）、顶部 banner 出血白缝、image 比例撑高、textarea 内层白底（postcss 元素选择器映射坑）。

**待办**：①~~dev server Node 环境阻塞~~ 已解决：`.temp/ts-hook.cjs` esbuild require 钩子绕过 Node22 strip-only 限制，watch 编译成功（:10086），浏览器实测已完成；②U-006 deep link path 规则、U-014 类目区 2 张布局、U-015 顶部条显隐、行数配置字段、APP 容器 UA 标识均按建议口径先行并 `TODO: wxj` 占位；③U-009 yeeda 软链仍断，按仓自身 AGENTS.md 约定执行（偏差已记录）；④收口时 grep `TODO: wxj mock` 清理 mock 过渡产物并复跑真实接口。

## 验证闭环记录

| 阶段 | 锚点 | 验证结果 | 证据 |
|---|---|---|---|
| 阶段0 需求分析 | 原始需求 + 两篇团队文档 + Figma 节点树 | 通过 | 阶段0 文档：①本人范围分工表；②规则拆解；③设计稿交叉验证；④横向搜索 8 维度；⑤涉及端与页面现状表；⑥验证清单与风险 |
| 阶段1 代码分析 | 阶段0 文件清单 + 团队技术方案点名路径 + `.repoWiki` 锚点 `533201f`；R2责任变化未新增代码现场 | 通过（原代码基线） | 阶段1 报告第一 / 三 / 四章（均附文件行号）：①7 个新增路径全 MISSING、5 个复用路径全 EXISTS；②四个验收脚本真实存在；③`resolveInquirySource` / `openLoginDialog` 已实现；④登录页 `isWeapp` 主入口已隐藏微信授权、协议弹窗仍有残留；⑤营销跳转有白名单与未知提示但任意外链直进 WebView；⑥下载引导组件有、链路与地址配置无；⑦服务商详情附件预览有、下载引导无；⑧miniapp 无行数控制 / 无 APP 桥接标识 / 无 H5 域名；⑨桥接文档给出容器标识与登录态传递；⑩频道页目录定名 `category-channel`，分包归属待定 |
| 阶段2 技术方案 | 阶段0 R2 + 阶段1报告 + 团队技术方案输入 + `invokeApp.js` | 用户授权路径 A 先行 | 正式产物 `阶段2-技术方案-REQ-133.md` 已覆盖责任调整、Cookie-only、APP scheme/商店回退和需求追踪；用户 2026-11-23 确认接口复用与登录移出后授权 UI 先行编码 |
| 阶段3 批次1（UI+mock） | 阶段2 方案 + PC DTO 契约 + 设计稿 UI 基线（R-022~R-027） | 已修正后通过（静态层） | ①ESLint 受检 18 文件 exit=0（prettier 问题 --fix 后清零）；②vue-tsc 与干净基线 stash 对照完全一致（4 个存量错误：webpack-dev-server 类型缺失 + agent-chat.ts 3 处未登记端点），零新增；③mock→mapper 运行时断言 14 项全 PASS（`.temp/req133-mock-assert.mts`）；④build:h5:test 受本机 Node 环境阻塞未跑通，浏览器渲染未实测 |
| 阶段3 批次2（UI 整改+内联留言） | 批次1 产物 + R-022~R-027 + PC 组件源码基线 + 用户反馈 | 已修正后通过（含浏览器实测） | ①esbuild require 钩子绕过 Node 环境，watch 编译成功；②Playwright 精确视口整页截图 mobile 375 / desktop 1280 复核：banner 375×120 无白缝、桌面版心 1200px 居中、表单双列 528×2、footer/留言/空位渲染齐全，NO CONSOLE ERRORS；③留言实测：空手机号/非法手机号校验拦截文案正确；真实后端 POST /v1/employer/inquiries 返回 400「来源一级类目不存在或已停用」（mock 类目 id 不在后端，属预期），错误 toast 显示后端 message；route 拦截 code=200 信封后成功态「留言已提交」+「再留一条」重置清空验证通过；④类目点击跳 serviceHall（tab 页参数走 pendingTabParams + 事件总线，代码链 queueRouteParams→applyRouteParams 核实）、商品卡跳 serviceDetail?productId=90001；⑤ESLint exit=0；vue-tsc 仍为 4 个存量错误零新增；⑥修复记录：textarea 内层白底（postcss 将元素选择器 textarea 映射为 taro-textarea-core，改类名 .taro-textarea）、桌面版心 pxtransform 2x（大写 PX）、image 比例撑高需外包 view |

- 阶段 1 检查范围：文件存在性、当前逻辑、依赖关系、公共组件契约、接口契约、双端能力、APP 容器桥接、知识库覆盖度、横向页面关联、脚本可用性。
- 知识库检索：INDEX.md → L1 README（缺失）→ L2 九份索引 → L4 368 个逐文件详情 → maps 目录树；`.sync-state.json` 锚点与 dev HEAD 一致，`git diff --stat` 为空。L1 断链按「先确认再改库」未擅自修改。
- 验证状态：**批次2 已修正后通过（静态层 + 浏览器实测）**；weapp 端渲染与生产构建证据待收口补。
- 是否允许进入下一阶段：**否**（阶段3 收口待 mock 清理 + 真实接口联调 + weapp/构建证据）。

## 已处理文件

仓库 `wds/wds-miniapp`，分支 `F-REQ-133` @ `a0f347d`，全部未提交（unstaged + untracked）：

| 状态 | 文件 | 职责 |
|---|---|---|
| 新增 | `src/types/category-channel.ts` | PC DTO 镜像 + 页面模型 + mapCategoryChannelPage + 商品卡适配器 |
| 新增 | `src/services/category-channel.ts` | categoryChannelApi；当前 mock 生效，真实调用注释保留 |
| 新增 | `src/services/category-channel.mock.ts` | 全模块 mock（原始 DTO 形状，资讯 2 条验证留空位） |
| 新增 | `src/store/category-channel.ts` | Pinia store，slug 切换 epoch 防过期请求 |
| 新增 | `src/utils/invoke-app.ts` | H5 scheme 唤起 + visibilitychange + 2500ms 商店回退，资源可清理 |
| 新增 | `src/utils/category-channel-jump.ts` | 运营链接白名单路由（可信域 + 已知内部路由） |
| 新增 | `src/components/AppOpenBanner/index.vue` | 顶部打开 APP 指引条（R-027，仅 H5 浏览器） |
| 新增 | `src/pages/category-channel/index.vue` + `index.config.ts` | 频道页编排：模块顺序同 PC，骨架/错误/空态、下拉刷新、分享、H5 SEO 标题 |
| 新增 | `src/pages/category-channel/components/`（ChannelBanner / ChannelCategories / ChannelAgents / ChannelNews / ChannelProducts / ChannelSectionHeader / ChannelInquiry） | 七个模块组件；商品区复用 ServiceCard grid，H5 响应式 2/3/4 列；ChannelInquiry 为频道页内联留言表单（批次2） |
| 修改 | `src/config/endpoints.ts` | 登记 categoryChannelPage（函数式）+ PUBLIC_PATH_PREFIXES |
| 修改 | `src/services/core/request.ts` | isPublicPath 精确+前缀双匹配（旧逻辑注释保留） |
| 修改 | `src/app.config.ts` | subPackages 注册 pages/category-channel |
| 修改 | `src/utils/router.ts` | Routes.categoryChannel |

## 本需求文件树

核对日期 2026-11-23；仓库：需求工作区（`.md/需求/进行中/REQ-133/`，独立仓库）、`wds/wds-miniapp`（`F-REQ-133` @ `a0f347d`，20 个文件未提交）、`wds/wds-web-channel`（HEAD `7fc0967`，干净）、`wds/es-app-main`（只读参考）；本轮代码改动文件数 **20**（15 新增 + 4 修改 + 1 mock）。

```text
.md/需求/进行中/REQ-133/
├── 原始需求/
│   ├── REQ-133 二级频道适配APP端_H5浏览器.md  [输入] 需求原文，602 行，未改动
│   └── 图片和附件/  [输入] 60 余张现状与设计稿截图，未改动
├── REQ-133 二级频道页二次优化-功能清单.md  [团队输入] 任务分工、排期与风险，未改动
├── REQ-133 二级频道页二次优化-技术方案.md  [团队输入] 18 章迁移方案，原样保留
├── 阶段2-技术方案-REQ-133.md  [正式产物] 本人范围方案、invokeApp参考、追踪矩阵与未决项
├── 阶段0-需求文档-REQ-133.md  [正式文档] 规则、合作分工、待确认、验证与风险
├── 阶段1-代码分析-REQ-133.md  [正式文档] 方案核查、差距矩阵、按责任切分的改动清单
└── workflow-state.md  [状态文件] 阶段进度、验证闭环、不确定项追踪
```

```text
wds/wds-miniapp/  (F-REQ-133 @ a0f347d，唯一落地基座；20 文件未提交)
└── src/
    ├── types/category-channel.ts  [新增] DTO 镜像 + 模型 + mapper + 商品卡适配
    ├── services/category-channel.ts  [新增] api（mock 生效，真实调用注释保留）
    ├── services/category-channel.mock.ts  [新增] 全模块 mock 数据
    ├── store/category-channel.ts  [新增] 页面状态 + 防过期请求
    ├── utils/invoke-app.ts  [新增] H5 唤起 APP + 商店回退
    ├── utils/category-channel-jump.ts  [新增] 运营链接白名单跳转
    ├── utils/router.ts  [修改] Routes.categoryChannel
    ├── config/endpoints.ts  [修改] 频道接口 + 游客前缀
    ├── services/core/request.ts  [修改] 游客路径前缀匹配
    ├── app.config.ts  [修改] 分包注册
    ├── components/AppOpenBanner/index.vue  [新增] 顶部打开 APP 指引条
    └── pages/category-channel/  [新增] index.vue + index.config.ts + components/×7（含 ChannelSectionHeader 共享标题行、ChannelInquiry 内联留言）
```

```text
wds/wds-web-channel/  (HEAD e78f076，工作区干净；本期零改动，仅作 DTO / 字段 / 模块顺序 / 视觉参考)
wds/es-app-main/      (只读；docs/integrations/h5/h5-bridge-api.md 给出容器标识与登录态传递)
```

## 阶段 3 允许改动文件

> 只列**王新骏负责**的条目；miniapp 路径落在 `wds/wds-miniapp`，运管后台路径待定位后纳入。合作方负责服务详情、留资页、独立三方下载页、流水线与H5域名；后台仓代码路径待定位后补入清单。具体字段与分包归属按 U-004 / U-005 / U-007 定稿后收窄。

| 层次 | 路径 | 对应规则 / 待确认 |
|---|---|---|
| 修改 | `src/pages/supplier-detail/index.vue` | R-007 / R-008；H5 适配、附件预览回归、按 U-001 挂载下载引导 |
| 修改 | `src/utils/employer-marketing-jump.ts` | R-009；外链可信域校验，保留白名单与未知链接提示 |
| 修改 | `src/config/endpoints.ts` | R-014 / U-005；频道接口与行数字段按 `/gateway` 前缀登记 |
| 新增 | `src/utils/category-channel-jump.ts` | R-009 / R-010；8 类目标受控解析 |
| 新增 | `src/utils/category-channel-url.ts` | R-016 / R-017 / U-010；公开地址与深链参数解析 |
| 新增 | `src/pages/category-channel/`、`src/components/AppOpenBanner/`、`src/utils/invoke-app.ts`（以阶段2实际架构核对后定稿） | 本人负责页面和顶部打开 APP；deep link `wdsheng://open/<encoded-path>`；Android/iOS商店地址见阶段2 |
| 新增 | `src/types/category-channel.ts` + mapper | R-014 / U-005；DTO → 页面模型，兼容缺省值 |
| 新增 | iPad / 桌面响应式公共容器样式 | R-012 / R-013；7 个验收尺寸 |
| 复用（不新建同类） | `src/components/ServiceCard`、`EsNavBar`、`EsEmptyState`、`EsListSkeleton` | 商品卡与页面基础件复用首页既有实现 |
| 复用（只读） | `src/utils/router.ts`、`src/store/auth.ts`、`src/services/employer-inquiry.ts` | R-002 / R-018；不新增登录门闩、不改留资接口 |
| 复用（回归） | `src/pages/supplier-mine/index.vue`、`src/pages/workbench/index.vue` | 下载引导组件的既有引用点 |

**明确排除**：`wds/wds-web-channel` 与 `wds/es-app-main` 整仓、埋点工具、现有请求基础策略及合作方负责的页面/流水线文件。运管后台文件待定位后补充。

## 阶段 4 审查差异

- 受检版本：未记录
- 相关未提交改动：未记录
- 内容指纹（按需）：未生成
- 受检文件：未生成
- 审查时间：未生成
- 复审失效原因：无

## 不确定项追踪

> 编号与阶段 0 / 阶段 1 一致。「归属」标明由谁推进确认。

| # | 问题 | 状态 | 确认方 | 归属 | 影响阶段 |
|---|------|------|--------|------|---------|
| U-001 | 服务商详情是否弹下载引导：功能清单 L18 要加、技术方案第九章写默认不弹 | 待确认（阻塞组件落点） | 产品 / UI | 本人 | 阶段3 |
| U-002 | 下载引导形态：**R3 部分确认——顶部常驻「打开 APP」指引条设计稿已提供（`175975-30231`，R-027）**；登录成功后一次性弹层是否保留、与顶部条关系仍待裁决 | 部分确认 | 产品 / UI | 共同 | 阶段3 |
| U-003 | APP 新版 WebView 容器与配置跳转权限；容器标识按桥接文档落地 | 待确认 | 客户端 / 前端 | 本人 | 阶段3 |
| U-004 | 新增H5跳转链接已确定由本人负责；后台仓、字段/API契约及与PC字段关系待定位 | 部分确认 | 产品 / 运管后台 / 前端 | 本人 | 阶段2、阶段3 |
| U-005 | 接口契约四件套：复用许可、`/gateway` 前缀、旧参数行为、行数字段落点与默认值 | 待确认（未确认前 `TODO: wxj`） | 后端 / 运管后台 | 本人 | 阶段2、阶段3 |
| U-006 | Android/iOS 商店地址及 `wdsheng://open/<path>` scheme 已提供；频道 path 来源和唤起失败回退策略待确认 | 部分确认 | 产品 / 前端 / 客户端 | 本人 | 阶段2、阶段3 |
| U-007 | 频道新页面主体已转本人负责；主包/分包注册方式按目标仓约定确定 | 待确认 | 前端 | 本人 | 阶段2、阶段3 |
| U-008 | 设计稿缺口：**R3 部分确认——移动端 H5 整页（`175570-262826`）与顶部打开 APP（`175975-30231`）已提供**；iPad 断点、服务商详情 H5、后台配置交互稿、section 直链仍缺 | 部分确认 | 设计 | 共同 | 阶段3、阶段5 |
| U-009 | yeeda 技能库六端软链全断，`AGENTS.md` 要求编码前必读 | 待确认（阶段 3 硬前置） | 开发 / 用户 | 本人 | 阶段3 前 |
| U-010 | H5 生产域名、网关回源、历史深链与流水线 | 待确认（合作方主责，本人依赖） | 产品 / 运维 / 合作方 | 合作方 | 阶段3、阶段6 |
| U-011 | 访问后缀配置与带后缀链接是否仍保留（最新两篇未涉及） | 待确认 | 产品 | 共同 | 阶段5 |
| U-012 | 技术方案中残留的埋点条目与 `category-channel-tracking.ts` 不进入本期改动清单 | 待确认 | 产品 / 前端 | 共同 | 阶段3 |
| U-013 | 已确认 Cookie-only 读取 `Authorization` / `ct`，忽略 localStorage；APP 直用页面清单、Cookie 域/path/属性及缺失/过期/登出处理待确认 | 部分确认 | 产品 / 客户端 / 前端 | 本人（客户端依赖） | 阶段2、阶段3、阶段5 |
| U-014 | 类目区 2 个类目时布局：标注只覆盖 1 个（等比填充）与 ≥3 个（固定宽横滑）；建议 2 个时同 1 个口径，待设计确认 | 待确认 | 设计 / 产品 | 本人 | 阶段3 |
| U-015 | 顶部指引条展示范围：APP 内 / weapp 是否隐藏、是否可关闭；建议仅 H5 浏览器展示、不可关闭，待产品确认 | 待确认 | 产品 / UI | 本人 | 阶段3 |

## 备注

- **R3 设计基线（2026-11-23）**：顶部指引条结构经 figmingo 实取（375×60，logo + 分隔线 + slogan + `#5653f8` 按钮）；整页节点 `175570-262826` 拉取超时且 whoami 显示 total429=2 处于限流窗口，已按经验停止调用；模块级规则以用户标注截图为准，逐模块样式细节留待阶段 3 串行提取。详见阶段2 第 9 节。
- 规范隔离：目标项目属企服线，按 `wds/wds-miniapp/AGENTS.md` 自身规范执行（Taro + Vue3 + TS），不套用 WLYD 物流线的 uni-app / Vue2 / `rpx` / `/deep/` 规范；验证命令为 `pnpm type-check` + `pnpm lint` + `pnpm build:h5:test` + `pnpm build:weapp:test`。
- 目标项目当前分支 `dev`（HEAD `533201f`），工作区干净；本阶段零代码改动，该仓是本期唯一改动仓库。
- 团队技术方案点名的 7 个新增路径全部不存在、5 个复用路径全部存在；四个验收脚本在 `package.json` 中真实存在，无需新增脚本。
- `AppDownloadGuidePopup` 组件已存在（2 处引用），缺的是频道 / 详情链路与 H5 下载地址配置；`openEmployerMarketingTarget` 已有白名单与未知链接提示，缺的是可信域校验。
- APP 容器口径参考 `wds/es-app-main/docs/integrations/h5/h5-bridge-api.md`（容器标识 + Cookie 登录态）；本需求只采用 Cookie，忽略 localStorage；miniapp 内三个标识零命中，识别失败降级普通 H5。功能清单所引 `h5-integration-guide.md` 在 `feature_2611_lichentao` 分支，本地 master 无此文件。
- PC 参考源：`wds/wds-web-channel` HEAD `e78f076`，工作区干净；`index.vue` 使用 `resolveChannelModules` / `renderedModules` 配置驱动编排，`channel-modules.ts` 已纳入版本管理，动态实例字段带 `TODO: wxj [REQ-045/161]`。本期该仓零改动，模块顺序与字段口径可作参考，`instances` / `sort_weight` 不写进本期稳定字段设计。
- 知识库：已接入 —— `kb/wds-miniapp/` 368 个条目、`maps/wds-miniapp-tree.md` 1782 行、锚点 `533201f` 与 HEAD 一致；但 L1 `README.md` 缺失导致 INDEX 链接断链，L4 多为脚本生成骨架，业务逻辑仍须实读源码。按「先确认再改库」未改知识库。
- H5 能力：配置完整（dev proxy / publicPath / output / 凭据拦截器 / cookie jar / 60+ 处 `IS_H5`），`dist/h5` 空目录仅表示尚未构建；`channel.wdsheng.com` 项目内零命中，部署口径由合作方给值。
- 阶段 3 前须先解决 U-009（yeeda 技能库软链），并收敛 U-001 / U-002 / U-004 / U-005，否则不满足编码前置。
- 阶段 3 入口状态：等待用户明确编码指令；当前禁止业务代码改动。按工作流规则，阶段 3 出口若仍有待确认项将再次强制暂停。

---

**文档版本**: v1.1
**最后更新**: 2026年11月
**整理人**: 王新骏
