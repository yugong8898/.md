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
| 阶段2 技术方案 | ✅已完成 | [阶段2-技术方案-REQ-132.md](./阶段2-技术方案-REQ-132.md) | 2026-10-20 |
| 阶段3 编码执行 | ⏳进行中（第一批骨架 + mock + R-8 未认证页面 + 组件拆分完成） | - | - |
| 阶段4 代码审查 | ⏳待开始 | - | - |
| 阶段5 测试基线与覆盖对齐 | ⏳待开始 | - | - |
| 阶段6 测试执行与Bug修复循环 | ⏳待开始 | - | - |
| 阶段7 需求复盘（第一轮） | ⏳待开始 | - | - |
| 阶段7 需求复盘（第二轮） | ⏳待开始 | - | - |

## 当前阶段
阶段3 编码执行（第一批骨架 + mock + R-8 未认证页面调整 + SupplierCtaCard 组件拆分已完成，第二批待接口契约）

> 第一批产出：formatDynamicModuleTime + DynamicModuleHeader + useDynamicModule + 三个模块容器组件 + index.vue 布局重排。
> Mock 数据产出：三模块填充设计稿示例数据（订单动态 2 条 / 售后动态 2 条 / 商机推荐 4 条），指标卡第 3 张新增待缴保证金/待提交交付物子项计数。
> 布局修正：从 top-section 方案改为左右两列布局（left-column: 指标卡+商机+订单/售后动态 | right-column: 消息中心+供应商工作台），宽度统一 368px。
> 发布服务迁移：从 ActionCenter 移至 WelcomeSection 右上角卡片（R-026）。
> R-8 未认证页面调整：SupplierCtaCard 扩展为三态（未认证/已认证未入驻/已入驻）；左列三模块 v-if="certified" 条件渲染，v-else 显示 CertificationPlaceholder；WelcomeSection 新增「了解服务商接单规则」按钮 + CertificationBanner 共享组件预览大图；图片 URL 收敛至 constants.ts 唯一定义点。
> 组件拆分收尾：三个动态模块改为文件夹包裹 + 状态组件独立拆分（XxxSkeleton/XxxError/XxxEmpty）；SupplierCtaCard 拆为文件夹（index.vue 编排层 + useSupplierCtaCard.ts composable + styles.less 共享样式 + 三个子组件各自内聚样式与模板）；样式全部按 SCSS 嵌套规范重写。
> Q1–Q5/Q7–Q10 仍为「待确认」状态，第二批需后端契约后推进。

## 验证闭环记录
| 阶段 | 锚点 | 验证结果 | 偏差数 | 修正次数 | 证据 |
|---|---|---|---|---|---|
| 阶段0 需求分析 | PRD 全文（更新版，含 6 处实质修改）+ 原型图 + 用户三次补充 | 已修正后通过 | 3 | 1 | ① 原型图推翻正文「模块在行动中心下方」表述，改以 image 3.png 为准（§2）；② 删除线第 3 条（售后 <4h 标红）确认不实现（R-015 保留追溯）；③ 用户澄清三模块为已有列表数据快捷入口，推翻「复用现有列表接口」假设，改为独立/融合接口待定（§1） |

## 横向搜索记录（阶段 0 已执行）
```
✅ 工作台首页 provider/dashboard/index.vue        ✅ 订单列表 provider/order/list.vue（Tab 接口驱动）
✅ 订单详情 provider/order/detail.vue             ✅ 售后列表/详情 provider/after-sale/*
✅ 我的商机列表/详情 provider/my-opportunity/*    ✅ 接口封装 api/provider/{order,afterSale,dashboard,creditScore}
✅ 状态管理 stores/provider/dashboard.ts          ✅ 认证拦截 composables/useCertCheck.ts
✅ 抢单链路 composables/useGrabOrder.ts           ✅ 供应商/雇主禁用 useEmployerFeatureAvailability.ts
✅ 路由 router/routes/provider/*                  ⚠️ App 端：正式仓库不在本 workspace（Q6）
```

## 已处理文件（阶段3用）
| 文件 | 操作 | 批次 |
|------|------|------|
| `src/utils/date.ts` | 新增 formatDynamicModuleTime | 第一批 |
| `dashboard/components/DynamicModuleHeader.vue` | 新增 | 第一批 |
| `dashboard/composables/useDynamicModule.ts` | 新增 | 第一批 |
| `dashboard/components/OrderDynamicModule.vue` | 新增 + mock 数据 | 第一批 + mock |
| `dashboard/components/AfterSaleDynamicModule.vue` | 新增 + mock 数据 | 第一批 + mock |
| `dashboard/components/OpportunityRecommendModule.vue` | 新增 + mock 数据 | 第一批 + mock |
| `dashboard/components/WelcomeSection.vue` | 新增（从 index.vue 拆分） | 前置 |
| `dashboard/components/MetricCards.vue` | 新增（从 index.vue 拆分）+ R-022/R-023 子项计数 | 前置 + mock |
| `dashboard/components/ActionCenter.vue` | 新增（从 index.vue 拆分）- 移除 publish_service | 前置 + 调整 |
| `dashboard/components/SupplierCtaCard.vue` | ~~新增（从 index.vue 拆分）- 宽度自适应~~ → 已拆为文件夹 | 前置 + 调整 → 拆分 |
| `dashboard/components/SupplierCtaCard/index.vue` | 编排层（三态路由 + 外层容器） | 拆分 |
| `dashboard/components/SupplierCtaCard/useSupplierCtaCard.ts` | composable（状态 + 接口 + 埋点 + 生命周期） | 拆分 |
| `dashboard/components/SupplierCtaCard/styles.less` | 共享样式变量与公共 BEM 类 | 拆分 |
| `dashboard/components/SupplierCtaCard/UncertifiedCard.vue` | 未认证引导卡（自有样式） | 拆分 |
| `dashboard/components/SupplierCtaCard/SupplierRegisterCard.vue` | 已认证未入驻申请卡（自有样式） | 拆分 |
| `dashboard/components/SupplierCtaCard/SupplierWorkbenchCard.vue` | 已入驻工作台切换卡（自有样式） | 拆分 |
| `dashboard/components/CertificationPlaceholder.vue` | 新增（R-8 未认证占位图） | R-8 |
| `dashboard/components/CertificationBanner.vue` | 新增（R-8 认证横幅共享组件） | R-8 |
| `dashboard/constants.ts` | 新增（CERTIFICATION_BANNER_URL 唯一定义） | R-8 |
| `dashboard/components/WelcomeSection.vue` | 新增 + 发布服务卡片（R-026） | 前置 + 调整 |
| `dashboard/index.vue` | 修改（布局重排 + 引入新组件 + 左右两列布局） | 第一批 + 布局修正 |

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
| Q7 | 信用分禁用接单拦截方式 | 待确认 | 后端 / 信用分需求方 | 阶段2/3 | 前端侧无现成实现 |
| Q8 | 商机标签「精准匹配」vs「为你推荐」 | 待确认 | 产品 | 阶段3 | PRD 内部二选一 |
| Q9 | 未认证兜底图高保真稿 | 待确认 | 产品 / UI | 阶段3 | 有则按稿，无则按原型 |
| Q10 | 订单详情页锚点定位方案（detail.vue 现状无 anchor/scrollTo/hash 能力） | 待确认 | 前端 / 产品 | 阶段2/3 | 可选 A.新增 hash 锚点 B.降级跳详情页顶部 |

## 需求变更日志
| 版本 | 变更时间 | 变更内容 | 影响的需求 | 回退阶段 | 处理结果 |
|---|---|---|---|---|---|
| R0 | 2026-10-20 | 初始需求（PRD 更新版全量） | - | - | 建立工作流，落阶段 0 文档 |
| 范围收口 | 2026-10-20 | App 端移出本期交付范围，仅处理 Web 端 | R-036/R-037/Q6 | 不回退 | Q6 关闭，R-036/R-037 标注废弃 |
| PRD 内部更新 | 2026-10-20 | PRD 六处更新：① 售后上限明确 6 条 ② 新增相对时间三段规则 ③ 删除售后 <4h 标红 ④ 新增信用分禁用接单 ⑤ 轮询范围限定三模块 ⑥ 1.5s 降级标注「以研发为准」 | R-012/R-015/R-027/R-028/R-035 | 不回退（尚未编码） | 已并入阶段 0 文档 |
| 用户澄清 1 | 2026-10-20 | 三模块为已有列表数据的快捷入口；商机交互与现有一致 | §1 需求本质 | 不回退 | 写入 §1，带动 Q1/Q2/Q3 重估 |
| 用户澄清 2 | 2026-10-20 | 接口形态：三独立 or 一融合，待定 | §7 接口说明 | 不回退 | 列为 Q1，采用接口无关中间层设计规避阻塞 |

> ⚠️ PRD 头部版本表仍为 V1.0（2026-09-18），本次更新未登记版本号 —— 建议让产品补记，便于后续追溯。

## 备注
- 企服线项目（Vue 3 + TS + Ant Design Vue），**不套用** WLYD 物流线 uni-app / Vue2 / Element UI 规范；编码规范以 `ai-platform/es-web/README.md` 与 `.cursor/` 为事实源
- 阶段 3 门禁：`bash .md/scripts/quick-verify.sh` + `npx tsc --noEmit`（企服线追加类型检查）
- 阶段 0 采用「先骨架、后契约」两段式开发顺序（见需求文档 §11），避免被后端契约阻塞
