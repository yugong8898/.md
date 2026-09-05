# 二级频道页 — 工作清单（内容运营模块 · 王新骏）

## 目录

- [1. 工作范围与边界](#1-工作范围与边界)
- [2. 公共件（三模块共用，最先做）](#2-公共件三模块共用最先做)
- [3. 智能体市场](#3-智能体市场)
- [4. 活动专区](#4-活动专区)
- [5. 行业资讯](#5-行业资讯)
- [6. 2026-09 数量表调整](#6-2026-09-数量表调整)
- [7. 待确认事项](#7-待确认事项)

---

## 1. 工作范围与边界

### 1.1 我负责的

`es-ops-platform` 二级频道配置页中三个模块，每个模块交付**四件套**（当前均为占位）：

| 模块 | 目录 | 数量上限 |
|---|---|---|
<!-- 旧（2026-09 数量表调整前）：智能体 ≤ 6 个 / 文章 ≤ 8 篇；活动专区「活动 ≤ 3 个，服务产品 ≤ 6 个」 -->
| 智能体市场 | `src/pages/secondary-channel/form/modules/agent-market/` | 智能体固定配置 3 个（2026-09 数量表；是否强制恰好 3 见待确认 #18） |
| 活动专区 | `src/pages/secondary-channel/form/modules/activity-zone/` | 活动 Banner 仅提醒最多 3 个（不硬拦截）；服务产品两类雇主分别至少 5 个（分类计数提醒），后台配置上限 6 个 |
| 行业资讯 | `src/pages/secondary-channel/form/modules/industry-news/` | 文章 ≤ 9 篇 |

四件套职责：

| 文件 | 交付内容 |
|---|---|
| `index.vue` | 表单编辑态全部交互 + **`readonly` 只读模式**（不单独新建 `readonly.vue`） |
| `types.ts` | 模块数据结构（字段名占位，联调集中替换） |
| `validate.ts` | 导出 `validateModule(formData): Promise<{ valid, message? }>`，只写本模块校验 |
| `submit.ts` | 导出 `buildModulePayload(formData): { moduleKey, data }`，只写本模块提交结构 |

### 1.2 我不碰的（工作边界）

| 内容 | 归属 |
|---|---|
| 菜单/路由/权限、频道列表、审核列表、三个详情页、初审/复审弹窗、公共 API 与状态枚举 | 梁树强（只消费） |
| 大表单外壳 `form/index.vue`、模块注册表 `module-registry.ts`、总校验、总提交 | 张立（只按注册契约接入） |
| 顶部轮播/底部 Banner | 汪明刚 |
| 类目列表/推荐服务/最新服务 | 罗永江 |
| 底部配置/SEO/发布配置 | 张立 |

### 1.3 关键约定

- 数据挂 `formData.modules[moduleKey]`，`moduleKey` = `agent-market` / `activity-zone` / `industry-news`（与注册表一致）。
- 保存草稿**不校验**；提交审核由总校验链逐模块调用 `validate.ts`，失败定位到本模块。
- 图片统一规则：PNG / JPG / JPEG、单张 ≤ 20MB、上传成功预览、失败/未传展示缺省态。
- **三模块的图片上传统一使用统一上传组件（`ChannelImageUpload`，见第 2 节）**，模块内不各自实现上传逻辑。
- 链接统一规则：标准网址格式校验、禁止危险脚本链接、前台新窗口打开。
- 模块开关关闭后**数据保留**，重新启用恢复；查看更多关闭后**已填链接保留**。
- **只读模式**：不新建 `readonly.vue`，在 `index.vue` 上加 `readonly` prop（默认 `false`）。只读态：隐藏新增/编辑/删除/开关等操作项，输入转纯文本展示，保留图片预览与可点击链接（新窗口打开）。详情页引用模块组件传 `readonly` 消费；该消费方式与原「五件套」协作规则不同，需与梁树强/张立同步（待确认 #9）。

---

### 2. 公共件（三模块共用，最先做）

放置位置：`src/pages/secondary-channel/form/components/`（目录约定先与张立对齐）。

| 公共件 | 具体行为 |
|---|---|
| 模块表头组件 | ① 启用/禁用 `el-switch`；② 前台展示名称输入框（启用时必填红星 + 必填校验，禁用时置灰）；③ 对外暴露 `enabled` / `displayTitle` 双向绑定 |
| 查看更多组件 | ① 「查看更多」开关；② 开启时展示链接输入框（网址格式校验）；③ 关闭时输入框隐藏但**值不清空** |
| 统一图片上传组件 | **三模块（智能体封面 / 活动 Banner 图片 / 资讯封面）统一使用本组件**，模块内不各自实现上传。文件暂定 `form/components/ChannelImageUpload.vue`（目录约定与张立对齐后可调整）。行为：① 点击上传，校验格式（非 PNG/JPG/JPEG 提示「仅支持 PNG、JPG、JPEG 格式」）与大小（>20MB 提示「图片大小不能超过 20MB」）；② 成功展示缩略图 + 预览（点击放大）+ 替换/删除操作；③ 上传中 loading；④ 加载失败/未上传展示缺省占位；⑤ 对外暴露 `v-model`（图片 URL）供编辑态绑定，另暴露 `readonly` 只读态（仅缩略图 + 预览，无上传/替换/删除），供三模块 `index.vue` 只读模式复用。实现优先基于项目已有能力封装：OSS 上传（`src/api/oss`）+ `marketing-position` 的 `ImagePreviewViewer` 预览 |
| 链接校验工具 | 标准网址格式校验（`http/https` 开头 + 合法域名格式），错误提示「请输入正确的网址格式」；统一供三个模块 `validate.ts` 与表单失焦校验复用 |

### 公共件任务勾选（三模块开发前置完成）

- [x] 模块表头组件（开关 + 展示名称双向绑定）
- [x] 查看更多组件（开关 + 链接，关闭不清空值）
- [x] **统一上传组件 `ChannelImageUpload`**（基于 OSS 上传 + `ImagePreviewViewer` 封装，三模块唯一上传入口）
- [x] 链接校验工具
- [ ] 确认组件命名与目录约定（待确认 #14）

---

## 3. 智能体市场

### 3.1 数据结构（`types.ts`，字段名对齐服务端）

```ts
interface AgentMarketModuleData {
  display_name: string;        // 模块展示名称
  enabled: boolean;            // 模块启用/禁用
  items: AgentCardDTO[];       // 智能体卡片列表，固定配置 3 个（2026-09 数量表；旧 ≤6）
  more_link: MoreLinkConfig;   // 查看更多配置
}

interface AgentCardDTO {
  agent_id: string;            // Agent ID（MANUAL 时为空字符串）
  description: string;         // 展示描述
  enabled: boolean;            // 单个智能体启用状态
  image: AgentCardImage;       // 卡片图片
  link: JumpLink;              // 点击跳转
  local_id: string;            // 版本内稳定本地 ID
  name: string;                // 展示名称
  sort_no: number;             // 排序号
  source_type: 'MANUAL' | 'AGENT';  // 来源类型
}
```

### 3.2 `index.vue` 页面结构

```
[模块表头：启用/禁用 + 前台展示名称]
[新增智能体] 按钮（达到 3 个时置灰，提示「最多配置 3 个智能体」；2026-09 数量表，旧 6 个）
[智能体列表（拖拽排序）]
[查看更多组件]
```

### 3.3 智能体新增/编辑弹窗（独立子组件 `AgentEditDialog.vue`）

| 字段 | 必填 | 控件 | 限制 |
|---|---|---|---|
| 智能体名称 | ✅ | `el-input` | 用于前台展示；长度上限待原型确认 |
| 智能体简介 | ❌ | `el-input` textarea | 建议 ≤ 100 字符，带字数统计 |
| PC 端封面图 | ❌ | 统一上传组件（`ChannelImageUpload`） | 格式/大小按 1.3；上传成功预览；建议尺寸 800×600px（2026-09 数量表，裁剪比例按像素 4:3） |
| 跳转链接 | ❌ | `el-input` | 失焦校验网址格式；前台新窗口打开 |
| 启用状态 | ✅ | `el-switch` | 默认开启 |

交互：
- 新增时默认：启用状态 = 开启；
- 编辑回填弹窗；保存校验名称必填、链接格式；
- 弹窗校验失败不关闭，定位错误项；
- 展示顺序不在弹窗内配置，通过列表拖拽完成。

### 3.4 智能体列表（行式卡片布局 + 原生 HTML5 拖拽排序）

显示列：
- 智能体名称（过长省略 + 悬停查看）
- 简介（过长省略 + 悬停查看）
- 封面图（缩略图，点击预览；未配置展示缺省）
- 启用状态（`el-tag` 启用/禁用）
- 操作（启用/禁用切换、编辑、删除）

交互：
- 启用/禁用切换即时生效，禁用项**配置保留**、前台不展示；
- 删除：`ElMessageBox.confirm`「确认删除该智能体？删除后前台不再展示。」，确认后移除；
- 拖拽排序：按住拖拽把手重排，拖完直接按新数组顺序提交。

### 3.5 `validate.ts` 校验规则（提交审核时执行）

| # | 规则 | 提示文案 |
|---|---|---|
| 1 | 模块禁用 → 直接通过 | — |
| 2 | 启用时 `display_name` 必填 | 「请填写前台展示名称」 |
| 3 | 智能体数量 ≤ 3（2026-09 数量表；旧 ≤6） | 「智能体最多配置 3 个」 |
| 4 | 每个智能体 `name` 必填 | 「存在未填写名称的智能体」 |
| 5 | `link.url` 有值时必须格式合法 | 「智能体跳转链接格式不正确」 |
| 6 | 开启查看更多时 `more_link.link.url` 必填且格式合法 | 「请填写查看更多链接 / 链接格式不正确」 |

### 3.6 `submit.ts` payload（对齐服务端结构）

```ts
{
  apiKey: 'agent-market',
  data: {
    display_name: string,
    enabled: boolean,
    items: AgentCardDTO[],  // 按数组顺序提交
    more_link: MoreLinkConfig,
  },
  overridesBaseline: false,
}
```

### 3.7 只读模式（`index.vue` `readonly` prop）

- 表头：模块启用状态 + 前台展示名称（纯展示，开关/输入框不可操作）；
- 智能体卡片列表（按数组顺序）：封面图（预览/缺省态）、名称、简介、跳转链接（可点击、新窗口）；操作列和拖拽把手隐藏；
- 查看更多：开启时展示可点击链接；
- 模块禁用时展示「模块已禁用」状态标识（具体形态与梁树强详情页风格对齐）。

### 3.8 任务勾选

- [x] `types.ts` 数据结构（对齐服务端字段 `display_name/items/description/image/link/local_id/sort_no`）
- [x] 模块表头 + 查看更多接入
- [x] `AgentEditDialog.vue` 新增/编辑弹窗
- [x] 智能体列表 + 启用禁用/编辑/删除
- [x] 排序实现（原生 HTML5 拖拽）
- [x] `validate.ts`（3.5 六条规则）
- [x] `submit.ts`（3.6 结构，字段名对齐服务端）
- [x] `index.vue` readonly 只读模式（3.7 内容）
- [x] 工作清单已同步更新
- [ ] 产品确认：名称长度上限（当前设为 999，待确认 #12）

---

## 4. 活动专区

### 4.1 数据结构（`types.ts`，字段名占位）

```ts
interface ActivityZoneModule {
  enabled: boolean;              // 模块启用/禁用
  displayTitle: string;          // 前台展示名称
  showActivityBanner: boolean;   // 是否展示活动 Banner
  activities: SelectedActivity[]; // 已选活动，≤3
  services: SelectedService[];    // 已选服务产品，≤6，数组顺序即前台顺序
  showMore: boolean;
  showMoreLink: string;
}

interface SelectedActivity {
  activityId: string;
  activityName: string;
  status: string;                // 未开始/进行中（检索时带回）
  startTime: string;
  endTime: string;
  bannerImage: string;           // 频道页展示图片（开启展示活动 Banner 时必填）
}

interface SelectedService {
  serviceId: string;
  serviceName: string;
  providerName: string;
}
```

### 4.2 `index.vue` 页面结构

```
[模块表头：启用/禁用 + 前台展示名称]
┌ 活动选择区 ────────────────────────────
│ 「展示活动 Banner」开关
│ [添加活动] 按钮（开关关闭时置灰；已选 3 个时置灰）
│ 已选活动卡片：活动名称/状态/活动时间 + 展示图片上传 + 删除
└────────────────────────────────────
┌ 活动服务产品区 ────────────────────────
│ [选择服务产品] 按钮（已选 6 个时置灰）
│ 已选服务表格：服务名称/服务 ID/服务商名称 + 删除 + 拖拽排序
└────────────────────────────────────
[查看更多组件]
```

<!-- 旧（2026-09 需求调整：活动与服务产品改为强关联，见 4.12）：- 两区域**独立配置，互不限制**；模块整体开关控制前台是否展示。 -->
- 服务产品区**强依赖已选活动**（关联规则见 4.12）；模块整体开关控制前台是否展示。

### 4.3 「展示活动 Banner」开关联动

| 开关状态 | 行为 |
|---|---|
| 打开 | 「添加活动」可用；提交校验：至少 1 个活动 + 每个活动展示图片必填 |
| 关闭 | 「添加活动」按钮置灰（提示「开启展示活动 Banner 后可添加活动」）；**已选活动数据保留不清空**；不影响服务产品区 |

### 4.4 活动选择弹窗（独立子组件，如 `ActivitySelectDialog.vue`）

- 数据源：活动管理中状态为「未开始 / 进行中（已上线）」的活动（检索接口归属见待确认 #8）；
- 顶部按**活动名称**搜索；分页**每页 5 条**；
- 列表列：

| 列 | 说明 |
|---|---|
| 勾选 | 多选，**最多 3 个**（含已选），达到上限后其余复选框置灰并提示「最多选择 3 个活动」 |
| 活动名称 | — |
| 状态 | 未开始 / 进行中 |
| 活动时间 | 起止时间 |
| 适用用户范围 | 已认证雇主 / 未认证雇主 / 指定雇主（指定雇主展示覆盖数量，如「指定雇主（12）」） |
| 服务适用范围 | 「按类目选择」时悬停 `el-popover` 展示具体适用类目 |

- 已选活动再次勾选时视为保持选中；确认添加后写入已选区。

### 4.5 已选活动卡片

- 展示：活动名称、状态、活动时间、频道页展示图片（上传位）；
- 展示图片：统一上传组件（`ChannelImageUpload`）；开启「展示活动 Banner」时必填（卡片上红星标识）；建议尺寸 940×560px（2026-09 数量表，裁剪比例按像素 ≈1.68:1）；
<!-- 旧（2026-09 需求调整：活动增删改为清空已选服务产品，见 4.12）：- 删除：确认弹窗「确认移除该活动？移除后不影响已选服务产品。」——**删除活动不影响已选服务产品**。 -->
- 删除：确认弹窗「确认移除该活动？移除后将清空已选服务产品，需重新选择。」——**删除活动后清空已选服务产品**（见 4.12）。

### 4.6 服务产品选择弹窗（独立子组件，如 `ServiceSelectDialog.vue`）

> ✅ 2026-09 接口就绪：本节「名称/服务 ID 检索」「关联活动列」已由 `GET options/activity-products` 落实（实际内联在 `ServiceProductCard.vue`，非独立弹窗），详见 4.15。

<!-- 旧（2026-09 需求调整：服务产品列表改为强依赖已选活动，见 4.12）：- **无需先选择活动**，直接从当前活动中的全部服务产品选择； -->
- **依赖已选活动**：未选活动时不请求列表接口，表格展示「请先添加活动」空态（见 4.12）；列表入参带活动 id list；
- 支持按**服务产品名称或服务 ID** 检索；分页**每页 5 条**；
- 列表列：勾选（最多 6 个，含已选）、服务名称、服务 ID、服务商名称、关联活动；
- 已选服务不可重复勾选（置灰）。

### 4.7 已选服务表格

| 列 | 说明 |
|---|---|
| 拖拽手柄 | 拖拽排序（依赖库待确认 #5），排序结果即前台展示顺序 |
| 服务名称 / 服务 ID / 服务商名称 | — |
| 操作 | 删除（确认弹窗）；重新选择（打开服务选择弹窗） |

### 4.8 `validate.ts` 校验规则

| # | 规则 | 提示文案（建议） |
|---|---|---|
| 1 | 模块禁用 → 直接通过 | — |
| 2 | 启用时 `displayTitle` 必填 | 「请填写前台展示名称」 |
| 3 | 活动 ≤ 3、服务 ≤ 6（防兜底，正常添加时已拦截） | 「活动最多 3 个 / 服务产品最多 6 个」 |
| 4 | **模块启用时活动 ≥ 1**（不依赖 Banner 开关，服务产品数据源强依赖活动；2026-09 新增，见 4.12；兼顾拦截老草稿「无活动但有服务」脏数据） | 「请至少添加 1 个活动」 |
| 5 | 模块开启至少选择活动服务产品：2026-09 数量表明确为「已认证 / 未认证两类雇主分别至少 5 个」，分类计数已在 `ServiceProductCard` 的 el-alert 展示（仅提醒）；提交校验暂按平面 ≥1（`SERVICE_MIN_COUNT`），是否加「两类分别 ≥5」硬校验见待确认 #1、#18 | 「请至少选择 N 个活动服务产品」 |
| 6 | 开启「展示活动 Banner」时：活动 ≥ 1（规则 4 已覆盖，保留作 Banner 语义兜底） | 「请至少添加 1 个活动」 |
| 7 | 开启「展示活动 Banner」时：每个活动 `bannerImage` 必传 | 「活动「xx」未上传展示图片」 |
| 8 | 查看更多开启时链接必填且格式合法 | 「请填写查看更多链接 / 链接格式不正确」 |

<!-- 旧（2026-09 需求调整前为七条，见 4.12）：规则 4 服务产品 ≥ N / 规则 5 Banner 开启时活动 ≥ 1 / 规则 6 Banner 开启时展示图必传 / 规则 7 查看更多链接，序号顺移 -->

### 4.9 `submit.ts` payload 草案

```ts
{
  moduleKey: 'activity-zone',
  data: {
    enabled, displayTitle, showActivityBanner,
    activities: activities.map(a => ({ activityId, activityName, bannerImage })),
    services: services.map(s => ({ serviceId, serviceName, providerName })),  // 数组顺序即排序结果
    showMore, showMoreLink,
  },
}
```

### 4.10 只读模式（`index.vue` `readonly` prop）

- 表头：模块启用状态 + 前台展示名称 + 是否展示活动 Banner 标识（纯展示）；
- 活动列表：名称、状态、活动时间、展示图片（预览/缺省）；删除/上传入口隐藏；
- 服务列表：服务名称、服务 ID、服务商名称（按排序结果）；拖拽手柄与删除隐藏；
- 查看更多链接（可点击、新窗口）。

### 4.11 任务勾选

- [x] `types.ts` 数据结构
- [x] 模块表头 + 两区域框架 + 查看更多
- [x] 「展示活动 Banner」开关联动（4.3）
- [x] `ActivitySelectCard.vue` 活动选择卡（4.5）
- [x] `ActivitySelectDialog.vue` 活动选择弹窗（4.4，~~使用 Mock 数据~~ → 已对接真实接口，见 4.14）
- [x] `ServiceProductCard.vue` 服务产品卡（4.7）
- [x] 已选活动卡片 + 图片上传 + 删除（4.5）
- [x] 已选服务表格 + 拖拽排序（4.7）
- [x] `validate.ts`（4.8，原七条；2026-09 调整为八条，见下）
- [ ] `validate.ts` 新增规则 4「启用时活动 ≥ 1」（4.12 历史脏数据同步处理）
- [x] `submit.ts`（4.9 结构，字段名待确认 #11）
- [x] `index.vue` readonly 只读模式（4.10 内容）
- [x] `select-api.ts` + `mock.ts`（临时 Mock 数据）
- [ ] **后端提供**：~~活动检索接口（待确认 #7, #8）~~ → ✅ 已就绪，`GET /api/v1/admin/category-channels/options/category-activities`（见 4.14）
- [x] **后端提供**：~~服务产品检索接口（待确认 #7, #8）~~ → ✅ 已就绪，`GET /api/v1/admin/category-channels/options/activity-products`（见 4.15）
- [ ] 活动与服务产品强关联（4.12）：index.vue watch activityId 集合 → 静默清空已选服务产品（含编辑态回显首跳保护）
- [ ] 活动与服务产品强关联（4.12）：服务产品列表请求 gating（无活动不请求）+ 活动变化重置第 1 页重新拉取
- [x] 活动与服务产品强关联（4.12）：~~`getPublicProductList` 入参补活动 id list（占位 `activity_ids`，待确认 #15）~~ → 改用专用接口 `options/activity-products`，`activity_ids` 为正式入参（见 4.15）+ 相关旧文案调整
- [ ] 活动与服务产品强关联（4.12）：`validate.ts` 新增「启用时活动 ≥ 1」校验（同步处理历史草稿脏数据风险）
- [ ] 产品确认：最少服务产品数 N 值（待确认 #1）
- [ ] 后端确认：字段名映射（待确认 #11）
- [ ] 接口就绪后：删除 `mock.ts`（`PUBLIC_ACTIVITYS` / `PUBLIC_PRODUCTS` 均已孤立、无引用），将 `USE_ACTIVITY_SELECT_MOCK` 改为 `false`

### 4.12 活动与服务产品强关联（2026-09 需求调整）

> 背景：原设计两卡独立、互不限制；调整为服务产品强依赖已选活动。

| 规则 | 行为 |
|---|---|
| 列表入参 | **（2026-09 接口就绪，见 4.15）** 已改用专用接口 `GET /api/v1/admin/category-channels/options/activity-products`：`activity_ids` = 已选活动 `activityId` 集合，为正式入参（重复 query key，服务端去重，1~50），待确认 #15 字段名/传参已明确。<br>~~旧：服务产品列表接口（`getPublicProductList`，`GET /api/v1/products-public`）新增活动 id list 入参，占位名 `activity_ids`，待确认 #15~~ |
| 清空联动 | 活动 id 集合有变化（新增/删除/换选）→ **静默清空**已选服务产品 `product`；集合不变（含仅顺序变化、弹窗原样确认）→ 不清空；「展示活动 Banner」开关切换不算增删，不清空 |
| 落位（一处维护） | `index.vue` watch「banner 的 activityId 排序后拼接 key」：集合变化时 `patchModuleData({ product: [] })`；**编辑态回显首跳保护**：外壳详情数据异步 hydrate，watch 第一次触发（空→有）跳过不清空；只读态不清空不请求 |
| 请求 gating | 未选活动（banner 为空）时不请求列表接口（含 onMounted / 搜索 / 翻页入口），表格展示「请先添加活动」空态；活动从空变有 → 重置第 1 页发起请求；活动集合变化 → 重置第 1 页重新拉取 |
| 实施口径（2026-09 定稿） | ① 只读态 + 无活动：保持现状（不请求、无引导文案，只展示已选区空态）；② 搜索框无活动时保持可用，请求由 gating 拦截；③ 删除活动保留二次确认弹窗，文案不带清空数量 |
| Mock 分支 | gating 对 mock（`PUBLIC_PRODUCTS`）同样生效；mock 出参无活动关联字段，不做按活动 id 过滤（代码 `TODO: wxj`，真实接口联调时验证） |
| 文案调整 | 删除活动确认弹窗、ActivitySelectCard banner 开关 hint、index.vue 头注释「互不限制」、ServiceProductCard subtitle 等处旧文案随本次一并调整（旧文案注释保留） |
| 校验同步（历史脏数据） | `validate.ts` 新增规则 4「模块启用时活动 ≥ 1」（置于服务产品 ≥ N 之前，不依赖 Banner 开关），拦截旧规则遗留的「无活动但有服务产品」老草稿提交；规则序号由七条变八条（见 4.8） |

### 4.13 活动选择卡表格化 + 跳转链接 / 适用用户范围（2026-09 需求调整）

> 背景：`ActivitySelectCard.vue` 由卡片式改为表格式；新增「跳转链接 link」与「适用用户范围 userScopeName」两字段。本次改动大，卡片旧结构直接覆盖重写（已获豁免「注释保留」）。

| 项 | 行为 |
|---|---|
| 布局改造 | 卡片式 flex → 表格式 grid，列 = 排序（拖拽）｜活动信息｜展示图片｜跳转链接｜操作；表头与数据行共用同一套 `grid-template-columns` 保证列对齐 |
| 新增 link（跳转链接） | 运营可编辑、**选填**；编辑态 `el-input`（placeholder `https://（选填）`），失焦有值才走 `validateChannelLink` 校验；提交进 payload（`submit.ts` 已含 `link`）。后端是否接受前端传入该字段待确认（待确认 #16，代码 `TODO: wxj`） |
| 新增 userScopeName（适用用户范围） | 活动信息列第二行展示（如「未认证雇主」）；弹窗选择时经 `userScopeDisplayText` 带回，**仅展示不进提交**（同 status / 时间）；`types.ts` 加字段、normalize 补 `?? ''` 映射 |
| meta 精简 | 活动信息 meta 行只保留「时间 · userScopeName」，不再展示 status / productScopeName |
| 展示图片必填星 | 列头 `*` 仅在「展示活动 Banner」开启时显示 |
| 只读态 link | 转纯文本可点击 `<a target="_blank">`（新窗口打开）；无值展示 `—` |
| 拖拽排序 | 原生 HTML5 DnD，复用 `ServiceProductCard` 套路（把手 mousedown 激活 + 让位预览 + dragend 一次性写回）；**仅重排、activityId 集合不变 → 不触发 4.12 服务产品清空** |
| 校验同步 | `validate.ts` 新增规则 8「活动 link 选填、有值才校验格式」，原「查看更多链接」顺延为规则 9；规则由八条变九条 |

### 4.14 活动选择弹窗接口对接（2026-09 接口就绪）

> 背景：后端提供「按一级类目查询频道页配置活动候选」接口，`ActivitySelectDialog.vue` 从 Mock 数据切换为真实接口。

**接口信息**：

| 项 | 内容 |
|---|---|
| 路径 | `GET /api/v1/admin/category-channels/options/category-activities` |
| 入参 | `category_code`（一级类目 ID）、`keyword`（活动名称模糊）、`page`、`page_size`、`selected_ids`（跨页回显已选 ID，重复 query key） |
| 出参 | `{ count, list: ActivityOptionDTO[] }` |
| 前端 API 文件 | `src/api/secondary-channel/category-activities-api.ts`（新建） |

**出参字段 → 表格列映射**：

| 出参字段 | 表格列 | 旧实现 | 新实现 |
|---|---|---|---|
| `activity_id` | row-key | `toEspId(row.activityId)` | `row.activity_id` 直取 |
| `name` | 活动名称 | `row.activityName` | `row.name` |
| `status` | 状态 | 数字枚举 `activityStatus` + 前端映射表 | **服务端文案直出**（「未开始」/「进行中」） |
| `start_at` / `end_at` | 活动时间 | `startTime` / `endTime`（本地格式） | RFC3339，前端 `formatDateTimeOrDash` 转展示 |
| `employer_scope_type` | 适用用户范围 | 数字 `userScopeType` + `formatUserScopeTypeLabel` | **服务端文案直出** |
| `service_scope_type` | 服务适用范围 | 数字 `sourceScopeType` + 前端映射表 | **服务端文案直出**（恒为「按类目选择」） |
| `category_scope_paths` | 类目 popover | 悬停时二次请求 `getActivityDetail` | **内联返回**，无需二次请求 |
| `selected` | 跨页回显 | 前端 `selectedIds.has()` 单一判断 | 服务端标记 + 本地双重校验 |

**简化效果**（移除的旧逻辑）：

| 移除项 | 原因 |
|---|---|
| `ACTIVITY_STATUS_TEXT` 枚举映射表 | 状态由服务端文案直出 |
| `PRODUCT_SCOPE_TEXT` 枚举映射表 | 服务范围由服务端文案直出 |
| `formatUserScopeTypeLabel` 调用 | 用户范围由服务端文案直出 |
| `getActivityDetail` + `loadCategories` + `categoryTags` 缓存 + `categoryLoadingKeys` 防重 | 类目详情内联返回 |
| `toEspId` 雪花 ID 转换 | 新接口直接返回字符串 ID |
| `PUBLIC_ACTIVITYS` Mock 数据引用 | 切换为真实接口 |
| `@/api/activity` 相关 import | 不再依赖活动管理模块接口 |

**`category_code` 传参链路**：

```
form/index.vue (categoryId ref)
  → provide via SecondaryChannelFormContext.categoryId
    → activity-zone/index.vue (从 context 取 categoryId)
      → ActivitySelectCard (:category-code prop)
        → ActivitySelectDialog (:category-code prop → 接口入参)
```

**影响范围**：

| 文件 | 改动类型 |
|---|---|
| `src/api/secondary-channel/category-activities-api.ts` | **新建**：类型 + 请求函数 |
| `src/api/secondary-channel/index.ts` | barrel export 新增一行 |
| `src/pages/.../composables/useSecondaryChannelFormContext.ts` | context 接口新增 `categoryId: Ref<string>` |
| `src/pages/.../form/index.vue` | provide 时注入 `categoryId` |
| `src/pages/.../activity-zone/index.vue` | 从 context 取 `categoryId`，传 prop |
| `src/pages/.../activity-zone/components/ActivitySelectCard.vue` | 新增 `categoryCode` prop 透传 |
| `src/pages/.../activity-zone/components/ActivitySelectDialog.vue` | **核心重写**：新接口 + 新出参适配 |

### 4.15 服务产品接口对接（2026-09 接口就绪）

> 背景：后端提供「按活动查询频道页配置服务候选」接口，`ServiceProductCard.vue` 从 Mock 数据（`PUBLIC_PRODUCTS`）切换为真实接口。与 4.14 同族（`options/*`），API 文件镜像 `category-activities-api.ts`（单文件内联类型 + 信封 `resolveEspModelOrData` + 雪花 ID 保精度）。

**接口信息**：

| 项 | 内容 |
|---|---|
| 路径 | `GET /api/v1/admin/category-channels/options/activity-products` |
| 入参 | `activity_ids`（已选活动 ID 列表，1~50，重复 query key，服务端去重）、`keyword`（服务名称关键字或精确服务编号）、`page`、`page_size`（默认 20，最大 100） |
| 出参 | `{ count, list: ActivityProductOptionDTO[] }` |
| 前端 API 文件 | `src/api/secondary-channel/activity-product-options-api.ts`（新建） |

**出参字段 → UI 映射**：

| 出参字段 | 用途 | 旧实现 | 新实现 |
|---|---|---|---|
| `product_id` | 服务 ID 列 / row-key | mock `id` | `toEspId(product_id)`（雪花保精度） |
| `name` | 服务名称列 | mock `name` | `name` 直取 |
| `provider_name` | 服务商列 | mock | `provider_name` |
| `related_activities[].activity_name` | 关联活动列 | 写死空数组 | `.map(activity_name).filter(Boolean)`，顿号连接 |
| `user_scope_types` | 已认证/未认证计数 alert | 硬编码「0/5」 | 动态计数（勾选写入 `product[].userScopeTypes`） |
| `service_no` | 搜索支持编号 | 无（仅名称） | `keyword` 支持名称/编号，placeholder 改「搜索服务名称/编号」 |

**简化 / 停用的旧逻辑**（注释保留）：

| 项 | 说明 |
|---|---|
| `getPublicProductList`（`GET /api/v1/products-public`）+ `activity_ids` 占位过滤 | 旧方案注释保留；`getPublicProductList` 仍被 `recommended-services/select-api.ts` 共用，未删 |
| `PUBLIC_PRODUCTS` Mock 引用 | import 注释保留；`mock.ts` 该导出已孤立（无其他引用） |

**认证计数（el-alert）口径**：

- 已选服务按 `userScopeTypes` 精确匹配「已认证雇主」「未认证雇主」两桶计数，「指定雇主」不计入任一桶。
- alert 分母 = `SERVICE_USER_SCOPE_TARGET = 5`（对应 2026-09 数量表「两类雇主各至少 5 个」）。
- **仅展示提醒，不参与 validate 硬校验**（提交校验仍用平面 `SERVICE_MIN_COUNT ≥ 1`，完整分类校验待办见待确认 #1）。
- **已知限制**：`userScopeTypes` 仅在「本次会话勾选」时写入 `product`；编辑态回显时后端 `product` 不含 `user_scope_types`（activity-zone `overridesBaseline=false`、product 不进 config），故回显态计数可能为 0，待后端 save/load 完整对接后补。

**影响范围**：

| 文件 | 改动类型 |
|---|---|
| `src/api/secondary-channel/activity-product-options-api.ts` | **新建**：类型 + 请求函数 |
| `src/api/secondary-channel/index.ts` | barrel export 新增一行 |
| `src/pages/.../activity-zone/types.ts` | `ProductDTO`/`ServiceOptionRow` 加 `userScopeTypes`；新增 `SERVICE_USER_SCOPE_TARGET`/`USER_SCOPE_CERTIFIED`/`USER_SCOPE_UNCERTIFIED` 常量；normalize 映射 |
| `src/pages/.../activity-zone/components/ServiceProductCard.vue` | **核心接入**：换接口 + 关联活动列 + 动态 alert + 勾选持久化 `userScopeTypes` |

**待联调验证点**：

| # | 点 | 说明 |
|---|---|---|
| 1 | `activity_ids` GET 数组序列化 | 接口要求「重复 query key」；axios 1.8.4 默认序列化为 `activity_ids[]=`（带方括号）。与 4.14 `selected_ids` 一致直接传数组、未加 `paramsSerializer`；若后端只认无括号重复 key，两个 options 接口需统一加 `qs` `arrayFormat:'repeat'` |
| 2 | `activity_ids` 上限 50 | 当前 banner 活动数无 50 上限拦截（正常业务不超）；待产品确认 banner 是否可能超 50 |

---

## 5. 行业资讯

### 5.1 数据结构（`types.ts`，字段名占位）

```ts
interface IndustryNewsModule {
  enabled: boolean;          // 模块启用/禁用
  displayTitle: string;      // 前台展示名称
  articles: ArticleItem[];   // 文章列表，≤9（2026-09 数量表；旧 ≤8）
  showMore: boolean;
  showMoreLink: string;      // 可填内容社区首页/列表页等
}

interface ArticleItem {
  id?: string;
  coverImage: string;        // 封面图，必填
  title: string;             // 文章名称，必填，≤25 中文字符
  author: string;            // 作者名称，必填
  link: string;              // 跳转链接，必填
  createdAt?: string;        // 时间（接口返回展示用，字段以接口为准，待确认 #4）
}
```

### 5.2 `index.vue` 页面结构

```
[模块表头：启用/禁用 + 前台展示名称]
[新增文章] 按钮（达到 9 篇时置灰，提示「最多配置 9 篇文章」；2026-09 数量表，旧 8 篇）
[文章列表]
[查看更多组件]
```

- 模块禁用不删除已配置文章与查看更多链接。

### 5.3 文章新增/编辑弹窗（独立子组件，如 `ArticleEditDialog.vue`）

| 字段 | 必填 | 控件 | 限制 |
|---|---|---|---|
| 封面图 | ✅ | 统一上传组件（`ChannelImageUpload`） | 格式/大小按 1.3；成功预览；建议尺寸 600×400px（2026-09 数量表，裁剪比例 3:2） |
| 文章名称 | ✅ | `el-input` | **最多 25 个中文字符**，超长禁止输入 + 字数统计 |
| 作者名称 | ✅ | `el-input` | — |
| 跳转链接 | ✅ | `el-input` | 网址格式校验；前台新窗口打开 |

交互：四字段任一未填不允许保存；编辑回填；保存后刷新列表。

### 5.4 文章列表（`el-table`）

| 列 | 说明 |
|---|---|
| 封面图 | 缩略图，点击预览 |
| 文章名称 | 单行省略 + `show-overflow-tooltip` 悬停查看完整 |
| 作者名称 | — |
| 时间 | 字段以接口返回为准（待确认 #4：创建时间 vs 发布时间） |
| 操作 | 编辑、删除（确认弹窗「确认删除该文章？」） |

排序：后台配置顺序即前台展示顺序；拖拽或顺序值（待确认 #5）。

### 5.5 `validate.ts` 校验规则

| # | 规则 | 提示文案（建议） |
|---|---|---|
| 1 | 模块禁用 → 直接通过 | — |
| 2 | 启用时 `displayTitle` 必填 | 「请填写前台展示名称」 |
| 3 | 文章 ≥ 1（启用时） | 「请至少配置 1 篇行业资讯」 |
| 4 | 文章 ≤ 9（2026-09 数量表；旧 ≤8） | 「行业资讯最多配置 9 篇」 |
| 5 | 每篇四字段完整（封面图/名称/作者/链接） | 「文章「xx」配置不完整」 |
| 6 | 文章名称 ≤ 25 中文字符 | 「文章名称不能超过 25 个字符」 |
| 7 | 链接格式合法 | 「文章跳转链接格式不正确」 |
| 8 | 查看更多开启时链接必填且格式合法 | 「请填写查看更多链接 / 链接格式不正确」 |

### 5.6 `submit.ts` payload 草案

```ts
{
  moduleKey: 'industry-news',
  data: {
    enabled, displayTitle,
    articles: articles.map(a => ({ coverImage, title, author, link })),
    showMore, showMoreLink,
  },
}
```

### 5.7 只读模式（`index.vue` `readonly` prop）

- 表头：模块启用状态 + 前台展示名称（纯展示）；
- 文章卡片（按配置顺序）：封面图（预览/缺省）、名称、作者、时间、链接（可点击、新窗口）；编辑/删除与新增按钮隐藏；
- 查看更多链接（可点击、新窗口）。

### 5.8 任务勾选

- [x] `types.ts` 数据结构
- [x] 模块表头 + 查看更多接入
- [x] `ArticleEditDialog.vue` 新增/编辑弹窗（含 25 字符限制）
- [x] 文章列表 + 编辑/删除（数组顺序即前台顺序，待确认 #5 是否需要拖拽）
- [x] `validate.ts`（5.5 八条）
- [x] `submit.ts`（5.6 结构，字段名待确认 #11）
- [x] `index.vue` readonly 只读模式（5.7 内容）
- [ ] 产品确认：作者名称长度上限 + 时间字段来源（待确认 #4, #12）
- [ ] 产品确认：是否需要拖拽排序（待确认 #5）
- [ ] 后端确认：字段名映射（待确认 #11）

---

## 6. 2026-09 数量表调整

> 背景：产品下发最新「二级频道页图片上传项 / 数量限制」表，涉及本清单三个模块的图片建议尺寸与配置数量。图片尺寸本质是改统一上传组件的裁剪比例（`MaterialImageSize` 驱动 `ImageCropperDialog` 宽高比）。本次仅调整三模块，不动其它内容。

### 6.1 调整内容（旧 → 新）

| 模块 | 项 | 旧值 | 新值（2026-09 数量表） | 落位 |
|---|---|---|---|---|
| 智能体市场 | 封面图建议尺寸 | 400×300（4:3） | 800×600px（标注 3:2 与像素矛盾，按像素取 4:3） | `AgentEditDialog.vue` `AGENT_COVER_IMAGE_SIZE` |
| 智能体市场 | 配置数量 | ≤ 6 个 | 固定配置 3 个（是否强制恰好 3 见待确认 #18） | `types.ts` `AGENT_MAX_COUNT = 3` |
| 活动专区 | Banner 图建议尺寸 | 400×300（4:3） | 940×560px（标注 3:2 与像素矛盾，按像素取 ≈1.68:1） | `ActivitySelectCard.vue` `CHANNEL_COVER_IMAGE_SIZE` |
| 活动专区 | Banner 数量 | 最多 3（曾计划硬拦截） | 维持「仅提醒不硬拦截」 | `types.ts` `ACTIVITY_DISPLAY_HINT_COUNT = 3` |
| 活动专区 | 服务产品数量 | 最少 N（未定义，暂 ≥1） | 两类雇主（已认证 / 未认证）分别至少 5 个；前台取前 5、有 Banner 取前 3 | 分类计数已实现：`SERVICE_USER_SCOPE_TARGET = 5` + `userScopeTypes` 驱动 el-alert；提交校验暂平面 ≥1 |
| 行业资讯 | 封面图建议尺寸 | 400×300（4:3） | 600×400px（3:2，像素与标注一致） | `ArticleEditDialog.vue` `ARTICLE_COVER_IMAGE_SIZE` |
| 行业资讯 | 配置数量 | ≤ 8 篇 | ≤ 9 篇 | `types.ts` `ARTICLE_MAX_COUNT = 9` |

> 图片尺寸矛盾说明：数量表对智能体封面（800×600 标注 3:2）、活动 Banner（940×560 标注 3:2）的「像素值」与「比例标注」不一致；经确认按**像素值**推导裁剪比例（智能体 4:3、Banner ≈1.68:1、资讯 3:2）。

### 6.2 影响范围

| 文件 | 改动 |
|---|---|
| `agent-market/types.ts` | `AGENT_MAX_COUNT` 6 → 3（旧值注释保留） |
| `agent-market/components/AgentEditDialog.vue` | `AGENT_COVER_IMAGE_SIZE` 400×300 → 800×600 |
| `industry-news/types.ts` | `ARTICLE_MAX_COUNT` 8 → 9；数据结构注释 ≤8 → ≤9 |
| `industry-news/components/ArticleEditDialog.vue` | `ARTICLE_COVER_IMAGE_SIZE` 400×300 → 600×400 |
| `activity-zone/components/ActivitySelectCard.vue` | `CHANNEL_COVER_IMAGE_SIZE` 400×300 → 940×560 |
| `activity-zone/types.ts` | `SERVICE_MIN_COUNT` 注释更新为「两类分别至少 5 个」口径（值仍 1，平面兜底）；分类计数常量 `SERVICE_USER_SCOPE_TARGET` / `USER_SCOPE_*` / `userScopeTypes` 由并发的服务产品接口对接一并落地（详见 4.15） |

- **自动跟随**：数量常量改后，各模块 `index.vue` 副标题、计数「已配置 X/Y」、新增按钮置灰阈值、`validate.ts` 提示文案均引用常量，无需逐处改。
- **不涉及**：`submit.ts` 提交结构、只读模式、活动/服务强关联联动（4.12）、活动弹窗接口（4.14）均未触碰。
- **前台展示数量限制**（C 端渲染，如「1 张单图 / >1 轮播」「取前 5 / 有 Banner 取前 3」）属频道页前台消费侧，不在 ops-platform 配置端代码范围。

### 6.3 本次新增 / 更新待确认

- **#18（新增）**：智能体「固定配置 3 个」是否 = 必须恰好 3 个（需补 `validate.ts` min=3 校验），还是维持「最多 3 个」上限模型。
- **#1（更新）**：服务产品「两类分别至少 5 个」是否需按类硬校验（当前仅 el-alert 提醒 + 提交平面 ≥1）。
- **#3（已确认）**：活动 Banner 维持「仅提醒不硬拦截」。

---

## 7. 待确认事项

| # | 问题 | 当前建议/实现 | 确认方 | 状态 |
|---|---|---|---|---|
| 1 | 活动专区最少服务产品数 N | **口径已明确（2026-09 数量表）**：适用的两类雇主（已认证/未认证）分别至少选 5 个；前台按拖拽优先级取前 5（有活动 Banner 时取前 3）。分类计数 alert 已实现（`SERVICE_USER_SCOPE_TARGET` + `userScopeTypes`，仅提醒，见 4.15）；**提交校验暂用平面 `SERVICE_MIN_COUNT ≥ 1`，未按「两类分别 ≥5」强制**，是否加硬校验待与 `SERVICE_USER_SCOPE_TARGET` 口径统一。`user_scope_types` 字段本次已就绪，剩编辑态回显补字段 | 产品 | 🔶 口径已明确 / 硬校验待定 |
| 2 | 活动专区是否含「服务展示数量、排序方式」（PRD 中属最新服务产品模块） | 暂不开发 | 产品 | ⏳ 待确认 |
| 3 | 活动 Banner 上限：2026-09 数量表「最多 3 个」，是否恢复硬拦截 | 已确认维持「仅提醒不硬拦截」（`ACTIVITY_DISPLAY_HINT_COUNT=3`，旧 `ACTIVITY_MAX_COUNT` 已重命名） | 产品 | ✅ 已确认（仅提醒） |
| 4 | 资讯时间字段：发布时间 vs 创建时间 | 按接口返回字段展示（当前 `createdAt` 占位），`industry-news/types.ts` 第 13 行 + `index.vue` 第 69 行 | 产品 | ⏳ 待确认 |
| 5 | 排序方式（拖拽 or 顺序值）与项目拖拽依赖 | 智能体/服务已实现原生 HTML5 拖拽；行业资讯数组顺序即前台顺序 | 产品/原型 | ⏳ 待确认 |
| 6 | 智能体/资讯：手动配置 or 从库选择（自动获取模式待定） | 本期手动 | 产品 | ⏳ 待确认 |
| 7 | ~~活动/服务检索接口是否复用活动管理、服务列表现有接口~~ | 活动候选用独立接口 `options/category-activities`（见 4.14）；服务产品用独立接口 `options/activity-products`（见 4.15） | 后端 | ✅ 活动、服务均已确认 |
| 8 | 检索类接口与图片上传由谁封装（不在梁树强公共 API 清单内） | 对齐后按模块补 `api/` 层 | 梁树强 | ⏳ 待确认 |
| 9 | 只读模式消费契约：`index.vue` `readonly` prop 的入参形态（收模块 `data` 还是 `formData`）；与原「五件套/`readonly.vue`」协作规则不同，需与梁树强/张立同步 | 当前从 `useSecondaryChannelFormContext` 读取，开发前对齐一次 | 梁树强/张立 | ⏳ 待确认 |
| 10 | 删除智能体/活动/服务/文章是否二次确认 | 默认全部加 `ElMessageBox.confirm` | 产品 | ✅ 已实现 |
| 11 | 提交字段与后端契约（`submit.ts` 的 `data` 结构） | 联调前对齐（第 3/4/5 章草案可直接作为对齐底稿）；三个模块 `submit.ts` 字段名当前均为占位 | 后端 | ⏳ 待确认 |
| 12 | 智能体名称/简介长度上限、文章作者长度上限 | 名称 999、简介 100、作者 999 占位；`agent-market/types.ts` 第 47/53 行，`industry-news/types.ts` 第 56 行 | 产品/原型 | ⏳ 待确认 |
| 13 | 统一上传组件是否需要裁剪（项目已有 `ImageCropperDialog`） | 暂不裁剪，仅格式/大小校验，待设计稿确认 | 设计/产品 | ⏳ 待确认 |
| 14 | 统一上传组件命名与 `form/components/` 目录约定 | 暂定 `ChannelImageUpload.vue`，动手前与张立对齐一次 | 张立 | ⏳ 待确认 |
| 15 | ~~服务产品列表接口活动 id list 入参：字段名与传参格式~~ | **已明确**：专用接口 `options/activity-products` 正式入参 `activity_ids`（重复 query key，服务端去重，1~50），见 4.15。**剩联调验证**：axios 默认序列化为 `activity_ids[]=`（带方括号），若后端只认无括号重复 key，需与 4.14 `selected_ids` 一并加 `qs` `arrayFormat:'repeat'` | 后端 | ✅ 字段已明确 / 序列化待联调 |
| 16 | 活动跳转链接 `link` 是否由前端传入并落库（后端契约） | 前端已按选填实现：有值走 `validateChannelLink` 校验、提交进 payload；后端是否接受该字段待确认，代码 `TODO: wxj`（见 4.13） | 后端 | ⏳ 待确认 |
| 17 | `userScopeName`「适用用户范围」文案来源与口径（与 productScopeName 展示取舍） | 弹窗选择时经 `userScopeDisplayText` 带回、仅展示不进提交；meta 行只展示「时间 · userScopeName」，status / productScopeName 不展示（见 4.13） | 产品/后端 | ⏳ 待确认 |
| 18 | 智能体「固定配置 3 个」是否 = 必须恰好 3 个（需补 `validate.ts` min=3 校验），还是维持「最多 3 个」上限模型 | 当前仅改 `AGENT_MAX_COUNT=3`（max-only），未加下限校验，代码未动 `validate.ts` | 产品 | ⏳ 待确认 |

---

## 附：开发进度与阻塞项（新增）

### 🔴 当前阻塞项（P0 - 联调前必须完成）

1. ~~**活动检索接口**（待确认 #7, #8）~~ ✅ 已就绪（2026-09-04）
   - 接口：`GET /api/v1/admin/category-channels/options/category-activities`
   - 前端 API 文件：`src/api/secondary-channel/category-activities-api.ts`（新建）
   - 组件已对接：`ActivitySelectDialog.vue` 已移除 Mock 引用，直接调用真实接口
   - ~~Mock 开关：`USE_ACTIVITY_SELECT_MOCK = true`~~（已废弃，弹窗不再走 mock 分支）
   - 详见 4.14

2. ~~**服务产品检索接口**（待确认 #7, #8, #15）~~ ✅ 已就绪（2026-09-04）
   - 接口：`GET /api/v1/admin/category-channels/options/activity-products`
   - 前端 API 文件：`src/api/secondary-channel/activity-product-options-api.ts`（新建）
   - 组件已对接：`ServiceProductCard.vue` 已停用 Mock（`PUBLIC_PRODUCTS`），直接调用真实接口
   - 数据源：已选活动关联的服务产品（强关联，入参 `activity_ids`，见 4.12 / 4.15）
   - 详见 4.15

3. **三个模块字段名映射**（待确认 #11）
   - `activity-zone/submit.ts` 第 11-30 行
   - `agent-market/submit.ts` 第 11-33 行
   - `industry-news/submit.ts` 第 11-28 行

### ✅ 已完成功能

#### 智能体市场（`agent-market/`）
- ✅ `types.ts` + `index.vue`（支持 readonly）
- ✅ `AgentEditDialog.vue` 新增/编辑弹窗
- ✅ 列表 + 启用禁用/编辑/删除 + 原生拖拽排序
- ✅ `validate.ts`（6 条规则）+ `submit.ts`

#### 活动专区（`activity-zone/`）
- ✅ `types.ts` + `index.vue`（支持 readonly）
- ✅ `ActivitySelectCard.vue` + `ActivitySelectDialog.vue`（~~使用 Mock~~ → 已对接真实接口 `options/category-activities`，见 4.14）
- ✅ `ServiceProductCard.vue` + 拖拽排序（~~使用 Mock `PUBLIC_PRODUCTS`~~ → 已对接真实接口 `options/activity-products`，关联活动列 + 认证计数 alert 动态化，见 4.15）
- ✅ 「展示活动 Banner」开关联动
- ✅ `validate.ts`（7 条规则）+ `submit.ts`
- ✅ `select-api.ts` + `mock.ts`（临时）

#### 行业资讯（`industry-news/`）
- ✅ `types.ts` + `index.vue`（支持 readonly）
- ✅ `ArticleEditDialog.vue`（含 25 字符限制）
- ✅ 列表 + 编辑/删除
- ✅ `validate.ts`（8 条规则）+ `submit.ts`

### 🟡 待确认事项汇总（P1）
- 清单 #1：活动专区最少服务产品数（口径已明确两类雇主各 ≥5，剩提交硬校验待定 + 编辑态回显补字段）
- 清单 #3：活动 Banner 上限确认
- 清单 #4：资讯时间字段来源
- 清单 #5：行业资讯是否需要拖拽排序
- 清单 #12：名称/简介/作者长度上限
- 清单 #13/#14：统一上传组件裁剪与命名
- 清单 #15：~~服务产品列表接口活动 id list 入参字段名与传参格式~~ → 字段已明确（`activity_ids` 重复 query key），剩 GET 数组序列化联调验证

### 📂 可删除文件（P2）
- `activity-zone/readonly.vue`（index.vue 已支持）
- `agent-market/readonly.vue`（index.vue 已支持）
- `industry-news/readonly.vue`（index.vue 已支持）
- `activity-zone/mock.ts`（活动弹窗已不引用 `PUBLIC_ACTIVITYS`；服务产品接口就绪后 `PUBLIC_PRODUCTS` 已孤立、`ServiceProductCard` 不再引用 → 整个 `mock.ts` 可删）

---

**文档版本**: v4.10（新增 6. 2026-09 数量表调整：三模块图片建议尺寸 800×600 / 940×560 / 600×400，智能体固定配置 3 个、文章 ≤9 篇，活动 Banner 维持仅提醒、服务产品两类雇主各 ≥5 分类计数已实现，新增待确认 #18，待确认事项顺延为第 7 节）  
**历史版本**: v4.9（4.15 服务产品接口对接：Mock → 真实接口 options/activity-products）、v4.8（4.14 活动选择弹窗接口对接）、v4.7（4.13 活动选择卡表格化重构）、v4.6（4.12 实施口径定稿）、v4.5（4.8 校验新增「启用时活动 ≥ 1」）、v4.4（4.12 活动与服务产品强关联需求调整）、v4.3（同步开发进度与阻塞项到工作清单）  
**最后更新**: 2026年09月  
**整理人**: 王新骏
