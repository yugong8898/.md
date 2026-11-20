# [REQ-045/161] 工作流进度

阶段 2 技术方案已按最新接口方向更新。用户已同意继续推进，阶段 3 可先处理已确认的前端交互。阶段 0 已收口（R1）：访问地址配置废弃，改为工商财税 cs 子域名调整；TDK 静态预置进打包前配置，不做动态表单；server 侧职责不阻塞前端，前端按正常业务逻辑与现有平台规则实现；Banner 按 PRD 正文 1200px 口径，页面预览本期不做。仅 TDK 预置内容清单待产品提供，不阻塞开发。新增接口字段联调时与后端对齐，未确认前用 TODO: wxj 占位。

## 目录

- [需求信息](#需求信息)
- [阶段进度](#阶段进度)
- [评审问题与不确定项追踪](#评审问题与不确定项追踪)
- [验证闭环记录](#验证闭环记录)
- [需求变更日志](#需求变更日志)

## 需求信息

- 需求名称：二级频道页模块优化
- 需求版本：R1
- 测试版本：T0，尚未建立测试基线
- 开始时间：2026-11-10
- 需求评审：2026-11-11；TDK 与子域名口径 2026-11-17 确认同步，其余结论待同步
- 来源：[原始 PRD](<原始需求/REQ-045_161 二级频道页模块优化 PRD.md>)

## 阶段进度

| 阶段 | 状态 | 产物 | 完成时间 |
|---|---|---|---|
| 0 需求分析 | 已完成（R1 收口） | [阶段 0 需求文档](阶段0-需求文档-REQ-045_161.md) | 2026-11-17 |
| 1 代码分析 | 已完成 | [阶段 1 代码分析](阶段1-代码分析-REQ-045_161.md) | 2026-11-17 |
| 2 技术方案 | 已更新（交互可实施，接口待定） | [阶段 2 技术方案](阶段2-技术方案-REQ-045_161.md) | 2026-11-17 |
| 3 编码执行 | 进行中 | [阶段 3 实施记录](阶段3-实施记录-REQ-045_161.md) | — |
| 4 代码审查 | 待开始 | — | — |
| 5 测试基线与覆盖对齐 | 待开始 | — | — |
| 6 测试执行与缺陷修复 | 待开始 | — | — |
| 7 复盘 | 待开始 | — | — |

当前为阶段 3 编码，页面类型弹窗已接入列表，类目频道沿用既有选类目路由，独立页接口待接入。展示模块的拖拽及上下移已接入表单，已接入临时 sort_weight 草稿保存、提交前保存及工作台回显，待后端联调。方案核心：模块双轨制（存量单例不动，新增 Banner/智能体市场走实例层）、统一 displayOrder 排序、agent-market dataKey 参数化复用、新 Banner 独立目录、TDK 追加预置条目；后端接口契约确认清单 C1~C7 已预置不一致时调整策略，均不阻塞编码（TODO: wxj 占位）。

补充沟通产物：[SLUG 下拉化方案（产品业务沟通）](SLUG下拉化方案-产品业务沟通-REQ-045_161.md)。背景：slug 即对外 URL 与接口 path（GET /v1/employer/category-channels/{slug}），现为自由输入；自由输入可能使发布地址与构建时预置的 TDK 地址不一致。产品拍板结论将影响 publish 模块改动设计与契约 C6（TDK 匹配键按 slug）；域名口径已核实为 cs.wdsheng.com，与 R-007 一致。

## 评审问题与不确定项追踪

| 编号 | 优先级 | 现场问题与影响 | 确认方 | 状态 |
|---|---|---|---|---|
| Q-01 | 补充 | TDK 静态预置内容清单（各页面标题／描述／关键词）待产品提供，打包前填入，不阻塞开发。 | 产品 | 待确认 |
| Q-02 | TODO: wxj | SLUG 已与产品当面达成结论：保持现有逻辑、不改为下拉选择。遗留：自定义路径部分是否保留（运营用于微信／小红书／线下活动等渠道来源区分）双方认知仍有偏差，约定再沟通一次；若产品坚持保留，可能催生独立需求。来源：2026-11-18。 | 产品（赵慧娟） | 待沟通 |

## 验证闭环记录

| 阶段 | 对照锚点 | 检查范围 | 发现与处置 | 状态 | 下一阶段 |
|---|---|---|---|---|---|
| 0 | 原始 PRD 正文、配图、一期前端 | 两种页面、配置与审核链路、发布、频道展示、旧入口 | 规则归档至 R-001 至 R-008，冲突和缺失口径列入 Q-01 至 Q-08。核对阶段文件、来源及问题引用。 | 待确认 | 否 |
| 0（R1） | 更新版 PRD、用户确认的 TDK 与子域名口径 | R-007、R-008、Q-05、范围边界及验证重点 | 访问地址配置随 PRD 划线废弃，TDK 改为静态预置不做表单；重写 R-007／R-008 并同步全部引用，Q-05 收敛为子域名变更与 TDK 内容清单。 | 通过 | 否（Q-01 至 Q-08 剩余项待确认） |
| 0（R1 收口） | 用户确认：server 侧问题不阻塞前端 | Q 表、R-002／R-006／R-007／R-008 引用 | 原 Q-01 至 Q-08 收口移除：server 侧职责由服务端处理，Banner 按正文 1200px，页面预览本期不做；仅留 TDK 内容清单并重编号 Q-01，跨文档引用全量同步。 | 通过 | 是 |
| 1 | 阶段 0 需求文档 R1（R-001 至 R-008） | 三仓库知识库检索 + git 锚点增量 + 关键文件实读（注册表、表单壳、列表、创建入口、发布模块、前台渲染、TDK 链路、主站入口） | 每条 R-* 均有现状锚点与差距结论；发现知识库模块数过时（12 模块含需求留言）、底部 Banner 现为固定裁切与新规则区分、独立页 TDK 匹配键待契约；7 项接口对齐项列入阶段 2 清单。 | 通过 | 是 |
| 2 | 阶段 0 R1（R-001 至 R-008）+ 阶段 1 代码分析 | 架构决策 D1~D5、横向影响检查、改动文件清单（三仓库）、关键逻辑 L1~L6、契约清单 C1~C7、开发顺序与风险 | 完整模式方案落盘；存量兼容采用双轨制 + 基线复制；7 项契约均预置调整策略且不阻塞编码；需求留言模块纳入统一排序已显式列出。 | 待确认 | 是（方案确认后进入阶段 3） |

R-008 的实施口径已确认。现有 `wds-web-channel/build/seo-tdk.mjs` 同时供构建预渲染与浏览器使用，当前以 `categoryId=4/9` 匹配。已用项目 HTML 模板在临时目录生成两份静态页，并逐项比对标题、描述和关键词。产品提供页面对应的访问地址及 TDK 文案后，再核对匹配规则是否覆盖独立页，补齐预置配置并验证部署路由。

已确认两个域名内容相互隔离，`cs.wdsheng.com` 仅开放工商财税频道，已确认沿用 `/gscs`，新地址为 `https://cs.wdsheng.com/gscs`。旧链接处理、域名归属校验及越界响应待研发对齐，详见 [SLUG 下拉选择综合方案](SLUG下拉选择综合方案-REQ-045_161.md)。

2026-11-18 已同步每个 item 的排序权重，以及新增 Banner、智能体市场暂共用数组，两类各最多 5 个。前端优先复用现有组件、拖拽和交互。确切字段和映射契约见阶段 2 C3、C5。

## 阶段 3 允许改动文件

当前批次已涉及以下文件，后续批次按技术方案更新清单。

- `wds/wds-admin-web/src/pages/secondary-channel/components/PageTypeDialog.vue`
- `wds/wds-admin-web/src/pages/secondary-channel/form/build-api-config.ts`
- `wds/wds-admin-web/src/pages/secondary-channel/form/components/AddModuleDialog.vue`
- `wds/wds-admin-web/src/pages/secondary-channel/form/index.vue`
- `wds/wds-admin-web/src/pages/secondary-channel/list/index.vue`

- `wds/wds-admin-web/src/components/CropImageUpload.vue`
- `wds/wds-admin-web/src/pages/secondary-channel/form/modules/bottom-banner/index.vue`

- `wds/wds-admin-web/src/pages/secondary-channel/form/modules/agent-market/index.vue`
- `wds/wds-admin-web/src/pages/secondary-channel/form/modules/components/ModuleHeader.vue`

- `wds/wds-admin-web/src/pages/secondary-channel/form/modules/category-list/index.vue`

- `wds/wds-admin-web/src/pages/secondary-channel/form/modules/category-list/types.ts`

- `wds/wds-admin-web/src/pages/secondary-channel/form/modules/publish/index.vue`

- `wds/wds-admin-web/src/pages/secondary-channel/form/modules/recommended-services/index.vue`

- `wds/wds-admin-web/src/pages/secondary-channel/form/components/ModuleOrderActions.vue`

## 本需求文件树

2026-11-18 核对运营后台 HEAD `f12a0589`，共 14 个未提交文件。开发起点待核。原始 QA 输入 [XMind 用例](二级频道页模块优化-待评审.xmind) 单独保留。

```text
wds-admin-web/
└── src/
    ├── components/
    │   └── CropImageUpload.vue [修改] 指定宽度时上传原图
    └── pages/
        └── secondary-channel/
            ├── components/
            │   └── PageTypeDialog.vue [新增] 页面类型选择及名称校验
            ├── form/
            │   ├── build-api-config.ts [修改] 临时排序权重映射
            │   ├── components/
            │   │   ├── AddModuleDialog.vue [新增] 添加模块弹窗及计数
            │   │   └── ModuleOrderActions.vue [新增] 上移、下移及删除按钮
            │   ├── modules/
            │   │   ├── agent-market/
            │   │   │   └── index.vue [修改] 转发实例标题插槽
            │   │   ├── bottom-banner/
            │   │   │   └── index.vue [修改] 实例配置及标题复用
            │   │   ├── category-list/
            │   │   │   ├── index.vue [修改] 独立页图片模式和启停
            │   │   │   └── types.ts [修改] 保留启停状态
            │   │   ├── components/
            │   │   │   └── ModuleHeader.vue [修改] 标题插槽与只读开关
            │   │   ├── publish/
            │   │   │   └── index.vue [修改] 工商财税 SLUG 下拉与历史值回显
            │   │   └── recommended-services/
            │   │       └── index.vue [修改] 独立页启停
            │   └── index.vue [修改] 页面类型、独立页名称原位编辑、排序和本地实例
            └── list/
                └── index.vue [修改] 创建入口和路由

REQ-045_161/
├── workflow-state.md [修改] 阶段进度、允许改动范围与文件树
└── 阶段3-实施记录-REQ-045_161.md [新增] 实施与验证记录
```

独立页已从模块导航和排序中移除「最新服务产品」。逐项待办、本批完成独立页图片模式、启停和工商财税 SLUG 选择。类型筛选待接口，阶段出口门禁因 ESLint 依赖缺失未通过。实施细节和验证边界见 [阶段 3 实施记录](阶段3-实施记录-REQ-045_161.md)。

2026-11-19 补充 [频道前台适配方案](阶段2-频道前台适配方案-REQ-045_161.md)，覆盖新增模块、排序、组件复用、独立页、域名及 TDK，数据适配层已实施并验证，页面模板已接入，浏览器验证待执行。

频道前台允许改动文件新增 `wds/wds-web-channel/src/views/sub-channel/channel-modules.ts`。适配层已通过独立执行验证，待页面接入。
```text
wds-web-channel/
└── src/
    └── views/
        └── sub-channel/
            ├── channel-modules.ts [新增] 权重及实例适配
            └── index.vue [修改] 内容模块按权重渲染，底部固定
```

## 需求变更日志

| 版本 | 日期 | 变更 | 结果 |
|---|---|---|---|
| R0 | 2026-11-10 | 登记原始需求和评审问题 | 等待评审更新 |
| R1 | 2026-11-17 | PRD 更新：查重限独立页自定义名称，已有智能体市场不占新增名额；访问地址配置划线废弃，改为仅工商财税 channel→cs 子域名调整；TDK 收口为静态预置进打包前配置，不做动态表单，内容待产品提供 | 重写 R-007／R-008，收敛 Q-05，阶段 0 升版重验；其余评审项仍待确认 |
| R1 | 2026-11-17 | 评审问题收口：server 侧职责不阻塞前端，前端按正常业务逻辑实现；Banner 按正文 1200px，页面预览本期不做 | Q 表仅留 TDK 内容清单（重编号 Q-01），阶段 0 完成，可进入阶段 1 |

---
**文档版本** v1.6  
**最后更新** 2026年11月  
**整理人** 王新骏

频道前台新增允许改动文件 `wds/wds-web-channel/src/views/sub-channel/index.vue`。旧模块及新增实例按临时权重统一渲染，留言单独参与排序。SFC 编译及混排执行验证通过，真实接口和浏览器待验。
