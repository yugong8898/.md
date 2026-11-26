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

**Part A 审查确认（2026-11-25，h5Url + R-032 合并审查）**：39 staged 文件全在 secondary-channel 域、无 untracked、TODO 全 `TODO: wxj` 合规；h5Url 41 项断言重跑全通过。审查发现的两处只读层连带影响**经原始需求 + 既有裁决确认属排除域，降级为已知限制，零代码改动**：①详情页「展示数量」读 DTO `display_count`，R-032 停写后新配置显示「—」（`detail-config.mapper.ts` L273-283）；②latest `readonly.vue` L25 `getSortAndCountLabel()` 恒显「固定展示10个」不随行数。确认依据：原始 PRD 行数章节（规则4 / 配置生效链路）只要求后台组件配置 + 用户侧按行数渲染，未涉及后台配置详情/只读页展示口径（PRD 中「详情页」均指用户侧服务/服务商详情）；R-030 明文「详情链路（detail-config.mapper.ts / detail 组件 / 各模块 readonly.vue）本期零改动」；R-032 裁决「只读层沿用 R-030 排除不动」。另注：实施记录「常量保留供详情链路兼容读取」表述对详情链路不成立（详情读 DTO 非常量），仅 readonly.vue 消费常量函数；如后续要求详情页展示行数，属范围变更需另行裁决。R-032 的 18 项断言脚本与门禁日志已按用户授权清理，结论以实施记录为准，不可重跑。

**R-032 编码执行（2026-11-24，裁决后同日落地，静态层）**：latest-services 固定 10 个改行数控制，6 文件改动（`constants.ts` 新增行数常量 1~10/默认暂定 2 + 旧固定策略注释废弃保留供 readonly/详情兼容；`types.ts` 新增 `displayRows` + `clampLatestServiceRows`，`displayCount` 改兼容读取；`index.vue` 固定预设 select 注释保留、新增 el-input-number 行数输入沿用 recommended draft/commit 模式；`validate.ts` 整数+范围校验；`api-types.ts` DTO 新增 `line_count` 暂定名 `TODO: wxj` C-B1/C-B2；`config-mapper.ts` 双向透传行数、`display_count` 不再写入仅兼容读取 C-B3）。recommended-services 参数零改动（U-016 余量待产品评审）；readonly/详情链路沿用 R-030 排除零改动；submit 委托 mapper 无需改。门禁：vue-tsc 170 条与 Part A 基线归一化 diff exit=0 零新增；stylelint latest index.vue 3 warning 与 worktree 基线一致零新增；断言 18 项全通过（clamp 边界/normalize/toApi 不下发 display_count/回显兼容/往返不丢/validate 原行为/recommended 回归）。ESLint 按用户裁决跳过；浏览器实测与真实接口联调未做（C-B1 字段名待后端）。工作区 39 文件全部 unstaged、无 untracked。

**R7 文档同步（2026-11-24，本轮，纯文档零代码改动）**：功能清单与团队技术方案更新后按用户「工作流的文档正向输出即可」同步正向阶段产物：阶段0 v1.5（R7 补充段 + 分工表重划 + F 节 R-034/R-035 + U-001/U-003 归属修正 / U-006・U-010 重开 / U-017・U-018 新增 + 验证清单与风险表更新）、阶段1 v1.4（R7 补充段 + 3.1/3.2/3.3 移出留档 + 核查表 #7/#9/#11/#13/#14 注记 + 差距矩阵补 R-034/R-035 + U 表同步 + 7.2/7.3 改动清单收敛）、阶段2 v1.7（R7 补充段 + 第 1/2/4/6/7 节更新 + 追踪矩阵补 R-034/R-035 + R7 验证闭环）、本 state v1.5。**关键判断**：①登录链路移出与用户 2026-11-23 口头指令（Part B 历史记录②）一致，本轮借功能清单正式收口，消除分工表旧「✅ 跟踪」矛盾；②已完成 Part A 39 文件与 Part B 批次1~7 均不涉及移出项，**零代码回退**；③R-035 与批次2 ChannelInquiry 已实现方向一致，只登记 U-018 待业务确认，不开编码任务；④R-034 桥接契约缺失（U-017），确认前 `TODO: wxj` 占位不预设实现。**待确认**：U-017（客户端）、U-018（业务）、U-010 域名两候选（华春风跟进）、U-006 Android 两候选（确认前沿用原地址）。

**APP 契约证据补充 + R-034 编码启动（2026-11-24，本轮）**：用户提供 APP 容器两份文档后实读 APP 仓库代码（`universal_route_config.dart` / `app_deep_link_parser.dart` / `employer_routes.dart` / `push_page_code_registry.dart` / `webview_ultra_native_bridge.dart`），U-017 部分闭环（navigate handler + 原生路由 + 失败行为），剩余 productId↔id 主键映射、employer 角色匹配、APP 版本兼容 3 项；scheme 与 R2 口径印证一致；U-010 补白名单硬约束、U-013 补 pageReady 时机。用户确认「1、2 都处理」：①四份文档同步（阶段0 v1.6 / 阶段1 v1.5 / 阶段2 v1.8 / 本 state v1.6）；②R-034 编码启动——H5 特性检测 `window.webview_ultra?.callHandler` + navigate 跳 `wdsheng://open/es/employer/service/<id>` + try/catch 降级浏览器路径，weapp 不注册，productId→id 默认同名直传 + `TODO: wxj` 占位。R-035 仍待 U-018，零改动。

**R-034 编码执行（2026-11-24，静态层 + 行为断言）**：2 文件改动——`src/utils/category-channel-jump.ts` 新增 `openServiceDetail(productId)`（IS_H5 + `webview_ultra.callHandler` 特性检测、数字 id 守卫、`callHandler('native', {method:'navigate', data:'wdsheng://open/es/employer/service/<id>'})`、`ok:false`/reject 降级 `navigateTo(Routes.serviceDetail)`，productId 映射 `TODO: wxj` 占位），`openChannelTarget` 服务详情分支改走该函数（旧直跳注释保留）；`src/pages/category-channel/index.vue` `handleSelectProduct` 改走 `openServiceDetail`（旧直跳注释保留，三处 ChannelProducts 共用此单点）。门禁：两文件 ESLint exit=0、Prettier exit=0；vue-tsc 4 条与既有基线一致（h5-dev-proxy + agent-chat×3）**零新增**（`.temp/tc-req133-r034.log`）；行为断言 9 项全通过（`.temp/req133-r034-assert.mjs`，esbuild 打包真实源码 + stub env/router/toast）：无桥降级/桥成功仅 native/ok:false 降级/reject 降级/非数字 id 直跳 H5/weapp 不触桥/配置链接容器内 native/配置链接浏览器回归/未知外链不跳转。未执行：`build:h5:test` / `build:weapp:test`（Node 环境约束沿用批次记录）、真机 APP 容器实测（需线上包含 navigate bridge 的版本）、真实接口联调。其余消费点（`EmployerServiceList` / `EmployerPublicReviewCard`）不在频道页范围，零改动。

**批次 8（2026-11-24，类目区组件拆分，用户确认方案 A +「先拆分组件吧 具体的UI再说」）**：3 文件——`ChannelCategories.vue` 薄壳化（306→60 行：白卡 panel + isImageMode 分发 + 事件透传，对外 props/emits 契约不变）；新增 `ChannelCategoryCards.vue`（STANDARD：icon 映射 / 渐变背景 / 子类目截断 / selectCategory 原样搬移）；新增 `ChannelCategoryImages.vue`（IMAGE：≤2 等分 / ≥3 横滑两分支 + selectLink 原样搬移，U-014 待确认注释保留）。BEM 类名不变保证视觉零差异；共用 `__scroll` 留壳内单一定义点；消费方 `index.vue` 零改动。**UI 规格修正挂起**（IMAGE 图 120×90 / 间距 8、STANDARD 按 Figma `175570-264657`，设计稿获取受阻：figmingo 本会话未注册 + IDE Browser 视图未打开）。门禁：ESLint 3 文件 exit=0、Prettier exit=0；vue-tsc 4 条基线**零新增**（`.temp/tc-req133-split.log`）；probe 双模式回归通过（`.temp/req133-split-probe.cjs`）：STANDARD 4 卡宽 168 / 渐变 / 子类目 ≤4 / tap→service-hall，IMAGE 4 固定卡宽 140 / 比例 0.563 / 名称条 4 / tap→service-hall，NO CONSOLE ERRORS；截图 `.temp/req133-split-{standard,image}.png`。iconCount=0 系 mock 类目名未命中切图映射（既有行为非回归）。未执行：weapp 端渲染、build。

**批次 9（2026-11-24，类目区三档布局 + 滑动出血 + 图片固定尺寸，用户截图验收口径 +「ok 不用注释保留 直接改吧」授权本批免注释保留）**：3 文件——壳加 `isScrollTier`（当前模式 items ≥3）→ panel `--scroll`（白底铺满屏宽、padding-block 8）/ `--fit`（margin 8 + padding 8）+ `__scroll--bleed`（padding-inline 8、border-box）；Cards 加 `scrollTier` / `fitModifier`（`--single` 撑满 / `--half` 等分 calc(50% - 4px)）+ `:scroll-x` 分档；Images 统一单容器、固定 120×90（padding-bottom 75%）间距 8，删除等分撑满分支与 `--fixed` / `__image-row`。**几何口径（用户三项裁决）**：出血档视口 0..vw 滑动到边、初始首卡 left 8、尾部留白 8；fit 档卡 left 16；圆角保留用户注释（直角）。**过程偏差**：执行中发现用户手改壳（`$divider: 8px` / radius 注释 / fit 内 padding 删除 / scroll padding-inline 8），按约定停自动编辑列差异请裁决，裁决后保留用户变量结构落地；probe 首跑因 service mock `Math.random() < 0.5 → IMAGE` 方向赋反致空渲染崩溃，修 probe 非代码。门禁：ESLint / Prettier exit=0；vue-tsc 4 条基线零新增（`.temp/tc-req133-tier.log`）；probe 六配置全 PASS（`.temp/req133-tier-probe.cjs` + log）：s1 卡宽 343=375−32 / s2 167.5 等分间距 8 / s4 视口 0..375 初始 8 卡 168 滑后 scrollLeft 337 首卡 −329 尾 367=375−8 / i1、i2 120×90 left 16 / i4 视口到边 120×90 scrollLeft 145 尾 367；双模式 tap→service-hall；NO CONSOLE ERRORS；截图 ×8（`.temp/req133-tier-{s1,s2,s4,i1,i2,i4}.png` + `{s4,i4}-scrolled.png`）。mock 档位覆盖为临时追加块，跑完还原 + sha256 校验 true（产品代码零净改动）。**U-014 闭环**（STANDARD 2 等分、IMAGE ≤2 固定 120×90 左对齐）。未执行：weapp 端渲染、build。

**批次 10（2026-11-25，滚动/出血单点收敛，用户批评「子组件为啥还单独搞滚动出血、:scroll-x 过于复杂」+「收敛 最简方案 改动和维护成本最低」授权）**：3 文件——壳唯一 scroll-view 持 `:scroll-x="isScrollTier"` 与 `--bleed` 包裹两子组件；Cards/Images 模板根改卡片 fragment，删各自 scroll-view/scrollTier/bleed 绑定；Cards 仅新增 `scrollable: boolean` prop（壳传 isScrollTier）切 --single/--half，Images 零档位逻辑（props 赋值一并去除防 unused）。**保留用户同期手改新契约**（emits 改名 selectCategory/selectLink、channelId 透传链、index.vue 同步），收敛不碰契约。回搜：scroll-view/bleed 各 1 处均在壳、scrollTier 三文件 0 残留。门禁：ESLint/Prettier exit=0；vue-tsc 改默认 tsconfig（用户已合并 tsconfig.app.json）4 条基线零新增；probe 六配置 54 项全 PASS（`.temp/req133-tier-probe-out.log`，probe 脚本外部同期重写但断言口径与批次9 基线一致）；mock 零净改动。**挂起**：`--scroll` padding-block 仍用户注释态（纵向贴边），恢复与否待裁决。未执行：weapp 渲染、build。

**批次 11（2026-11-25，容器不分档 + 单层嵌套，用户「不管子内容多少容器都用 scroll-view、不够 3 个不滚动、容器共用一个」+「三层嵌套有必要？」指令）**：壳删 `--fit`/`--scroll`/`--bleed` 三修饰类与根 view/panel view 两层嵌套——根类 `.channel-categories` 无自有样式且外部零引用、panel 层仅白底一条属性，均无存在必要；白底并入唯一 scroll-view 根节点（`width:100% + padding-inline:8 + border-box + nowrap`，纵向留白按用户手改现状不设）。`:scroll-x="isScrollTier"` 仅由数量决定，1/2 个内容不超宽自然不滚动。**几何基线变更**：全档容器 0..375 铺满；fit 卡 left 8、宽 359（1 个）/175.5（2 个）；≥3 出血口径不变（初始 8、滑后到边、尾 367）。**事故与修复**：前两轮命令被中断致 probe finally 未跑，mock 残留 `imageItems.slice(0,1)` 覆盖块使用户侧 IMAGE 只渲染 1 张（用户报障「图片模式目前只渲染一张」），已删除残留块恢复 4 张；service 随机分支为用户自行恢复正确写法，零改动。门禁：ESLint/Prettier exit=0；vue-tsc 4 基线零新增；probe 六配置 48 项全 PASS（`.temp/req133-tier-probe-out.log`）；mock git diff 空。未执行：weapp 渲染、build。

**批次 12（2026-11-25，用户「check 调整文件（非新增）内容是否必要，非必要处理」审计）**：范围=两仓修改态文件（Part B staged 7 + Part A unstaged 39）；方法=逐文件 diff 增删行过需求关键词筛残留 + 消费点 grep 实证。结论：Part A 39 文件全为 h5Url/行数/校验机械必需改动零漂移保留；Part B `request.ts` 纯注释预置零行为变化判非必要→还原 HEAD，`endpoints.ts` PUBLIC_PATH_PREFIXES 死导出删除（categoryChannelPage 保留）；漂移对 home.ts/service-plan-display.ts 实证必需保留（mapper:303→ServiceCard:190）；router/app.config/components.d.ts 必需保留。门禁：ESLint exit 0、vue-tsc 4 基线零新增（`.temp/tc-req133-audit.log`）；probe 适配用户 mock 重构（单对象 + mode 字段、有效类目 2 个→s4 克隆补齐临时块）后六配置 48 项全 PASS，mock 零残留。批次11 闭环见验证闭环记录表。

**批次 13（2026-11-25，用户「ChannelProducts 49-55 要支持多张图片轮播展示，数据格式参考 channel 项目」+「不需要指示器」）**：仅渲染层改 `ChannelProducts.vue`——prop `banner?: ChannelBannerItem[]` 与 mapper 数组透传本就就绪（PC `ActivitiesModuleDTO.banner?: ActivityBannerDTO[]` 实证），旧 `activityBanner` 首图 computed 与单图 image 模板注释保留；新增 `bannerSlides` filter + 原生 `swiper autoplay circular`（同 ChannelNews 范式，间隔默认 5000 同 PC）+ 每 slide tap 透传 selectLink；容器 120 高圆角裁切沿用旧值。**指示器按用户裁决不做**（首版自绘 dots 已删净含 current 状态）。mock 零改动（现 1 张，多图验证走临时覆盖块）。门禁：Prettier unchanged、ESLint exit 0、vue-tsc 4 基线零新增（`.temp/tc-req133-banner.log`）；probe 双档 10 项全 PASS（multi 3 非克隆 slide/autoplay transform 变化/tap→service-hall；single 1 slide；无指示器；120 高；NO CONSOLE ERRORS；`.temp/req133-banner-probe-out.log`），mock 还原 sha 校验 true。未执行：weapp 渲染、build。

**批次 14（2026-11-25，用户报障「屏幕缩放之后留资的 placeholder 大小未调整」）**：根因实证——Taro H5 postcss 把 `input`/`textarea` 元素选择器改写为 `taro-*-core` 外壳，`::placeholder` 挂外壳无效、内层字号规则也命不中内层原生 input；placeholder/输入文本落回 NutUI 内层固定 `var(--nut-font-size-2, 14px)`，root 20→40 时恒 14px 不缩放。修复仅 `ChannelInquiry.vue` 三处选择器/字号：兜底组改 `.input-text::placeholder`/`.nut-textarea__textarea::placeholder`（旧元素选择器注释保留；文件随后被外部清理注释并 staged，按现状保留不回填）、input 内层规则 `input` 改 `.input-text`、textarea 内层补 `font-size: 14px; line-height: 22px`（均经 pxtransform 转 rem）。实测：375 档 ph/phTa/inpFs/taFs 全 14px、1280 档全 28px（2x 根字号），NO PAGE ERRORS；Prettier unchanged、ESLint exit 0、vue-tsc 4 基线零新增（`.temp/tc-req133-ph.log`）。**同根因观察待裁决**：`demand-inquiry/index.vue:276-279` 存在同款元素选择器兜底组（存量页，非本需求范围），是否同修待用户确认。未执行：weapp 渲染、build。

**批次 15（2026-11-25，用户「样式基本完成 处理相关逻辑」+ 裁决：恢复真实调用 / 顶部条是公共组件不挂本页 / footer 不需要 / 非登录态必须能获取数据 + 契约佐证「channel 项目接口本来就不需要登录态」）**：3 文件——①`services/category-channel.ts` 恢复 `getModel` 真实调用，mock import/分支注释保留可回退；②`endpoints.ts` 增 `PUBLIC_PATH_PREFIXES`（`${ESP}/v1/employer/category-channels/`，slug 动态路径无法枚举进 PUBLIC_PATHS 静态集）；③`request.ts` `isPublicPath` 补前缀匹配（旧行注释保留），登录态注入保留、仅游客预检与 401 全局通知放行（不选 skipAuth：会连登录用户 role/roleId 头一起跳过）。挂载裁决：AppOpenBanner 公共组件其他业务按需调用、不挂本页，footer 不需要，现状即用户口径不回填。实测（游客无会话）：GET `/gateway/aira-aiplatform-esp-api/v1/employer/category-channels/employer` 直达后端 200/succeed true/`model {}`，无登录跳转、零 pageerror，页面空态「频道暂无内容」；`law` slug curl 同样 `model {}`——测试后端未配频道数据，真实数据渲染待后端配置/联调。门禁：Prettier unchanged ×3、ESLint exit 0、vue-tsc 4 基线零新增（`.temp/tc-req133-real.log`）；probe `.temp/req133-real-probe.cjs` + `req133-real-probe-out.log` + `req133-real-guest.png`。mock 期 tier/banner probe 随真实化失效（历史证据保留）。未执行：weapp 渲染、build、登录态真机回归（role 头注入保留为代码事实）。

**批次 16（2026-11-25，用户报障 localhost/gscs 空 vs dev-channel/gsc 有数据）**：定责双因素。①环境：`dev:h5` 硬编码 `APP_ENV=test`，与用户对照的 dev 不一致——重启 agent 持有的 dev server 为 `APP_ENV=dev`（仅运行时环境变量，**零代码改动**，脚本未动，回退=test 重启）；②**游客空数据是后端行为**：dev-esp/test-esp/dev-channel 三上游对 gsc 游客请求均 `model: {}`，六组假设（cookie jar 两次/role 头/Origin/Referer/浏览器 UA/文档 Cookie）逐一排除，traceId 留证（dev-esp c5074b43…、test-esp cf785f35…、localhost-dev cf9188b5…）；用户 dev-channel 成功取数疑似登录态浏览器上下文，一步复核=无痕窗口开 dev-channel/gsc。**新增 U-019（外部）**：后端公开接口游客返回空与「非登录态能取数」需求不符，待后端书面确认。前端链路 dev 探针 PASS（200/无登录跳转/零错误/空态兜底，`.temp/req133-dev-probe-out.log`）。

**批次 17（2026-11-25，用户澄清「slug 是后台配置的真实数据，test 环境肯定有」+ 再定位）**：**纠正批次16 结论②**——后端游客行为正常：test-esp 对有效 slug 游客直达返回全量 model（工商财税，categories/agents/products/recommendedProducts/industryNews/bottomBanner/footer/seo 齐备）；前几轮 `{}` 均因 **slug 在对应环境不存在**（employer/law/gsc 为无效 slug），非后端游客限制，**U-019 撤销闭环**。localhost 当时空的真因：批次16 把代理切去 dev，test 配置 slug 在 dev 不存在。处置：dev server 切回 `APP_ENV=test`（与 `dev:h5` 默认及用户 test-channel 对照一致；零代码改动）。**真实数据渲染见证**：probe modules = categories 横滑/agents/products×2/news/bottomBanner，导航标题「工商财税」（SEO title 生效），零 pageerror，截图 `.temp/req133-realdata-guest.png`；mapper 与真实 DTO 字段名匹配**零改动**；该频道未下发 inquiry/activities/topBanner → 对应模块隐藏，符合服务端控制契约。遗留观察：dev-channel/gsc 与 dev-esp 差异属环境数据分布问题，已被有效 slug 证据取代，不需动作。

**批次 18（2026-11-25，用户报障「子类目单个内容单行超出未…显示致布局乱」+ 终裁「最好还是通过 nut-ellipsis 实现最终效果」）**：根因实证——nut-ellipsis 以根节点渲染高度 > maxHeight 判定截断，测高失效时空 rejection 静默放全文→换行撑乱布局；flex 子项槽另有行高 stretch 异常（ interim CSS 版探针实测 h42）。最终形态（用户确认方案B）：去 nut-ellipsis，单 `<view>` 子项直接插值文本 + 纯 CSS 单行截断（固高 17 消除 stretch + nowrap/ellipsis/hidden），`@tap` 原生透传。依据：组件截断纯靠 JS 测高且无 CSS 模式（Ellipsis.js L126-144），本 flex 槽测高不可靠（h42 实证）、内置 display:flex 致外层 ellipsis 无效，组件在此槽无确定性收益。旧 nut-ellipsis 形态与兜底样式段经用户授权直接删除不留注释（规则例外条款），IDE 保存冲突已解决，磁盘即终态。实测：全部子类目 17px 单行、长名截断（scrollWidth>clientWidth）、四卡等高 100、children 盒 42、@tap 透传跳转 service-hall PASS、零 pageerror，截图 `.temp/req133-child-guest.png`；Prettier/ESLint 绿；vue-tsc 6 = 基线 4 + 2 TS6133（**外部状态**：用户将 `category-channel.ts` 回退 mock 分支致 import 未用，按现状保留不回填，非本批引入）。横向：group-name/News/Agents/Images 的 nut-ellipsis 消费点不在点名范围未动。未执行：weapp 渲染、build。临时证据已于 2026-11-25 按用户约定二次清理（39 个一次性日志/截图/Part B probe 删除，仅留 Part A 5 个可重跑断言脚本与 ts-hook.cjs），本文与实施记录各批结论为准，表中旧证据指针不再可查。

**批次 19（2026-11-25，用户裁决「133 所有样式类名重新写、严格嵌套、去长前缀，仅限小程序；单行省略方案不替换」）**：11 文件类名重写——根类短域前缀 `cc-` 全 app 唯一（cc-page/cc-cats/cc-card/cc-image/cc-header/cc-agents/cc-news/cc-banner/cc-products/cc-inquiry/cc-open），元素类裸短名严格按 DOM 嵌套，修饰类同节点复合（&.single/&.half/&.hover/&.active/&.open/&.row/&.empty）；旧 channel-*__* 长前缀全废（9 项 grep 全 0）。纯改名+重组，样式值/DOM/省略方案零变化。跨文件消费点仅 Agents measure() 两选择器改组件作用域裸类（query.in 不变）；反向污染核查全 app 根级裸类选择器 0 命中。实测 probe 双形态 PASS：STANDARD 四卡 168、子类目单行 17 长名截断、head 22px、kids 42、tap→service-hall；IMAGE 120×90、name absolute；agentMeasure swiper 高=卡实测高、newsRow 80、区块齐全、零错误；截图目检与改前一致；mock 临时切 IMAGE 取证后逐字节还原（git diff 空）。门禁 ESLint exit=0、vue-tsc 6=4 基线+2 外部零新增。旧类名整体替换系用户授权（规则例外条款）。未执行：weapp 渲染、build。probe/截图用后即删。

**批次 20（2026-11-25，用户裁决「类似 cc-products 这种类名直接干掉 cc-」）**：根类去前缀改裸名（page/cats/card/image/header/agents/news/banner/products/inquiry/open）。取证：全 app 裸名精确 token（class 属性/：class/hover-class/任意层样式定义）133 外 0 命中，裸根类全局安全；批内 5 处元素/修饰类与根类重名会串污，同步让位改名——Agents 元素 card→agent（measure() 选择器随改 '.agent'）、Inquiry 元素 card→panel、Banner/Products 元素 image→pic、Products 元素 banner→activity、Inquiry 修饰 open→expanded。期间两处外部写入干扰按现状修复：index.vue 根类被外部回退旧名 category-channel（按本批裁决改 page）、SectionHeader 样式根节点写坏缺 dot/brace（修复 .header {）。实测 probe 双形态 PASS 含 5 项串污断言（agent 宽>200 非 inline-block、panel 宽>300、activity marginLeft 0、banner pic 120 高 block 全宽、.open 节点 0）；几何/截断/tap/scoped 测量同批次19 基线；截图目检一致；mock 临时切 IMAGE 逐字节还原（git diff 空）。门禁 cc- 残留 0、11 根类完好、ESLint exit=0、vue-tsc 6=4 基线+2 外部零新增。未执行：weapp 渲染、build。probe/截图用后即删。

**批次 21（2026-11-25，用户报障「行业资讯样式乱了」）**：根因实证——批次20 裸名化后 index.vue 的 `.page { .content {...} }` 编译为后代选择器 `.page .content`，与 News/Products 内部同名元素类 `.content` 同特异性 (0,2,0) 且 display/flex-direction/gap 三属性在子组件无竞争定义，直接灌入：probe 实测 newsContent display flex/column/gap 16px、h331、swiper 与 dots 间距 16（应 0），productsContent 同污 h696。批次20 串污断言只覆盖根类让位 5 处，漏「页面根的元素类 vs 子组件同名元素类」后代链。修复：index.vue `.content` 改 `> .content` 子选择器限定直接子级（1 处，类名与模板零变化，注释记需求号）。复测：newsContent block/gap normal/h315、productsContent block/h680、pageContent 自身 flex column gap16 保留（h3947）、swiperToDotsGap 0、5 行×80 不变、零 pageerror；截图目检三行整齐 dots 紧贴；ESLint exit=0；纯样式选择器改动无 script 变化，vue-tsc 基线 6 不受影响。教训：页面级根下的元素类规则必须子选择器或全子树唯一 token。未执行：weapp 渲染、build。probe/截图用后即删。

**批次 22（2026-11-25，用户「留资接口的调用帮我处理一下」→「参考 channel 项目的留资，二级频道接口调通了」）**：首轮游客实测 POST /v1/employer/inquiries 400「来源一级类目不存在或已停用」——当时页面处 mock 分支（外部回退态），mock categoryId '4' 不在测试后端一级类目树（含4=False）；取值口径与 PC sub-channel index.vue L175（page.categoryId）一致，链路无误。中途用户恢复真实频道调用并裁决参照 PC，重新评估后 mock 错配结论失效。对齐改动 3 处：①ChannelInquiry industry 改取所选需求类型名称（PC selectedCategoryName() 口径，旧行注释保留）；②category-channel.ts mock import 注释补全过渡形态（消解外部 TS6133）；③清理 mock 内批次13 残留 [probe-banner] 临时覆盖块（兑现跑完即还原；旧 state「零残留」声称与磁盘不符，本轮纠正）。开关口径核对：PC showInquiry 与 miniapp mapper 同为 inquiry?.enabled === true；测试频道后端配置无 inquiry 字段→两端一致不显示留资区，属后端配置非前端缺陷。实测：probe 侧 route 注入 inquiry:{enabled:true}（产品代码零改动）+ 真实 slug 游客提交→POST 200 succeed=true model{id, openLoginDialog:true}、success 态渲染、带 returnTo 跳登录页（同 PC openLoginModal 链路）、零 pageerror。门禁 ESLint 3 文件 exit=0、vue-tsc 4=基线零新增。遗留：mock 死代码待收口删（含 L114 附近外部重复 link 键一处未动）；测试频道 inquiry 开关待后端配置。未执行：weapp 渲染、build。probe 用后即删。

**批次 23（2026-11-25，用户报障「智能体市场高度不一致 + 资讯日期格式化/标题固高/作者超出未省略」）**：根因实证——nut-ellipsis 外层包装节点 computed display:inline，`.desc` height 34 与 `.name` margin-bottom 6 对 inline 无效：probe 实测 1 行描述卡 body 71 vs 2 行 88（卡 200.5 vs 217.5）、6px 间距丢失；News `.title` 同因高度随内容（20/40 不齐）；author 包装被 flex block 化但内部 JS 测高在 flex 槽不可靠（h36 两行，同批次18 __child 根因）；日期模板直插裸 ISO。修复 2 文件：①Agents `.name`/`.desc` block 化 + 固高 22/34 + overflow hidden 兜底（nut-ellipsis 保留，内部测高不受包装固高影响）；②News `.title` block 化 + 固高 40 + overflow hidden；author 改方案 B 单 view + 纯 CSS 单行截断（旧 nut-ellipsis 模板注释保留）；新增 formatCreatedAt 对齐 PC SubChannelIndustryNewsSection（空→''、非法→原值、Intl zh-CN medium，无 Intl 环境退化 ISO 日期段）。复测真实接口态：agent 三卡 223.5 齐平（swiper 224）、body 94（间距恢复）、desc 34×3；title 40×3、meta/author 18×3 nowrap hidden；日期「2026年9月11日/14日」；截图目检卡底齐平、资讯三行节奏统一；零 pageerror。横向：Cards `.name` flex 子项、Images `.name` absolute 均已 block 化无此缺陷；banner 空白色块系截图瞬态加载占位（复测 naturalWidth 328 complete true）非缺陷。门禁 ESLint 2 文件 exit=0、vue-tsc 4=基线零新增。未执行：weapp 渲染、build。probe/截图用后即删。

**批次 24（2026-11-25，用户「子类目槽按批次23 思路改 nut-ellipsis 实现」）**：ChannelCategoryCards `.child` 槽方案B 单 view 改 nut-ellipsis（用户明确裁决反转批次18 终态）：模板旧 view 注释保留、事件改 @click（源码实证 emits 仅 click/change、根 onClick→emit click，@tap 不透传）；包装类 block 化 + 固高 17 防 stretch + overflow 兜底，外层 nowrap/ellipsis 注释废弃（内层 display:flex 致无效且 nowrap 继承破坏测高）。首轮实测发现 flex 槽内部测高仍不可靠（长名硬裁无省略号，批次18 根因未被包装 block 化消除）→ 按既有兜底模式 descendant 挂 `.nut-ellipsis { display:block; overflow:hidden; nowrap; ellipsis }` 确定性截断。复测真实接口态：14 child 17×68 block、kids 42×7、卡 100×7 等高、5 长名 CSS 省略号目检可见、tap→service-hall、零 pageerror。门禁 ESLint exit=0、vue-tsc 4=基线。结论修正：批次23 包装 block 化只解 inline 包装固高失效（block 流槽），flex 子项槽内部测高不可靠依旧，须 descendant CSS 兜底。未执行：weapp 渲染（descendant 穿透依赖 nutui 组件样式隔离口径，收口补验）、build。probe/截图用后即删。

**批次 25（2026-11-25，用户「这个实现太拉胯了 还是改回去吧 过程内容不要 只保留最后的结果即可」）**：批次24 nut-ellipsis 实现整体回退，`.child` 槽终态 = 方案B 单 view + 纯 CSS 单行截断 + @tap（与批次24 前逐字一致）；按用户明确指令代码内不留过程注释/废弃块（规则4 例外条款生效；磁盘曾见外部先行清理注释，按终态直接替换）。child 槽 nut-ellipsis 残留 grep 0（L97 系类目名 .name 槽既有消费，非本次范围）。复测真实接口态：14 child 17×68、nowrap+ellipsis、12 长名 CSS 省略、kids 42×7、卡 100×7 等高、tap→service-hall、零 pageerror。门禁 ESLint exit=0、vue-tsc 4=基线。终态裁决：flex 槽 nut-ellipsis 无确定性收益（测高不可靠+需 descendant 兜底），方案B 为该槽唯一终态。未执行：weapp 渲染、build。probe 用后即删。

**批次 26（2026-11-25，用户「ChannelInquiry 131-144 纯纯多余 一个toast就可以 参考channel实现」）**：留资成功态面板（✓/留言已提交/再留一条）整体移除——submitted 状态、成功态模板块与 v-else 包装、.success 样式全删（用户明确裁决冗余，过程注释零保留）；成功链路对齐 PC DemandLeaveMessageCard：reset() 清表单 + toast('提交成功','success')，openLoginDialog→openLoginForCurrentPage 登录链保留。坑实证：Taro H5 路由切换清理全局 toast（body 挂载但跳转后 toast 自身 display:none，150ms 可见/400ms 起隐藏）→ 跳转分支 toast 延 400ms 待新页落定，非跳转分支即时。复测（路由注入 inquiry 开关+真实提交）：200→login returnTo；toast 可见窗跳转后 +600~+2000ms、+2600 自动隐藏；goBack 表单全空、无成功态面板、提交按钮在；零 pageerror。门禁 ESLint exit=0、vue-tsc 4=基线。未执行：weapp 渲染（原生 toast 不受 H5 路由清理影响，延迟无害）、build。probe 用后即删。

**批次 27（2026-11-25，用户「多余动作太多 提交完成 toast 然后 reset 就可以了」）**：批次26 的 setTimeout 400ms 延迟补偿与 if/else 分支全删，成功路径收敛三行：`toast('提交成功','success')` → `reset()` → `openLoginDialog && 游客` 登录契约行保留（后端契约、PC 同口径，非多余动作）。复测：toast 即时可见（seen true）、goBack 表单全空、提交按钮在；停留 1.5s 后 goBack 零错误。已知平台竞态（非本次引入、不修）：到达登录页毫秒级（探针 3ms）内即 back 触发 nut-ellipsis 重 show 测高 null root ×16；人类可操作停留（≥1.5s）零错误，属 Taro H5 页生命周期/组件库清理缺陷，超最小改动范围仅登记。门禁 ESLint exit=0、vue-tsc 4=基线。未执行：weapp、build。probe 用后即删。

**批次 28（2026-11-25，用户「页面滚动时 AppOpenBanner+EsNavBar 要在最顶端，banner 可能不存在」→ 思路确认后落地）**：index.vue 顶栏包 `.top` wrapper 单一 sticky 单元（position:sticky top:0 z-index:100），banner 显隐仍由组件内部 v-if 决定、wrapper 高度自适应（有 104 / 无 44）；wrapper 内 `.es-nav` 置 static（EsNavBar 自带 sticky 在吸顶 wrapper 内会与 banner 重叠吸同一点），覆写限定 `.top` 祖先内不影响其他消费页。零 JS 零测高。探针双态（浏览器 UA / wdshengapp 容器 UA）：滚动层为 `.taro_page`（非 window，scrollY 恒 0 系探针首跑误判已修正）；滚 600 后 wrapper top 0、entry 0-60 / nav 60-104 无重叠、容器态 nav 0-44、首内容 top -496/-556 从顶栏下穿过；截图目检钉顶无透底；零 pageerror。门禁 ESLint exit=0、vue-tsc 4=基线。未执行：weapp 渲染（页面级滚动 sticky 口径同 H5，收口补验）、build。probe/截图用后即删。

**待办**：①~~dev server Node 环境阻塞~~ 已解决：`.temp/ts-hook.cjs` esbuild require 钩子绕过 Node22 strip-only 限制，watch 编译成功（:10086），浏览器实测已 完成；②U-006 deep link path 规则、~~U-014 类目区 2 张布局~~（批次9 闭环）、U-015 顶部条显隐、行数 配置字段、APP 容器 UA 标识均按建议口径先行并 `TODO: wxj` 占位；③U-009 yeeda 软链仍断，按仓自身 AGENTS.md 约定执行（偏差已记录）；④批次15 已恢复真实调用（游客前缀白名单放行），批次17 已用 test 有效 slug 见证真实渲染；mock 注释分支与 category-channel.mock.ts 待收口按用户指令删除；⑤~~类目区 UI 修正挂起~~ 批次9 已完成：三档布局 + 出血 + 120×90 落地并六配置实测通过，验收口径为用户标注截图 + 三项裁决（到边 + 首卡 8 / fit 内留白 8 / 直角）；⑥批次10 滚动单点收敛已闭；`--scroll` padding-block 恢复与否待用户裁决（现注释态纵向贴边）；⑦~~U-019~~ 撤销闭环（批次17：游客+有效 slug 返回全量 model，前几轮 {} 系无效 slug 所致，非后端游客限制）。

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
| 阶段3 批次8（类目区组件拆分，2026-11-24） | 用户方案 A 确认 +「先拆分组件 吧 具体的UI再说」指令 | 通过（含浏览器双模式回归） | ①3 文件：ChannelCategories 薄壳化 + ChannelCategoryCards / ChannelCategoryImages 新增（原样搬移，BEM 不变，__scroll 单点留壳）；②ESLint / Prettier exit=0；vue-tsc 4 条基线零新增（`.temp/tc-req133-split.log`）；③probe 双模式：STANDARD 4 卡 168 渐变 tap→service-hall / IMAGE 4 固定卡 140 比例 0.563 tap→service-hall，NO CONSOLE ERRORS（`.temp/req133-split-probe.cjs` + 截图×2）；④回搜：壳内孤儿符号 0、index.vue 零 diff、BEM 定义单点；⑤UI 规格修正挂起（120×90 / Figma 175570-264657 待设计稿获取）；⑥未执行：weapp 渲染、build |
| 阶段3 批次9（类目区三档布局 + 出血 + 固定尺寸，2026-11-24） | 用户标注截图 ×2 验收口径 + 三档/出血口径确认 +「ok 不用注释保留 直接改吧」+ 手改差异三项裁决（到边 + 首卡 8 / fit 内留白 8 / 直角） | 通过（六配置浏览器实测） | ①3 文件：壳 isScrollTier + panel --scroll/--fit + __scroll--bleed；Cards --single/--half + :scroll-x 分档；Images 单容器固定 120×90 间距 8（删等分分支）；②ESLint / Prettier exit=0；vue-tsc 4 基线零新增（`.temp/tc-req133-tier.log`）；③probe 六配置全 PASS：s1 343 / s2 167.5 / s4 视口 0..375 初始 8 滑后首卡 −329 尾 367 / i1、i2 120×90 / i4 到边 120×90，双模式 tap→service-hall，NO CONSOLE ERRORS（`.temp/req133-tier-probe.cjs` + 截图×8）；④mock 临时档位覆盖跑完还原 sha256 校验 true；⑤U-014 闭环；⑥过程偏差登记：用户手改壳停编辑请裁决、probe random 方向赋反修 probe；⑦未执行：weapp 渲染、build |
| 阶段3 批次10（滚动/出血单点收敛，2026-11-25） | 用户批评子组件各自持滚动/出血过复杂 +「收敛 最简方案 改动和维护成本最低」 | 通过（六配置浏览器实测） | ①3 文件：壳唯一 scroll-view（:scroll-x + --bleed）；Cards 删 scrollTier 改 scrollable prop；Images 纯卡片渲染零档位；②保留用户手改新契约 selectCategory/selectLink + channelId 链；③ESLint/Prettier exit=0；vue-tsc 默认 tsconfig 4 基线零新增；④probe 六配置 54 项全 PASS（`.temp/req133-tier-probe-out.log`）；⑤单点回搜 scroll-view/bleed 各 1 处在壳、scrollTier 0 残留；⑥mock 零净改动；⑦未执行：weapp 渲染、build |
| 阶段3 批次11（容器不分档 + 单层嵌套，2026-11-25） | 用户「容器共用一个、不够 3 个不滚动」+「三层嵌套有必要？」+ IMAGE 只渲染 1 张报障 | 通过（六配置浏览器实测） | ①壳删三修饰类与根/panel 两层 view，白底并入唯一 scroll-view 根；②几何：全档容器 0..375、fit 卡 left 8 宽 359/175.5、出血不变；③事故修复：中断致 probe 残留 slice(0,1) 覆盖块删净，IMAGE 恢复 4 张；④ESLint/Prettier exit=0、vue-tsc 4 基线零新增；⑤probe 六配置 48 项全 PASS；⑥mock git diff 空；⑦未执行：weapp 渲染、build |
| 阶段3 批次12（修改文件必要性审计，2026-11-25） | 用户审计指令 + 两仓 46 修改态文件 diff + 消费点 grep | 审计完成，非必要已处理 | ①Part A 39 全必需保留；②Part B request.ts 还原 HEAD、endpoints 死导出删除；③漂移对重分类必需保留（消费链实证）；④ESLint exit 0、vue-tsc 4 基线零新增；⑤probe 48 项全 PASS、mock 零残留；⑥未执行：weapp 渲染、build |
| 阶段3 批次13（活动 banner 多图轮播，2026-11-25） | 用户「支持多张图片轮播、数据格式参考 channel 项目」+「不需要指示器」 | 通过（双档浏览器实测） | ①仅 ChannelProducts.vue 渲染层：bannerSlides + swiper autoplay circular，旧单图注释保留；②数据层零改动（数组本就就绪）；③指示器按裁决不做；④ESLint exit 0、vue-tsc 4 基线零新增；⑤probe 双档 10 项全 PASS、mock 零改动零残留；⑥未执行：weapp 渲染、build |
| 阶段3 批次14（留资 placeholder 缩放修复，2026-11-25） | 用户报障「屏幕缩放后 placeholder 大小未调整」 | 通过（375/1280 双档实测） | ①根因：postcss 元素选择器改写外壳致兜底失效，NutUI 内层固定 14px；②ChannelInquiry.vue 三处改内层类选择器+rem 化字号，旧选择器注释保留；③375 全 14px / 1280 全 28px；④ESLint exit 0、vue-tsc 4 基线零新增；⑤demand-inquiry 同款缺陷观察待裁决；⑥未执行：weapp 渲染、build |
| 阶段3 批次15（逻辑层真实化，2026-11-25） | 用户「处理相关逻辑」+ 恢复真实调用/游客必须能取数/顶部条不挂本页/footer 不需要 裁决 + PC 接口公开契约佐证 | 通过（游客浏览器实测） | ①3 文件：getPage 真实调用恢复（mock 注释保留）、PUBLIC_PATH_PREFIXES 前缀白名单、isPublicPath 前缀匹配（旧行注释保留）；②游客 GET 直达后端 200/succeed true，无登录跳转零错误；③测试后端 model {} 空态如实登记，真实渲染待后端配置；④ESLint exit 0、vue-tsc 4 基线零新增；⑤未执行：weapp 渲染、build、登录态真机回归 |
| 阶段3 批次16（环境对齐+游客空数据定责，2026-11-25） | 用户报障 localhost 空 vs dev-channel 有数据 | 环境已对齐，定责后端 U-019 | ①dev server 重启 APP_ENV=dev（零代码改动）；②六组游客假设排除实测，三上游 model {} traceId 留证；③dev 探针 PASS 空态兜底；④U-019 登记待后端书面确认+用户无痕复核；⑤未执行：登录态真机回归（无凭证不可代验） |
| 阶段3 批次17（根因纠正+真实数据渲染见证，2026-11-25） | 用户澄清 slug 为后台配置真实数据、test 必有 | 通过（真实数据浏览器实测） | ①纠正批次16②：游客+有效 slug 全量 model，U-019 撤销；②代理切回 APP_ENV=test；③probe 真实渲染六模块+SEO 标题+零错误+截图；④mapper 零改动；⑤未执行：weapp 渲染、build、登录态真机 |
| 阶段3 批次18（子类目单行省略，2026-11-25） | 用户报障布局乱 + 终裁 nut-ellipsis 实现 | 通过（浏览器实测） | ①方案B 单 view 子项 + 纯 CSS 单行（固高 17/nowrap/ellipsis/hidden）+ @tap 原生透传；②全子类目单行、长名截断、四卡等高、tap 跳转 PASS、零错误；③Prettier/ESLint 绿，vue-tsc 零新增（6=4 基线+2 外部 mock 回退 TS6133）；④横向其余 ellipsis 消费点未动；⑤未执行：weapp 渲染、build |
| 阶段3 批次19（133 类名重写+严格嵌套，2026-11-25） | 用户裁决类名重写、去长前缀、仅限小程序 | 通过（浏览器实测） | ①cc- 短根类+裸元素名严格 DOM 嵌套+同节点复合修饰类，11 文件；②probe 双形态几何/截断/tap/scoped 测量全 PASS、截图目检一致；③ESLint exit=0、vue-tsc 零新增、9 旧前缀 grep 全 0；④mock 临时切 IMAGE 逐字节还原；⑤未执行：weapp 渲染、build |
| 阶段3 批次20（根类去 cc- 改裸名，2026-11-25） | 用户裁决「直接干掉 cc-」 | 通过（浏览器实测） | ①11 根类裸名+批内 5 处重名元素/修饰让位改名（agent/panel/pic/activity/expanded）；②全 app 裸名 token 133 外 0 命中取证；③probe 双形态 PASS 含 5 项串污断言、截图目检一致；④cc- 残留 0、ESLint exit=0、vue-tsc 零新增；⑤外部写入干扰 2 处按现状修复；⑥未执行：weapp 渲染、build |
| 阶段3 批次21（资讯串污修复，2026-11-25） | 用户报障「行业资讯样式乱了」 | 通过（浏览器实测） | ①根因 `.page .content` 后代选择器串污 News/Products 同名 .content（flex/gap 灌入，probe 实证 gap16/h331）；②index.vue 改 `> .content` 子选择器 1 处；③复测 newsContent block/h315、swiperToDotsGap 0、products 同归位、page 自身布局保留、零错误、截图目检正常；④ESLint exit=0、纯样式改动 vue-tsc 不受影响；⑤未执行：weapp 渲染、build |
| 阶段3 批次22（留资调用对齐 PC + 真实联调，2026-11-25） | 用户「处理留资调用」→「参考 channel 项目、频道接口调通」 | 通过（真实后端实测） | ①首轮 400 根因 mock categoryId '4' 不存在（取值口径同 PC 无误）；②industry 对齐 PC 取所选类目名、mock import 注释补全、probe-banner 残留清理；③开关口径两端一致（inquiry.enabled），测试频道未启用属后端配置；④probe 注入开关后真实提交 200 succeed+openLoginDialog→returnTo 登录页、零错误；⑤ESLint exit=0、vue-tsc 4=基线；⑥未执行：weapp 渲染、build |
| 阶段3 批次23（智能体卡等高 + 资讯日期/标题/作者，2026-11-25） | 用户报障四项 + PC 资讯日期口径参照 | 通过（真实接口态浏览器实测） | ①根因 nut-ellipsis 包装 inline 致固高/纵向 margin 无效（卡 200.5/217.5、title 20/40 实测）；②Agents name/desc block 化固高 22/34、News title 固高 40、author 方案 B 纯 CSS 单行（旧模板注释保留）、formatCreatedAt 对齐 PC Intl zh-CN medium；③复测三卡 223.5 齐平、title 40×3、author 18 nowrap、日期中文格式、零错误、截图目检；④ESLint exit=0、vue-tsc 4=基线；⑤未执行：weapp 渲染、build |
| 阶段3 批次24（子类目槽改 nut-ellipsis，2026-11-25） | 用户裁决按批次23 思路反转批次18 方案B | 通过（真实接口态浏览器实测） | ①@click 契约源码实证（emits click/change）；②包装 block 化固高 17 防 stretch；③首轮 flex 槽测高仍不可靠（长名硬裁无省略号）→ descendant .nut-ellipsis 单行三件套兜底；④复测 14 child 17×68、kids 42、卡 100 等高、省略号目检、tap→service-hall、零错误；⑤ESLint exit=0、vue-tsc 4=基线；⑥未执行：weapp 渲染（样式隔离口径收口补验）、build；**批次25 已整体回退** |
| 阶段3 批次25（子类目槽回退方案B，2026-11-25） | 用户「实现太拉胯 改回去 过程内容不要」 | 通过（真实接口态浏览器实测） | ①终态=批次24 前方案B 逐字一致，过程注释零保留（用户明确指令，规则4 例外）；②child 槽 nut-ellipsis 残留 0；③复测 14 child 17×68 nowrap+ellipsis、12 长名省略、kids 42、卡 100 等高、tap→service-hall、零错误；④ESLint exit=0、vue-tsc 4=基线；⑤未执行：weapp 渲染、build |
| 阶段3 批次26（留资成功态改 toast，2026-11-25） | 用户「成功态面板纯纯多余 一个toast 参考channel」 | 通过（路由注入开关+真实提交实测） | ①成功态面板/submitted/.success 全删零注释残骸；②成功=reset+toast('提交成功','success')+登录链保留（对齐 PC）；③H5 路由清理全局 toast 实证→跳转分支延 400ms；④toast 可见窗 +600~+2000ms、goBack 表单全空、零错误；⑤ESLint exit=0、vue-tsc 4=基线；⑥未执行：weapp 渲染、build；**批次27 延迟补偿已按用户裁决删除** |
| 阶段3 批次27（成功路径收敛 toast+reset，2026-11-25） | 用户「多余动作太多 toast 然后 reset 就可以」 | 通过（真实提交实测） | ①setTimeout/分支/注释全删，成功=toast→reset→登录契约行；②toast 即时可见、goBack 表单全空、停留 1.5s 零错误；③毫秒级 back 竞态 ×16 登记不修（平台缺陷非本次引入）；④ESLint exit=0、vue-tsc 4=基线；⑤未执行：weapp、build |
| 阶段3 批次28（顶栏整体吸顶，2026-11-25） | 用户「滚动时 banner+导航在最顶端 banner 可能不存在」 | 通过（双 UA 态浏览器实测） | ①`.top` wrapper 单一 sticky 单元 + 内层 es-nav static 防重叠；②高度自适应 104/44；③滚 600 顶栏钉 0 无重叠、内容下穿、截图目检、零错误；④滚动层 `.taro_page` 非 window（探针口径修正）；⑤ESLint exit=0、vue-tsc 4=基线；⑥未执行：weapp、build |

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
| 新增 | `src/pages/category-channel/components/`（ChannelBanner / ChannelCategories / ChannelAgents / ChannelNews / ChannelProducts / ChannelSectionHeader / ChannelInquiry） | 七个模块组件；商品区复用 ServiceCard grid，H5 响应式 2/3/4 列；ChannelInquiry 为频道页内联留言表单（批次2）（批次8：类目区拆出 ChannelCategoryCards / ChannelCategoryImages 两子组件，ChannelCategories 薄壳化） |
| 新增 | `src/pages/category-channel/components/ChannelCategoryCards.vue` | 批次8：STANDARD 渐变类目卡（自 ChannelCategories 原样搬移）；批次9：1 撑满 / 2 等分 / ≥3 横滑出血三档；批次10：删自身 scroll-view/scrollTier，改 scrollable prop 接壳判定 |
| 新增 | `src/pages/category-channel/components/ChannelCategoryImages.vue` | 批次8：IMAGE 图片类目卡（自 ChannelCategories 原样搬移，≤2/≥3 两分支）；批次9：统一单容器固定 120×90 间距 8，≥3 横滑出血；批次10：纯卡片渲染器（零档位逻辑） |
| 修改 | `src/config/endpoints.ts` | 登记 categoryChannelPage（函数式）；PUBLIC_PATH_PREFIXES 批次12 审计判死导出删除 |
| 修改→已还原 | `src/services/core/request.ts` | 批次12 审计：纯注释预置、零行为变化，判非必要还原 HEAD；游客前缀匹配留联调时重评 |
| 修改 | `src/app.config.ts` | subPackages 注册 pages/category-channel |
| 修改 | `src/utils/router.ts` | Routes.categoryChannel |

**2026-11-24 基线漂移记录（本轮文档更新时 git 复核发现，未触碰任何代码）**：

- HEAD 由 `a0f347d` 漂移至 `7f096af`（`fix(order): 修复搜索态取消订单快照过期及取消后详情无法下拉刷新问题`，非本需求提交）；上表批次 1~3 的 20 文件仍在，但部分已 staged（`A`/`M`）且叠加新 unstaged 改动（`AM`/`MM`），非本人本轮所为，不覆盖不回退。
- 新增未跟踪资源 12 个：`src/assets/category-channel/` 下类目图标 svg×10、`customer_service_wechat_qr.png`、`ic_expand_dark.svg`；已跟踪新增 `icon_right_outlined.svg`（staged）——频道页 UI 资源，归属待确认（疑似其他会话/用户补充）。
- REQ-133 清单外改动 3 处（批次12 审计重分类）：`src/types/home.ts` + `src/utils/service-plan-display.ts` 判**必需横向补漏**保留（消费链实证：频道 mapper `category-channel.ts:303` 写 `displayText` → `ServiceCard/index.vue:190` `planPromoTags` 消费，缺则频道商品卡折扣话术丢失）；`types/components.d.ts` 为 auto-import 类型登记必需保留。
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
    ├── config/endpoints.ts  [修改] 频道接口（游客前缀批次12 删除）
    ├── services/core/request.ts  [已还原] 批次12 审计判非必要（纯注释预置）
    ├── app.config.ts  [修改] 分包注册
    ├── components/AppOpenBanner/index.vue  [新增] 顶部打开 APP 指引条
    └── pages/category-channel/  [新增] index.vue + index.config.ts + components/×9（含 ChannelSectionHeader 共享标题行、ChannelInquiry 内联留言；批次8 类目区拆分：ChannelCategories 薄壳 + ChannelCategoryCards [新增] STANDARD + ChannelCategoryImages [新增] IMAGE；批次9 三档布局 + 滑动出血 + 图片固定 120×90）
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

**文档版本**：v1.33
**最后更新**：2026年11月
**整理人**：王新骏
