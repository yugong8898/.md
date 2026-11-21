# WLYD 项目

## 项目概览

WLYD（万连通）是一个物流管理平台，包含多个子项目，同时使用 Cursor、Qoder、CodeBuddy 和 Trae 进行维护。

> **规则四工具同步（铁律 v2.0）**：项目规则以 `.cursor/rules/*.mdc` 为**单一事实源（SSOT）**。四端同步策略如下：
>
> - **Cursor（模块化 .mdc）**：`.cursor/rules/*.mdc`（13 个文件，按 `core-` / `tech-` / `ref-` 分类，frontmatter 用 `alwaysApply` / `globs` / `description` 三种生效方式）是规则维护源；`core-project-rules.mdc` 为入口索引。
> - **CodeBuddy / Qoder（单文件镜像）**：`.codebuddy/rules/wlyd-project-rules.md` 与 `.qoder/rules/wlyd-project-rules.md` 汇集 Cursor 对应章节，两份文件须保持字节一致。
> - **Trae（模块化 .md，镜像 Cursor）**：`.trae/rules/{core,tech,ref}/*.md`（13 个文件，镜像 `.cursor/rules/*.mdc` 内容，frontmatter 与 Trae 官方格式一致）。原单文件 `.trae/rules/wlyd-project-rules.md` 已废弃删除。
>
> 修改规则时以 Cursor 为准，同轮同步其他三端；提交前跑 `bash ai-tooling-seed/scripts/verify-rules-sync.sh .` 校验文件镜像与目录结构。

## 子项目

| 项目 | 说明 | 技术栈 |
|------|------|--------|
| `bdbl-admin/` | 后台管理端 | Vue 2 + Element UI |
| `logisticsweb/` | 物流 Web 端 | Vue 2 + Element UI + Vue CLI 4 |
| `platformweb/` | 平台 Web 端 | Vue 2 + Element UI + Rsbuild |
| `wlyd-app-consigner/` | 货主移动端 | uni-app（H5 + 小程序 + APP） |
| `fe-match-end/flutter_yidabao_driver/` | 司机端 App | Flutter |
| `fe-match-end/web-match-owner/` | 货主撮合 PC 端（合仓项目，唯一维护对象） | Vue 3 + Vite + pnpm workspace + Turborepo + qiankun |
| `fe-match-end/match-owner-pc/` | 货主撮合 PC 端（旧多仓库，目录保留但不再维护） | Vue 3 + Vite |

### 企服线（`wds/`，2026-08 新接入；2026-10-28 仓库迁移；2026-11-21 接入 wds-miniapp）

| 项目 | 说明 | 技术栈 |
|------|------|--------|
| `wds/wds-admin-web/` | 企服运营管理后台 | Vue 3 + TS + Vite 6 + Element Plus + Pinia 3 + UnoCSS |
| `wds/wds-web/` | 企服 Web 端（雇主端 / 服务商端） | Vue 3 + TS + Vite 6 + Ant Design Vue 4 + Pinia 2 + @antv/g6 |
| `wds/wds-mobile-pay/` | 微信扫码支付 H5 | Vue 3 + TS + Vite 8 |
| `wds/wds-web-channel/` | 二级频道 | Vue 3 + TS + Vite 6 + Ant Design Vue 4 + Pinia 2 |
| `wds/wds-operation-h5/` | 拉新登录 H5 | Vue 3 + TS + Vite 6 + Vant 4 + SCSS |
| `wds/wds-sso/` | 统一登录前端 | Vue 3 + TS + Vite 6 + Ant Design Vue 4 |
| `wds/wds-miniapp/` | 雇主端微信小程序 | Taro 4.3.1 + Vue 3.5 + Pinia 2 + NutUI-Taro + TypeScript（webpack5） |
| `wds/ai-skills/` | AI Agent Skills 资产仓库（非前端项目） | — |

> ⚠️ **企服线不适用本文档的 WLYD 物流项目规范**：均为 Vue 3 + TS 体系，与物流线（Vue 2 + Element UI + uni-app）不是同一套技术栈，
> 因此**不适用**后文的 uni-app 规范、Vue2 规范、条件编译、`rpx`、`/deep/` 等约定，也**不适用** WLYD 的 commit/文档/注释等工程约定（各项目各有自己的 husky 与 lint 体系）。
> 编码规范以各项目自带文件为**唯一事实源**：`wds-admin-web` → [`wds/wds-admin-web/AGENTS.md`](./wds/wds-admin-web/AGENTS.md)；`wds-web` → [`wds/wds-web/README.md`](./wds/wds-web/README.md)（无 `AGENTS.md`）。
> 知识库入口：`.repoWiki/kb/wds-admin-web/README.md`、`.repoWiki/kb/wds-web/README.md`（知识库按「先查库再读码」惯例仍适用）。
> [2026-11-21 补记] `wds-miniapp` 例外：Taro 4.3.1 + Vue 3.5 + Pinia 2 + NutUI-Taro + webpack5 的小程序 / H5 双端体系，**不是 Vite 项目**；规范事实源 `wds/wds-miniapp/AGENTS.md`、`README.md`，技术栈见 `.cursor/prompts/stack-taro-miniapp.md`，知识库入口 `.repoWiki/kb/wds-miniapp/README.md`，不适用 Vite 栈 / uni-app 口径。
>
> 注：`wds/` 位于 wlyd workspace 内但被根 `.gitignore` 白名单机制默认忽略（`.gitignore` 第 2 行 `*`），不纳入 wlyd 根 git 跟踪；各项目各自独立 git（仅 `master` 分支，remote 阿里云 codeup）；`wds-miniapp` 另有 `dev` 分支且为知识库同步基线（`master` 落后 `dev` 138 提交，详见 `.repoWiki/.sync-state.json`）。
>
> `wds/` 下 8 个目录均为独立 git：上表 7 个前端项目 + `ai-skills`（AI Agent Skills 资产仓库，非前端项目）。`wds-sso` 的规范入口为 `wds/wds-sso/AGENTS.md`；`wds-miniapp` 的规范入口为 `wds/wds-miniapp/AGENTS.md`。


## 知识库（.repoWiki）

`.repoWiki/` 是 WLYD 整个前端项目的**统一知识库**（带点目录，不在 git 内），承载概览/导航层与逐文件源码语义索引。使用约定（先查库再读码、库与代码冲突先确认再更新等）见 `.cursor/rules/ref-knowledge-base.mdc` 与 `.repoWiki/维护手册.md`。

## 开发规则

详细开发规则已迁移至 `.cursor/rules/` 目录（13 个模块化 `.mdc` 文件，采用分类命名）：

```
.cursor/rules/
├── core-general-standards.mdc       # 核心：通用规范
├── core-development-workflow.mdc    # 核心：开发流程
├── core-execution-visibility.mdc    # 核心：执行过程可见性
├── core-comment-standards.mdc       # 核心：注释规范
├── core-project-rules.mdc           # 核心：项目规则（alwaysApply，Cursor 端入口索引）
├── core-ai-collaboration.mdc        # 核心：AI 协作与独立判断（alwaysApply）
├── tech-uniapp-standards.mdc        # 技术：uni-app 规范
├── tech-vue-standards.mdc           # 技术：Vue 规范
├── ref-tech-stack.mdc               # 参考：技术栈索引（编码前必查）
├── ref-project-overview.mdc         # 参考：项目信息
├── ref-quality-assurance.mdc        # 参考：质量保证
├── ref-known-pitfalls.mdc           # 参考：已知坑点
└── ref-knowledge-base.mdc           # 参考：知识库使用
```

**命名规范**：
- `core-` - 核心行为规则（始终应用）
- `tech-` - 技术栈规范（文件匹配）
- `ref-` - 参考信息（智能应用）

> 旧版单文件 `.cursorrules` 已废弃（迁移说明见文件内容），完整备份位于 `.cursorrules.backup`。
> Qoder 同步至 `.qoder/rules/wlyd-project-rules.md`、CodeBuddy 同步至 `.codebuddy/rules/wlyd-project-rules.md`、Trae 同步至 `.trae/rules/{core,tech,ref}/*.md`（13 个模块化文件，镜像 `.cursor/rules/*.mdc`）。

核心规则摘要：
- 回复使用中文
- 不主动提交代码，只在用户明确要求时生成 commit 信息
- 修改已有内容时优先注释保留，不直接删除
- 禁止在文档中写入估时
- 文档整理人固定为王新骏

## 可用 Skills

Skills 位于 `.cursor/skills/` 目录（`.qoder/skills`、`.codebuddy/skills` 和 `.trae/skills` 均为指向它的 symlink，改一处四端自动生效）。

> Skill 体系的权威说明见根目录 [`skills.md`](./skills.md)（存量、职能、串联链路、待确认问题），Skill 变动需同步更新该文档；本章节表格为快速索引：

| Skill | 说明 |
|-------|------|
| `wlyd-workflow` | **全链路流程编排器**，自动串联需求分析→代码分析→技术方案→编码→审查→提测，支持断点续传 |
| `wlyd-requirement-change-analysis` | 需求改动分析，生成改动清单 |
| `wlyd-review` | 代码审查，接单确认 + 完成自检 |
| `memory-update` | **记忆整理器**，从需求文档/改动清单/验收记录提取新坑和新约定，更新 `.cursor/rules/` 模块化规则文件和 `.cursor/context/known-pitfalls.md` |
| `bugfix-helper` | **线上问题排查助手**，信息收集→排查报告→根因确认→修复方案→验证清单 |
| `yunxiao-bug-fix` | **云效缺陷处理助手**（2026-09 新增），从云效拉取分配给自己的缺陷（含"待评审"筛选），结合当前仓库做只读影响分析；仅在明确授权后才改代码或回写云效状态。凭据放 `~/.yunxiao/.env`（权限 600），命令参数须 `aliyun devops --help` 现查，禁止凭记忆猜 |
| `commit-helper` | Commit 信息生成（含 scope、需求编号、确认后自动执行提交） |
| `code-analyzer` | 代码分析，三种模式：影响范围分析 + 模块深度分析 + 组件引用追踪；仅模块深度分析可沉淀到 `.repoWiki/analysis/`（脚本不覆盖区），影响范围/引用追踪为一次性产物不落盘 |
| `module-doc-curator` | **模块文档梳理与维护专家**，五大能力：代码问答、文档更新、流程图制作与修复、代码评估、技术债务识别；支持正向梳理生成标准结构模块文档 |
| `overtime-tracker` | **加班工时追踪器**，解析打卡记录 → 脚本重算加班工时（工作日 `(末−首)−9.5h`、周末整段），双自检校验，禁止手算 |
| `mastergo-playwright` | **设计稿代码生成器**，通过 Playwright MCP 从 MasterGo 设计稿提取图层样式数据，生成静态 HTML / Vue / React 组件，支持像素级还原 |
| `humanizer-zh` | **中文写作去 AI 味工具**，识别并改写中文文本中的 AI 生成痕迹（夸大象征意义、宣传性语言、模糊归因、破折号过度使用、三段式法则、AI 词汇、否定式排比等 24 类模式）。仅适用于**文档/commit/日报/需求说明**等中文散文，**不适用于代码注释和实现** |
| `wlyd-deai-style` | **代码与注释去 AI 味检测器**（项目专属），判定基线锚定存量真人代码实测数据（物流线真人注释密度 0%–2%，>10% 高度可疑）。四类检测维度：注释（复述方法名/纯结构注释/同一注释重复/JSDoc 滥用/死代码无标注）、实现（过度防御/冗余中间变量/薄封装/三行 if 写成策略模式）、命名（空洞名/与模块既有风格不一致）、结构（SCSS 平铺/模板复杂表达式/`/deep/`/条件编译缺失）。三模式：detect（只出报告）/ fix（改写，旧逻辑注释保留不删）/ baseline（重新抽样基线）。分线判断，企服线不套物流线口径；不碰 Markdown（交给 `humanizer-zh`） |

#### 缺陷处理链路的 Skill 分工

| 技能 | 职责 |
|---|---|
| `yunxiao-bug-fix` | 云效取数 + 缺陷到代码的定位与影响分析 + 云效状态回写（默认只读） |
| `bugfix-helper` | 问题明确后的排查方法：信息收集→排查报告→根因确认→修复方案→验证清单 |
| `wlyd-review` | 代码审查 / 接单确认 / 完成自检 |

典型串联：`yunxiao-bug-fix` 拉缺陷并定位 → `bugfix-helper` 深挖根因与方案 → 改完用 `wlyd-review` 自检。

### Skill 维护原则（铁律）

1. **Symlink 四端合一**：`.qoder/skills`、`.codebuddy/skills` 和 `.trae/skills` 均为指向 `.cursor/skills/` 的 symlink，物理上只有一份文件。以 Cursor 端（`.cursor/skills/`）为唯一权威源，新增/删除 skill 只需在 `.cursor/skills/` 下操作，四端自动一致。
2. **命名前缀**：通用技能不加前缀（如 `bugfix-helper`）；项目专属技能加 `wlyd-` 前缀（如 `wlyd-workflow`）。新增 skill 须按此命名，避免与通用技能混淆。
3. **防回归固化**：skill 内若曾发生计算/口径错误，须把正确公式与「禁止做法」写进 skill 自身（SKILL.md 铁律 + references 警示 + 脚本自检），杜绝同类错误复发。
4. **脚本为唯一权威来源**：涉及数值计算的 skill，计算逻辑只存在于脚本，文档表格由脚本生成/校验，禁止手算或另立公式。
5. **改造记录可追溯**：skill 重大修订须在 `SKILL.md` 记录版本/日期与要点。

### 已归档 Skills

以下 Skill 因内容重复或使用率低已归档，不再随工具加载。归档目录同样通过 symlink 四端合一（`.qoder/skills-archived`、`.codebuddy/skills-archived` 和 `.trae/skills-archived` 均指向 `.cursor/skills/_archived/`）：

| 归档 Skill | 归档原因 |
|-----------|---------|
| `commit-message` | 被 `commit-helper` 完全覆盖 |
| `conditional-compile` | 已被 `.cursorrules` 和组件规范覆盖 |
| `component-mapper` | 能力并入 `code-analyzer` 模式三（组件引用追踪） |
| `code-graph` | 能力并入 `code-analyzer` 分析后可选沉淀 |
| `api-generator` | 与 `.cursor/snippets/api-method-template.md`、`.cursor/context/api-patterns.md` 重复 |
| `doc-generator` | 文档格式已由项目规则约定，无增量价值 |
| `mixin-creator` | 使用频率低，可参考项目现有 mixin |
| `uni-app-component` | 组件规范已固化到 `.cursorrules` 与 snippets |
| `uniapp-page` | 内容单薄，与组件规范重叠 |

## 上下文参考文档（Context）

位于 `.cursor/context/` 目录（`.codebuddy/context` 和 `.trae/context` 为指向它的 symlink），编码前可 `@` 引用快速获取背景知识：

| 文件 | 说明 |
|------|------|
| `known-pitfalls.md` | **已知坑点汇总**，13 类高频坑（渲染循环/OSS 图片/金额精度/锚点/层级等），每次编码前检索 |
| `business-terms.md` | 业务术语表（运单、结算、司机对账、回单付、磅单、附件类型等词汇解释） |
| `api-patterns.md` | 接口调用约定（各子项目 baseUrl、响应结构、resetData、OSS 转换、金额计算写法） |

## 代码片段模板（Snippets）

位于 `.cursor/snippets/` 目录（`.codebuddy/snippets` 和 `.trae/snippets` 为指向它的 symlink），可直接复制使用：

| 文件 | 说明 |
|------|------|
| `vue2-component-template.md` | 带 JSDoc 头部注释的 Vue2 组件标准结构 |
| `payment-calc-template.md` | 金额三角联动计算模板（回单付/到付/预付款，含等式校验和比例校验，PC + 移动端） |
| `api-method-template.md` | logisticsweb 接口封装标准写法（含接口切换过渡方案） |

## 配置维护说明

本项目以 Cursor 为主进行配置维护，skills / context / snippets / prompts 通过 symlink 实现四端合一：
- Cursor 主配置（**唯一物理源**）：`.cursor/`（rules / skills / context / snippets / prompts）
- Qoder：`.qoder/rules/` 独立维护 + `.qoder/skills` → `.cursor/skills` + `.qoder/prompts` → `.cursor/prompts`（symlink）+ `AGENTS.md`
- CodeBuddy：`.codebuddy/rules/` 独立维护 + `.codebuddy/skills` → `.cursor/skills` + `.codebuddy/context` → `.cursor/context` + `.codebuddy/snippets` → `.cursor/snippets` + `.codebuddy/prompts` → `.cursor/prompts`（均为 symlink）
- Trae：`.trae/rules/` 独立维护 + `.trae/skills` → `.cursor/skills` + `.trae/context` → `.cursor/context` + `.trae/snippets` → `.cursor/snippets` + `.trae/prompts` → `.cursor/prompts`（均为 symlink）
- 共享配置：`.vscode/settings.json`

> **入库范围提示**：根 `.gitignore` 采用「第 2 行 `*` 全局忽略 + 白名单放行」机制，白名单含 `.cursor/`、`.codebuddy/`、`.qoder/`、`.trae/`、`.md/`、`AGENTS.md`、`README.md`、`docs/`、`scripts/`，四端配置均可入库。
>
> [2026-10-15] 已在 `.gitignore` 追加 `!.trae/` 与 `!.trae/**`，Trae 端 13 个 rules 镜像与 5 个 symlink 现纳入版本库，与其他三端一致。原说明保留用于追溯：白名单原不含 `.trae/`——故 Trae 端全部配置（含 `.trae/rules/` 13 个镜像文件与上述 symlink）不进版本库，仅本机生效。// TODO: wxj 确认 Trae 端配置是否需要纳入版本库（2026-10-15 已确认纳入，TODO 保留待复核）

### 规则文件结构

Cursor 规则已从单文件 `.cursorrules` 迁移至模块化结构（采用分类命名）：

```
.cursor/rules/
├── core-general-standards.mdc       # 核心：通用规范（始终应用）
├── core-development-workflow.mdc    # 核心：开发流程（始终应用）
├── core-execution-visibility.mdc    # 核心：执行过程可见性（始终应用）
├── core-comment-standards.mdc       # 核心：注释规范（始终应用）
├── core-project-rules.mdc           # 核心：项目规则（始终应用，Cursor 端入口索引）
├── core-ai-collaboration.mdc        # 核心：AI 协作与独立判断（始终应用）
├── tech-uniapp-standards.mdc        # 技术：uni-app 规范（文件匹配）
├── tech-vue-standards.mdc           # 技术：Vue 规范（文件匹配）
├── ref-tech-stack.mdc               # 参考：技术栈索引（编码前必查，智能应用）
├── ref-project-overview.mdc         # 参考：项目信息（智能应用）
├── ref-quality-assurance.mdc        # 参考：质量保证（智能应用）
├── ref-known-pitfalls.mdc           # 参考：已知坑点（智能应用）
└── ref-knowledge-base.mdc           # 参考：知识库使用（智能应用）
```

**命名规范**：
- `core-` - 核心行为规则，每次对话必须应用
- `tech-` - 技术栈规范，按文件类型匹配
- `ref-` - 参考信息，按需智能加载

> 旧版 `.cursorrules` 已废弃（迁移时间：2026年7月24日，命名优化：2026年7月25日），完整备份位于 `.cursorrules.backup`。

### 同步规则与约定

1. **规则同步**：修改 `.cursor/rules/*.mdc` 时，以 Cursor 侧为准，同步到其他工具配置（rules 为独立文件，不走 symlink）
2. **Skills / Context / Snippets（symlink 四端合一）**：`.qoder/skills`、`.codebuddy/skills`、`.trae/skills`、`.codebuddy/context`、`.trae/context`、`.codebuddy/snippets`、`.trae/snippets` 均为指向 `.cursor/` 对应目录的 symlink，只需在 `.cursor/` 下操作即可四端自动生效，无需手动同步
3. **AI 完成更新后不再重复提醒同步其他工具**

## 可用 Prompts

Prompts（多角色协作）位于 `.cursor/prompts/` 目录，与 skills / context / snippets 一样走 symlink 四端合一（`.codebuddy/prompts`、`.qoder/prompts`、`.trae/prompts` 均指向 `.cursor/prompts`，只需在 `.cursor/prompts/` 下操作）：

| Prompt 角色 | 说明 |
|-------------|------|
| `role-pm` | 需求分析师，拆解需求、识别不确定项 |
| `role-architect` | 架构师，交互式分阶段技术方案设计（快速模式/完整模式） |
| `role-coder` | 开发工程师，逐文件编码、旧逻辑注释保留、完成自检 |
| `role-reviewer` | 代码审查员，P0/P1/P2 分级审查 + 横向影响检查 |
| `role-refactor` | 重构师，批次化重构、行为不变底线、收益量化 |
| `role-bugdetective` | Bug 侦探，信息收集→排查报告→根因确认→修复方案 |
| `role-qa-checklist` | 提测清单生成器，主流程/边界/多端/回归用例 |
| `role-ui-reviewer` | UI 还原审查员，设计稿 vs 实际截图对比，8 维度审查 |

使用方式详见 `.cursor/prompts/README.md`。

> [2026-10-15] 角色与技术栈文件由 `.md/prompts/` 迁入 `.cursor/prompts/`。原位置在 wlyd 主仓库之外的独立个人仓库，导致 `.cursor/rules/ref-tech-stack.mdc` 声明的「技术栈唯一源」在项目 clone 后为死链，现已闭环。`.md/prompts` 保留为指向新位置的 symlink，旧路径仍可解析。

---

## AI 执行纪律标识（用户校验锚点，铁律）

> **本区块是用户校验「AI 是否按 AGENTS 与项目规则执行」的唯一锚点。**
> AI 每次处理涉及代码 / 文档 / skill / rules 修改的任务，**必须在回复末尾输出本标识**；用户凭标识是否齐全，判断本次是否走了规范流程。

**AI 每次动手前必做**：
1. 读取并遵循本 `AGENTS.md` 与 `.cursor/rules/` 中的核心规则（覆盖接单确认、横向搜索、完成自检、独立判断）；CodeBuddy / Qoder 单文件规则是同步镜像。
2. 涉及 skill / rules / context / snippets 改动，skills/context/snippets 通过 symlink 四端合一（只需改 `.cursor/` 下），rules 需手动同步四端。
3. 凡涉及数值计算，以脚本为重算/校验唯一来源，禁止手算另立公式。
4. 每次回复**开头以「honey 王」起句**、**末尾含「wang 工」称呼**（双探针，见下），作为 AGENTS / rules 加载校验。

**双称呼探针（加载校验，强制）**：
- 回复**开头**必须以「honey 王」称呼起句（如"honey 王，关于..."）→ 证明 `AGENTS.md` 已加载。
- 回复**末尾**须含「wang 工」称呼（由 rules 文件约束，紧邻【规则对齐】之前一行）→ 证明 `rules` 已加载。
- 用户重置上下文后据此判断：两称呼齐全 = 双边约束均生效；只见「honey 王」不见「wang 工」= rules 未生效；只见「wang 工」不见「honey 王」= AGENTS 未生效。

**AI 每次交付前必输出（置于回复末尾）**：
```
【规则对齐】AGENTS✓  rules✓  横向搜索✓  四端同步✓  完成自检✅/⚠️
```
- 任一项缺 `✓` → 视为未走规范流程，用户应要求重做。
- 完成自检为 `⚠️` 时，必须先修正再交付，不得带问题交付。
- 此标识缺失 → 视为本次未遵循 AGENTS，用户可直接指出。

---

## AI 交付验收清单（强制自检）

> **AI 交付代码前必须对照本清单自检，用户验收时也按此清单校验。**
>
> 清单正文已独立至 [AI-DELIVERY-CHECKLIST.md](./AI-DELIVERY-CHECKLIST.md)（含 Vue 组件清单、API/工具函数清单、用户验收方式、清单说明与常见问题）。
