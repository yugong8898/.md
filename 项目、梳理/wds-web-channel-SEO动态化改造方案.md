# wds-web-channel 频道落地页 SEO 渲染架构升级方案（区块级 SSR）

> **适用范围（全文约束）**：本方案只覆盖 wds-web-channel 的频道落地页（路由 `/:slug?categoryId=*`，视图 `src/views/sub-channel/`）的渲染、数据获取与部署链路改造。
>
> **文档定位**：本文为技术评估初稿。所述渲染路线、改动项与周期均为初步判断，需与后端 / 运维 / 产品评审后再行确认，暂不作为开发与上线承诺依据。

## 目录

- [一、背景与现状](#一背景与现状)
- [二、方案总览](#二方案总览)
- [三、渲染路线](#三渲染路线)
- [四、改造清单](#四改造清单)
- [五、影响范围](#五影响范围)
- [六、难度与风险评估](#六难度与风险评估)
- [七、前置依赖](#七前置依赖)
- [八、实施顺序与周期预估](#八实施顺序与周期预估)
- [九、上线步骤](#九上线步骤)
- [十、验证清单](#十验证清单)
- [十一、待确认事项](#十一待确认事项)

## 一、背景与现状

### 1.1 现状

项目为纯 SPA（Vue 3 + Vite），构建产物仅一份 `dist/index.html`，head 内 `<title></title>` 为空、无 description/keywords，爬虫需执行 JS 才能拿到 TDK。现有 SEO 机制两层：

| 层 | 实现 | 数据来源 |
|---|---|---|
| 运行时 | `src/views/sub-channel/index.vue` 接口返回后写 document.title 及 meta | 后端接口 `seo` 字段优先，`categoryId=4/9` 走本地静态兜底，回退 `categoryName` |
| 构建期 | `build/seo-prerender.mjs` 为 categoryId=4/9 生成 2 份静态 HTML，nginx 按 query 硬编码 rewrite 命中 | `build/seo-tdk.mjs` 硬编码（已与业务定稿） |

现有限制：

1. 不执行 JS 的爬虫只能正确收录 2 个页面（工商财税、跨境企服），其余频道页首屏无 TDK；
2. TDK 文案写死在代码中，改文案要重新构建发版；
3. nginx 规则按 categoryId 逐条硬编码，新增页面要同步改 nginx 配置；
4. 无 OG 社交分享 meta、无 sitemap；
5. 首屏 HTML 的 body 仅为空壳 + 骨架屏，**正文内容不可被收录**。

### 1.2 SSR 基础现状（基于当前代码初判）

| 检查项 | 现状观察 | 初步影响 |
|---|---|---|
| SSR 依赖与代码 | grep `server-renderer` / `renderToString` / `Nuxt` / `ssr`，本仓库与 wds-web 均 0 命中 | 从零搭 SSR 服务层 |
| 容器运行时 | `Dockerfile.prod` runner 阶段为 `nginx:alpine`，只 `COPY dist`，镜像内无 Node | 须改镜像或拆多容器 |
| nginx | 仅 1 个 CDN `proxy_pass`，无 Node upstream，`location /` 为纯静态 `try_files` | 须新增分流与 upstream |
| 数据层 | `useSubChannelData.ts` 含 `localStorage.setItem`、`window.location.href` 跳主站，并依赖守卫阶段的 `channelPagePrefetch` | 三处逻辑在服务端环境会异常，需在数据层改造时先行处理 |
| 构建编排 | `build/index.mjs` 单次 `vite build` + 成功后调 `generateSeoPages()`；全部 build 脚本走这一条链路 | 须拆 client / server 双产物 |

### 1.3 落地页区块清单（依据 `src/views/sub-channel/index.vue` 整理，按渲染顺序）

| # | 区块组件 | 数据字段 | 首屏可见 | 时效性 |
|---|---|---|---|---|
| 1 | SubChannelBannerCarousel（顶部轮播） | `topBanner.items` | 是 | 低 |
| 2 | SubChannelQuickAccessSection（快捷入口，上提 124px 压在 banner 上） | `categories.imageItems / standItems`、`categoryId` | 是 | 低 |
| 3 | SubChannelSmartMarketSection（智能体市场） | `agents.items` | 否 | 低 |
| 4 | SubChannelActiveServiceSection（活动服务产品 1+5） | `activities.banner / product` | 否 | **高** |
| 5 | SubChannelProductGridSection（最新服务产品） | `products.products` | 否 | **高** |
| 6 | SubChannelProductGridSection（推荐服务产品） | `recommendedProducts.products` | 否 | 中 |
| 7 | SubChannelIndustryNewsSection（行业资讯） | `industryNews.items` | 否 | **最高** |
| 8 | SubChannelBannerStatic（底部静态 banner） | `bottomBanner.items` | 否 | 低 |
| 9 | SubChannelFooter（页脚 + 咨询入口） | `footer`、`inquiry.enabled`、`categoryId` | 否 | 低 |
| — | 状态兜底：EmptyState(offline) / error 文案 / SubChannelSkeleton | `isOffline` / `error` / `loading` | — | — |

> 关键事实：上表 9 个区块的数据当前全部来自同一个接口的一次响应（`GET /v1/employer/category-channels/{slug}` → `useSubChannelData` 的 `page`），因此数据获取方式需按 2.2 调整。

## 二、方案总览

**核心：新增 Node SSR 服务层，首屏 SEO 关键区块在服务端渲染进 HTML，强时效区块留给客户端渲染；nginx 按规则把落地页打到 SSR，其余保持静态，SSR 异常时回落静态壳。**

### 2.1 渲染归属划分

| 归属 | 区块 | 理由 |
|---|---|---|
| **SSR（服务端渲染）** | head（title / description / keywords / canonical / OG）、区块 1 顶部轮播、区块 2 快捷入口、区块 9 页脚 | 首屏可见，承载类目语义与内链，是爬虫需要看到的正文；页脚含联系方式与内链锚 |
| **CSR（客户端渲染）** | 区块 4 活动、区块 5 最新产品、区块 7 行业资讯、区块 8 底部 banner；区块 3、6 按性能实测结论归属 | 时效性强、内容长、非首屏，放进 SSR 只会拉长渲染等待 |
| **两侧都不渲染** | IM 客服、埋点上报、登录态交互、图片懒加载触发 | 与 SEO 无关 |

### 2.2 数据获取方式

**后端按区块拆接口**：SSR 只取「首屏区块数据包」，CSR 区块各自调自己的接口。

- SSR 侧不再为次屏数据等待，**渲染等待时间与单次响应体积下降**；
- CSR 区块可各自设置缓存与刷新策略；
- **同一 PV 的后端总请求数会上升**（初步估算 SSR 1 次 + 客户端 3~6 次），对外沟通建议统一按此口径描述：降低的是渲染等待与响应体积，不是请求总数；QPS 评估需按请求数上升的前提来做，具体数值待接口拆分方案定稿后再核。

#### 2.2.1 后端接口诉求清单（逐项为前端实现依赖）

| # | 需后端提供的数据 | 消费方 | 对应区块 |
|---|---|---|---|
| 1 | 首屏数据包：`seo`（TDK）、`categoryName`、`categoryId`、`topBanner`、`categories`（快捷入口）、`footer`、`inquiry.enabled` | **SSR** | head + 区块 1、2、9 |
| 2 | `activities.banner / product` | CSR | 区块 4 活动服务产品 |
| 3 | `products`（最新服务产品） | CSR | 区块 5 |
| 4 | `industryNews`（行业资讯） | CSR | 区块 7 |
| 5 | `bottomBanner`（底部静态 banner） | CSR | 区块 8 |
| 6 | `agents`（智能体市场）、`recommendedProducts`（推荐服务产品） | CSR | 区块 3、6 |

> 拆分粒度由后端定：可逐区块拆，也可合并为「首屏包 + 次屏包」两三份。**关键约束：SSR 侧只取首屏包，不必等待次屏数据。** 接口契约与服务端调用方式见待确认事项【1】。

### 2.3 预期收益

1. 爬虫可拿到**真实正文 DOM**（类目名、快捷入口、页脚内链），不再只有 head 的 TDK；
2. TDK 与内容为**请求时刻实时取数**，改文案无需前端发版，也可避免快照与实时数据不一致的窗口；
3. OG / sitemap / 结构化数据在 SSR 层统一产出；
4. 标题由服务端一次写死，浏览器标签页不再出现中间态跳变；
5. 首屏正文随 HTML 到达即存在，首屏可见时间提前。

### 2.4 需权衡的成本

1. 新增**故障域**：Node 进程（内存泄漏、事件循环阻塞、冷启动、GC 抖动）；
2. 后端总请求数上升（见 2.2），需接口拆分 + 缓存 + 限流三者配套；
3. TTFB 从「读静态文件」变为「等接口 + 渲染」，需有缓存策略兜住；
4. **CLS 风险**：CSR 区块在数据返回后撑开高度，页面可能出现下跳，需通过占位设计控制；
5. hydration 一致性成为新的质量门槛；
6. 数据层、构建、镜像、k8s、nginx 五层同时改动，多环境同步成本高。

## 三、渲染路线

**区块级混合渲染 + 后端区块接口**：

- 首屏 SEO 区块（轮播、快捷入口、页脚）与 head 由服务端渲染并写入真实正文；
- 强时效与非首屏区块由客户端渲染，各自请求独立接口；
- 服务端渲染采用流式输出：先吐 head 与首屏区块，动态区块留占位容器；
- 客户端 hydration 复用服务端下发的首屏包数据，不重复请求；
- SSR 不可用时 nginx 回落静态壳，用户侧仍可正常浏览。

## 四、改造清单

### 4.1 SSR 服务与流式渲染

- 新增 `server/` 入口（Node HTTP 服务，框架选型待定：express / hono / koa）；
- 采用**流式渲染**（`renderToNodeStream` / `pipe`）：先吐 head + 首屏区块，动态区块留占位容器；
- `vite.config.ts` 增加 `ssr` 配置，构建拆 **client + server 双产物**；`package.json` 新增 `build:ssr` / `start:ssr`，`build/index.mjs` 编排同步调整；
- 生产环境**不用** `vite.ssrLoadModule`（仅开发用），需预打包 server bundle。

### 4.2 数据层改造（依赖后端接口，工作量偏大）

- `useSubChannelData.ts`：`localStorage.setItem('categoryId')` 与 `window.location.href` 跳主站两处改为「仅客户端执行」；服务端分支返回可识别状态，由 SSR 层发 HTTP 302；
- `channelPagePrefetch.ts`：现由路由守卫在浏览器提前发整包请求，改为**服务端只取首屏区块数据包**；该包序列化进 HTML（`window.__INITIAL_STATE__`）供客户端首屏区块 hydration 复用，客户端不再请求首屏包；
- **按区块拆数据源**：现「一份 `page` 喂 9 个区块」改为「首屏包（SSR 下发）+ 各区块独立 composable」，区块 3~6 项各自取数、各自 loading / error；
- **区块失败隔离**：任一 CSR 区块接口失败时只降级该区块（隐藏或空态），不应拖成整页白屏——现有 `index.vue` 是「一份数据 + 全局 error」模型，需一并调整；
- 客户端多请求的并发控制，避免串行等待放大首屏可交互时间；
- `api/employer/categoryChannel` 下新增各区块接口封装，命名与调用方沿用既有约定；旧整包接口在过渡期保留可用（注释标注废弃原因与需求号），不在本次删除；
- 确认服务端调用所需 baseURL / 鉴权 / 超时（服务端无浏览器 Origin）。

### 4.3 区块归属与分块 hydration

- 按 2.1 划分，在页面内明确「SSR 区块」与「CSR 占位区块」的边界与挂载方式；
- CSR 区块**需预留固定高度或比例占位**，避免数据返回后撑开造成 CLS；
- 每个 SSR 区块加区块标识（如 `data-block`），供客户端定点 hydration，避免整页重新挂载；
- 首屏区块 hydration 数据来源统一走 `__INITIAL_STATE__`。

### 4.4 SEO head 单点写入

- title / description / keywords / canonical / OG 由 SSR 一次写入**最终值**，客户端 hydration 后不再覆盖；
- `router/guard.ts` 与 `sub-channel/index.vue` 中现有标题写入逻辑按此收敛（「静态 TDK 优先于接口 seo」的短路判断在 SSR 下废弃，改造时注释保留）；
- canonical 仍按真实请求地址动态生成并丢弃 `categoryName` 等噪声参数，取数由 `window.location` 改为服务端请求 URL（配合 X-Forwarded-Proto / Host）。

### 4.5 nginx 分流（6 套配置全部同步）

- 涉及 `nginx.conf` / `nginx.dev.conf` / `nginx.dev3.conf` / `nginx.test.conf` / `nginx.uat.conf` / `nginx.uat2.conf` / `nginx.prod.conf`；
- 落地页路径 `proxy_pass` 至 SSR upstream；其余路径保持静态 `try_files $uri $uri/ /index.html`；
- **降级链路（建议具备）**：SSR upstream 超时 / 5xx 时回落静态 `index.html`，保证用户侧仍可浏览；
- 不引入静态预渲染页，nginx 中现有 categoryId 硬编码 `if + rewrite` 规则在 SSR 分流稳定后清理。

### 4.6 容器与编排

- 6 套 `Dockerfile.{prod,uat,uat2,test,dev,dev3}` runner 阶段：改为含 Node 运行时，或拆 nginx + node 双容器；
- `k8s-deployment.yaml` / `k8s-deployment-prod.yaml`：新增 SSR 容器（或新 Deployment + Service）、就绪 / 存活探针、资源 request / limit、必要时 HPA。

### 4.7 缓存与降级

- SSR 首屏结果缓存（进程内存 / Redis，方式待定）：明确 TTL、key 维度（slug + categoryId + 协议 / 主机）、失效触发（内容或 TDK 变更后如何主动清）；
- CSR 区块接口可各自依赖 CDN / 浏览器缓存，与 SSR 缓存分层设计；
- 接口超时上限、超时后降级到静态壳的判定阈值。

### 4.8 可观测与回滚

- 指标：SSR 命中率、缓存命中率、流式渲染耗时、SSR 错误率、TTFB、Node 内存与事件循环延迟；
- 回滚：nginx 摘除 SSR 分流即回到纯静态，成本主要在配置层。

## 五、影响范围

- **主项目**：wds-web-channel（渲染架构、数据层、构建、容器、nginx 五层同时变动）；
- **代码面（横向搜索结果）**：`src/views/sub-channel/index.vue`、`src/router/guard.ts`、`composables/useSubChannelData.ts`、`composables/channelPagePrefetch.ts`、`src/config/seoStaticTdk.ts`、`api/employer/categoryChannel/*`、9 个区块组件、`vite.config.ts`、`build/index.mjs`、`build/seo-prerender.mjs`、`build/seo-tdk.mjs`、`package.json`、6 套 nginx conf、6 套 Dockerfile、2 份 k8s yaml；
- **后端**：需提供区块级接口（见 2.2.1），为本方案的实现前提；
- **用户可感知行为**：
  - 页面视觉内容与布局不变，首屏正文更早出现、标题不再跳变，属改善；
  - **CSR 区块加载存在撑高页面的风险（CLS）**，需由 4.3 的占位设计控制，并在第十章实测验证；
  - SSR 异常时用户看到静态壳 + 客户端渲染，与现状一致；
- **运维面**：新增 Node 运行时 = 新增故障域与值班对象，须明确 SLA。

## 六、难度与风险评估

| 项 | 评估 |
|---|---|
| 技术难度 | **中~高（初步判断）**，最终以阶段 0 spike 验证结论为准。纳入考虑项：流式渲染、分块 hydration、CLS 占位、数据层按区块重构（一份 `page` 拆多源）、区块失败隔离、后端多接口联调、容器与 k8s 编排、缓存与降级体系 |
| 主要风险 | ① 后端总请求数上升，若缓存与限流未配套，后端压力风险较高；② TTFB 劣化；③ CLS 造成视觉跳动并拖累 Core Web Vitals 表现；④ hydration mismatch 引发 DOM 重建；⑤ Node 进程长期稳定性；⑥ 6 nginx + 6 Dockerfile + 2 k8s 多环境需逐一同步，遗漏导致环境行为不一致；⑦ 后端区块接口就绪时间影响前端收口节奏；⑧ CSR 请求瀑布拉高首屏可交互时间；⑨ 单个区块接口失败可能波及整页（现有代码为全局 error 模型，见 4.2）；⑩ 团队无 SSR 运维经验，故障定位链路变长 |
| 回滚方案 | nginx 摘除 SSR 分流回落纯静态，以配置级回滚为主，成本较低 |

## 七、前置依赖

1. **后端（最高优先，前置依赖）**：按 2.2.1 清单提供区块级接口——接口数量、路径、字段契约、服务端调用方式（内网直连 / 走网关）、超时 SLA、可承受 QPS（按同一 PV 多次调用评估）；
2. **前端**：区块接口未就绪期间的过渡策略（先沿用旧整包接口做 SSR 骨架，还是与后端并行等就绪），在技术方案评审定；
3. **运维**：镜像内引入 Node 或 k8s 多容器的许可与责任人；SSR HTML 的 CDN 缓存与刷新方式（刷新机制、生效延迟、配额、执行责任人）；
4. **产品 / 运营**：运营后台 TDK 编辑界面是否已具备（若无，文案仍由后端 / DB 维护，不阻塞改造，但影响「改文案不发版」这条收益的兑现）；
5. **安全 / 合规**：SSR 渲染时是否会带入用户态信息（本页为公开落地页，预期不涉及，仍需确认）。

## 八、实施顺序与周期预估

> 口径说明：以下为方案评估阶段的初步区间，仅用于判断量级，非正式排期承诺。前端按 1 人投入估算，后端与运维数字需两端各自确认后合并进正式排期。阶段 0 spike 与后端接口开发可并行。

| 阶段 | 内容 | 前端 | 后端 | 运维 |
|---|---|---|---|---|
| 0 | spike 最小闭环：流式 SSR + 首屏区块渲染 + nginx 分流 + 异常回落静态壳 | 2~3 工作日 | — | 配合起环境 |
| 1 | 技术方案定稿 + 区块接口契约评审锁定 | 2~3 工作日 | 契约评审与内部排期 | 参与评审 |
| 2 | 数据层改造：服务端取首屏包、`__INITIAL_STATE__` 序列化、区块独立 composable、失败隔离 | 4~5 工作日 | **接口开发 5~8 工作日（与前端并行）** | — |
| 3 | 区块归属与分块 hydration + CLS 占位 + head 单点写入 | 3~4 工作日 | — | — |
| 4 | 构建双产物 + 6 套 Dockerfile + 2 份 k8s + 6 套 nginx 配置 | 3~4 工作日 | — | 2~3 工作日 |
| 5 | 缓存与降级链路、可观测指标与告警 | 3~4 工作日 | 配合限流 | 1~2 工作日 |
| 6 | dev 全量验证 → 灰度 → test → uat → uat2 → prod 逐环境发布 | 4~5 工作日 | 联调支持 | 发布窗口 |
| **合计（量级参考）** | | **约 21~28 工作日** | 约 5~8 工作日（并行） | 约 3~5 工作日 |

**周期结论（初步）**

- **前端净工时**：约 21~28 个工作日，量级上落在 4~6 周区间；
- **整体日历周期**：叠加方案评审、后端接口就绪与逐环境发布等待，初步看在 6~8 周区间，实际以后端接口就绪时间为主要变量；
- **关键路径**：阶段 2 → 3 → 4 → 5 → 6 大致串行，压缩空间有限；后端接口若在阶段 2 结束前未就绪，整体周期相应顺延；
- **可压缩空间**：CSR 区块统一走「进页即并发取数」不做惰加载、区块 3/6 暂不改归属，阶段 3 有一定压缩余地；环境配置分批上线可短期提前，但会造成环境行为不一致，需权衡；
- **返工风险**：待确认【1】【2】【4】若在开发启动前未闭环，存在对应阶段返工的可能。

## 九、上线步骤

1. 后端区块接口契约确认完毕（2.2.1 清单逐项有结论），阶段 0 spike 结论评审通过；
2. 后端确认服务端调用参数、QPS 与超时 SLA，前端确认缓存与限流配套；
3. 运维确认镜像 / k8s 变更方案、CDN 刷新机制与发布窗口；
4. dev 环境完成第十章全量验证；
5. 灰度：单环境 / 单 slug 切 SSR，观察 SSR 错误率、TTFB、CLS；
6. test → uat → uat2 逐环境发布验证；
7. prod 发布，线上以爬虫 UA `curl` 抽查首屏 HTML 正文、TDK、sitemap；
8. 发布窗口内随时可用「摘除 SSR 分流」回滚预案。

## 十、验证清单

> 以下为初步建议项，随方案定稿与后端接口拆分结果裁剪。

```
□ 爬虫可见性：以 Baiduspider / Googlebot UA curl，首屏 HTML 含类目名、快捷入口、页脚内链等真实正文（非仅 head）
□ TDK 正确性：title / description / keywords / canonical / OG 与接口实时数据一致
□ 标题一致性：SSR 输出 title 与 hydration 后 document.title 相同，无中间跳变
□ hydration：控制台无 mismatch 告警，SSR 区块未被客户端重建
□ CLS：CSR 区块加载完成后页面无明显跳动（CLS ≤ 0.1，用 Lighthouse 实测）
□ 请求合理性：首屏包仅服务端取一次、客户端不重复请求；CSR 区块各取一次，无同区块重复调用
□ 区块失败隔离：逐个关停 CSR 区块接口，页面其余部分与 SSR 首屏仍正常，不整页白屏
□ 请求瀑布：CSR 区块并发取数，首屏可交互时间不因串行等待劣化
□ 降级：SSR 进程停止 / 接口超时时，nginx 回落静态壳，页面可正常打开
□ 缓存：内容或 TDK 变更后在约定 TTL 内生效；缓存 key 覆盖 slug + categoryId + 协议 / 主机
□ CDN 刷新：内容 / TDK 变更后执行刷新，验证在约定时间内于线上生效
□ 性能：TTFB 与首屏时间不劣于现状基线（灰度期实测对比）
□ 回归：categoryId=4/9 旧落地页表现不劣化；其余 categoryId 正常
□ 环境一致性：6 套 nginx conf + 6 套 Dockerfile + 2 份 k8s yaml 逐一 diff
□ SEO 附件：robots.txt / sitemap.xml（若本次纳入）可访问
□ 稳定性：压测下 Node 内存与事件循环延迟无持续上涨
□ 收录观察：上线后搜索引擎抓取量与索引量跟踪
```

## 十一、待确认事项

| # | 要决定什么 | 选 A / 选 B 的后果 | 谁回答 | 不定会怎样 |
|---|---|---|---|---|
| 【1】 | 后端拆几个接口；每个接口的路径、字段名与返回层级、超时与错误码语义；服务端怎么调（内网直连还是走网关、要不要鉴权） | 逐区块拆：前端改造最干净但后端工作量大；只拆「首屏包 + 次屏包」：后端省，但 CSR 区块粒度缓存做不了 | 后端给清单与契约，运维给内网/网关口径，前端确认字段够用 | 未闭环前阶段 2、3 难以启动，优先级最高 |
| 【2】 | 缓存与生效延迟：SSR 结果存不存、TTL 多长、缓存 key 怎么定；CDN 刷新是工单 / 控制台 / API，刷新延迟与配额，`Cache-Control` 取值 | 不缓存：文案绝对实时，后端压力最大、TTFB 最不稳；缓存 N 分钟：压力与 TTFB 可控，运营改文案最多延迟 N 分钟生效 | 后端给可承受并发，运维给缓存设施与刷新机制，产品确认可接受延迟 | 无缓存策略时不宜直接上线，后端压力风险较高 |
| 【3】 | SSR 挂了或太慢怎么判定退回静态页：超时阈值、重试次数、按错误码还是按状态降级、降级后多久切回 | 阈值定太松：SSR 卡住时用户等太久；定太紧：后端轻微抖动就大面积回落，SEO 效果不稳定 | 前端提策略，运维在 nginx / k8s 落地 | 属安全生产基线，建议上线前明确 |
| 【4】 | 容器里加 Node 运行时、k8s 加服务：谁来改，允不允许双容器 | 单镜像双进程：改动小、发布流程不变，但资源互抢、故障不易隔离；双容器 / 独立 Deployment：隔离清晰可单独扩缩容，但 k8s 模板、发布与监控都要新增配置 | 运维 | 影响阶段 0 环境搭建与阶段 4 发布落地 |
| 【5】 | CSR 区块的占位高度口径（按设计稿固定值还是实测平均值）+ 取数时机（进页即并发拉 / 滚到可视区再拉） | 并发拉：内容一步到位、CLS 窗口短，但首屏并发请求最多；惰加载：首屏并发小省带宽，但滚到时才有内容，占位没做好会持续跳动 | 前端 + 设计（给区块高度口径） | 不阻塞架构，但 CLS 劣化会拖累 Core Web Vitals 表现 |
| 【6】 | 运营后台有没有改 TDK 的入口 | 有：改文案不用发版这条收益兑现；没有：暂由后端 / DB 维护，文案改动仍要走开发 | 产品 / 后端 | 不阻塞改造，决定收益能否兑现 |
| 【7】 | SEO 附件范围：OG 分享图素材用哪张、sitemap 与结构化数据本次是否一并做 | 一并做：收录与分享卡片效果好，SSR 层顺手成本低；不做：搜索引擎缺页面清单与富摘要，分享卡片无图或裂图 | 产品 / 设计（素材）+ 评审（范围） | 不阻塞，影响 SEO 效果上限 |

---

**文档版本**： v3.2
**最后更新**： 2026年11月
**整理人**： 王新骏
