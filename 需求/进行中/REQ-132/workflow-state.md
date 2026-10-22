# REQ-132 工作流进度

## 需求信息
- 需求名称：服务商工作台展示订单/售后动态（含重要商机推荐）
- 需求编号：REQ-132（云效 RZMP-9033）
- 工作区：.md/需求/进行中/REQ-132
- 需求版本：R0
- 测试版本：T0
- 开始时间：2026-10-20
- 需求来源：[原始需求/REQ-132 服务商工作台展示订单_售后动态.md](./原始需求/REQ-132%20服务商工作台展示订单_售后动态.md)
- 所属平台：企服线 `ai-platform/es-web`（服务商端 PC）
- **范围收口（2026-10-20）**：本期仅交付 Web 端，App 端由其他开发人员负责
- 产品经理：傅杰彬
- 测试用例：无（QA 未提供，阶段 5 由 AI 推导并标注）

## 阶段进度
| 阶段 | 状态 | 产物文件 | 完成时间 |
|------|------|---------|---------|
| 阶段0 需求分析 | ✅已完成 | [阶段0-需求文档-REQ-132.md](./阶段0-需求文档-REQ-132.md) | 2026-10-20 |
| 阶段1 代码分析 | ✅已完成 | [阶段1-代码分析-REQ-132.md](./阶段1-代码分析-REQ-132.md) | 2026-10-20 |
| 阶段2 技术方案 | ✅已完成（v1.2） | [阶段2-技术方案-REQ-132.md](./阶段2-技术方案-REQ-132.md) | 2026-10-21 |
| 阶段3 编码执行 | ⏳进行中（第一批完成，第二批待接口契约） | - | - |
| 阶段4 代码审查 | ⏳待开始 | - | - |
| 阶段5 测试基线与覆盖对齐 | ⏳待开始 | - | - |
| 阶段6 测试执行与Bug修复循环 | ⏳待开始 | - | - |
| 阶段7 需求复盘（第一轮） | ⏳待开始 | - | - |
| 阶段7 需求复盘（第二轮） | ⏳待开始 | - | - |

## 当前阶段
阶段3 编码执行（第一批完成，第二批待接口契约）

**第一批交付结果**：
> 布局：左右两列（left-column: 指标卡+商机+订单/售后动态 | right-column: 消息中心+供应商工作台），宽度统一 368px；WelcomeSection 全宽置顶。
> 三动态模块：`useDynamicModule` 泛型中间层（fetchFn 注入 + 5 分钟轮询 + 四态渲染）+ 三个模块容器组件（文件夹结构，Skeleton/Error/Empty 独立状态组件）+ `DynamicModuleHeader` 通用标题栏 + `formatDynamicModuleTime`（透传 stub，R-027 三段规则已注释；需求文档变更中，待本地拿到最新版后再定）。
> Mock 数据：独立 `mocks/*.ts` + `types.ts` 卡片视图模型（订单动态 5 条 / 售后动态 5 条 / 商机推荐 6 条，契约确认后整体删除）；`total` 为服务端返回总数语义；指标卡第 3 张含待缴保证金/待提交交付物子项计数（R-022/R-023）。
> R-8 未认证页面：SupplierCtaCard 三态（未认证/已认证未入驻/已入驻）；左列三模块 `v-if="certified"` 条件渲染 + CertificationPlaceholder 占位；WelcomeSection 含「了解服务商接单规则」按钮 + CertificationBanner 共享组件（URL 组件内唯一定义，无独立 constants.ts）。
> 组件数据自治：fetchStatistics 由 MetricCards 拉取、unreadStore.refresh 由 ActionCenter 拉取（各自挂载自拉 + watch 主体切换重拉），index.vue 为纯编排层（无数据拉取职责）。
> R-026：发布服务入口位于 WelcomeSection 右上角卡片。
> 类型扩展：`page_workbench.ts` 的 SupplierStatusGuidanceStatus 含 not_certified / go_certify 枚举值。
> 商机 hover 埋点保持手写 `trackClk`（专用封装已回滚，口径待 Q8 确认）。
> Q1–Q5/Q7–Q17 共 16 项待确认，第二批需后端契约后推进。

## 验证闭环记录
| 阶段 | 锚点 | 验证结果 | 偏差数 | 修正次数 | 证据 |
|---|---|---|---|---|---|
| 阶段0 需求分析 | PRD 全文（更新版，含 6 处实质修改）+ 原型图 + 用户三次补充 | 已修正后通过 | 3 | 1 | ① 布局以 image 3.png 原型图为准（§2）；② 售后 <4h 标红不实现（R-015 保留追溯）；③ 三模块为已有列表数据快捷入口，独立/融合接口待定（§1） |

## 已处理文件（阶段3）
| 文件 | 现状 | 批次 |
|------|------|------|
| `src/utils/date.ts` | formatDynamicModuleTime（透传 stub，R-027 注释保留；需求文档变更中待确认） | 第一批 + 清理 |
| `dashboard/components/DynamicModuleHeader.vue` | 通用动态模块标题栏 | 第一批 |
| `dashboard/composables/useDynamicModule.ts` | 泛型中间层（fetchFn + 轮询 + 四态）；`total` 注释为服务端总数语义 | 第一批 |
| `dashboard/components/WelcomeSection.vue` | 欢迎区 + 发布服务卡片（R-026）+ 接单规则按钮（R-8） | 前置 |
| `dashboard/components/MetricCards.vue` | 指标卡 + R-022/R-023 子项计数；数据自治（挂载自拉 fetchStatistics + watch 主体重拉） | 前置 + 迁移 |
| `dashboard/components/ActionCenter.vue` | 消息中心；刷新图标内部消化（无 emit）；数据自治（自拉 unreadStore + watch 主体重拉） | 前置 + 迁移 |
| `dashboard/components/SupplierCtaCard/` | 文件夹结构：index.vue 编排层（三态路由）+ useSupplierCtaCard.ts composable + styles.less 共享样式 + UncertifiedCard / SupplierRegisterCard / SupplierWorkbenchCard 三子组件 | 拆分 |
| `dashboard/components/CertificationPlaceholder.vue` | R-8 未认证占位图容器 | R-8 |
| `dashboard/components/CertificationBanner.vue` | R-8 认证横幅共享组件（URL 唯一定义点） | R-8 |
| `dashboard/index.vue` | 纯编排层：左右两列布局 + certified 条件渲染 + 新手引导链路；无数据拉取职责（refreshDashboard 已拆分至组件） | 第一批 + 迁移 |
| `dashboard/types.ts` | `OrderDynamicItem` / `AfterSaleDynamicItem` 卡片视图模型（47 行） | mock 抽离 |
| `dashboard/mocks/orderDynamic.ts` | 订单动态 mock 5 条 + `mockOrderDynamicTotal`（联调后随目录整体删除） | mock 抽离 |
| `dashboard/mocks/afterSaleDynamic.ts` | 售后动态 mock 5 条 + `mockAfterSaleDynamicTotal` | mock 抽离 |
| `dashboard/mocks/opportunityRecommend.ts` | 商机 mock 6 条 + `mockOpportunityRecommendTotal` | mock 抽离 |
| `dashboard/components/OrderDynamicModule/` | 文件夹结构：index.vue 编排层（四态路由 + 订单卡片列表）+ Skeleton / Error / Empty | 第一批 + mock |
| `dashboard/components/AfterSaleDynamicModule/` | 文件夹结构：index.vue 编排层（四态路由 + 售后工单卡片）+ Skeleton / Error / Empty | 第一批 + mock |
| `dashboard/components/OpportunityRecommendModule/` | 文件夹结构：index.vue 编排层（四态路由 + 横向商机卡片）+ Skeleton / Error / Empty；埋点保持手写 `trackClk`（待 Q8） | 第一批 + mock |
| `src/views/provider/order/detail.vue` | R-007 锚点滚动：`scrollToHash` + `id="bond"` / `id="deliverable"` + watch route.hash | Q10 实现 |
| `src/tracking/page_workbench.ts` | SupplierStatusGuidanceStatus 含 not_certified / go_certify 枚举 | 类型扩展 |

## 阶段 3 允许改动文件
（待阶段 2 技术方案确定后填入）

## 阶段 4 审查差异
- SHA-256：未生成
- 受检文件：未生成
- 审查时间：未生成
- 复审失效原因：无

## 不确定项追踪
| # | 问题 | 状态 | 确认人 | 影响阶段 | 结论 |
|---|------|------|--------|---------|------|
| Q1 | 三独立接口 or 一融合接口 | 待确认 | 后端 | 阶段1/2 | 建议独立接口；若融合须带 per-module 状态位 |
| Q2 | API-1/2/3 契约四件套（字段名/类型/嵌套层级/total） | 待确认 | 后端 | 阶段2/3 | TODO 占位，未确认不落码 |
| Q3 | 三个排序时间字段名 | 待确认 | 后端 | 阶段2/3 | 无则后端排序兜底 |
| Q4 | 「待提交交付物」tab id | 待确认 | 后端 / 天保 | 阶段2/3 | 影响 R-023 跳转 |
| Q5 | 指标卡两个计数来源 | 待确认 | 后端 | 阶段2/3 | 建议随 API-1 返回 |
| Q6 | ~~App 端本期是否交付~~ | ✅已关闭 | - | - | App 端由其他开发人员负责，本期仅交付 Web 端 |
| Q7 | 信用分禁用接单拦截方式 | 待确认 | 后端 / 信用分需求方 | 阶段2/3 | 前端侧无现成实现；信用分 API 已集成（CreditLevelBadge + creditScoreProfile），但无接单拦截逻辑 |
| Q8 | 商机标签「精准匹配」vs「为你推荐」 | 待确认 | 产品 | 阶段3 | OpportunityListItem.vue 硬编码「精准匹配」，待 Q8 确认后统一替换 |
| Q9 | ~~未认证兜底图高保真稿~~ | ✅已关闭 | - | - | 无高保真稿，按原型降级实现：CertificationPlaceholder.vue（蓝底渐变 + CertificationBanner），待设计稿确认后可调整 |
| Q10 | ~~订单详情页锚点定位方案~~ | ✅已实现 | 前端 | 阶段3 | detail.vue 新增 scrollToHash + BondCard/SingleDeliverableSection 外层 div 加 id 锚点；OrderListItem 跳转已带 hash |
| Q11 | 订单接口无「订单编号」字段（`ProviderOrderInfo` 仅 `id`） | 待确认 | 后端 | 阶段3 | 阶段1 §8.5 G1；影响订单动态与售后关联订单展示 |
| Q12 | 订单接口无「状态更新时间」（列表项仅 `createTime`） | 待确认 | 后端 | 阶段3 | 阶段1 §8.5 G2；**阻塞 R-004 排序规则**，无字段则需降级按 createTime |
| Q13 | 订单列表项无「阶段状态」（`stageStatus` 仅详情页 `OrderStageView`） | 待确认 | 后端 | 阶段3 | 阶段1 §8.5 G3；**阻塞「待提交交付物」分类判定** |
| Q14 | 商机接口无「匹配度标识」字段 | 待确认 | 后端 | 阶段3 | 阶段1 §8.5 G4；标签文案另见 Q8 |
| Q15 | `real_create_time` 在 `HallDemandItem` 中类型缺失 | 待确认 | 后端 | 阶段3 | 阶段1 §8.5 G5；`employer_id` 类型不一致（定义 number，实际返回 string） |
| Q16 | 「订单金额」三字段口径未定（totalAmount / adjustedTotalAmount / totalPayAmount） | 待确认 | 产品 / 后端 | 阶段3 | 阶段1 §8.5 G6；三字段均在 ProviderOrderInfo 中定义，待产品确认卡片展示哪个 |
| Q17 | 死代码链 `handleDemandSidebarClick` 是否确认废弃 | 待确认 | 产品 | 阶段3 | 代码核实：handleDemandSidebarClick 定义但模板零调用，PROVIDER_TASK_LIST_PATH / newTaskCount 同属死链 |

## 需求变更日志
| 版本 | 变更时间 | 变更内容 | 影响的需求 | 回退阶段 | 处理结果 |
|---|---|---|---|---|---|
| R0 | 2026-10-20 | 初始需求（PRD 更新版全量） | - | - | 建立工作流，落阶段 0 文档 |
| 范围收口 | 2026-10-20 | App 端移出本期交付范围，仅处理 Web 端 | R-036/R-037/Q6 | 不回退 | Q6 关闭，R-036/R-037 标注废弃 |
| PRD 内部更新 | 2026-10-20 | PRD 六处更新：① 售后上限明确 6 条 ② 新增相对时间三段规则 ③ 删除售后 <4h 标红 ④ 新增信用分禁用接单 ⑤ 轮询范围限定三模块 ⑥ 1.5s 降级标注「以研发为准」 | R-012/R-015/R-027/R-028/R-035 | 不回退（尚未编码） | 已并入阶段 0 文档 |
| 用户澄清 1 | 2026-10-20 | 三模块为已有列表数据的快捷入口；商机交互与现有一致 | §1 需求本质 | 不回退 | 写入 §1，带动 Q1/Q2/Q3 重估 |
| 用户澄清 2 | 2026-10-20 | 接口形态：三独立 or 一融合，待定 | §7 接口说明 | 不回退 | 列为 Q1，采用接口无关中间层设计规避阻塞 |
| 用户澄清 3 | 2026-10-21 | 数据格式：订单动态参考 `provider/order/list`，售后参考 `provider/after-sale`，商机沿用「我的商机」现有数据，不再另起接口结构 | Q2/Q3 | 不回退 | 落阶段1 §8 字段对照表；新增 Q11–Q16 |
| 用户澄清 4 | 2026-10-21 | 数据契约：`total` 由服务端返回（待处理总数），`list` 长度由服务端截断（≤6），前端不截断不计数 | 三模块 fetchFn | 不回退 | mock 拆出独立 total（12 / 8 / 9），`useDynamicModule` 注释更正 |

> ⚠️ PRD 头部版本表仍为 V1.0（2026-09-18），需求变更未登记版本号——建议让产品补记，便于后续追溯。

## 备注
- 企服线项目（Vue 3 + TS + Ant Design Vue），**不套用** WLYD 物流线 uni-app / Vue2 / Element UI 规范；编码规范以 `ai-platform/es-web/README.md` 与 `.cursor/` 为事实源
- 阶段 3 门禁：`bash .md/scripts/quick-verify.sh` + `npx tsc --noEmit`（企服线追加类型检查）
- 阶段 0 采用「先骨架、后契约」两段式开发顺序（见需求文档 §11），避免被后端契约阻塞
- 横向搜索（阶段 0 已执行，11 项）：工作台首页 / 订单列表 / 订单详情 / 售后列表·详情 / 我的商机列表·详情 / api 封装 / stores / 认证拦截 / 抢单链路 / 雇主禁用 / 路由；App 端正式仓库不在本 workspace
- 埋点纪律：埋点口径改动必须先经产品/数据侧确认（等价 ≠ 授权）；商机埋点专用封装因未经确认已回滚，待 Q8 口径确认后再统一
- 死代码链待定（见 Q17）：`handleDemandSidebarClick`(index.vue) → `PROVIDER_TASK_LIST_PATH` → `newTaskCount`；对应「海量精准需求」入口，在 `.bak` 中即为定义未调用
- 同源孤儿（✅ 2026-10-22 已清理）：`index.vue` 的 `WORKBENCH_PGID` / `WORKBENCH_PG_NAME` / `getProviderWorkbenchUserContext` / `WORKBENCH_AUTH_POPUP_ENTRY_SOURCE` / `PROVIDER_SERVICE_PUBLISH_PATH` 已删除（tracking/page_workbench.ts 已有同名定义；子组件各自持有 WORKBENCH_AUTH_POPUP_ENTRY_SOURCE 副本）
- 存量缺陷（按边界未动）：`my-opportunity/list.vue` 只 import 未调用 `trackBusinessGrabOrderClick` / `trackBusinessViewDetailClick`，按钮埋点靠手写 `trackClk`
- 阶段文档阅读注意：阶段2 §3.1 的 top-section 布局已被设计稿推翻，实际落地为左右两列——规划改动一律以「实际落地」列与当前代码为准；阶段1 基线快照存在过期项（已标注）
- 门禁状态（2026-10-22）：`vue-tsc --noEmit` exit=0；`formatDynamicModuleTime` 透传 stub（R-027 注释保留，需求文档变更中待本地拿到最新版后再定）；空 `@media (max-width: 768px)` 已删除；Q10 锚点滚动已实现（detail.vue scrollToHash + id 锚点）
- 行为差异备案（用户已确认）：① 点消息中心刷新图标仅刷新未读数（指标卡数据由 MetricCards 自治）；② 新手引导时序不依赖数据请求；③ 两接口请求各自消化异常，不再聚合中断页面初始化
