# REQ-133 工作流进度

## 目录

- [需求信息](#需求信息)
- [需求变更日志](#需求变更日志)
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
- 需求版本：**R7**（2026-11-24 功能清单与团队技术方案更新：分工重划——引导登录/注册、服务商详情、app端跳转h5 划归华春风；频道页新增 R-034 app内跳原生 / R-035 留资末尾内联；域名与 Android 下载地址口径重开；R6 原始需求文档更新：运管后台行数配置扩为 Part A 工作项 R-032、访问后缀与埋点按新 PRD 复活并登记归属裁决 R-033/U-016；R5 行业资讯 3 条一组轮播；R4 拆分 Part A / Part B 独立开发验证，运管后台仓定位并确认 h5Url 字段口径，新增 R-028~R-031；历史：R3 设计稿基线 R-022~R-027；R2 责任范围调整；R1 Cookie-only；详见变更日志）
- 测试版本：T0
- 需求编号：RZMP-11286
- 开始时间：2026-11-20（需求评审）；开发启动 2026-11-24
- 需求来源：`原始需求/REQ-133 二级频道适配APP端_H5浏览器.md`（含 60 余张截图）、`REQ-133 二级频道页二次优化-功能清单/REQ-133 二级频道页二次优化-功能清单.md`、`REQ-133 二级频道页二次优化-技术方案.md`（两份团队输入均为 2026-11-24 更新版，R7 依据）
- **miniapp 落地基座（Part B）**：`wds/wds-miniapp`（Taro 4.3 + Vue 3.5，微信小程序 + H5 双端编译）；二级频道新页面与顶部打开 APP 组件落此仓。~~运管后台 H5 跳转能力由本人负责，但后台仓库尚未定位。~~（R4 已定位，见下条）页面暂定 `src/pages/category-channel`，路由 `/pages/category-channel/index`（参数 `slug` + 可选 `categoryId`）
- **运管后台落地基座（Part A，R4 定位）**：`wds/wds-admin-web`（Vue 3 + TS + Vite 6 + Element Plus），分支 `F-REQ-133` @ `f12a0589`，工作区干净；二级频道模块 `src/pages/secondary-channel/`，12 处手填链接点位新增 `h5Url`（非必填）；验证脚本 `pnpm lint` / `pnpm type-check` / `pnpm stylelint` / `build:test` 均存在
- **参考项目（零改动）**：`wds/wds-web-channel`（PC 频道页 DTO / 模块顺序 / 视觉）、`wds/es-app-main`（Flutter 交互契约与 H5 容器桥接文档）
- **交付端口径**：代码一处开发，Taro 编译 weapp + h5；不新建小程序原生频道页，H5 链接在微信内打开需可用，~~小程序端只做回归~~（R7：技术方案第十七章划掉「微信开发者工具完成小程序回归」，weapp 侧仅保留 `build:weapp:test` 构建验收）；H5 覆盖手机、iPad 竖屏 / 横屏与桌面浏览器
- **技术方案**：团队 `REQ-133 二级频道页二次优化-技术方案.md` 是输入材料；正式阶段产物为 `阶段2-技术方案-REQ-133.md`
- 复杂度判定：完整档（多端 × 多模块 × 新接口新字段 × 运管后台配置链路 × 合作开发分工）
- 设计稿：Figma「万大圣WEB」page「二级频道」`52162:93147`
- 本期排除：数据侧后缀解析与事件采集、按后缀维度统计报表（后端/数据侧）、PC / APP 仓改动、小程序端专项频道页开发（R6 新 PRD 明确：小程序本期不包含，PAD/APP/移动端浏览器本期适配）；（R4 新增）模块外 3 处手填链接（活动二级页配置 / 营销位素材 / 全局配置工作台）、后台审核详情/只读页 H5 展示（暂定）。~~埋点上报层与埋点工具本期排除~~（R6：新 PRD 复活埋点，用户侧归属待裁决 U-012，裁决前按 R-019 不在本人范围；运管后台后缀管理与带后缀链接生成按 R-033 纳入 Part A，契约确认后启动；2026-11-24 用户裁决不接手，R7 功能清单划线「暂不做」印证）。**R7 新增移出**：引导登录/注册（登录页实现侧）、服务商详情、app端跳转h5（营销位跳转与 WebView 容器）划归华春风；本人保留频道页侧登录态消费、登录后下载引导与 providerId 传参边界

## 需求变更日志

| 版本 | 日期 | 变更内容 | 变更类型 | 回退阶段 |
|---|---|---|---|---|
| R0 | 2026-11-20 | 初始需求分析 | 初始 | - |
| R1 | 2026-11-23 | APP 页面登录态 Cookie-only（`Authorization` / `ct`） | 字段口径 | 阶段0 |
| R2 | 2026-11-23 | 本人责任范围调整：频道新页面、顶部打开 APP 组件、后台 H5 跳转；商店地址与 scheme 确定 | 业务范围 | 阶段0 |
| R3 | 2026-11-23 | 设计稿基线：移动端 H5 整页 + 顶部指引条 + 模块级 UI 标注，落为 R-022~R-027 | 交互/UI 规则 | 阶段0 |
| R4 | 2026-11-24 | 拆分 Part A（运管后台 `wds-admin-web`）/ Part B（C 端 `wds-miniapp`）独立开发验证；后台仓定位；用户确认 h5Url 暂定名/非必填/12 处全量/模块外不处理/详情只读不处理（暂定）/双轨独立；新增 R-028~R-031；U-004 收窄 | 新增端/模块/字段 | 阶段0（已完成）→ 阶段1/2 已同步更新，待用户 check |
| R5 | 2026-11-24 | 用户重申行业资讯交互：list 每 3 条一组、一组一个 swiper-item、水平自动轮播（默认间隔）、尾组不占位、固定高；授权删除 ChannelNews 历史实现；R-026 旧口径失效 | 交互规则变更 | 阶段0（已同步 v1.3）→ 阶段1/2 同步、批次5 已实现并实测 |
| R6 | 2026-11-24 | 原始需求文档更新（2026-11-24 版）。用户重申范围：二级频道 H5、打开 APP 入口、运管后台。①行数配置扩为 Part A 工作项 R-032（latest 固定 10 改行数、recommended 参数调整，新增 U-016 范围/默认值冲突）；②访问后缀管理落 R-033 纳入 Part A（契约缺失待确认）、用户侧埋点归属待裁决（U-012，裁决前 R-019 仍有效）；③小程序本期不包含与既有口径一致；④R-022 补单张 banner 不显示多余指示点；⑤R-026 不被 PRD「单列列表」通用描述推翻 | 新增模块/字段 | 阶段0（已同步 v1.4）→ 阶段1 v1.3 / 阶段2 v1.6 已同步，Part A 新工作项待用户 check + 契约确认 |
| R7 | 2026-11-24 | 功能清单与团队技术方案更新（2026-11-24 版），范围重新划分。①分工重划：引导登录/注册（登录页实现侧）、服务商详情、app端跳转h5 划归华春风（登录链路移出与用户 2026-11-23 口头指令一致，本轮文档正式收口）；②频道页新增 R-034 app内服务详情跳原生（U-017 桥接契约缺失）、R-035 留资表单末尾内联（U-018 待业务确认，与批次2 ChannelInquiry 方向一致）；③`channel.wdsheng.com` 划线废弃，候选 `m.wdsheng.com` / `h5.wdsheng.com` 不一致（U-010 重开）；④Android 下载地址新增应用宝 `microdown.yyb.qq.com` 候选（U-006 部分重开）；⑤微信开发者工具小程序回归划掉（`build:weapp:test` 保留）；⑥埋点划线「暂不做」印证 U-012 裁决。已完成 Part A 39 文件与 Part B 批次1~7 均不涉及移出项，零代码回退 | 分工/范围重划 | 阶段0（已同步 v1.5）→ 阶段1 v1.4 / 阶段2 v1.7 已同步；R-034/R-035 待 U-017/U-018 确认后启动 |
| APP 契约证据补充 | 2026-11-24 | 用户提供 APP 容器文档 `wds/es-app-main/docs/integrations/h5/h5-integration-guide.md`（当前实现口径）与 `h5-container-architecture.md`（演进规划），经 APP 仓库代码核验：①U-017 部分闭环——桥接 `webview_ultra.callHandler('native', {method:'navigate', data:链接})`、原生路由 `wdsheng://open/es/employer/service/<id>`（id int）、失败 reject/`{ok:false}` 已实证，剩余 productId↔id 映射、employer 角色匹配、APP 版本兼容 3 项；②scheme `wdsheng://open` 与 R2 口径印证一致（团队技术方案 `wlyd://` 失配残留）；③U-010 补硬约束：H5 域名必须 `*.wdsheng.com` 子域（容器白名单 + Cookie 注入域）；④U-013 补 pageReady 读取时机信号；⑤用户确认「1、2 都处理」：文档同步 + R-034 编码授权（productId 映射 `TODO: wxj` 占位） | 契约证据/编码授权 | 阶段0 v1.6 / 阶段1 v1.5 / 阶段2 v1.8 / state v1.6 已同步；R-034 编码启动 |

> **R4 双轨拆分声明（置顶）**：Part A（运管后台 h5Url）与 Part B（C 端频道页）**各自开发、各自验证、互不阻塞**，以 `h5Url` 接口契约为边界。Part B 既有批次 1/2/3 进度与结论不变；Part A 当前处于阶段2 方案待用户 check，**check 通过前不编码**。

## 合作分工与范围边界

> 依据功能清单「人员分配」列。**本工作流只跟踪王新骏负责的条目**；合作方条目只保留协作接口，不展开实现、不列入阶段 3 允许改动文件。

| 归属 | 功能清单条目 | 对应技术方案章节 | 本工作流 |
|---|---|---|---|
| ~~**本人（王新骏）**~~ 华春风（R7 移交） | 引导登陆 / 注册 | 八、登录统一方案；九、浏览器登录后的下载引导 | 仅记协作接口：登录态标记与登录后下载引导由本人频道页侧消费 |
| ~~**本人**~~ 华春风（R7 移交） | app 端跳转 h5 | 十、H5 路由和外链兼容；十一、频道跳转规则 | 仅记协作接口：营销位跳转 `employer-marketing-jump.ts` 与 WebView 容器（U-003）；本人保留 `category-channel-jump.ts`（R-009）与 Cookie 登录态 |
| **本人** | 二级频道新页面 | 三、四、十五章 | ✅ 页面主体及路由；R7 新增 R-034 app内跳原生（U-017 待确认）、R-035 留资末尾内联（U-018 待确认） |
| **本人** | 顶部「打开 APP」组件 | 九、十、十一章 | ✅ deep link 与商店兜底（R7：Android 地址两候选待确认 U-006） |
| **本人** | 运管后台新增 H5 跳转链接 | 十一、十四章 | ✅ Part A；仓已定位 `wds/wds-admin-web`（R4） |
| ~~**本人**~~ 华春风（R7 移交） | 服务商详情 | 六、服务商详情范围；九、下载引导展示范围 | 仅记协作接口：本人保留 providerId 传参边界；U-001 由其跟进 |
| **本人** | 运营后台限制行数 | 四、模块范围；十四、工程实现要求 | ✅ 跟踪 |
| **本人** | 配置链接跳转 | 十一、频道跳转规则 | ✅ 跟踪（R7：仅频道配置受控解析 R-009，营销位 R-010 移出） |
| **本人（共同）** | buffer · iPad 适配 | 十二、iPad 和响应式适配 | ✅ 跟踪 |
| 合作方 | 服务详情 | 五、服务详情范围 | 仅记接口：登录回跳目标 |
| 合作方 | 提交留言 H5 页面 | 七、需求留言和留资页 | 仅记接口：`sourceCategoryId` 传参 |
| 合作方 | 三方应用下载页面 | 九、下载引导 | 仅记接口：下载引导地址来源 |
| 合作方 | 流水线 dev / test / uat / master | 十七、验收标准 | 仅记接口：`build:h5:test` / `build:weapp:test`（R7：微信开发者工具回归划掉） |
| 合作方 | 域名确认 | 十、频道公开地址；十八、上线和回滚 | 仅记接口：~~`channel.wdsheng.com` 与回源~~（R7 废弃，候选 `m.wdsheng.com` / `h5.wdsheng.com` 待确认 U-010，华春风跟进） |
| 合作方（R7 新增，华春风） | 引导登录/注册（登录页实现侧）、服务商详情、app端跳转h5 | 六、八、九、十、十一章 | 仅记协作接口，不展开实现、不列入阶段 3 允许改动文件 |

## 阶段进度

> R4 起双轨记录：Part B（miniapp）沿用原表；Part A（wds-admin-web）单独下表。

**Part B · C 端频道页（`wds/wds-miniapp`）**

| 阶段 | 状态 | 产物文件 | 完成时间 |
|------|------|---------|---------|
| 阶段0 需求分析 | ✅已完成（R7 同步更新 v1.5） | 阶段0-需求文档-REQ-133.md | 2026-11-23（R7 更新 2026-11-24） |
| 阶段1 代码分析 | ✅已完成（R7 同步更新 v1.4） | 阶段1-代码分析-REQ-133.md | 2026-11-23（R7 更新 2026-11-24） |
| 阶段2 技术方案 | ⚠️待确认（正式方案已形成，出口受 U 项阻塞；R7 更新 v1.7） | 阶段2-技术方案-REQ-133.md | 2026-11-23（R7 更新 2026-11-24） |
| 阶段3 编码执行 | 🔄进行中（批次1~7 + R-034 已落地：批次1~7 浏览器实测通过、R-034 静态层+行为断言；待收口：mock 清理 + 真实接口联调 + weapp/构建证据） | 阶段3-实施记录-REQ-133.md（代码改动见「已处理文件」） | 2026-11-23 起（批次7 / R-034 2026-11-24） |
| 阶段4 代码审查 | ⏳待开始 | - | - |
| 阶段5 测试基线与覆盖对齐 | ⏳待开始 | - | - |
| 阶段6 测试执行与Bug修复循环 | ⏳待开始 | - | - |
| 阶段7 需求复盘（可选） | ⏳待开始 | - | - |

**Part A · 运管后台 h5Url（`wds/wds-admin-web`，R4 新增）**

| 阶段 | 状态 | 产物文件 | 完成时间 |
|------|------|---------|---------|
| 阶段0 需求分析 | ✅已完成（R-028~R-031，并入阶段0 v1.2；R6 新增 E 节 R-032/R-033，v1.4） | 阶段0-需求文档-REQ-133.md D / E 节 | 2026-11-24 |
| 阶段1 代码分析 | ✅已完成（12 点位读码核实，第十章；R6 新增第十一章行数/后缀现状实读，v1.3） | 阶段1-代码分析-REQ-133.md 第十 / 十一章 | 2026-11-24 |
| 阶段2 技术方案 | ✅已完成（2026-11-24 用户 check 通过；第 10 节 + 10.4 契约清单；C-A1~C-A5 待后端书面确认，不阻塞编码、阻塞联调）**（R6 第 11 节：行数配置方案 + C-B1~C-B4 契约清单 + 后缀占位；2026-11-24 用户 check 通过并裁决：U-016 PRD 口径 1~10 先行 + 占位、recommended 参数不动待评审；U-012 埋点不接手；授权 R-032 编码）** | 阶段2-技术方案-REQ-133.md 第 10 节（R6：第 11 节） | 2026-11-24 |
| 阶段3 编码执行 | ✅已完成（静态层）——h5Url 38 文件 + R-032 行数 6 文件（2 文件叠加，合计 39 文件）全部未提交；12 点位 h5Url 双向贯通 + latest 行数链路贯通；type-check / stylelint 零新增 + 41 项断言 + R-032 18 项断言全通过；ESLint 环境阻塞未执行（用户裁决跳过）；浏览器实测与真实接口联调未做 | 阶段3-实施记录-REQ-133.md（代码改动见「本需求文件树」Part A 块） | 2026-11-24 |
| 阶段4~7 | ⏳待开始 | - | - |

## 当前阶段

**双轨状态（R4，2026-11-24）**：
- **Part A**：~~阶段2 方案已落盘（阶段2 第 10 节），**等待用户 check 文档后再实施**~~（2026-11-24 用户 check 通过，阶段3 进行中，授权连续执行）。用户裁决三项：①活动专区只加 h5Url，存量 TODO（4.13 #16）保留不动；②底部 Banner H5 输入随 url 同显隐；③连续执行，每步验证后继续。契约 C-A1~C-A5 待后端书面确认，未确认处 `TODO: wxj` 占位，不阻塞编码。基线 `wds/wds-admin-web` `F-REQ-133` @ `f12a0589`，启动时工作区干净。
  - **2026-11-24 阶段3 已收尾（静态层）**：按开发顺序 p2→p5 全部落地，38 文件均 unstaged、无 untracked。门禁：vue-tsc（`-p tsconfig.app.json`）170 条 vs worktree 基线 170 条，逐条 diff 仅 1 处行号位移（存量 `nextTick` TS6133），**零新增**；stylelint 15 个样式文件 68 warning vs 基线 68 warning，归一化 diff exit=0，**零新增**；断言自检 p2 mapper 19 项 + p5 validate/submit 22 项 = **41 项全通过**。**ESLint 未执行**（`@unocss/eslint-plugin` 解析缺失，用户裁决跳过，详见备注）。**未验证**：浏览器渲染与交互实测、真实接口联调、`build:test` 构建。出口结论：静态层通过，**不足以进入阶段4 审查前的联调收口**，C-A1~C-A5 仍需后端书面确认。
- **Part B**：阶段 3 进行中（用户 2026-11-23 授权路径 A：UI 先行批次），状态不变，见下方历史记录。

**Part B 历史记录**：用户 2026-11-23 确认：①频道接口复用 `wds-web-channel` 现有契约（U-005 复用许可关闭，行数字段仍待后端）；②登录链路（引导登录/注册及登录后下载弹层）移出本人范围；③文档一律正向输出。开发基线 `F-REQ-133` @ `a0f347d`（与 dev 同 HEAD）。

批次 1 已落地 18 个文件（16 个功能文件 + 2 个 mock 过渡文件）：频道页全模块 UI、顶部打开 APP 指引条、scheme 唤起工具、运营链接白名单跳转、分包与路由注册。后端接口未就绪，service 层按项目过渡决策口径 **mock 生效 + 真实调用注释原地保留**（`TODO: wxj mock` 标注，收口时 grep 一次定位）。

批次 2（用户同日反馈「每个模块 UI 再审视 + 留言要在频道页直接留」）新增 2 文件、累计 20 文件：①逐模块按 PC 视觉语言整改（灰底画布 + 白卡分层、共享标题行 ChannelSectionHeader、类目渐变图标等高卡、智能体封面叠加白标题、资讯独立白卡 + 空位透明、商品区接共享标题行）；②留言改频道页内联表单 ChannelInquiry（复用 createEmployerInquiry + resolveInquirySource，旧跳页入口模板/样式/方法注释保留），H5 ≥768 双列；③补挂 AppOpenBanner 与 footer 模板（批次1 漏挂载）；④修复 pxtransform 桌面版心（大写 PX）、顶部 banner 出血白缝、image 比例撑高、textarea 内层白底（postcss 元素选择器映射坑）。

批次 3（用户反馈「智能体市场轮播化 + Figma 176799-141732 逐项核对 item UI」）只改 ChannelAgents.vue（用户手改的 index.vue / ChannelBanner / ChannelCategories / ChannelProducts / ChannelSectionHeader 五文件零触碰）：①scroll-view 改 Taro 原生 swiper 居中轮播（previous/next-margin 双侧等宽露出、circular、按张吸附，旧 scroll-view 模板/样式注释保留）；②按 Figma Component 244 规格重写卡片：封面 2:1（260×130）、标题移入白底卡身（16/22 Semibold #1f1f29 单行省略）、描述 12/17 两行 clamp、卡身 padding 16（16+22+6+34+16=94）、旧封面压字遮罩注释废弃；「查看更多」按钮在设计稿三变体中均被卡边界裁剪，不纳入；③卡宽 260 设计像素随视口等比（2x 封顶）、peek 由容器宽反算整数且双侧精确等宽；④H5 ≥768 版心改 15rem（root40 → 真实 600px）；⑤顺带清理 mock 过渡遗留的 3 处 TS6133 未用 import（category-channel.ts ×2、request.ts ×1，注释保留）。新增坑点：Taro H5 swiper parseMargin 正则 /^(\d+)px/ 只认整数 px 且 previousMargin 无 watch（margin 变化需 key 重建实例）；pxtransform 对大写 PX 同样转 rem、样式表 margin 随 root 缩放（桌面 4px→8px），恒定真实像素需走内联 style。index.vue 桌面版心失效源于用户手改 1200PX→1200px（编译 60rem），属用户调整范围未回改。

批次 4（用户三连指令：①代码层面清理多余注释/过程内容；②客服二维码换用户提供的 3x 图；③暂只做 H5 移动端、媒体查询全部移除）：①清理 ChannelInquiry 注释旧代码块（mobileChecked/mobileError、updateMobile、原生 textarea 模板与样式、__error、红边样式）与过程叙述注释、index.vue 8 处纯结构模板注释、死类 __fields/__field/--wide；保留 nut-form/nut-textarea 适配等非显然坑点注释与 TODO: wxj（mock 恢复点注释按收口约定保留）；②customer_service_wechat_qr.png 同名覆盖为用户 3x 图（360×360），零代码改动；③移除 4 文件全部 @media（index 1024 版心、Agents 768 15rem 及同口径 JS 镜像、Inquiry 768 双列、Products 768/1024 三/四列），layout() 收敛为单调用；桌面现为全宽移动布局（用户明确暂不要响应式）。用户此前已手动清理一轮 [REQ-133] 注释，本轮在其现状上继续，未回改用户调整。

批次 5（用户重申 ChannelNews 需求：list 每 3 条一组、一组一个 swiper-item、自动轮播；确认水平方向、默认间隔、尾组不足不占位、固定高度，授权删除该组件历史内容）：重写 ChannelNews.vue 为 `groups` chunk computed + Taro swiper（autoplay circular 水平），行卡 UI 与点击 select 事件保留，删除 slice(0,3) 静态截断与空位占位逻辑；swiper 固定高 304px（3×96+2×8）。mock industryNews 2→5 条（3+2，原 2 条保留追加）以验证分组与尾组不占位。文档同步（R5，交互结果变更按回退规则补阶段0）：阶段0 v1.3（R5 补充段 + R-026 重写 + 版本行）、阶段1 v1.2（R5 注记）、阶段2 v1.3（9.1 口径重写 + 9.2 实施回填）。

批次 6（用户指令：133 小程序所有超出文本隐藏统一 nut-ellipsis，不自实现）：6 个文本节点替换为 `nut-ellipsis`（ChannelAgents name rows1 / desc rows2、ChannelNews title rows2、ChannelCategories group-name / child / image-name×2；child 外层 view 保留 @tap，desc 保留用户加的 v-if）；自实现 clamp/ellipsis/nowrap 三件套按原内容保留规则注释废弃，字体/行高/min-height 保留；`__scroll` 的 nowrap 属横滑布局非文本截断，不动。实测：单行 22/17、两行 34/40 且文本以「...」收尾（自实现已注释，截断只能来自组件）；ESLint exit=0、vue-tsc 基线 4、无 console 错误；截图 `.temp/req133-ellipsis-{agents,news,categories}.png`。未覆盖：IMAGE 模式 image-name 无 mock 数据（STANDARD 模式），替换与 group-name 同构，待收口补验。

批次 7（用户指令：行业资讯 swiper 指示器激活 12×3、非激活 3×3，附设计截图）：ChannelNews 新增 `__dots` 指示器行（`current` + `@change` 跟随轮播，单组隐藏）；激活 12×3 胶囊 radius 2px `$color-primary`、非激活 3×3 圆点 #cccccc（附图像素采样 #5753ff/#cccccc，激活归一品牌 token），gap 4px 居中、swiper 下 8px。收尾时 IDE 保存冲突致磁盘第 90 行闭合标签损坏为 `<vieww>`（编译报错），用户报障授权后修回 `</view>`；dots v-for 未用变量改 `_group` 清 TS6133。复跑：ESLint exit=0、vue-tsc 回基线 4、probe t0 [12×3 active, 3×3] → 5.6s 后 active 移第 2 点、NO CONSOLE ERRORS；截图 `.temp/req133-news-dots.png`。

**R6 文档同步（2026-11-24，本轮，纯文档零代码改动）**：原始需求文档更新后，按用户重申范围（二级频道 H5、打开 APP 入口、运管后台）同步正向阶段产物：阶段0 v1.4（R6 补充段 + E 节 R-032/R-033 + R-019 R6 注 + R-022 单张指示点 + U-005 补充 / U-011・U-012 重写 / U-016 新增 + 8.5 Part A 配置扩展验证清单）、阶段1 v1.3（第十一章：latest 固定策略 / recommended 行数链路 / suffix 零命中，全部实读附行号）、阶段2 v1.6（第 11 节：latest 改行数 7 层改动清单 + recommended 参数调整 + C-B1~C-B4 契约清单 + 后缀占位不预设方案 + 验证计划沿用 10.7 门禁口径）、本 state v1.4。**Part A 新工作项（R-032/R-033）编码前置**：~~①用户 check 阶段2 第 11 节；②U-016 行数范围/默认值冲突裁决~~（**2026-11-24 用户 check 通过并裁决**：U-016 latest 按 PRD 口径 1~10 先行 + `TODO: wxj` 占位、recommended 存量参数不动待产品评审；U-012 用户侧埋点**不接手**，R-019 维持，Part B 不新增埋点层；授权 R-032 编码，每步验证后连续执行；只读层沿用 R-030 排除不动）；③C-B1~C-B4 后端书面确认（不阻塞编码、阻塞联调，未确认处 `TODO: wxj` 占位）；④R-033 后缀待接口契约与交互稿，确认前不启动。Part B 批次1~7 进度与结论不变。

**R-032 编码执行（2026-11-24，裁决后同日落地，静态层）**：latest-services 固定 10 个改行数控制，6 文件改动（`constants.ts` 新增行数常量 1~10/默认暂定 2 + 旧固定策略注释废弃保留供 readonly/详情兼容；`types.ts` 新增 `displayRows` + `clampLatestServiceRows`，`displayCount` 改兼容读取；`index.vue` 固定预设 select 注释保留、新增 el-input-number 行数输入沿用 recommended draft/commit 模式；`validate.ts` 整数+范围校验；`api-types.ts` DTO 新增 `line_count` 暂定名 `TODO: wxj` C-B1/C-B2；`config-mapper.ts` 双向透传行数、`display_count` 不再写入仅兼容读取 C-B3）。recommended-services 参数零改动（U-016 余量待产品评审）；readonly/详情链路沿用 R-030 排除零改动；submit 委托 mapper 无需改。门禁：vue-tsc 170 条与 Part A 基线归一化 diff exit=0 零新增；stylelint latest index.vue 3 warning 与 worktree 基线一致零新增；断言 18 项全通过（clamp 边界/normalize/toApi 不下发 display_count/回显兼容/往返不丢/validate 原行为/recommended 回归）。ESLint 按用户裁决跳过；浏览器实测与真实接口联调未做（C-B1 字段名待后端）。工作区 39 文件全部 unstaged、无 untracked。

**R7 文档同步（2026-11-24，本轮，纯文档零代码改动）**：功能清单与团队技术方案更新后按用户「工作流的文档正向输出即可」同步正向阶段产物：阶段0 v1.5（R7 补充段 + 分工表重划 + F 节 R-034/R-035 + U-001/U-003 归属修正 / U-006・U-010 重开 / U-017・U-018 新增 + 验证清单与风险表更新）、阶段1 v1.4（R7 补充段 + 3.1/3.2/3.3 移出留档 + 核查表 #7/#9/#11/#13/#14 注记 + 差距矩阵补 R-034/R-035 + U 表同步 + 7.2/7.3 改动清单收敛）、阶段2 v1.7（R7 补充段 + 第 1/2/4/6/7 节更新 + 追踪矩阵补 R-034/R-035 + R7 验证闭环）、本 state v1.5。**关键判断**：①登录链路移出与用户 2026-11-23 口头指令（Part B 历史记录②）一致，本轮借功能清单正式收口，消除分工表旧「✅ 跟踪」矛盾；②已完成 Part A 39 文件与 Part B 批次1~7 均不涉及移出项，**零代码回退**；③R-035 与批次2 ChannelInquiry 已实现方向一致，只登记 U-018 待业务确认，不开编码任务；④R-034 桥接契约缺失（U-017），确认前 `TODO: wxj` 占位不预设实现。**待确认**：U-017（客户端）、U-018（业务）、U-010 域名两候选（华春风跟进）、U-006 Android 两候选（确认前沿用原地址）。

**APP 契约证据补充 + R-034 编码启动（2026-11-24，本轮）**：用户提供 APP 容器两份文档后实读 APP 仓库代码（`universal_route_config.dart` / `app_deep_link_parser.dart` / `employer_routes.dart` / `push_page_code_registry.dart` / `webview_ultra_native_bridge.dart`），U-017 部分闭环（navigate handler + 原生路由 + 失败行为），剩余 productId↔id 主键映射、employer 角色匹配、APP 版本兼容 3 项；scheme 与 R2 口径印证一致；U-010 补白名单硬约束、U-013 补 pageReady 时机。用户确认「1、2 都处理」：①四份文档同步（阶段0 v1.6 / 阶段1 v1.5 / 阶段2 v1.8 / 本 state v1.6）；②R-034 编码启动——H5 特性检测 `window.webview_ultra?.callHandler` + navigate 跳 `wdsheng://open/es/employer/service/<id>` + try/catch 降级浏览器路径，weapp 不注册，productId→id 默认同名直传 + `TODO: wxj` 占位。R-035 仍待 U-018，零改动。

**R-034 编码执行（2026-11-24，静态层 + 行为断言）**：2 文件改动——`src/utils/category-channel-jump.ts` 新增 `openServiceDetail(productId)`（IS_H5 + `webview_ultra.callHandler` 特性检测、数字 id 守卫、`callHandler('native', {method:'navigate', data:'wdsheng://open/es/employer/service/<id>'})`、`ok:false`/reject 降级 `navigateTo(Routes.serviceDetail)`，productId 映射 `TODO: wxj` 占位），`openChannelTarget` 服务详情分支改走该函数（旧直跳注释保留）；`src/pages/category-channel/index.vue` `handleSelectProduct` 改走 `openServiceDetail`（旧直跳注释保留，三处 ChannelProducts 共用此单点）。门禁：两文件 ESLint exit=0、Prettier exit=0；vue-tsc 4 条与既有基线一致（h5-dev-proxy + agent-chat×3）**零新增**（`.temp/tc-req133-r034.log`）；行为断言 9 项全通过（`.temp/req133-r034-assert.mjs`，esbuild 打包真实源码 + stub env/router/toast）：无桥降级/桥成功仅 native/ok:false 降级/reject 降级/非数字 id 直跳 H5/weapp 不触桥/配置链接容器内 native/配置链接浏览器回归/未知外链不跳转。未执行：`build:h5:test` / `build:weapp:test`（Node 环境约束沿用批次记录）、真机 APP 容器实测（需线上包含 navigate bridge 的版本）、真实接口联调。其余消费点（`EmployerServiceList` / `EmployerPublicReviewCard`）不在频道页范围，零改动。

**待办**：①~~dev server Node 环境阻塞~~ 已解决：`.temp/ts-hook.cjs` esbuild require 钩子绕过 Node22 strip-only 限制，watch 编译成功（:10086），浏览器实测已完成；②U-006 deep link path 规则、U-014 类目区 2 张布局、U-015 顶部条显隐、行数配置字段、APP 容器 UA 标识均按建议口径先行并 `TODO: wxj` 占位；③U-009 yeeda 软链仍断，按仓自身 AGENTS.md 约定执行（偏差已记录）；④收口时 grep `TODO: wxj mock` 清理 mock 过渡产物并复跑真实接口。

## 验证闭环记录

| 阶段 | 锚点 | 验证结果 | 证据 |
|---|---|---|---|
| 阶段0 需求分析 | 原始需求 + 两篇团队文档 + Figma 节点树 | 通过 | 阶段0 文档：①本人范围分工表；②规则拆解；③设计稿交叉验证；④横向搜索 8 维度；⑤涉及端与页面现状表；⑥验证清单与风险 |
| 阶段1 代码分析 | 阶段0 文件清单 + 团队技术方案点名路径 + `.repoWiki` 锚点 `533201f`；R2责任变化未新增代码现场 | 通过（原代码基线） | 阶段1 报告第一 / 三 / 四章（均附文件行号）：①7 个新增路径全 MISSING、5 个复用路径全 EXISTS；②四个验收脚本真实存在；③`resolveInquirySource` / `openLoginDialog` 已实现；④登录页 `isWeapp` 主入口已隐藏微信授权、协议弹窗仍有残留；⑤营销跳转有白名单与未知提示但任意外链直进 WebView；⑥下载引导组件有、链路与地址配置无；⑦服务商详情附件预览有、下载引导无；⑧miniapp 无行数控制 / 无 APP 桥接标识 / 无 H5 域名；⑨桥接文档给出容器标识与登录态传递；⑩频道页目录定名 `category-channel`，分包归属待定 |
| 阶段2 技术方案 | 阶段0 R2 + 阶段1报告 + 团队技术方案输入 + `invokeApp.js` | 用户授权路径 A 先行 | 正式产物 `阶段2-技术方案-REQ-133.md` 已覆盖责任调整、Cookie-only、APP scheme/商店回退和需求追踪；用户 2026-11-23 确认接口复用与登录移出后授权 UI 先行编码 |
| 阶段3 批次1（UI+mock） | 阶段2 方案 + PC DTO 契约 + 设计稿 UI 基线（R-022~R-027） | 已修正后通过（静态层） | ①ESLint 受检 18 文件 exit=0（prettier 问题 --fix 后清零）；②vue-tsc 与干净基线 stash 对照完全一致（4 个存量错误：webpack-dev-server 类型缺失 + agent-chat.ts 3 处未登记端点），零新增；③mock→mapper 运行时断言 14 项全 PASS（`.temp/req133-mock-assert.mts`）；④build:h5:test 受本机 Node 环境阻塞未跑通，浏览器渲染未实测 |
| 阶段3 批次2（UI 整改+内联留言） | 批次1 产物 + R-022~R-027 + PC 组件源码基线 + 用户反馈 | 已修正后通过（含浏览器实测） | ①esbuild require 钩子绕过 Node 环境，watch 编译成功；②Playwright 精确视口整页截图 mobile 375 / desktop 1280 复核：banner 375×120 无白缝、桌面版心 1200px 居中、表单双列 528×2、footer/留言/空位渲染齐全，NO CONSOLE ERRORS；③留言实测：空手机号/非法手机号校验拦截文案正确；真实后端 POST /v1/employer/inquiries 返回 400「来源一级类目不存在或已停用」（mock 类目 id 不在后端，属预期），错误 toast 显示后端 message；route 拦截 code=200 信封后成功态「留言已提交」+「再留一条」重置清空验证通过；④类目点击跳 serviceHall（tab 页参数走 pendingTabParams + 事件总线，代码链 queueRouteParams→applyRouteParams 核实）、商品卡跳 serviceDetail?productId=90001；⑤ESLint exit=0；vue-tsc 仍为 4 个存量错误零新增；⑥修复记录：textarea 内层白底（postcss 将元素选择器 textarea 映射为 taro-textarea-core，改类名 .taro-textarea）、桌面版心 pxtransform 2x（大写 PX）、image 比例撑高需外包 view |
| 阶段3 批次3（智能体轮播+Figma 卡片规格） | Figma 176799-141732（Component 244 三变体）+ 渲染图像素采样 + 用户轮播要求 | 已修正后通过（含浏览器实测） | ①Figma 取数：get_design_context 规格 + get_screenshot 落盘 `.temp/figma-agent-item.png`，卡身渐变色值经 Playwright canvas 像素采样 12 点全 #ffffff（figmingo 超时后不再试探限流）；②probe 实测 mobile 375：卡 259×223.5、coverRatio 0.5、标题 16/22 单行 #1f1f29、描述 12/17 两行 #646473、卡身 pad16 白底 h94、leftPeek=rightPeek=58、拖拽吸附 centerIdx 1→2；desktop 1280：swiper 600 版心居中、卡 520×448（2x）、leftPeek=rightPeek=40，直载/拖拽/resize 往返均对称；NO CONSOLE ERRORS；③组件截图 `.temp/req133-agents-mobile.png` / `-desktop.png` 与 Figma 视觉比对一致；④ESLint 3 文件 exit=0；vue-tsc 回到基线 4 存量（清理 3 处 TS6133 后）；⑤修复记录：peek 小数被 parseMargin 归 0 → 整数化+奇偶微调卡宽；previousMargin 无 watch → :key 重建 + :current/@change 保索引；样式表 margin 随 root 缩放 → 内联恒定 4px |
| R4 文档更新（Part A 阶段0/1/2，2026-11-24） | 用户 6 项确认 + `wds/wds-admin-web` 实读源码（`F-REQ-133` @ `f12a0589`）+ 知识库 `kb/wds-admin-web/` | 已修正后通过（文档层，待用户 check） | ①阶段0 v1.2：R4 补充 + R-028~R-031 + U-004 收窄 + 8.4 Part A 验证清单；②阶段1 v1.1：第十章 12 点位清单（7 条目级 + 5 查看更多，全部读码核实，含必填性差异）+ DTO/mapper 链路 + 存量 TODO；③阶段2 v1.1：第 10 节方案 + 10.4 契约清单 C-A1~C-A5 + 追踪矩阵 R-028~R-031；④本轮纯文档更新，两仓零代码改动；⑤未验证项：Part A 未编码，lint/type-check 未跑（无代码改动不适用） |
| **Part A 阶段3 编码执行（2026-11-24）** | 阶段2 第 10 节方案 + 10.4 契约清单 + 用户三项裁决 + 基线 worktree `f12a0589` | **已修正后通过（仅静态层）** | ①**范围校验**：`git diff --name-only` 38 文件，全部落在 `src/api/secondary-channel/` 与 `src/pages/secondary-channel/form/modules/`；排除域（detail-config.mapper / components/detail / readonly.vue / 模块外 3 处 / list、audit）**零命中**，无 untracked。②**type-check**：`./node_modules/.bin/vue-tsc --noEmit -p tsconfig.app.json` exit=2 / 170 条，与 worktree 基线（`f12a0589` + 补拷 `types/auto-imports.d.ts`、`types/components.d.ts` 生成物）170 条逐条 diff，唯一差异为 `ShowMoreConfig.vue` 存量 `nextTick` TS6133 行号 45→60，**零新增**（证据：`.temp/tc-req133-partA-base.log`、`tc-req133-p4.log`、`tc-req133-p5.log`）。③**stylelint**：15 个改动样式文件 exit=0 / 68 warning，基线同文件 68 warning，去行号归一化后 diff exit=0，**零新增**（`.temp/sl-req133-partA.log`、`sl-req133-base.log`）。④**断言自检 41 项全通过**：p2 mapper 19 项（`.temp/req133-p2-assert.mts`，双向透传 / 只填 H5 / 旧数据结构不变 / 顶底 Banner 回显）+ p5 validate・submit 22 项（`.temp/req133-p5-assert.mts`，9 模块 H5 选填口径 / 非法拦截 / 长度兜底 / 查看更多开关联动 / 顶底 Banner 提交结构），均用仓内 esbuild 打包后真实执行。⑤**发现偏差与修正**：方案 10.2 写「ChannelLinkField 覆盖 3 弹窗 + 内联 4 处」，实读为 **4 弹窗（含 CategoryImageItemDialog）+ 内联 3 处**（category-list 走弹窗）；新增方案未列的横向点 `ActivitySelectDialog.toEmitItem`（不补则弹窗确认后 H5 丢值）；`build-api-config.ts` 实读为壳（遍历 modules 调 buildPayload），**无需改动**。⑥**未执行 / 未验证**：ESLint（`@antfu/eslint-config` 需 `@unocss/eslint-plugin`，package.json 未声明、解析路径缺链接，`CI=true` 下 `ERR_MODULE_NOT_FOUND`；用户裁决跳过）、浏览器渲染与交互实测、真实接口联调、`build:test`。⑦**已知边界**：`h5UrlFromLinkDto` 不跟随 `type === 'NONE'` 清空（type 由 url 推导），故底部 Banner 若回显到「只填 H5」的历史数据，type=NONE 使输入框隐藏但值保留并提交；正常录入路径不会出现该组合（url 必填 + 切 NONE 同步清空）。 |
| 阶段3 批次4（清理+QR 3x+去媒体查询） | 用户三连指令 + 批次3 产物 | 已修正后通过（含浏览器实测） | ①ESLint 4 文件 exit=0；133 目录 @media 残留 0；vue-tsc 基线 4 存量零新增；②probe：mobile 卡 259、ratio 0.5、标题 22 单行、peek 58/58；desktop 1280 全宽无版心、peek 380/380 对称；QR naturalWidth 360（3x）display 110；NO CONSOLE ERRORS；③留言区截图 `.temp/req133-inquiry-qr.png` 确认新二维码与单列表单渲染正确 |
| 阶段3 批次5（ChannelNews 分组轮播重构） | 用户重申需求 + 水平/默认间隔/尾组不占位/固定高确认 + 删除授权 | 通过（含浏览器实测） | ①DOM：slideCount 2、rowsPerSlide [3,2]、emptyRows 0、swiperH 304 固定、flexDir row（水平）；②autoplay：t0 transform 0 → t1 -375 换组，t2 circular 循环重排 [2,3]；③ESLint exit=0（prettier --fix 后复跑 probe 一致）；vue-tsc 基线 4 零新增；NO CONSOLE ERRORS；④截图 `.temp/req133-news-carousel.png` |
| 阶段3 批次6（截断统一 nut-ellipsis） | 用户统一组件指令 + nut-ellipsis props 类型实读 | 通过（含浏览器实测） | ①6 节点替换、自实现截断样式注释废弃；②probe：agentName h22 / catChild h17 / catGroupName h22 单行、agentDesc h34 / newsTitle h40 两行，文本均以「...」收尾；③ESLint exit=0；vue-tsc 基线 4；NO CONSOLE ERRORS；④IMAGE 模式 image-name 无 mock 覆盖待收口补验 |
| 阶段3 批次7（资讯指示器 12×3/3×3） | 用户尺寸指令 + 附图像素采样 | 已修正后通过（含浏览器实测） | ①probe：t0 [12×3 active radius2px #5653f8, 3×3 50% #ccc] → t1 active 移第 2 点；②IDE 保存冲突致 `<vieww>` 损坏行修回 `</view>`（用户报障授权）；`_group` 清 TS6133；③ESLint exit=0；vue-tsc 回基线 4；NO CONSOLE ERRORS；④截图 `.temp/req133-news-dots.png` |
| R6 文档更新（阶段0/1/2 + state，2026-11-24） | 更新版原始需求（2026-11-24 版）+ 用户范围重申 + `wds/wds-admin-web` 实读源码（基线同 Part A） | 通过（文档层，Part A 新工作项待用户 check） | ①阶段0 v1.4：R6 补充段 + E 节 R-032/R-033 + U-016 新增 + 8.5 验证清单；②阶段1 v1.3：第十一章现状实读（latest `DISPLAY_COUNT_FIXED=10` / recommended `displayRows` 默认 2、2~99、DTO `line_count` mapper L633/L653 / suffix・后缀 grep 零命中，均附文件行号）；③阶段2 v1.6：第 11 节方案 + C-B1~C-B4 契约清单 + 追踪矩阵 / 未决项 / R6 验证闭环；④本轮纯文档更新，两仓零代码改动，lint/type-check 不适用；⑤未验证项：R-032/R-033 未编码，行数范围/默认值（U-016）、后缀契约、埋点归属（U-012）均待确认 |
| **R-032 编码执行（latest 行数配置，2026-11-24）** | 阶段2 第 11 节（用户 check 通过）+ 三项裁决（U-016 PRD 口径先行/U-012 不接手/授权编码）+ 基线 worktree `f12a0589` | **通过（仅静态层）** | ①范围：R-032 净增改动 6 文件（latest constants/types/index/validate + api-types/config-mapper，后两者与 h5Url 叠加），工作区合计 39 文件全 unstaged 无 untracked；recommended 参数 / readonly / 详情链路 / submit 零改动。②type-check：`./node_modules/.bin/vue-tsc --noEmit -p tsconfig.app.json` 170 条，与 Part A p5 日志去行号归一化 diff exit=0，**零新增**（`.temp/tc-req133-r632.log`）。③stylelint：latest index.vue 3 warning，与 worktree 基线归一化 diff exit=0，**零新增**（`.temp/sl-req133-r632{,-base}.log`）。④断言 18 项全通过（`.temp/req133-r632-assert.mts`，esbuild 打包真实执行）：clamp 边界（含 null→下限 1 与 recommended 同行为）、normalize 不再强制 displayCount、toApi 下发 line_count 且无 display_count 键、历史 display_count 兼容回显、往返行数不丢、validate 原行为不变、recommended 2~99 回归。⑤修正记录：断言脚本初版误设 clamp(null)=2，实测 Number(null)=0 收口下限 1 与 recommended 既有行为一致，修正断言而非代码。⑥未执行：ESLint（用户裁决跳过）、浏览器实测、真实接口联调（C-B1 字段名待后端）、build:test。 |
| R7 文档更新（阶段0/1/2 + state，2026-11-24） | 功能清单与团队技术方案 2026-11-24 更新版 + 用户「正向输出即可」指令 | 通过（文档层） | ①阶段0 v1.5：R7 补充段 + 分工重划 + F 节 R-034/R-035 + U-017/U-018 新增 + U-001/U-003 归属修正 + U-006/U-010 重开；②阶段1 v1.4：移出项留档（3.1/3.2/3.3）+ 差距矩阵 / U 表 / 改动清单同步，代码事实结论沿用既有实读证据未重读代码；③阶段2 v1.7：第 1/2/4/6/7 节 + 追踪矩阵 + R7 验证闭环；④本轮纯文档更新，两仓零代码改动，lint/type-check 不适用；⑤范围核验：已完成 Part A 39 文件与 Part B 批次1~7 均不涉及移出项，零代码回退；⑥未验证项：R-034 待 U-017 桥接契约、R-035 待 U-018 业务确认、域名两候选待 U-010、Android 两候选待 U-006 |
| APP 契约证据补充 + R-034 编码（2026-11-24） | 用户提供 APP 容器文档 + APP 仓库代码实读 + 用户「1、2 都处理」授权 | 通过（静态层 + 行为断言） | ①U-017 部分闭环：navigate handler / `wdsheng://open/es/employer/service/<id>`（id int）/ 失败行为代码实证；②scheme 印证一致（团队方案 `wlyd://` 失配残留登记）；③U-010 白名单硬约束、U-013 pageReady 时机落四份文档；④阶段0 v1.6 / 阶段1 v1.5 / 阶段2 v1.8 / state v1.6 同步；⑤R-034 落地 2 文件：ESLint/Prettier exit=0、vue-tsc 零新增（4 条基线）、断言 9/9 PASS；⑥未执行：两 build 脚本（Node 环境）、真机容器实测、真实接口联调；⑦剩余待确认：productId↔id 映射、employer 角色、APP 版本兼容（客户端）；R-035 仍待 U-018 零改动 |
| 阶段3 产物补建（2026-11-24） | SKILL.md 阶段产物命名规则（`阶段<序号>-<产物类型>-<需求编号>.md`）+ REQ-132 判例（阶段内容内联 state 不满足工作流要求）+ 用户确认 | 通过（文档层） | ①新建 `阶段3-实施记录-REQ-133.md` v1.0：双轨基线/授权依据、Part B 批次1~7+R-034、Part A h5Url+R-032、验证闭环汇总（含未执行项）、漂移与范围外改动说明、遗留项与收口待办；②state 阶段进度双轨两行回链 + 文件树登记 + 本行；③内容全部提取自 state 既有批次记录与验证闭环，未新增未验证结论；④本轮零代码改动，lint/type-check 不适用 |

- 阶段 1 检查范围：文件存在性、当前逻辑、依赖关系、公共组件契约、接口契约、双端能力、APP 容器桥接、知识库覆盖度、横向页面关联、脚本可用性。
- 知识库检索：INDEX.md → L1 README（缺失）→ L2 九份索引 → L4 368 个逐文件详情 → maps 目录树；`.sync-state.json` 锚点与 dev HEAD 一致，`git diff --stat` 为空。L1 断链按「先确认再改库」未擅自修改。
- 验证状态：**批次7 已修正后通过（静态层 + 浏览器实测）**；weapp 端渲染与生产构建证据待收口补。
- 是否允许进入下一阶段：**否**（阶段3 收口待 mock 清理 + 真实接口联调 + weapp/构建证据）。

## 已处理文件

仓库 `wds/wds-miniapp`，分支 `F-REQ-133`；~~@ `a0f347d`，全部未提交（unstaged + untracked）~~（2026-11-24 复核：HEAD 已漂移至 `7f096af`（fix(order) 提交，非本需求），工作区出现 staged + unstaged 混合状态及新增改动，见下方漂移记录）：

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

**2026-11-24 基线漂移记录（本轮文档更新时 git 复核发现，未触碰任何代码）**：

- HEAD 由 `a0f347d` 漂移至 `7f096af`（`fix(order): 修复搜索态取消订单快照过期及取消后详情无法下拉刷新问题`，非本需求提交）；上表批次 1~3 的 20 文件仍在，但部分已 staged（`A`/`M`）且叠加新 unstaged 改动（`AM`/`MM`），非本人本轮所为，不覆盖不回退。
- 新增未跟踪资源 12 个：`src/assets/category-channel/` 下类目图标 svg×10、`customer_service_wechat_qr.png`、`ic_expand_dark.svg`；已跟踪新增 `icon_right_outlined.svg`（staged）——频道页 UI 资源，归属待确认（疑似其他会话/用户补充）。
- REQ-133 清单外改动 3 处：`src/types/home.ts` + `src/utils/service-plan-display.ts`（频道页折扣话术 `displayText` 直传，语义属频道页但不在原 20 文件清单）、`types/components.d.ts`（staged，自动生成登记 AppOpenBanner）。
- **待办**：Part B 收口/阶段4 审查前需与用户确认上述漂移归属，并重核受检基线；本轮 Part A 文档更新不受影响。

## 本需求文件树

核对日期 2026-11-24（R4）；仓库：需求工作区（`.md/需求/进行中/REQ-133/`，独立仓库）、`wds/wds-miniapp`（`F-REQ-133`，~~@ `a0f347d`，20 个文件未提交~~ HEAD 已漂移至 `7f096af`，staged+unstaged 混合，含新增资源与清单外改动，见「已处理文件」漂移记录，Part B）、`wds/wds-admin-web`（`F-REQ-133` @ `f12a0589`，~~工作区干净，Part A 待 check 后编码~~ 阶段3 已落地 38 文件均 unstaged，Part A）、`wds/wds-web-channel`（HEAD `7fc0967`，干净）、`wds/es-app-main`（只读参考）；本轮代码改动文件数 **Part A 38**（Part B 存量改动 20+ 文件见漂移记录，本轮未触碰）。

```text
.md/需求/进行中/REQ-133/
├── 原始需求/
│   ├── REQ-133 二级频道适配APP端_H5浏览器.md  [输入] 需求原文，602 行，未改动
│   └── 图片和附件/  [输入] 60 余张现状与设计稿截图，未改动
├── REQ-133 二级频道页二次优化-功能清单/  [团队输入] 功能清单.md + 图片和附件（2026-11-24 更新版，R7 分工重划依据）
├── REQ-133 二级频道页二次优化-技术方案.md  [团队输入] 18 章迁移方案（2026-11-24 更新版，R7 依据：域名废弃划线、微信开发者工具回归划掉）
├── 阶段2-技术方案-REQ-133.md  [正式产物] v1.8；Part B 方案 + 第 10 节 Part A h5Url + 第 11 节行数配置 + R7 分工/契约更新 + APP 契约证据补充（R-034 实现口径）
├── 阶段0-需求文档-REQ-133.md  [正式文档] v1.6；规则（含 R-028~R-035）、合作分工（R7 重划）、待确认（含 U-017/U-018）、验证与风险 + APP 契约证据补充段
├── 阶段1-代码分析-REQ-133.md  [正式文档] v1.5；方案核查、差距矩阵 + 第十章 Part A + 第十一章配置扩展 + R7 移出留档 + APP 契约证据注记
├── 阶段3-实施记录-REQ-133.md  [正式产物] v1.0（2026-11-24 补建）；双轨基线与授权、Part B 批次1~7+R-034、Part A h5Url+R-032、验证闭环汇总、漂移与范围外说明、遗留项
└── workflow-state.md  [状态文件] 阶段进度、验证闭环、不确定项追踪
```

```text
wds/wds-miniapp/  (F-REQ-133，HEAD 7f096af；原 20 文件 + 新增资源/清单外改动，staged+unstaged 混合，见漂移记录)
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
wds/wds-admin-web/  (F-REQ-133 @ f12a0589；Part A 阶段3 已落地，38 文件全部 unstaged，无 untracked；核对日期 2026-11-24)
└── src/
    ├── api/secondary-channel/
    │   ├── api-types.ts  [修改 +5] CategoryChannelJumpLinkDTO 加 h5Url?，附 C-A1~C-A3 待确认 TODO: wxj
    │   └── config-mapper.ts  [修改 +48/-16] 双向咽喉：jumpLinkToApi/moreLinkToApi 扩展 h5Url 入参、新增 h5UrlFromLinkDto、7 个模块 ToApi/ApiToModule 与顶底 Banner 回显全量透传
    └── pages/secondary-channel/form/modules/
        ├── components/
        │   ├── ChannelLinkField.vue  [修改 +33] 新增可选第二字段（h5Url/h5Prop/h5Label + update:h5Url），覆盖 4 个弹窗
        │   ├── ShowMoreConfig.vue  [修改 +31/-2] 新增「查看更多H5链接」输入（moreH5Url + h5LinkRules），覆盖 5 个模块
        │   └── link-validator.ts  [修改 +9] 新增 validateOptionalChannelLink（空值放过、有值才校），9 模块共用
        ├── agent-market/
        │   ├── types.ts  [修改 +6] AgentCardDTO.h5Url? + moreH5Url + defaults/normalize
        │   ├── index.vue  [修改 +6] showMoreH5Value + v-model:more-h5-url
        │   ├── validate.ts  [修改 +11/-1] 规则 5.1 条目 H5 + 6.1 查看更多 H5
        │   └── components/AgentEditDialog.vue  [修改 +4] form.h5Url + ChannelLinkField 绑定 + save payload
        ├── activity-zone/
        │   ├── types.ts  [修改 +7] ActivityBannerDTO.h5Url? + moreH5Url + normalize
        │   ├── index.vue  [修改 +6] 查看更多 H5 接线
        │   ├── validate.ts  [修改 +12/-1] 规则 6.1 活动 H5（带活动名）+ 7.1 查看更多 H5
        │   └── components/
        │       ├── ActivitySelectCard.vue  [修改 +32/-1] 内联：新增 H5 列与行内输入，grid 五列→六列（原列宽注释保留）；L207 存量 TODO 按裁决①原样保留
        │       └── ActivitySelectDialog.vue  [修改 +2/-1] 横向补漏（方案未列）：toEmitItem 保留 h5Url，否则弹窗确认后 H5 丢值
        ├── industry-news/
        │   ├── types.ts  [修改 +8/-2] ItemDTO.h5Url? + FormPayload 加 'h5Url' + moreH5Url
        │   ├── index.vue  [修改 +6] 查看更多 H5 接线
        │   ├── validate.ts  [修改 +11/-1] 规则 6.1 文章 H5 + 7.1 查看更多 H5
        │   └── components/ArticleEditDialog.vue  [修改 +4] form.h5Url + 绑定 + save
        ├── category-list/
        │   ├── types.ts  [修改 +3] CategoryImageItem.h5Url? + normalize
        │   ├── validate.ts  [修改 +9/-1] H5 选填：长度 + 格式（带类目名）
        │   └── components/CategoryImageItemDialog.vue  [修改 +4] form.h5Url + 绑定 + save（方案原写 3 弹窗，实为第 4 个）
        ├── footer/
        │   ├── types.ts  [修改 +2] FooterContentItem.h5Url?
        │   ├── validate.ts  [修改 +9] H5 选填：长度 + 格式
        │   └── components/FooterContentItemDialog.vue  [修改 +5] form.h5Url + 绑定 + save
        ├── top-banner/
        │   ├── types.ts  [修改 +2] TopBannerLink.h5Url?
        │   ├── submit.ts  [修改 +8/-2] 自拼 DTO：jumpLinkToApi 平行传 h5Url（原单参调用注释保留）
        │   ├── validate.ts  [修改 +5/-1] H5 选填格式；url 必填口径不变
        │   └── components/BannerEditModal.vue  [修改 +17/-1] 内联：linkH5Url 表单全链路（初始化/回显/校验/提交）
        ├── bottom-banner/
        │   ├── types.ts  [修改 +3/-1] BottomBannerLink.h5Url? + defaults
        │   ├── index.vue  [修改 +45/-6] 内联：H5 form-item 随 url 同显隐（裁决②）、切 NONE 同步清空、linkH5UrlValue/formModel/watch/rules
        │   ├── submit.ts  [修改 +8/-2] 平行传 h5Url；回退结构 { url: '' } 保持不变
        │   └── validate.ts  [修改 +5/-1] 规则 3.1 有跳转时 H5 选填格式
        ├── latest-services/
        │   ├── types.ts  [修改 +4] showMoreH5Url + defaults/normalize
        │   ├── index.vue  [修改 +6] 查看更多 H5 接线
        │   └── validate.ts  [修改 +5/-1] 开启查看更多且有值才校 H5
        └── recommended-services/
            ├── types.ts  [修改 +4] showMoreH5Url + defaults/normalize
            ├── index.vue  [修改 +6] 查看更多 H5 接线
            └── validate.ts  [修改 +5/-1] 开启查看更多且有值才校 H5
```

> **零改动确认**：`form/build-api-config.ts` 实读为壳（遍历 modules 调 `buildPayload`），无需改动；7 个模块 `submit.ts` 全部委托 `config-mapper`，p2 改 mapper 即已贯通，未重复改动；`agent-market`/`activity-zone`/`industry-news`/`category-list`/`footer` 无独立 `index.vue` 链接输入（走弹窗），故 index.vue 只改 5 个。

```text
wds/wds-web-channel/  (HEAD e78f076，工作区干净；本期零改动，仅作 DTO / 字段 / 模块顺序 / 视觉参考)
wds/es-app-main/      (只读；docs/integrations/h5/h5-bridge-api.md 给出容器标识与登录态传递)
```

## 阶段 3 允许改动文件

> 只列**王新骏负责**的条目；Part B 路径落在 `wds/wds-miniapp`；Part A 路径落在 `wds/wds-admin-web`（R4 已定位，下表第二部分，**待用户 check 文档后启用**）。合作方负责服务详情、留资页、独立三方下载页、流水线与H5域名。具体字段与分包归属按 U-004 / U-005 / U-007 定稿后收窄。

**Part B（`wds/wds-miniapp`）**

| 层次 | 路径 | 对应规则 / 待确认 |
|---|---|---|
| ~~修改~~ R7 移出（华春风） | `src/pages/supplier-detail/index.vue` | ~~R-007 / R-008；H5 适配、附件预览回归、按 U-001 挂载下载引导~~（R7：服务商详情划归华春风；本人仅保留 providerId 传参边界） |
| ~~修改~~ R7 移出（华春风） | `src/utils/employer-marketing-jump.ts` | ~~R-009；外链可信域校验，保留白名单与未知链接提示~~（R7：营销位跳转随 R-010 划归华春风） |
| 修改 | `src/config/endpoints.ts` | R-014 / U-005；频道接口与行数字段按 `/gateway` 前缀登记 |
| 新增 | `src/utils/category-channel-jump.ts` | R-009；8 类目标受控解析（R7：R-010 营销位移出后本文件为本人唯一跳转工具；R-034 app内跳原生分支落点随此，~~U-017 确认前 `TODO: wxj` 占位~~ 契约证据补充后已授权编码，仅 productId→id 映射占位） |
| 新增 | `src/utils/category-channel-url.ts` | R-016 / R-017 / U-010；公开地址与深链参数解析 |
| 新增 | `src/pages/category-channel/`、`src/components/AppOpenBanner/`、`src/utils/invoke-app.ts`（以阶段2实际架构核对后定稿） | 本人负责页面和顶部打开 APP；deep link `wdsheng://open/<encoded-path>`；Android/iOS商店地址见阶段2 |
| 新增 | `src/types/category-channel.ts` + mapper | R-014 / U-005；DTO → 页面模型，兼容缺省值 |
| 新增 | iPad / 桌面响应式公共容器样式 | R-012 / R-013；7 个验收尺寸 |
| 复用（不新建同类） | `src/components/ServiceCard`、`EsNavBar`、`EsEmptyState`、`EsListSkeleton` | 商品卡与页面基础件复用首页既有实现 |
| 复用（只读） | `src/utils/router.ts`、`src/store/auth.ts`、`src/services/employer-inquiry.ts` | R-002 / R-018；不新增登录门闩、不改留资接口 |
| 复用（回归） | `src/pages/supplier-mine/index.vue`、`src/pages/workbench/index.vue` | 下载引导组件的既有引用点 |

**明确排除**：`wds/wds-web-channel` 与 `wds/es-app-main` 整仓、埋点工具、现有请求基础策略及合作方负责的页面/流水线文件。~~运管后台文件待定位后补充。~~（R4 已定位，见下表）

**Part A（`wds/wds-admin-web`，R4 新增；~~待 check 后启用~~ 2026-11-24 用户 check 通过，已启用并完成；明细以阶段2 10.2 为准，实际落地以下表备注为准）**

| 层次 | 路径（仓内相对） | 对应规则 / 待确认 |
|---|---|---|
| 修改 | `src/api/secondary-channel/api-types.ts` | R-028 / R-029；DTO 加 h5Url，字段形态按 C-A1~C-A3 确认，未确认 `TODO: wxj` |
| 修改 | `src/api/secondary-channel/config-mapper.ts` | R-029；双向透传，断言自检 |
| 修改 | `src/pages/secondary-channel/form/modules/components/ChannelLinkField.vue`、`ShowMoreConfig.vue`、`link-validator.ts` | R-028；公共组件收敛 8 处，校验复用 |
| 修改 | ~~`form/modules/{top-banner,category-list,activity-zone,bottom-banner}` 内联输入 4 处~~ → 实为 **内联 3 处**：`top-banner/components/BannerEditModal.vue`、`bottom-banner/index.vue`、`activity-zone/components/ActivitySelectCard.vue`（category-list 走 `CategoryImageItemDialog` 弹窗，已由 ChannelLinkField 覆盖） | R-028；活动专区存量 TODO（4.13 #16）按用户裁决①**保留不动** |
| 修改 | 涉及 9 模块各自 `types.ts` / `index.vue` / `submit.ts` / `validate.ts`（实际：types ×9、validate ×9、index ×5、submit ×2） | R-029；h5Url 平行字段贯通，有值才校 |
| 修改（方案未列，横向补漏） | `activity-zone/components/ActivitySelectDialog.vue` | R-029；`toEmitItem` 不保留 h5Url 则弹窗确认后丢值，属必需改动 |
| 修改（R6 R-032，2026-11-24 用户 check 通过并裁决后启用） | `form/modules/latest-services/{constants,types,index.vue,validate}.ts` + `api/secondary-channel/{api-types,config-mapper}.ts`（后两者与 h5Url 改动同文件叠加） | R-032；latest 固定 10 改行数 1~10（默认暂定 2，`TODO: wxj` U-016/C-B4）；DTO `line_count` 暂定名 `TODO: wxj` C-B1/C-B2；`display_count` 兼容读取不再写入（C-B3）；recommended 参数零改动（待产品评审）；readonly/详情链路沿用 R-030 排除零改动 |
| 零改动（已核实） | `form/build-api-config.ts` | 实读为壳，遍历 modules 调 `buildPayload`，无需改动 |
| 零改动（已核实） | 7 个模块 `submit.ts`（agent-market / activity-zone / industry-news / category-list / footer / latest-services / recommended-services） | 全部委托 `config-mapper`，mapper 改完即贯通 |

**Part A 明确排除**：详情/只读链路（`detail-config.mapper.ts`、`components/detail/*`、各模块 `readonly.vue`，R-030 暂定）；模块外 3 处（`activity/secondary-page-config`、`marketing-position/material/MaterialJumpFields`、`global-config/workbench`）；list/audit 列表页。

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
| U-001 | 服务商详情是否弹下载引导：功能清单 L18 要加、技术方案第九章写默认不弹 | 待确认（阻塞组件落点） | 产品 / UI | ~~本人~~ 华春风（R7 移交，本人消费其结论） | 阶段3 |
| U-002 | 下载引导形态：**R3 部分确认——顶部常驻「打开 APP」指引条设计稿已提供（`175975-30231`，R-027）**；登录成功后一次性弹层是否保留、与顶部条关系仍待裁决 | 部分确认 | 产品 / UI | 共同 | 阶段3 |
| U-003 | APP 新版 WebView 容器与配置跳转权限；容器标识按桥接文档落地 | 待确认 | 客户端 / 前端 | ~~本人~~ 华春风（R7 移交，app端跳转h5；本人消费其结论） | 阶段3 |
| U-004 | ~~新增H5跳转链接已确定由本人负责；后台仓、字段/API契约及与PC字段关系待定位~~（R4 收窄）：后台仓已定位 `wds-admin-web`，字段口径已确认（h5Url 暂定/非必填/12 处全量）；**仅剩 DTO 层字段形态待后端书面确认（阶段2 10.4 C-A1~C-A5）**，不阻塞编码，阻塞联调收口 | 部分确认 | 后端 / 运管后台 | 本人 | Part A 阶段3 联调 |
| U-005 | 接口契约四件套：复用许可、`/gateway` 前缀、旧参数行为、行数字段落点与默认值。**R6 补充：推荐 `line_count` 已有代码事实；latest 需新增行数字段（现 DTO 仅 `display_count` 数量语义），字段名/层级/默认值待后端书面确认（阶段2 11.4 C-B1~C-B4）** | 待确认（未确认前 `TODO: wxj`） | 后端 / 运管后台 | 本人 | 阶段2、阶段3、Part A 扩展 |
| U-006 | Android/iOS 商店地址及 `wdsheng://open/<path>` scheme 已提供；频道 path 来源和唤起失败回退策略待确认。**R7 部分重开**：Android 新增应用宝候选 `microdown.yyb.qq.com/o/simple.jsp?pkgname=com.wlit.esp`，原 `a.app.qq.com` 标待确认（同 pkgname 两候选，确认前沿用原地址） | 部分确认（R7 部分重开） | 产品 / 前端 / 客户端 | 本人 | 阶段2、阶段3 |
| U-007 | 频道新页面主体已转本人负责；主包/分包注册方式按目标仓约定确定 | 待确认 | 前端 | 本人 | 阶段2、阶段3 |
| U-008 | 设计稿缺口：**R3 部分确认——移动端 H5 整页（`175570-262826`）与顶部打开 APP（`175975-30231`）已提供**；iPad 断点、服务商详情 H5、后台配置交互稿、section 直链仍缺 | 部分确认 | 设计 | 共同 | 阶段3、阶段5 |
| U-009 | yeeda 技能库六端软链全断，`AGENTS.md` 要求编码前必读 | 待确认（阶段 3 硬前置） | 开发 / 用户 | 本人 | 阶段3 前 |
| U-010 | ~~H5 生产域名 `channel.wdsheng.com`~~（R7：技术方案划线废弃，「产品业务重新确认h5对应域名」）；新候选 `m.wdsheng.com`（功能清单域名段）与 `h5.wdsheng.com`（运维段，接口走 `h5.wdsheng.com/xx/gateway` 转发四环境）不一致；网关回源、历史深链与流水线待确认。**契约证据补充（2026-11-24）：最终域名必须 `*.wdsheng.com` 子域（APP 容器白名单 + Cookie 注入域，硬约束）** | 待确认（R7 重开，华春风跟进域名确认，本人依赖） | 产品 / 运维 / 合作方 | 合作方 | 阶段3、阶段6 |
| U-011 | ~~访问后缀配置与带后缀链接是否仍保留（最新两篇未涉及）~~（R6 复活）：新 PRD 明确后缀管理与带后缀链接生成，按用户范围声明纳入 Part A（R-033）；**剩余**：接口契约、交互稿、后缀与 slug 的 URL 组合规则缺失（后台 grep 零命中）；契约与交互稿确认前不启动编码 | 待确认（R6 重写） | 产品 / 后端 / 设计 | 本人（运管配置侧） | Part A 扩展 |
| U-012 | ~~技术方案中残留的埋点条目与 `category-channel-tracking.ts` 不进入本期改动清单~~（R6 复活）：新 PRD 含按后缀维度埋点（PV/UV、导流访问量，6 事件规格 @王宇轩）；~~用户侧实现归属待裁决~~ **2026-11-24 用户裁决：不接手**（APlus 属 `wds-web`，本人基座 `wds-miniapp`），R-019 维持有效 | 已裁决（不接手） | 用户 / 产品 | 共同 | 阶段3、Part B 不新增埋点层 |
| U-013 | 已确认 Cookie-only 读取 `Authorization` / `ct`，忽略 localStorage；APP 直用页面清单、Cookie 域/path/属性及缺失/过期/登出处理待确认。**契约证据补充（2026-11-24）：APP 打开 H5 前写 Cookie 到目标 origin（path `/`），加载后写同源 localStorage 并发 `pageReady`（`flutterMessage`）——可以 pageReady 为读取时机信号；未登录不注入** | 部分确认 | 产品 / 客户端 / 前端 | 本人（客户端依赖） | 阶段2、阶段3、阶段5 |
| U-014 | 类目区 2 个类目时布局：标注只覆盖 1 个（等比填充）与 ≥3 个（固定宽横滑）；建议 2 个时同 1 个口径，待设计确认 | 待确认 | 设计 / 产品 | 本人 | 阶段3 |
| U-015 | 顶部指引条展示范围：APP 内 / weapp 是否隐藏、是否可关闭；建议仅 H5 浏览器展示、不可关闭，待产品确认 | 待确认 | 产品 / UI | 本人 | 阶段3 |
| U-016 | 行数范围与默认值口径冲突（R6 新增）：PRD 建议 1~10 行、默认待评审 vs 存量推荐 2~99、默认 2（且必配至少 10 个服务的选品下限联动）；latest 固定 10 改行数后选品/校验联动未定义。**2026-11-24 用户部分裁决：latest 按 1~10 先行 + `TODO: wxj` 占位；recommended 参数不动待产品评审** | 部分裁决（余待产品评审） | 产品 / 后端 | 本人 | Part A 扩展（R-032） |
| U-017（R7 新增） | ~~R-034 app内服务详情跳原生桥接契约：具体 handler 名（`WLYDBridge` / `webview_ultra.callHandler`）、原生路由标识、productId 参数映射、失败降级行为；桥接文档未覆盖，miniapp 内三标识零命中~~ **部分闭环（2026-11-24 APP 契约证据）**：navigate handler、`wdsheng://open/es/employer/service/<id>`（id int）、失败 reject/`{ok:false}` 已代码实证；剩余 productId↔id 主键映射、employer 角色匹配、APP 版本兼容 | 部分确认（已授权编码，映射处 `TODO: wxj` 占位，失败降级浏览器路径） | 客户端 | 本人 | 阶段3（R-034） |
| U-018（R7 新增） | R-035 留资表单末尾内联：功能清单标「按 web 类似追加到二级频道末尾（11月23日修正，待业务确认）」；内联形态是否采纳、字段与 web 版 `DemandLeaveMessageCard` 差异；批次2 ChannelInquiry 方向已一致 | 待确认（确认前现实现零改动） | 业务 / 产品 | 本人 | 阶段3（R-035） |

## 备注

- **Part A 门禁环境阻塞与假绿陷阱（2026-11-24 首次发现，后续阶段勿重踩）**：
  - `pnpm type-check` / `pnpm lint` / `pnpm stylelint` 均报 `ERR_PNPM_VERIFY_DEPS_BEFORE_RUN`（node_modules 与 lockfile 不同步，重装会丢 `pnpm.overrides`）→ **直调 `./node_modules/.bin/<tool>`**，不跑 pnpm 包装层。
  - **`type-check` script 本身是假绿**：`vue-tsc --noEmit -p tsconfig.json` 秒回 exit=0 且零输出，因为根 `tsconfig.json` 是 solution-style（`files: []` + `references`），**一个文件都没检**。必须 `-p tsconfig.app.json`（真实结果 exit=2 / 170 条存量）。
  - **零新增基线法**：`git worktree add .temp/req133-base-admin f12a0589` + symlink node_modules；worktree 内缺 vite 生成物 `types/auto-imports.d.ts`、`types/components.d.ts`（gitignore）会多出 115 条 `Cannot find name 'computed'` 类假错误，**从主仓拷这两个文件后基线才收敛到 170 条**。
  - **ESLint 不可用**：`@antfu/eslint-config` 交互式提示安装 `@unocss/eslint-plugin` 导致进程挂起（需 kill）；`CI=true` 下报 `ERR_MODULE_NOT_FOUND`。核查：`package.json` 未声明该包，`pnpm-lock.yaml` 有记录，`.pnpm` 虚拟仓内存在但解析路径缺链接。**用户 2026-11-24 裁决：跳过 lint，仅 type-check**；本轮 Part A 的 ESLint **未执行**，不得标通过。修依赖需单独授权（会动 lockfile）。
  - zsh 不做 word splitting：多文件传参需 `xargs`，`$FILES` 直传会被当成单个超长文件名（ENAMETOOLONG）；stylelint `--config` 按 cwd 解析，跑基线需 `cd` 到 worktree 目录。
- **Part A 字段命名与边界口径（2026-11-24）**：条目级统一 `h5Url`；查看更多在 agent-market / activity-zone / industry-news 为 `moreH5Url`，在 latest-services / recommended-services 为 `showMoreH5Url`（沿用各模块已有 `moreLink` / `showMoreLink` 命名，不强行统一）。DTO 层 `h5Url` 为暂定名，若后端定为 `h5_url` 只需改 `api-types.ts` 字段名 + `config-mapper` 映射，模块层命名不动。`h5UrlFromLinkDto` 有意不跟随 `type === 'NONE'` 清空（type 由 url 推导，否则只填 H5 的数据回显丢值）。
- **R4 Part A 基线与规范（2026-11-24）**：`wds/wds-admin-web` `F-REQ-133` @ `f12a0589`，工作区干净；属企服线 Vue 3 + TS + Vite 6 + Element Plus，按仓内 `AGENTS.md` 执行，不套用物流线规范；验证命令 `pnpm lint` / `pnpm type-check` / `pnpm stylelint`（scripts 已核实存在）。知识库 `.repoWiki/kb/wds-admin-web/` 已有 secondary-channel L2/L4 条目，点位结论以实读源码为准。Part A 编码前置：用户 check 阶段2 第 10 节；活动专区存量 TODO（4.13 #16）需先收口。
- **R3 设计基线（2026-11-23）**：顶部指引条结构经 figmingo 实取（375×60，logo + 分隔线 + slogan + `#5653f8` 按钮）；整页节点 `175570-262826` 拉取超时且 whoami 显示 total429=2 处于限流窗口，已按经验停止调用；模块级规则以用户标注截图为准，逐模块样式细节留待阶段 3 串行提取。详见阶段2 第 9 节。
- 规范隔离：目标项目属企服线，按 `wds/wds-miniapp/AGENTS.md` 自身规范执行（Taro + Vue3 + TS），不套用 WLYD 物流线的 uni-app / Vue2 / `rpx` / `/deep/` 规范；验证命令为 `pnpm type-check` + `pnpm lint` + `pnpm build:h5:test` + `pnpm build:weapp:test`。
- 目标项目当前分支 `dev`（HEAD `533201f`），工作区干净；本阶段零代码改动，~~该仓是本期唯一改动仓库~~（R4：双基座，Part A 另落 `wds/wds-admin-web`，见需求信息与文件树）。
- 团队技术方案点名的 7 个新增路径全部不存在、5 个复用路径全部存在；四个验收脚本在 `package.json` 中真实存在，无需新增脚本。
- `AppDownloadGuidePopup` 组件已存在（2 处引用），缺的是频道 / 详情链路与 H5 下载地址配置；`openEmployerMarketingTarget` 已有白名单与未知链接提示，缺的是可信域校验。
- APP 容器口径参考 `wds/es-app-main/docs/integrations/h5/h5-bridge-api.md`（容器标识 + Cookie 登录态）；本需求只采用 Cookie，忽略 localStorage；miniapp 内三个标识零命中，识别失败降级普通 H5。功能清单所引 `h5-integration-guide.md` 在 `feature_2611_lichentao` 分支，本地 master 无此文件。
- PC 参考源：`wds/wds-web-channel` HEAD `e78f076`，工作区干净；`index.vue` 使用 `resolveChannelModules` / `renderedModules` 配置驱动编排，`channel-modules.ts` 已纳入版本管理，动态实例字段带 `TODO: wxj [REQ-045/161]`。本期该仓零改动，模块顺序与字段口径可作参考，`instances` / `sort_weight` 不写进本期稳定字段设计。
- 知识库：已接入 —— `kb/wds-miniapp/` 368 个条目、`maps/wds-miniapp-tree.md` 1782 行、锚点 `533201f` 与 HEAD 一致；但 L1 `README.md` 缺失导致 INDEX 链接断链，L4 多为脚本生成骨架，业务逻辑仍须实读源码。按「先确认再改库」未改知识库。
- H5 能力：配置完整（dev proxy / publicPath / output / 凭据拦截器 / cookie jar / 60+ 处 `IS_H5`），`dist/h5` 空目录仅表示尚未构建；~~`channel.wdsheng.com`~~ 项目内零命中（R7：该域名被技术方案划线废弃，候选 `m.wdsheng.com` / `h5.wdsheng.com` 待确认 U-010），部署口径由合作方给值。
- 阶段 3 前须先解决 U-009（yeeda 技能库软链），并收敛 U-001 / U-002 / U-004 / U-005，否则不满足编码前置。（R4 注：此条针对 Part B；Part A 的 U-004 已收窄为不阻塞编码，前置为用户 check 文档 + 活动专区存量 TODO 收口）
- 阶段 3 入口状态：等待用户明确编码指令；当前禁止业务代码改动。按工作流规则，阶段 3 出口若仍有待确认项将再次强制暂停。（R4：Part A 额外要求文档 check 通过；Part B 状态不变）

---

**文档版本**: v1.7
**最后更新**: 2026年11月
**整理人**: 王新骏
