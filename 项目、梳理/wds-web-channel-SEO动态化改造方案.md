# wds-web-channel SEO 动态化改造方案

## 目录

- [一、背景与现状](#一背景与现状)
- [二、改造方案](#二改造方案)
- [三、影响范围](#三影响范围)
- [四、难度与风险评估](#四难度与风险评估)
- [五、前置依赖](#五前置依赖)
- [六、工作量排期](#六工作量排期)
- [七、上线步骤](#七上线步骤)
- [八、待确认事项](#八待确认事项)

## 一、背景与现状

项目为纯 SPA（Vue 3 + Vite），构建产物仅一份 `dist/index.html`，head 内无 title/description/keywords，爬虫需执行 JS 才能拿到 TDK（标题/描述/关键词）。

现有 SEO 机制分两层：

| 层 | 实现 | 数据来源 |
|---|---|---|
| 运行时 | `src/views/sub-channel/index.vue` 接口返回后动态写入 document.title 及 meta | 后端接口 `seo` 字段优先，`categoryId=4/9` 走本地静态兜底，回退 `categoryName` |
| 构建期 | `build/seo-prerender.mjs` 为 categoryId=4/9 生成 2 份静态 HTML，由 `nginx.prod.conf` 按 query 硬编码 rewrite 命中 | `build/seo-tdk.mjs` 硬编码（已与业务定稿） |

由此产生的限制：

1. 不执行 JS 的爬虫只能正确收录 2 个页面（工商财税、跨境企服），其余分类频道页首屏为空 TDK；
2. TDK 文案写死在代码中，修改需重新构建发版；
3. nginx 规则按 categoryId 逐条硬编码，新增预渲染页需同步改 nginx 配置；
4. 无 OG 社交分享 meta、无 sitemap。

## 二、改造方案

**核心：预渲染数据源从"构建期硬编码"改为"部署期拉接口"，一次性全量覆盖，单批实施。**

### 1. 预渲染脚本动态化

- `seo-prerender.mjs` 增加接口数据源：调用后端"分类频道列表"聚合接口，为**所有** categoryId 生成 `dist/seo/categoryId-{id}.html`；
- 现有 `SEO_STATIC_PAGES` 硬编码保留作降级兜底（接口失败时仍产出 4/9 两页）；
- 生成时一并注入 OG meta（`og:title/og:description`）；
- sitemap.xml 由同一数据源顺带生成。

### 2. 生成时机：构建期 → 部署期

- 现状 `vite build` 时生成，TDK 固化进镜像，改文案仍需发版；
- 改为**容器启动时**（Dockerfile entrypoint）执行生成脚本：后端 TDK 更新后重新部署即生效，无需改前端代码；
- entrypoint 采用"先起 nginx、后台生成补写"或"启动前重试拉取（超时跳过）"，避免后端抖动阻塞发布。

### 3. nginx 动态命中

```nginx
# 现状（硬编码）：
if ($arg_categoryId = "4") { rewrite ^ /seo/categoryId-4.html break; }
if ($arg_categoryId = "9") { rewrite ^ /seo/categoryId-9.html break; }

# 改为（map + try_files，新增页面零配置）：
map $arg_categoryId $seo_page {
    default "";
    ~^.+$ /seo/categoryId-$arg_categoryId.html;
}
# location / 内：
try_files $seo_page $uri $uri/ /index.html;
```

- `$seo_page` 文件不存在时自动回落 `index.html`，未配置 seo 的频道保持现状，只升不降；
- 各环境 nginx 配置（prod/uat/uat2/test/dev/dev3）同步修改。

### 4. 运行时侧

**业务代码是否需要调整：待确认。** 初步代码走读发现以下 3 处 SEO 专用代码疑似需调整（优先级/时机层面，非业务逻辑），是否调整及调整方式待技术方案评审确认：

| 位置 | 疑似调整点 |
|---|---|
| `src/views/sub-channel/index.vue` | 现为静态硬编码 TDK 优先于接口 seo（`if (staticTdk) return` 短路）；预渲染改为接口数据源后，需评估是否反转为"接口优先、静态兜底"，否则出现爬虫与浏览器文案不一致 |
| `src/router/guard.ts` | 路由守卫按静态 TDK 定稿标题（防闪烁）；若优先级反转需同步调整，否则防闪烁逻辑失效 |
| `build/index.mjs` | 现构建成功后调 `generateSeoPages()`；生成时机改为容器启动后，需评估此处移除或降级为镜像内兜底 |

OG meta 写入为纯新增（在现有 `setMetaContent` 机制上追加）。业务功能代码（数据层 useSubChannelData/channelPagePrefetch + 全部版块组件）经走读不涉及，canonical 动态生成逻辑不受影响。

## 三、影响范围

- 涉及 wds-web-channel 项目（构建/部署层改造为主）；
- 用户浏览器侧可感知行为预期零变化；
- 后端"分类频道列表 + seo"聚合接口、运营后台 TDK 编辑能力为外部依赖（见前置依赖）；
- 其他子项目（wds-web 等）零改动。

## 四、难度与风险评估

| 项 | 评估 |
|---|---|
| 技术难度 | 低~中。构建/部署/nginx 层改造无新依赖；运行时侧待确认调整点集中在优先级反转，逻辑简单但需细致回归（防闪烁、前后端文案一致性） |
| 主要风险 | ① 容器启动依赖后端可用性 → 降级策略兜底（失败回落 index.html，等同现状）；② `try_files` 回落语义需实测验证；③ 多环境 Dockerfile/nginx 配置需逐一同步，遗漏导致环境间行为不一致 |
| 回滚方案 | nginx map 回退为原 if 硬编码即可，回滚成本趋近于零 |

## 五、前置依赖

1. **后端**：需提供"全量分类频道 + seo 字段"的列表聚合接口（现有接口按 categoryId 单查，不适合批量生成），这是唯一硬阻塞项；
2. 运营后台是否已有 TDK 编辑界面：不阻塞本次改造，缺失仅意味着 TDK 暂由后端/运营走数据库维护。

## 六、工作量排期

| 阶段 | 内容 | 工作量 |
|---|---|---|
| **1. 调研 + 技术方案** | 后端聚合接口确认、es-web 同款机制调研、nginx map+try_files spike 验证、运行时 3 处待确认点结论、技术方案输出与评审 | **3~4 天** |
| **2. 开发实施** | 预渲染脚本动态化（含 OG meta、sitemap）、Dockerfile/nginx 各环境配置改造、运行时侧按评审结论调整 | **3~4 天** |
| **3. 验证 + 上线** | dev 环境联调验证（全量生成/回落/4-9 回归/防闪烁/降级）、运维对齐、test→uat→prod 逐环境发布与线上抽查 | **3~4 天** |

**合计：约 10~12 个工作日（2~2.5 周）**，不含后端聚合接口开发（若不存在，与前端并行，约 3~5 天，上线依赖其就绪）。

## 七、上线步骤

1. 后端列表接口就绪；
2. 前端完成开发，dev 环境验证（全量 categoryId 生成、未配置频道回落、4/9 旧页面回归、标题防闪烁、后端不可用降级、sitemap 可访问）；
3. 运维对齐 entrypoint/k8s 变更与发布窗口；
4. test → uat → uat2 逐环境发布验证；
5. prod 发布，线上 `curl` 抽查首屏 HTML 的 TDK 与 sitemap。

## 八、待确认事项

1. 后端"分类频道列表 + seo"聚合接口：是否存在 / 路径 / 字段契约（阻塞项）；
2. **业务代码是否需要调整**：初步走读发现 index.vue / guard.ts / build/index.mjs 共 3 处疑似调整点（详见 二.4），待技术方案评审确认；
3. k8s deployment 模板对 entrypoint 变更是否有约束；
4. OG image 素材来源；
5. 是否需要定时刷新（k8s CronJob 重跑生成脚本），还是仅部署时生成。

---

**文档版本**： v1.0
**最后更新**： 2026年11月
**整理人**： 王新骏
