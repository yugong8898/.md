# REQ-195 工作流进度

## 需求信息
- 需求名称：电子签章改造（双端）
- 工作区：.md/需求/进行中/REQ-195/
- 需求版本：R1（原始需求已更新至 V1.3）
- 测试版本：T0
- 开始时间：2026-11-02
- 需求来源：.md/需求/进行中/REQ-195/原始需求/REQ-195 电子签章改造（双端）.md
- 云效ID：RZMP-9021
- 产品经理：刘炳伟、丁建文

## 接口契约开发依据（2026-11-10 切换）

### Apifox 契约对照与本轮代码调整

- 已按新契约调整短信发送、校验、重发请求体：只传 `caFlowId`（校验另传 `verifyCode`）；`/auth-file` 只传 `caFlowId` 与 `ossCode`；`/success-seen` 不传请求体。协议响应类型增加可选 `countdown`，有正值时按服务端秒数展示冷却。
- **[2026-11-11 口径修订（B 口径）] 重传链路改为重走全流程。** 2026-11-10 记录的「原地替换：只上传新文件直接调 `/auth-file`，不重新申请协议、不重发或校验短信」口径**作废**。现行口径：被拒后步骤条由接口状态驱动回第一步（认证场景重读 `user/info`，签署场景重读 `/status`），经办人重新收集委托书后重走协议+动态码，`check-sms-code` 通过且 `nextAction=UPLOAD_AUTH_FILE` 时凭本轮新 `caFlowId` 提交 `/auth-file`。原「重传 `caFlowId` 来源待 Server 确认」问题随之关闭：每轮重走经 `/agreement` 取得新流程号，不再依赖 `/status` 下发。
- **代码处理（已按 B 口径落地）**：独立页重传入口不再沿用会话流程号直传 `/auth-file`（原 `reuploading` 路径注释保留），回委托书第一步收集后由 `ElectronicSign` 重走 `/agreement` + 短信校验再送审；服务商/雇主认证容器「重新初始化按接口状态定位步骤」本就与 B 口径一致，无需改动。新增联调点：RE_UPLOAD 用户重走 `check-sms-code` 时 Server 须返回 `nextAction=UPLOAD_AUTH_FILE`。
- **[2026-11-11 二轮口径（送审方式分流 + 5 秒静默等待 + 方案 a）]** ① 认证环节经办人改为「收集即落库」：收集步上传 OSS 后立即调 `ca-auth-letter` 落认证域物料，动态码通过后由 Server 用已落库物料自动送审，前端认证环节**不再调 `/auth-file`**（前端拿不到 oss 资源）；非经办人动态码通过即进下一环节（无审核无等待）。② 合同签署/固定入口（独立页）经办人可取到 oss 资源，维持短信通过后调 `/auth-file` 送审。③ 经办人审核通过后**静默等待 5 秒**（常量 `CA_AUTH_PASS_ADVANCE_DELAY_MS=5000`，无页面倒计时）再进下一环节（认证场景→签署协议；独立页/合同场景→回退 returnUrl/back）；独立页重进时已是认证成功态同样自动 5 秒回退，不停留在结果页。〔此独立页自动回退口径已由 2026-11-23“完成”按钮口径取代；认证容器 5 秒等待规则保留。〕④ P1「重新上传」拍板方案 a：重进先见驳回态，点重新上传后认证场景调 `user/info`、合同场景调 `/status` 刷状态，仍处 RE_UPLOAD 则回委托书收集步重走。⑤ 雇主认证页补齐经办人委托书收集步（原仅服务商容器有 `authLetterUpload` 视图）。
- 待联调：`isAuthFileNeeded` 虽在 schema 标为必填，示例却缺失；新用户委托书物料落库 T1 与短信重发冷却时长也未闭环。以上不视为已验收。
- **[2026-11-23 联调实证 JL-02] 新用户认证缺少委托书时不得由前端跳回提交资料**：雇主、服务商认证容器收到 CA 缺料结果或进入 CA 前发现委托书 OSS code 缺失时，保留错误提示并停留在当前步骤，不再强制切到 `submitMaterials`；独立签署页仍保留转到委托书上传步骤的行为。OSS code 在认证流程中的取值问题暂不处理，后续按《测试用例逐条验证-REQ-195》3.6.4 核实。

- **当前依据**：`电子签章接口契约-Apifox-REQ-195.md`。内容取自 Apifox 项目 `8677491`「万大圣企业服务平台API接口」默认模块实测数据，覆盖 `/v1/employer/ca-verification/*` 与 `/v1/provider/ca-verification/*` 共 14 个接口及其 20 个 schema（请求体、响应 model、枚举取值、服务端错误文案、失败语义、调用时序）。〔2026-11-16 补〕新增两端共用无角色前缀接口 `GET /v1/ca-verification/auth_file_template`（模板 URL 下发），核身接口口径 14→15，契约详见契约文档第九节。**接口字段名、类型、层级、必传参数一律以该文档为准，不再引用对齐表的预估签名。**
- **停止作为依据**：`后端接口契约对齐表-REQ-195.md`。其零章 0.1 节的 7 个核身接口预估已被 Apifox 实测契约取代，已知差异包括：`/auth-file` 实际为 `caFlowId` + `ossCode`（不收 `fileName`/`fileUrl`）；`/success-seen` 无请求体；`/send-sms-code`、`/check-sms-code`、`/resend-sms-code` 不传主体 ID；`/status` 另有 `authStatus`、`authPhase`；`entryStatus` 枚举无 0；短信倒计时 `countdown` 挂在 `/agreement` 响应。
- **保留原因**：对齐表不删除，继续承担两项追溯——① C-001~C-007 / U-008 等确认项的决策历史；② 认证域接口（`ca-auth-letter`、`/v1/{role}/protocol` 服务端强校验、`url-2-osscode`、`user/info` 透传差异）的契约记录。**这部分内容不在新契约文档范围内，仍只能从对齐表查。**
- **更新机制**：Apifox 侧接口有更新时由用户通知，按「刷新模块索引 → 取 14 个路径子文件 → schema 两跳取 20 个叶子」重新拉取，并与契约文档逐节比对差异。

## 阶段进度
| 阶段 | 状态 | 产物文件 | 完成时间 |
|------|------|---------|---------|
| 阶段0 需求分析 | ✅已完成 | 阶段0-需求文档-REQ-195.md | 2026-11-04 |
| 阶段1 代码分析 | ✅已完成 | 阶段1-代码分析-REQ-195.md | 2026-11-04 |
| 阶段2 技术方案 | ✅已完成 | 阶段2-技术方案-REQ-195.md | 2026-11-04 |
| 阶段3 编码执行 | ✅已完成 | 阶段3-编码执行计划-REQ-195.md | 2026-11-17 |
| 阶段4 代码审查 | ✅已完成 2026-11-17（bugfix 后指纹已更新） | 阶段4-审查报告-REQ-195.md | 通过（无代码 P0）；R4-01 文档校准待阶段5 前，R4-04~R4-11 P2 待裁决；2026-11-17 晚 entryStatus=3/4 分流 bug 修复、协议文案统一、RZMP-11254 两端订单页签署守卫补齐及 RZMP-11265 按钮文案条件化（含口径二次修正）后 SHA 更新为 74a0be18…3e8a3f（受检 33 文件） |
| 阶段5 测试基线与覆盖对齐 | ⏳待开始 | - | - |
| 阶段6 测试执行与Bug修复循环 | ⏳待开始 | - | - |
| 阶段7 需求复盘（可选） | ⏳待开始 | - | - |

## 当前阶段
**2026-11-23 老用户认证成功落地页口径已实现**：独立电子签章认证页进入时若 `/status.entryStatus=7`，无论是否经办人均展示“电子合同签章认证已完成”成功页，不自动返回；用户点击“完成”后返回 `returnUrl` 或上一页。平台认证容器仍按原规则自动流转，新用户认证流程不变。代码与阶段2/3文档已更新；静态检查通过，页面实机回归待执行。

**2026-11-23 新用户 CA 缺材料处理调整**：雇主与服务商认证容器在 CA 验证码校验返回 `UPLOAD_AUTH_FILE` 但前端拿不到 OSS code 时，不再发出 `missing-auth-file` 触发回到 `submitMaterials`；认证前置缺材料校验也只提示并留在当前视图。独立电子签章页仍保留进入授权委托书上传步骤的行为。OSS code 取值异常仍是独立未解决项，本次只移除错误回退。

**前一事项（2026-11-20）**：RZMP-11727「审核不通过，web 跳上传授权书页、app 跳企业认证成功页」只读分析与新用户重传口径确认。用户确认新用户委托书在第一步收集，CA 审核失败后点“重新上传”进入单独委托书上传页，不回退提交材料，StepBar 不动，重传后回签章步走新协议。Web 代码当时与口径一致；APP 跳成功页为独立问题待 APP/Server 定位。分析记录见《RZMP-11727-缺陷分析-REQ-195.md》。

**2026-11-20 CA 签署拦截覆盖盘点**：全项目双轨盘点（API sign 封装追消费点 + views handler/文案 grep）完成，8 处守卫点覆盖确认无遗漏；发现遗漏：P0-A buy.vue 下单后直签无守卫、P0-B common.vue/confirm.vue 页内最终动作无守卫（可被直达 URL/push 绕过）、P1-C 供应商订单签署缺口（待裁决）、P2-D 重新上传/钱包签约待产品定范围。已落《CA签署拦截覆盖盘点-REQ-195.md》（含确认记录表），用户拿去做产品/后端确认，确认前不落代码。另本轮已实施 SubpackageSignConfirmDialog 弹窗内聚守卫（覆盖总分包 5 页，ESLint 0 error、vue-tsc 全仓 0 error、回归 4/4）。〔同日晚 P1-C 收口〕用户裁决供应商纳入拦截 + 方案②：useElectronicSignGuard 新增可选 authPath（缺省按 role 推导，既有接入点不变），supplier/order/list.vue sign() 与 detail.vue signContract() 接守卫跳供应商专属 URL，卡片零改动；3 文件 +20/-2，ESLint 0 error、vue-tsc 全仓 0 error、回归 4/4；盘点文档升 v1.1（P1-C 确认表回填）。P0-A/P0-B/P2-D 仍待外部确认。

**2026-11-20 服务商签署协议恢复修复**：平台认证草稿为 `pending + authPhase=4` 时，两端不直接进入系统审核；CA `/status.canSign=true` 后恢复到签署协议。服务商签署组件原 `authPhase >= 3` 将 CA 完成误判为协议已签，已改为 `authPhase === 3`，与雇主端一致。已通过类型检查、相关 ESLint 与差异检查；实际账号页面回归由用户确认修复。

**2026-11-17 独立页委托书提交顺序确认**：用户确认点击委托书下一步时 `/draft` 成功后立即调 `ca-auth-letter`，两者成功才进入短信步骤；短信通过后只调 `/auth-file`。新用户平台认证不调用 `ca-auth-letter`；接口失败由请求层提示，不处理跨刷新补偿。代码与补充方案已同步，待联调验证。

**2026-11-17 独立页委托书草稿恢复**：Apifox 确认雇主/服务商 `POST /ca-verification/draft` 的主体 ID + `draftOssCode` 契约；独立页上传后先暂存，`/status.authFileOssCode` 决定经办人默认在上传还是签章步骤，审核中/驳回态仍显示结果。详见《阶段2-补充方案-新用户委托书复用》。改动未提交，阶段4需增量复审。

**2026-11-17 新用户委托书复用**：按用户新口径，新用户经办人平台认证不再二次上传委托书；从认证草稿 `uploads.authLetter.ossCode` 在短信通过后调 `/auth-file`，驳回重传回“提交材料”〔2026-11-20 口径更新：改为单独委托书上传页 authLetterUpload，不回退提交材料，StepBar 不动，见置顶 RZMP-11727 条目〕；独立签章页保持原上传流程。实施依据见《阶段2-补充方案-新用户委托书复用》。当前为未提交改动，阶段4既有审查指纹需增量复审；静态检查与联调边界见补充方案。

**2026-11-17 签署守卫去重**：六个合同/订单签署入口统一调用 `useElectronicSignGuard.checkBeforeSign()` 处理查询失败提示与未认证跳转；各页原签署请求、埋点和 loading/busy 清理不变。改动未提交，阶段4既有指纹不覆盖本次去重，后续增量复审时更新。ESLint 7 文件 0 error（332 条 warning），电子签章回归测试 2/2，`git diff --check` 通过。

**2026-11-17 晚 RZMP-11265 按钮文案条件化（云效缺陷，用户明确口径后实施）**：缺陷标题「服务商web端，个人老用户进入电子合同签章页面，按钮应该展示文案为确认」，描述为空。用户明确口径：**按钮文案按入口场景区分——合同签署时「提交」，认证时「下一步」**（非按个人/企业或新老用户）。修复：ElectronicSign.vue 新增 `verifyButtonText = computed(() => props.contractFlow ? '提交' : '下一步')`，模板硬编码「下一步」改插值（旧文案 HTML 注释保留）。判定复用既有 contractFlow prop：独立页传 route.query.source==='contract'（守卫弹窗跳转带 source:'contract'），两端认证容器不传（恒「下一步」），三消费点零改动。验证：ESLint 0 error（5 存量 warning 均不在新增行）、vue-tsc 110 存量持平零新增（本文件 0 条）。受检清单 33 文件不变（ElectronicSign.vue 本在清单内），SHA 更新 6813eb3c…1f5c83。审查报告新增 R4-15 节（v1.5）。云效状态未回写待授权。〔2026-11-17 晚二次修正：用户纠正「需求理解错了」——判定维度是承载页面而非合同触发与否：**所有 /electronic-sign 独立页入口（合同签署+固定入口）均「提交」，所有 /certification 认证容器均「下一步」**。contractFlow 口径作废（固定入口进独立页也须「提交」）：新增 standalonePage prop，verifyButtonText 改按 standalonePage 判定（旧 computed 行注释保留），独立页传 standalone-page，两端容器不传。验证：ESLint 2 文件 0 error（12 存量 warning）、vue-tsc 110 存量持平零新增；SHA 二次更新 74a0be18…3e8a3f；审查报告 R4-15 删除线更正升版 v1.6；原遗留①（固定入口文案待裁决）关闭〕
**2026-11-17 晚 RZMP-11254 雇主订单页守卫补齐（用户追问「雇主的呢？」，范围裁决后实施）**：重查推翻上一轮「雇主端无订单页直调签署链路」错误结论（当时仅 grep 服务商接口名未查雇主自有封装 postEmployerOrderSignContract）。实测雇主签署出口全景：订单 list/detail handleSignContract（briefStatus 分流：直开 URL/选方式弹窗→common/custom/审核提示/兜底跳 common）、contract/common.vue、contract/confirm.vue、总分包 5 页（openSubpackageSignContractUrl）均无守卫。**用户裁决：仅补雇主订单 list/detail 2 页入口守卫**，common/confirm 旁路（purchase/buy 等入口）与总分包 5 页范围另议。修复：两页 handleSignContract 入口插 useElectronicSignGuard('employer').guardBeforeSign()，未认证 confirmAndGoElectronicSign(router, route)（雇主无路径常量，沿用雇主合同页无参写法，默认目标即雇主独立页，身份正确），原 briefStatus 链路零删改。验证：ESLint 0 error（253 存量 warning）、vue-tsc 110 存量持平（detail.vue 存量错行号 1056→1072 随插入位移，内容逐字一致，diff 比对确认零新增）、回归 2/2、diff --check 通过。受检 31→33 文件（/tmp/req195-files-v4.txt），SHA 更新 a4d22803…850865。审查报告 R4-13 错误结论已删除线更正，新增 R4-14 节（v1.4）。
**2026-11-17 晚 RZMP-11254 订单页签署守卫补齐（云效缺陷，回退阶段3）**：测试报障——服务商 web 端订单管理列表和详情点「签署合同」未弹去认证弹窗。根因：provider/order/list.vue handleSignContract 与 detail.vue handleSignContract 直调 postProviderSignContract，从未接入 REQ-195 签署前置守卫（阶段2 入口收敛只覆盖两个核心合同页，订单页属遗漏面）。修复：两处 handler 在 busy/loading 置位后、调签署接口前插入 `useElectronicSignGuard('provider').guardBeforeSign()`，未认证走 `confirmAndGoElectronicSign(router, route, PROVIDER_ELECTRONIC_SIGN_PATH)` 弹「去认证」，查询失败 message.error 拦截，loading 静默返回；镜像合同页 handleSign 既有模式，原签署链路零删改纯插入。横向搜索：postProviderSignContract 第三消费点 ProviderOrderDetailBasicInfoCard.vue 经全仓 grep 确认无任何 import/注册（仅 uploadAchievements.vue 注释提及），为孤儿组件不在活跃链路，按最小改动不动。验证：ESLint 2 文件 0 error（27 存量 warning）、vue-tsc 110 存量持平零新增、回归测试 2/2。受检清单 29→31 文件（/tmp/req195-files-v3.txt），SHA 更新 43fdb2a9…c3bad91。注意：当前 useElectronicSignStatus 为用户手改 mock（entryStatus=3），守卫必拦截弹窗，真实放行需待 mock 恢复后联调。云效状态未回写（默认只读，待用户单独授权）。
**2026-11-17 晚 协议详情描述文案统一（用户指令）**：ElectronicSign.vue 协议详情描述不再区分 contractFlow，统一为「请滑动阅读下方全部协议，确认同意后，获取验证码完成电子认证，方可签署合同。」，旧三元 HTML 注释保留。横向搜索：同文案另仅 useElectronicSignGuard.ts L36 守卫弹窗 content 一处（合同页拦截弹窗，非本次点名范围，未动，待用户确认是否同步）。contractFlow prop 仍被 ProviderAuthLetterUpload 传参消费，无 unused。ESLint 0 error（5 存量 warning）；受检 diff SHA 更新 d2671832…d4abeb。
**2026-11-17 晚 entryStatus=3/4 分流 bug 修复（回退阶段3）**：用户报障——/status 返回 entryStatus=3（审核中）时点「下一步」误入委托书收集步，上传后进协议页误显「协议加载失败」。根因：两端容器 4 处前进 handler（provider handleMoreInfoNext/handleFaceNext、employer handleSubmitNext/handleFaceNext）分流只看 isAuthFileNeeded 未排除 3/4 结果态；首屏恢复路径已有排除故刷新重进正常，仅前进触发。修复：types.ts 新增共享集合 `CA_AUTH_LETTER_REVIEW_STATUS=[REVIEWING, RE_UPLOAD]`（用户指令避免双 !== 链，按项目枚举数组+includes 惯例），4 处三元补 `&& !CA_AUTH_LETTER_REVIEW_STATUS.includes(entryStatus.value!)`（前置守卫已保 status 非空），旧三元注释保留。全状态矩阵核验仅 3/4 行为变化，审核通过 5 秒静默流转/4 态重传闭环不受影响；附带堵住 3 态重传覆盖 ca-auth-letter 物料副作用。验证：ESLint 3 文件 0 error（32 存量 warning）、回归测试 2/2、vue-tsc 修复 3 文件零报错（全仓 111=110 存量+1 为用户手改 mock 块多余字段 authPhase/authstatus/ShowSuccessEntry 所致，非本次引入，mock 拼写瑕疵已提示不顺手改）。受检 diff SHA 更新 c21a72ce…1837195（含用户 mock 工作区改动）。复现口径：需首屏落 moreInfo 的早期进度企业账号点下一步；authPhase=2/4 账号首屏直落审核中页且 StepBar 无回退，无法触发。待用户 mock 复验后提交。
**2026-11-17 阶段4 审查通过**：29 个受检文件逐文件读完（Vue SFC 含完整 template），范围限定 REQ-195 19 笔提交（排除 master 合并带入的 REQ-206 草稿/REQ-132 工作台等他人改动）。结论：**无代码 P0**；双弹 toast 疑虑实测请求层后排除（静默接口返回 data、非静默弹一次后 reject，组件无叠加提示）；回归测试 2/2 通过。P1 仅 R4-01（阶段2/逐条验证旧送审口径文档校准，阶段5 前完成）；P2 八项（R4-04 雇主容器 ElectronicSign 缺 :key、R4-05 认证容器双状态源重复查询/轮询、R4-06 英文兜底文案、R4-07 re-upload 事件 kebab 命名、R4-08 模板下载 url 空静默、R4-09 succeed 旧口径注释、R4-10 returnUrl 未校验同源、R4-11 范围外删两行他需求 TODO 注释）均不顺手改，待用户逐项裁决。mock 块/断言按开发阶段保留口径不判缺陷。受检 diff SHA-256 `4ada5a17…a1c9d9` 已写入「阶段 4 审查差异」；阶段5 准入时业务代码 diff 变化须复审。报告 v1.1。
**2026-11-17 阶段3 收尾与阶段4 启动**：用户手动提交并推送 `eac55dfa3`（13 文件 +42/-27，与 commit 提案一致无漂移）。出口门禁按兜底口径执行（`quick-verify.sh` 只查工作区 staged/unstaged，不适用已提交改动）：ESLint 13 文件 0 error（exit=0，112 条存量 warning）、`vue-tsc --noEmit -p tsconfig.app.json` 110 条存量持平零新增。R 类全部闭环（R-02 Server 确认关闭）。工作区仅剩 `ElectronicSignEntry.vue` 两行行尾空格清理（L165/L168，无逻辑改动），待下次顺带提交。遗留 U-015/T1/P-1 与联调必验项转阶段5/6，不阻塞编码出口。**阶段3 标完成，阶段4 启动**：分支 `b78b1e73d..HEAD` 全量 diff 187 文件含 master 合并带入的他人改动（不作审查范围），审查范围限定 REQ-195 自身 **19 笔提交、29 个文件**（`git log --grep="REQ-195" --name-only` 并集）。
**2026-11-17 阶段3出口核验**：分支相对 `master` 的 30 个 TS/Vue/测试文件 ESLint 0 error（178 warning）；电子签章回归测试 2/2 通过；全量 `vue-tsc -b --noEmit` 仍有 110 条错误，CA 核心文件零报错，雇主合同页 3 条错误对应 `master` 已有代码。修正固定入口组件 2 行尾随空格后，`git diff master --check` 通过，`quick-verify.sh` 对这 1 个未提交文件通过；脚本不能覆盖已提交的整个分支。当前无本地页面服务或真实接口联调记录。阶段3步骤8尚未满足，阶段4不标开始。〔2026-11-17 晚更新：commit 已由用户手动完成并推送，本段结论被上方「阶段3 收尾与阶段4 启动」段取代，保留作历史快照〕
**2026-11-17 R-02 关闭**：用户确认当前短信恢复实现没有问题，前端保持现状，不再将 R-02 列为待 Server 确认的开发阻塞项；短信接口行为仍随正常联调验收。代码零改动；同步阶段3和《测试用例逐条验证》当前状态。〔2026-11-17 晚升级〕用户转达 Server 结论：send-sms-code / resend-sms-code 选择现行实现没问题，依据由「用户确认」升级为 **Server 确认**；R 类全部闭环，无待处理代码项。同步逐条验证 v1.15（头部依据升级 + 3.4.1/3.4.3/变更记录补齐）。
**2026-11-17 R-06 关闭与文案常量化提案**：① R-06 经用户确认「不处理」关闭（需求原文未提及未上传提示文案，期望来自 xmind:2377，维持置灰+点击拦截现状，代码零改动）；至此 R 类仅剩 R-02（待 Server）。〔2026-11-17 晚〕R-02 Server 确认现行实现关闭，R 类全部闭环。② 用户指令「电子合同签章认证」统一文本提为常量：横向搜索实测活跃消费 14 处/10 文件（守卫弹窗标题、两端合同页 toast、两端认证步骤数组、独立页步骤+标题、入口配置 4 处、委托书上传/结果态文案、三端路由 meta.title），注释内 6 处不动；方案：新建零依赖 `src/constants/electronicSign.ts` 导出 `CA_CERT_NAME`（authentication/const.ts 携带 useAplus 埋点依赖不宜被路由文件引入），旧行注释保留，方案待用户确认后实施。文档同步：逐条验证 v1.14、workflow-state。〔2026-11-17 已实施〕用户裁决「直接替换，不用注释保留，简单问题不要复杂化」→ 旧行注释保留口径作废，直接替换。实施时复测活跃字面量实为 19 行/12 文件（提案时 14 处/10 文件为粗计）：新建零依赖 `src/constants/electronicSign.ts` 导出 `CA_CERT_NAME`，12 文件逐个替换（合成文案用模板字符串、模板用插值、路由 meta.title 直引），注释/JSDoc 内 7 处不动。验证：回搜活跃字面量仅剩常量定义；ESLint 13 文件 0 error（112 条存量 warning）；vue-tsc 110 条存量持平零新增。git：12 改 + 1 新增未跟踪，commit 提案已更新待确认。
**2026-11-17 G-13 关闭与 R-06 核实**：① G-13 主体信息展示经用户裁决「需求文档上就没提，不处理」关闭；核实需求原文 grep「主体信息/企业名称/当前主体/公司名」确无委托书页展示主体名称的要求（用例 5.11 标题来自 XMind），G-13 整条闭环（埋点+主体信息均不处理，代码零改动）。② R-06 核实：需求原文未提及未上传提示文案（期望来自 xmind:2377），用例 5.4 核心预期「不能提交审核」已由置灰+点击拦截满足；建议按「不处理」关闭，待用户确认。文档同步：逐条验证 v1.13、阶段3 v1.17、workflow-state。剩余开口：R-02（今日找 Server）、R-06（待用户确认关闭）；commit 仍待确认（暂存 1 + 未暂存 5 文件）。〔2026-11-17 晚〕R-06 用户已确认不处理，关闭；R 类仅剩 R-02。〔同日晚再更新〕R-02 Server 确认关闭，R 类全部闭环。
**2026-11-16 用户逐项裁决落地（A1–A8 / C1 / C3 / D1）**：① A1 succeed 误判不改，`code=200 && succeed=false` 风险登记为已知项；② A2/R-02 短信通道恢复问题记录待定，用户 2026-11-17 找 Server 确认（countdown>0 时短信是否已发、旧码对新 caFlowId 是否有效、冷却后走哪个接口）；③ A3/R-03 判伪关闭——`fetchCaSuccessEntrySeen` POST body `{}` 符合 Apifox 契约 3.7「无请求体，服务端按当前登录用户定位主体」，多主体 seen 隔离转联调必验；④ A4/G-09 文案收尾已执行：4 文件 5 处统一「电子合同签章认证」（`ProviderAuthLetterUpload.vue:134` 两处旧名「电子签名认证」、`AuthLetterStatus.vue:53` 与两端合同页错误 toast 缺「合同」的「电子签章认证」），旧文案注释保留；⑤ A5 到期 UI 与首次相同、本需求所有埋点不处理（G-11 关闭；G-13 委托书页主体信息展示仍待确认）；⑥ A6 状态失败不处理、个人中心入口位置按现有实现（R-05/R-08 闭环；R-06 未上传提示文案仍待确认）；⑦ A7 入口未实名短路 GET /status：`ElectronicSignEntry.vue` 改 `useElectronicSignStatus(role, { autoRefresh: false })` + 门控 watch（immediate）承接首查/主体切换/实名晚加载，共享 composable 零改动，认证页/守卫不受影响；⑧ A8 批准按现状更新文档：即将到期与已过期落地页完全相同、StepBar 仅一组数据（steps.length<=1）时隐藏；⑨ C1/U-016 关闭（入口为用户按设计图手动还原，无需设计补图）；⑩ C3/U-018 关闭（成功描述文案没问题）；⑪ D1 阶段0 三处残留校准获授权。验证：ESLint 0 error（73 条存量 warning）、`vue-tsc --noEmit -p tsconfig.app.json` 110 条存量持平、本次 5 文件零新增。文档同步：逐条验证 v1.12、阶段0 v2.14、阶段3 v1.16、阶段2 v2.21、workflow-state。遗留两问：R-06、G-13 主体信息展示。〔2026-11-17〕G-13 已关闭（需求未提及、不处理）；R-06 核实需求未提及，待用户确认关闭。
**2026-11-16 落地对齐（即将到期入口 → 完整认证环节）**：入口放开后，独立页落地逻辑与已过期（RE_AUTHENTICATE）对齐——`electronicSign/index.vue` 的 `IS_IN_SIGN_STATUS` 移出 `EXPIRING_SOON`，经办人（isAuthFileNeeded=true）先落「补充授权委托书」收集步，再进协议+短信认证，与已过期链路完全一致；非经办人不受影响。4 个消费页跳转链路不变，`returnUrl` 已由 `handleSignCompleted` 消费，无需改动。横向核对全仓 5 个 `EXPIRING_SOON` 消费点：`ElectronicSign.vue` 的 `NEED_AGREEMENT_STATUS` 含 6（申请新协议）、`AUTH_LETTER_RESULT_STATUS` 不含 6，组件侧零改动。验证：ESLint 0 error（6 条存量 warning）、vue-tsc 本文件 0 条（全仓 110 条存量）、`git diff --check` 通过。暂存区含该文件两处改动：落地对齐 + 用户自改 `<StepBar v-if="steps.length > 1">`（单步不渲染步骤条），工作区~~无未暂存改动~~〔2026-11-16 晚更正：裁决落地轮新增 5 文件未暂存（A4 四文件文案统一 + A7 入口短路）〕，提交待用户指令。
**2026-11-16 二轮提交盘点（19fe1c2f7）**：本需求 9 文件已由用户提交并推送 `19fe1c2f7`（feat(authentication): REQ-195 电子签章改造 — 认证环节送审统一调 /auth-file & 模板 URL 接口下发 & 恢复即将到期入口 #RZMP-9021）。内容：① 认证环节送审统一 `/auth-file`（见下条）；② 授权委托书模板改接口下发 `GET /v1/ca-verification/auth_file_template`（无角色前缀、无入参、无需登录；成功 `model.url`；未配置 HTTP 200 + `code=11001` + `succeed=false` + `model=null`），取代前端静态资源（U-006 旧结论作废）；③ 恢复即将到期入口（文案「电子合同签章认证即将到期 / 需要重新认证 / 去认证」，U-016 偏离解除）；④ 按用户指令正向化清理，旧注释块物理删除（注释保留规则例外，git 历史可追溯）；⑤ `useElectronicSignStatus.ts` mock 块整块注释，恢复真实 `/status` 调用。本轮文档盘点同步 6 份：workflow-state、阶段3 v1.15、Apifox 契约 v1.1（新增第九节 auth_file_template，核身接口口径 14→15）、阶段0 v2.13、阶段2 v2.20、逐条验证 v1.11；《测试用例核对》为被取代历史文档、《对齐表》非开发依据，均不改。
**2026-11-16 认证环节送审统一**：按用户口径变更，认证环节（两端 certification）与合同签署/独立页完全同一套处理逻辑——经办人动态码通过后统一按 `nextAction=UPLOAD_AUTH_FILE` 分支调 `/auth-file` 送审，废弃 2026-11-11/11-13「认证环节只刷 status、Server 自动送审」口径（本文件下方旧条目为历史快照，保留备查）。`ElectronicSign.vue` 旧 `certificationFlow` 提前返回分支与 `confirmAutoSubmit` 送审确认轮询（含 `isAwaitingSubmitConfirm`、重试常量、generation 自增、`AUTH_POLLING_INTERVAL_MS` import）整块注释保留；认证容器 `persist-preuploaded-auth-letter=false` 保证收集步已落物料后 `/auth-file` 前不重复调 `ca-auth-letter`；两端容器与 `ProviderAuthLetterUpload.vue` 旧注释原文保留并追加新口径说明（逻辑零改动）。验证：ESLint 0 error（39 条存量 warning）、`git diff --check` 通过、废弃符号无活跃引用残留。**联调必验**：认证环节 `check-sms-code` 对经办人须返回 `nextAction=1`，返回 2 会撞「状态与流程不一致」报错。文档已同步：对齐表 v2.9、阶段3计划 v1.14、U-012。当前 5 文件未提交（api/electronicSign/index.ts、ElectronicSign.vue、ProviderAuthLetterUpload.vue、两端认证容器），提交时机待用户指令。〔2026-11-16 晚修正〕上述 5 文件已随 `19fe1c2f7` 提交推送（共 9 文件）；「整块注释保留」已按用户正向化清理指令物理删除（注释保留规则例外，git 历史可追溯），现行代码为正向实现。
**2026-11-12 测试用例核对**：已逐条登记 XMind 149 条用例至 `测试用例核对-REQ-195.md`，区分 PC 待实测、Server/联调、APP 范围外、口径冲突与暂缓项。修复非经办人重进认证成功态仍等待 5 秒的问题；经办人审核通过继续等待 5 秒。回归测试 2/2 通过，相关 ESLint 0 error（5 条存量 warning）；全量 `vue-tsc -b --noEmit` 仍有其他模块 110 条错误，未报本次组件。另发现协议 iframe 加载失败时验证码按钮可能仍可用，待确认加载失败信号和降级口径；即将到期固定入口继续注释，待产品确认。
**2026-11-12 CA 响应判定修正**：Apifox 允许 `code=200, succeed=false` 表示业务失败。已调整通用请求结果判定，以显式 `succeed` 为准，缺失时才按 `code` 兼容；覆盖静默的 `/status`、`check-sms-code` 和 `success-seen`，避免失败被误当成功。`src/service/index.ts` ESLint 0 error（1 条存量 warning）、diff 检查通过；全量 `vue-tsc -b --noEmit` 仍有其他模块的存量错误，联调结果待验证。〔2026-11-16 更正〕**本条记录超前于代码，实际未落地**：`git log b78b1e73d..HEAD -- src/service/index.ts` 为空（需求区间零提交），`api/electronicSign/index.ts` 亦无 CA 层绕行实现（仅 L70 注释提及 succeed）。`src/service/index.ts` 经用户明令禁改；`code=200 && succeed=false` 被误判为成功的风险仍在，处置方案（如 CA 层绕行）~~待用户拍板~~〔2026-11-16 用户裁决 A1〕不改，维持现状，风险登记为已知项。
**2026-11-12 错误提示收口**：协议、短信发送和委托书接口失败由请求层提示一次；`/status` 自动查询与 5 秒轮询始终静默，用户主动操作后的查询失败由当前页面提示；`check-sms-code` 失败只在验证码输入框下方提示；`success-seen` 失败静默。合同签署守卫由合同页提示状态查询失败。已清理本轮遗留的重复错误提示和注释掉的旧提示分支。
**2026-11-12 固定入口文案按设计稿收口**：Figma 组件集 `PC电子签入口`（node `173925:63471`，6 个变体）与 `STATUS_CONFIG` 逐态比对，4 态（去认证/继续认证/审核中/重新认证）本就一致，余下按用户“按设计稿完成”指令调整：① RE_UPLOAD 改「授权委托书 + 审核未通过 #db2414 / 请重新上传 / 按钮重新上传 / 光晕 #efb7ba」；② AUTHENTICATED 去掉「电子合同签章认证」前缀（设计稿该文字层隐藏），描述改设计稿原文；③ EXPIRING_SOON 无设计变体，经用户确认整块注释——注释后 `config` 为 null → `visible` 返回 false → **入口整体不渲染**（非“展示但无按钮”），与 R-006-2 偏离，已登记 U-016。隐藏层识别靠截图与坐标双校验（审核中/认证成功两变体的按钮层与成功态前缀层均为隐藏）。“其余问题”一并处理：`disabled` 字段在 7 个状态里已无 `true` 使用场景，入 interface 字段、模板 `:disabled`、`handleAction` 判断与 `&:disabled` 样式四处均注释下线（行为不变）；删除 `visible` 内调试残留 `// return true;`。L18 类型定义单行写法为用户手动调整，保留不动。ESLint 0 error、`git diff --check` 无空白错误；已同步阶段0 v2.11、阶段2 v2.18、阶段3 v1.12。未做：未跑 vue-tsc（用户已限定只验业务）、未做页面实机回归。
**2026-11-12 固定入口补平台实名认证前置门控**：按 R-006-1 「仅对已完成平台实名认证的用户展示」，在 `ElectronicSignEntry.vue` 内部新增 `platformAuthCompleted` 判定并在三处同时短路（`visible` 不渲染、`handleAction` 不emit、成功曝光 watch 不调 `success-seen`）。口径经用户拍板：雇主取 `employerInfo.authStatus===1`、服务商取 `providerInfo.authStatus===1`（均由组件按 `role` 自取）、供应商取 `onboarding.status===2` 由 `supplier/personalCenter/index.vue` 以新增可选 prop `authCompleted` 传入（未认证不渲染，非禁用）。背景：上一轮为收敛显隐决策权已删掉四个消费页的本地认证位 `v-if`，使 R-006-1 一度失去实现依托，本轮把门控收回组件内部后与「显隐单点决策」不再矛盾。ESLint 0 error（仅存量模板风格 warning）；已同步阶段0 v2.10、阶段2 v2.17、阶段3 v1.11。待确认：未认证用户仍会触发一次 `GET /status`（组件自带取数，未在本次范围内加停止条件）；签署守卫 `useElectronicSignGuard` 只读 CA 状态，未补平台实名认证前置（理论上未实名用户走不到合同页，待产品确认是否需兜底）。
**2026-11-11 合同页重复请求修正**：`/provider/contract` 与雇主合同页首屏由固定入口组件查询一次 `/status`；签署守卫关闭自动查询（包括主体切换时的自动查询），仅在点击“立即签署”时主动刷新。相关 composable ESLint 与 diff 检查通过，浏览器 Network 仍待实测。

**2026-11-11 阶段3出口检查**：`wds-web` 分支 `F-REQ-195-wxj` 当前有 12 个未提交文件（含已暂存和未暂存）。`quick-verify.sh --scope both --files ...` 实际检查这 12 个文件，exit=0：无新增 `console.log`、无大文件、diff 无空白错误，ESLint 0 error（99 条 warning）；差异指纹 `1ee0d31a3b7035685d23fc007bce86ace53fb753269e58a2034981ffa7e7bb81`。完整 `vue-tsc -b --noEmit` 仍有其他模块类型错误，未取得页面和接口联调证据；阶段3保持进行中，阶段4不标通过。Server 状态时序及 `isAuthFileNeeded` 缺省按用户确认不作为本轮前端阻塞项。

**2026-11-11 提测前复核**：统一 `/status.isAuthFileNeeded` 缺失时按非经办人处理，两端认证页不再因此阻断；`entryStatus=4` 重传按状态进入委托书步骤。验证码只校验非空，不限制长度；发送失败显示接口错误。授权委托书上传上限为 10MB。清理已不可达的重传变量、回调和调试注释。`ElectronicSign` 的 5 秒跳转在状态失效或状态刷新期间取消，并在刷新确认成功后重新计时。改动范围 ESLint 为 0 error；完整 `vue-tsc -b --noEmit` 仍有仓库其他模块的类型错误，REQ-195 关键模块未报错。接口时序与真实页面效果仍待联调。

阶段3 编码执行：接口封装、独立状态层、电子签章组件、两端认证页与合同签署守卫已接入；服务商恢复分支已区分 `authPhase=3/4`。本期五处固定入口（两端个人中心、两端合同列表、供应商个人中心）已接入，待接口联调。原始需求 V1.2 的 PC 规则已同步至阶段0；新增的「从未与平台签署爱签协议需重签」须核对 Server 状态语义。用户已取消协议内容滚动与获取验证码前等待 3 秒的交互门槛；验证码发送后的重发冷却仍按接口规则处理。供应商入口按特殊服务商复用 `providerId` 状态，从供应商路由进入认证组件，待联调核验。Server 认证模块方案另写 `user/info` 三字段透传，与本期前端独立状态接口方案存在差异，待 Server 复核；前端不新增 CA DTO/store。

本轮代码审查已修复状态请求卸载后续轮询、驳回态申请新流程失败后错误离开结果页、即将到期入口进入认证页却未加载协议，以及 `ElectronicSign.vue` 的泛型语法错误。驳回重传已按 2026-11-11 B 口径落地：回第一步重新收集，重走协议+动态码凭新 `caFlowId` 送审，不再依赖 `/status` 下发流程号（详见「Apifox 契约对照」节口径修订）。首次爱签协议重签与新经办人委托书收集仍待产品/Server 契约。依用户本轮指示跳过 `vue-tsc` 与 ESLint 后续处理。

独立电子签章页按 `GET /status.isAuthFileNeeded` 展示经办人双步或其他身份单步；服务商平台认证总步骤条保持“提交材料 → 完善信息 → 电子合同签章认证 → 签署协议 → 系统审核”，委托书上传是电子签章认证环节内页面，不额外增加总步骤（雇主端同样处理，收集步与签章认证同处一个步骤位）。经办人 UI 先上传 OSS 文件，再完成协议与短信。~~验证码通过且 `nextAction=1` 后才调用 `/auth-file` 送审。老用户/过期用户先调用 `ca-auth-letter` 落物料，新认证用户当前直接调用 `/auth-file`。~~〔2026-11-11 二轮口径后此句仅适用于独立页/合同场景；认证环节改为收集步 `ca-auth-letter` 收集即落库，动态码通过后 Server 自动送审，前端不调 `/auth-file`，详见「Apifox 契约对照」节二轮口径条目。〕送审成功不等于审核通过；~~平台认证页观察到审核中转认证成功且 `canSign=true` 后沿用 `next` 事件继续原协议，继续前重查 `canSign`，不增加成功态按钮。~~〔2026-11-11 二轮口径后改为：审核通过后静默等待 5 秒（常量 `CA_AUTH_PASS_ADVANCE_DELAY_MS`）再沿用 `next` 流转；独立页成功后自动回退的部分已由 2026-11-23“完成”按钮口径取代；非经办人验证码通过即放行。〕合同入口、固定入口、平台认证使用对应来源文案。Server T1 所述新用户材料落库、`isAuthFileNeeded` 实际响应层级和审核回调仍待联调，阶段3不标完成。

**2026-11-11 二轮编码落地**：`const.ts` 新增 5 秒常量；`ProviderAuthLetterUpload.vue` collectOnly+persistAuthLetter 组合实现收集即落库；`ElectronicSign.vue` 认证分支（非经办人放行/经办人刷状态）与审核通过 5 秒静默等待、独立页重进自动回退、卸载清理定时器；〔独立页自动回退于 2026-11-23 调整为手动点击“完成”返回。〕服务商认证页 `handleFaceNext`/`handleAuthLetterReUpload` 按方案 a 分流、收集步模板切换 collect-only+persist-auth-letter（旧 A 口径注释保留）；雇主认证页补齐 `authLetterUpload` 视图、两处入口 CA 分流、断点续走分流、`handleAuthLetterReUpload` 方案 a、模板收集步与 `preuploaded-auth-file` 防死锁接线。本轮 `vue-tsc --noEmit` exit=0、改动文件 ESLint 0 error（存量模板风格 warning 不动）。待联调点不变，另新增：`check-sms-code` 后 Server 自动送审时序、非经办人 `canSign` 同步返回、RE_UPLOAD 重走返回 `UPLOAD_AUTH_FILE`。

**2026-11-11 二轮验证与收尾**：全链路验证通过——ElectronicSign 5 秒定时（防重复/卸载清理/immediate 覆盖父子时序）、独立页 B 项重进回退链路（`currentView`→ELECTRONIC_SIGN→watch `previousStatus==null`→`handleSignCompleted`）、落物料语义双场景各自正确（独立页未传 `persist-preuploaded-auth-letter` 默认 true 走老用户 `ca-auth-letter`→`/auth-file`；认证页显式 false 防收集步重复落库）、vue-tsc exit=0 / ESLint 0 error。经用户确认处理三项：① 恢复独立页 L45 状态门控（`identityReady` 取消注释 + `content-area` 包回 `v-if`，联调验证期曾临时停用）；② 独立页收集步简化为显式 `collect-only`（旧 reuploading 三元与 `handleReUploadSubmitted` 注释保留）；③ provider 页 `reuploading`/`reuploadFlowId` 死变量拍板保持注释标注现状，待后续版本统一清理。后端联调点 4 项前端不动。

**2026-11-11 白屏缺陷修复（联调实证）**：服务商合同入口 `/provider/my/electronic-sign?returnUrl=/provider/contract` 页面为空。实测 `/status` 响应（entryStatus=2、canSign=false）**未下发 `isAuthFileNeeded`**，P-1 契约缺口实锤——恢复后的门控 `isAuthFileNeeded !== null` 恒 false 导致 `content-area` 不渲染。经用户确认采用**前端兼容降级**：门控改为 `status 已加载且无 error`（旧条件注释保留）；字段缺失时独立页按非经办人单步渲染（`isKnownOperator === true` 才双步），真经办人由 `check-sms-code` 返回 `UPLOAD_AUTH_FILE` 拉起内嵌上传兜底，流程不断；后端补齐字段后前端无需再改。`useElectronicSignStatus` 的 `isAuthFileNeeded` 注释防线同步更新（认证容器 null 时仍不分流收集步，仅独立页按单步渲染）。vue-tsc exit=0、ESLint 0 error。遗留小项：独立页 `/status` 加载失败且从未成功时门控下页面无重试入口（原门控即此行为，如需错误重试 UI 另立需求）。

**2026-11-11 三轮缺陷修复（外部静态 check 复核）**：复核另一模型对调整后流程的 6 条静态质疑，判定 2 条真实卡死缺陷并经用户拍板修复，其余 4 条处置如下。已修（均落 `ElectronicSign.vue`）：① **5 秒等待触发过窄**——原 watch 仅「审核中(3)→成功(7)」触发，验证码后首刷若直接 2→7 则卡死；放宽为「前值任何非成功态→成功均触发」（覆盖 3→7/2→7/4→7/null→7，immediate 首触兜底父子挂载时序；独立页重进成功态自动回退口径于 2026-11-23 被“完成”按钮取代；7→7 变化不重复排队）。② **送审时序差停住**——认证环节经办人验证码通过后 Server 自动送审存在时序差，首刷仍 entryStatus=2 时轮询（仅 REVIEWING 续排）不启动；新增 `confirmAutoSubmit` 送审确认循环（`AUTO_SUBMIT_CONFIRM_MAX_RETRIES=5`、间隔 `AUTH_POLLING_INTERVAL_MS`，generation 标记防重走协议/切换主体/卸载后旧循环污染；查到 REVIEWING 交还 refresh 自动续排轮询、直接成功交还状态 watch 排 5 秒等待、查询失败不重试交还既有链路）。登记联调点（不改代码）：非经办人 `check-sms-code` 返回 `canSign=true` 后父页面 `GET /status` 是否同事务同步返回。判定不成立：组件内上传页缺少文件时打开（系 P-1 兜底设计）；独立页 5s 回退未区分经办人/非经办人（B 项拍板口径统一回退，无需区分）；白屏与响应矛盾（现场在旧门控版本，已按兼容降级修复）。vue-tsc exit=0、ESLint 0 error。

**2026-11-10 交叉复核**：按原始需求、Server 方案和代码核对了服务商平台认证固定五步、独立认证页双步/单步、`check-sms-code → ca-auth-letter（老用户）→ auth-file` 的调用门禁、审核成功后的 `canSign` 复查，以及合同/固定入口文案。补齐异步请求在主体切换或组件卸载后的失效检查，避免旧流程继续用新主体参数送审。Vue 单文件组件编译检查和 `git diff --check` 通过；真实接口响应、新用户委托书物料落库（Server T1）与审核流转仍待联调。

**2026-11-07 开发进展**：`wds/wds-web` 已提交 `dcf298da5`，覆盖经办人独立页双步、授权书文件先收集后按本次 `caFlowId` 提交、状态源共享与签署守卫、状态结果 UI 及 REQ-195 注释校准；代码仓库当前无未提交改动。对本需求 24 个代码文件做了注释核对，注释整理未改动业务代码。阶段3仍待联调和验证，不因提交而标记完成。

**待修正差异**：~~阶段0 R-010-6 规定授权委托书单文件上限 20MB~~ 已于 2026-11-10 收口：产品确认统一按 10MB，代码无需改动，R-010-6 已反向修正为 10MB。Figma 已按节点拆分逐张核对，但首个节点 `173925:69921` 读取遇 429，尚无新的设计核对结论。

## 验证闭环记录
| 阶段 | 锚点 | 验证结果 | 偏差数 | 修正次数 | 证据 |
|---|---|---|---|---|---|
| 阶段0 需求分析 | 需求原文 + 补充设计图 | 已修正后通过 | 5 | 5 | 阶段0-需求文档-REQ-195.md v2.7（2026-11-05 Server 回填后）：R-001~R-014 完整，服务商个人现有链路已校准为“提交材料→完善信息→人脸认证→签署协议→系统审核”；新增 R-006-9/10，U-008/C-001 已关闭。 |
| 阶段1 代码分析 | 阶段0需求文档与认证精读 | 已修正后通过 | 4 | 4 | 阶段1-代码分析-REQ-195.md v1.4：确认服务商个人与个体/企业法人均先进入 moreInfo；`authPhase` 不可复用；本期签署入口收敛为两个核心合同页。 |
| 阶段2 技术方案 | 阶段0、阶段1、源码状态机与 11-05 Server 评审 | 已修正后通过 | 7 | 7 | 阶段2-技术方案-REQ-195.md：api 签名按 `caFlowId` 流程制落定，电子签章状态统一走独立接口，`authPhase=4` 恢复门禁保留；C-005 经办人标识与 T1 仍开放。 |
| 阶段3 编码执行 | 阶段2 技术方案 + 用户逐项裁决（A1–A8/C1/C3/D1）+ Apifox 契约 | 通过 | 0 | 0 | 2026-11-17 出口门禁：用户手动提交 `eac55dfa3`（13 文件与提案一致无漂移）；ESLint 13 文件 0 error（exit=0，112 存量 warning）；vue-tsc -p tsconfig.app.json 110 条存量持平零新增；R 类全部闭环（R-02 Server 确认）；quick-verify.sh 不适用已提交改动，按兜底口径手动 lint 留证。遗留：工作区 ElectronicSignEntry.vue 两行行尾空格清理待顺带提交；U-015/T1/P-1 与联调必验项转阶段5/6。 |
| 阶段3 bugfix（认证成功落地页） | 本轮已确认口径 + 独立认证页状态恢复逻辑 + 认证容器调用点 | 已修正后通过 | 1（代码） | 1 | 2026-11-23：独立页 `entryStatus=7` 对经办人/非经办人展示成功页并由“完成”按钮返回；自动流转限制在平台认证容器。quick-verify 2 文件通过（ESLint 0 error，25 条存量 warning），`vue-tsc --noEmit` exit=0，`git diff --check` 通过；页面实机回归待执行。 |
| 阶段3 bugfix（新用户 CA 缺材料回退） | 用户确认新用户认证不自动返回提交资料 + `missing-auth-file` 两端消费点 | 已修正后通过 | 1（代码） | 1 | 2026-11-23：雇主/服务商验证码后不再因缺 OSS code 自动切回 `submitMaterials`；认证前置缺材料分支同样不切页；独立签章页上传授权书的事件保留。待 Node 22 下 quick-verify 与 vue-tsc 验证，实机联调未执行。 |
| 阶段4 代码审查 | 阶段0 需求 + 阶段2 方案 + Apifox 契约 + 2026-11-16 送审口径 | 通过 | 1（文档） | 0 | 2026-11-17：29 文件逐文件审查（含完整 template）；无代码 P0；双弹 toast 实测请求层排除；回归测试 2/2；受检 diff SHA-256 4ada5a175baa8ba724ce6b89f3969eb8c31c93e0c5f7558eca3590b974a1c9d9。偏差：R4-01 旧送审口径文档待校准（阶段5 前）；R4-04~R4-11 P2 待用户裁决，零代码改动。见阶段4-审查报告 v1.1。 |
| 阶段3 bugfix（entryStatus=3/4 分流） | 用户报障截图 + 恢复路径既有排除条件 | 已修正后通过 | 1（代码） | 1 | 2026-11-17 晚：4 处前进 handler 补结果态排除（共享集合 CA_AUTH_LETTER_REVIEW_STATUS + includes，旧三元注释保留）；全状态矩阵核验仅 3/4 变化；ESLint 0 error、回归 2/2、vue-tsc 修复文件零报错；SHA 更新 c21a72ceb67ef28320bd16e6153a9d0db54f08b5fc1c3aa0705c2abdb1837195。待用户 mock 复验。 |

## 已处理文件（阶段3用）
- 阶段3-编码执行计划-REQ-195.md：完成执行步骤、目标、涉及文件与验收效果拆分；服务商实际链路已纳入步骤4与验收约束。
- `wds/wds-web` REQ-195 分支：两端认证与合同页已接电子签章状态和守卫；`ElectronicSignEntry.vue` 已在个人中心及合同列表共五处消费独立状态。`entryStatus=2` 按 Server 方案重新调用 `/agreement` 获取新 `caFlowId`，旧未完成流程按服务端规则作废。代码已提交至 `dcf298da5`；依用户指示本轮跳过 `vue-tsc` 与 ESLint，仍待接口联调和阶段出口验证，阶段3不标完成。

## 本需求文件树（2026-11-07 核对）

代码口径：`wds/wds-web` 的 `F-REQ-195-wxj` 分支，以 `b78b1e73d` 为开发起点，统计至当前 HEAD `dcf298da5`；共 24 个文件（A 新增 11、M 修改 13），代码工作区无未提交改动。功能说明表示文件当前承担的职责，不代表接口联调或验收通过。

〔2026-11-12 修正〕上段 HEAD 锚点与未提交状态已过期：REQ-195 代码已陆续提交至 `e952ae4e7`（接口竞态），上方 24 文件清单与 A/M 标注仍以 2026-11-07 核对为准，未随后续提交重算。当前工作区未提交 2 个文件（均为本轮固定入口门控改动）：`views/authentication/components/ElectronicSignEntry.vue`、`views/supplier/personalCenter/index.vue`。

〔2026-11-16 修正〕HEAD 锚点再次更新：REQ-195 代码已提交推送至 `19fe1c2f7`（9 文件：认证环节送审统一 /auth-file、模板 URL 接口下发、恢复即将到期入口、正向化清理、mock 回退）。当前工作区仅 `views/authentication/electronicSign/index.vue` 一个文件有已暂存改动（落地对齐移出 EXPIRING_SOON + 用户自改 StepBar `v-if="steps.length > 1"`），无未暂存改动。上方 24 文件清单与 A/M 标注仍以 2026-11-07 核对为准，未重算。

```text
wds/wds-web/src/
├── api/electronicSign/
│   ├── [A] index.ts — CA 状态、协议、短信、授权书、成功曝光接口封装
│   └── [A] types.ts — 角色、入口状态、后续动作与响应类型
├── assets/icons/authentication/
│   └── [A] icon-electronic-sign.svg — 电子签章入口图标
├── composables/electronicSign/
│   ├── [A] useElectronicSignGuard.ts — 签署前实时状态守卫与认证页跳转
│   └── [A] useElectronicSignStatus.ts — 独立状态查询、主体切换、审核轮询与成功曝光
├── router/routes/
│   ├── employer/[M] my.ts — 雇主独立认证页路由
│   ├── provider/[M] index.ts — 服务商独立认证页路由
│   └── supplier/[M] index.ts — 供应商路由复用认证页
├── utils/
│   └── [M] downloadUrlAsFile.ts — 共用授权委托书模板下载
└── views/
    ├── authentication/
    │   ├── components/
    │   │   ├── [A] AuthLetterStatus.vue — 委托书审核中、待上传与认证成功状态
    │   │   ├── [A] AuthLetterUpload.vue — 复用的委托书 OSS 文件上传
    │   │   ├── [M] CertEnterpriseSupplementSection.vue — 原企业补充材料区复用上传组件
    │   │   ├── [A] ElectronicSign.vue — 协议展示、短信核身与授权书后续流程
    │   │   ├── [A] ElectronicSignEntry.vue — 按主体状态展示固定入口
    │   │   └── [A] ProviderAuthLetterUpload.vue — 经办人委托书收集及提交
    │   ├── electronicSign/[A] index.vue — 合同入口的单步/经办人双步认证页
    │   └── personalCenter/[M] index.vue — 雇主、服务商个人中心固定入口
    ├── employer/
    │   ├── certification/
    │   │   ├── components/[M] EmployerBusinessSubmitMaterials.vue — 共用模板下载
    │   │   └── [M] index.vue — 认证状态机插入电子签章步骤及断点恢复
    │   └── contract/[M] index.vue — 合同签署守卫与列表固定入口
    ├── provider/
    │   ├── certification/
    │   │   ├── components/[M] ProviderBusinessSubmitMaterials.vue — 共用模板下载
    │   │   └── [M] index.vue — 认证状态机插入步骤，区分系统审核与 CA 恢复
    │   └── contract/[M] index.vue — 合同签署守卫与列表固定入口
    └── supplier/personalCenter/[M] index.vue — 供应商个人中心固定入口
```

需求工作区下列 10 份文档为本需求的历史修改范围；`[M]` 表示相对需求初始版本有过修改，`[A]` 表示本需求新增文件，均不代表当前 Git 未提交。原始需求图片作为输入资料收录，Server 技术方案不计入前端改动：

```text
.md/需求/进行中/REQ-195/
├── 原始需求/[M] REQ-195 电子签章改造（双端）.md — 需求基线及补充规则
├── [M] 阶段0-需求文档-REQ-195.md — PC 范围与业务规则
├── [M] 阶段1-代码分析-REQ-195.md — 既有认证链路与代码影响
├── [M] 阶段2-技术方案-REQ-195.md — 前端状态、接口与页面方案
├── [M] 阶段3-编码执行计划-REQ-195.md — 开发步骤和验收条件
├── [M] 后端接口契约对齐表-REQ-195.md — 预估与服务端方案比对基线（2026-11-10 起不再作为开发依据，保留追溯 C-*/U-* 与认证域接口）
├── [A] 电子签章接口契约-Apifox-REQ-195.md — Apifox 实测契约，当前接口开发依据
├── [A] CA签署拦截覆盖盘点-REQ-195.md — 签署出口守卫覆盖盘点与遗漏场景待确认清单（2026-11-20，供产品/后端确认）
├── [A] RZMP-11727-缺陷分析-REQ-195.md — 审核失败跳转缺陷只读分析与新用户重传口径确认（2026-11-20，供 QA/Server/APP 核对）
└── [M] workflow-state.md — 阶段进度、文件树与待确认项
```

## 阶段 3 允许改动文件
- 编码前置：C-001、C-005、C-006、C-007 按步骤1确认；U-009 已按供应商为特殊服务商收口。
- 允许文件范围以 `阶段3-编码执行计划-REQ-195.md` 步骤2至步骤7列出的文件为准；供应商入口位置已确认，复用同一服务商主体 `providerId` 的 CA 状态。

## 阶段 4 审查差异
- SHA-256：`74a0be18abf2ee53c36c8d6355f4451cb114e8461df369b1cd04c848363e8a3f`（`git diff b78b1e73d -- <33文件>`，含工作区改动：entryStatus bugfix 3 文件 + 协议文案统一与 RZMP-11265 按钮文案 ElectronicSign.vue + 独立页 standalone-page 传参 + 用户手改 mock + RZMP-11254 两端订单页守卫 4 文件；清单 /tmp/req195-files-v4.txt）〔2026-11-17 晚 RZMP-11265 口径二次修正（standalonePage）后重算〕
- ~~SHA-256：`6813eb3c757909203c676c29941bd59b60047777104902995b687132fc1f5c83`（`git diff b78b1e73d -- <33文件>`）~~〔2026-11-17 晚失效：RZMP-11265 口径二次修正（contractFlow→standalonePage，独立页新增传参）改变业务 diff，保留作首轮 contractFlow 口径快照〕
- ~~SHA-256：`a4d2280305c1b57123d36bfcd78674b17feb0965249484d987a31148e8850865`（`git diff b78b1e73d -- <33文件>`）~~〔2026-11-17 晚失效：RZMP-11265 按钮文案条件化改变 ElectronicSign.vue 业务 diff，保留作雇主订单页补齐轮快照〕
- ~~SHA-256：`43fdb2a9ac72e9ace472045f68734f47cd755063a2ec4ef552cb29d91c3bad91`（`git diff b78b1e73d -- <31文件>`）~~〔2026-11-17 晚失效：雇主订单页守卫补齐改变业务 diff 且受检清单扩至 33 文件，保留作服务商订单页轮快照〕
- ~~SHA-256：`d2671832671ce8c93de05e3ca80a16df9d5fea1a2543f7537cf1a7e9f5d4abeb`（`git diff b78b1e73d -- <29文件>`）~~〔2026-11-17 晚失效：RZMP-11254 订单页守卫补齐改变业务 diff 且受检清单扩至 31 文件，保留作文案统一轮快照〕
- ~~SHA-256：`c21a72ceb67ef28320bd16e6153a9d0db54f08b5fc1c3aa0705c2abdb1837195`~~〔2026-11-17 晚失效：协议详情描述文案统一改变业务 diff，保留作 bugfix 轮快照〕
- ~~SHA-256：`4ada5a175baa8ba724ce6b89f3969eb8c31c93e0c5f7558eca3590b974a1c9d9`（`git diff b78b1e73d HEAD -- <29文件>`，HEAD=eac55dfa3）~~〔2026-11-17 晚失效：entryStatus=3/4 分流 bugfix 改变业务 diff，保留作首轮审查快照〕
- 受检文件：REQ-195 19 笔提交并集 29 文件（api/electronicSign 2 + constants 1 + composables 2 + router 3 + utils 1 + authentication 组件/页面 8 + employer 4 + provider 4 + supplier 1 + assets 1 + tests 1 + const.ts 1）+ RZMP-11254 新增 provider/order/list.vue、detail.vue 与 employer/order/list.vue、detail.vue 共 **33 文件**；工作区 ElectronicSignEntry.vue 两行行尾空格未纳入
- 审查时间：2026-11-17（首轮）；2026-11-17 晚 bugfix 增量复审（4 处分流条件 + 共享集合，全状态矩阵核验）；2026-11-17 晚 RZMP-11254 增量复审（服务商订单页 2 处 + 雇主订单页 2 处守卫插入，镜像各自合同页模式）；2026-11-17 晚 RZMP-11265 增量复审（ElectronicSign.vue 按钮文案按 contractFlow 条件化，三消费点传参核验；同晚口径二次修正为 standalonePage 承载页面判定，独立页新增传参）
- 复审失效原因：首轮 SHA 因 bugfix 失效已重算；文案统一轮 SHA 因 RZMP-11254 服务商轮失效已重算；服务商轮 SHA 因雇主订单页补齐失效已重算；雇主轮 SHA 因 RZMP-11265 按钮文案失效已重算；RZMP-11265 首轮 SHA 因口径二次修正失效已重算；新 SHA 含用户手改 mock 块（开发阶段保留口径，收口时随 mock 清理再变）

## 不确定项追踪
| # | 问题 | 状态 | 确认人 | 影响阶段 |
|---|------|------|--------|---------|
| U-005 | 消息通知跳转的具体 path 值 | 待确认（不阻塞阶段2） | 后端 | 阶段2 |
| U-006 | 新版授权委托书模板下载来源（旧版已确认为前端静态资源） | ~~✅已确认（复用现有静态资源）~~〔2026-11-16 作废〕改为接口下发：`GET /v1/ca-verification/auth_file_template` 返回 `model.url`（后端配置 `ca_verification.auth_file_template_url`），`downloadAuthLetterTemplate()` 已 async 化消费，a 标签下载逻辑与文件名不变；未配置时 `code=11001` 由请求层提示「授权委托书模板暂未配置」。契约见 Apifox 契约文档第九节 | 后端/产品 | 阶段2 |
| U-007 | 电子签名认证协议内容获取方式（URL 外链 vs 富文本内嵌） | ✅已确认（URL 外链） | 后端 | 阶段2 |
| U-008 | 电子合同签章认证状态查询接口的字段名、类型、嵌套层级及条件性省略规则 | ✅字段名/类型/层级已收口（2026-11-10，依 Apifox 实测契约）：全部挂在 `model` 下——`entryStatus`(int 1–7)、`canSign`(bool)、`showSuccessEntry`(bool)、`maskedPhone`(string)、`authStatus`(int 0–3)、`authPhase`(int 0–4)、`isAuthFileNeeded`(bool)；`isAuthFileNeeded` 是 `StatusModel` 唯一 required。~~响应层级待联调~~ 遗留：契约自己的示例未返回 `isAuthFileNeeded`/`authStatus`/`authPhase`（见契约文档 P-1），是否恒定下发仍需联调 | 后端 | 阶段2、阶段3 |
| C-001 | 电子签章认证状态数据归属 | ✅已确认：本期前端 Profile、固定入口、认证恢复和签署守卫统一读取独立 `GET /status`；Server 认证模块方案另写 `user/info` 三字段透传，是否继续实施待 Server 复核，不作为前端开发前置。 | 后端 | 阶段2 |
| C-005 | 电子签章认证状态字段结构（字段名、类型、嵌套层级、条件性省略） | ✅分流字段已收口（2026-11-10，依 Apifox 实测契约）：`model.isAuthFileNeeded`（bool）为经办人事前分流依据；`model.authStatus`、`model.authPhase` 已确认存在，来源分别为雇主 `employerInfo`/`auditInfo`、服务商 `providerInfo`/`auditInfo`，`authPhase=4` 即 CA 完成。~~实际响应层级待确认~~ 遗留：字段缺省规则（同 P-1）；新认证经办人「完善信息」阶段收集委托书的页面/接口（Server T1）仍待确认 | 后端 | 阶段2、阶段3 |
| C-006 | 电子签章独立恢复状态（字段/枚举及状态语义） | ⚠️代码已区分服务商 `phase===3` 系统审核与 `phase===4` CA 完成检查点，继续以独立状态接口判断可签署；需联调验证组合状态后关闭 | 后端 | 阶段2、阶段3 |
| C-007 | 操作能力接入契约（复用/扩展/新增接口映射） | ✅核身 14 接口映射与倒计时字段已收口（2026-11-10，依 Apifox 实测契约，详见 `电子签章接口契约-Apifox-REQ-195.md`）：每角色 7 个 `/v1/{role}/ca-verification/*`；倒计时 = `AgreementModel.countdown`，**仅 `POST /agreement` 返回**，60s 内为正整数、0 或无值视为可点击；`/send-sms-code`、`/check-sms-code`、`/resend-sms-code` 只传 `caFlowId`（不传主体 ID）；`/auth-file` 传 `caFlowId` + `ossCode`（不收 `fileName`/`fileUrl`）；`/success-seen` 无请求体。~~验证码倒计时字段~~ 〔2026-11-16 补〕新增共用无角色前缀接口 `GET /v1/ca-verification/auth_file_template`（模板 URL 下发，无需登录），核身接口口径 14→15，见契约文档第九节。遗留：短信发送频控规则；`ca-auth-letter` 是否计入“14 个对称接口”口径；新认证经办人 T1 链路 | 后端 | 阶段2、阶段3 |
| 协议阅读判定 | 前端滚动与 3 秒门槛已取消；Server 发短信接口仍可能因“尚未阅读协议”返回失败 | 待联调确认 Server 如何判定阅读，不补回前端交互门槛 | 后端 | 阶段3 |
| U-009 | 供应商个人中心入口与状态来源 | ✅入口已接入 PC，位置为主体资料卡下方、保证金提示上方；供应商是特殊服务商，复用 `providerId` 状态与曝光标记，从供应商路由进入认证组件，待联调核验 | 产品/后端 | 阶段2、阶段3 |
| 新增遗留 | ~~验证码 60s 倒计时字段~~ 已于 2026-11-10 收口（= `AgreementModel.countdown`，见 C-007）；仍待确认：短信发送频控规则（纪要待办 @盛瑞泽）；供应商独立入参属于后续扩展；中台 `userId` 必填冲突与 `fileType=20` 来源；CA 委托书 `material_type=10` 占用核对 | 部分确认 | 后端/产品 | 阶段3 |
| U-010 | 审核结果态展示位置：容器页新 ViewType vs ElectronicSign.vue 内部切换 | ✅已确认：ElectronicSign.vue 内部根据 entryStatus 切换，不新增容器页 ViewType | 产品/开发 | 阶段3 |
| U-011 | 审核中状态轮询频率和终止条件 | ✅已确认（2026-11-10 产品最终口径）：与既有认证统一 5 秒轮询，复用 `AUTH_POLLING_INTERVAL_MS`，直到查到结果（审核通过或拒绝）后停止 | 产品+后端 | 阶段3 |
| U-012 | 审核未通过后的「重新上传」入口 | ✅已确认（2026-11-11 修订为 B 口径，推翻 11-06「原地替换」记录；同日二轮拍板方案 a）：**重进先见驳回态**，点重新上传后认证场景调 `user/info`、合同场景调 `/status` 刷状态，仍处 RE_UPLOAD 则回委托书收集步（非材料首步）重新收集后**重走协议+动态码**；~~认证环节收集即落库由 Server 自动送审（不调 `/auth-file`），签署场景凭本轮新 `caFlowId` 调 `/auth-file`~~〔2026-11-16 送审统一后：认证环节与签署场景均凭本轮新 `caFlowId` 调 `/auth-file`，认证环节收集步已 `ca-auth-letter` 落物料，`persist=false` 防重复调用〕，`caFlowId` 来源问题随之关闭。联调点：RE_UPLOAD 重走 `check-sms-code` 须返回 `nextAction=UPLOAD_AUTH_FILE` | 产品 / Server | 阶段3 |
| U-013 | 审核未通过是否展示驳回原因 | ✅已确认（2026-11-10 产品）：UI 不展示具体驳回原因，维持 RE_UPLOAD 中性文案；无需接口下发意见字段 | 产品+后端 | 阶段3 |
| U-014 | 合同签署场景跳转后认证页展示逻辑 | ✅已确认：认证页根据 entryStatus 直接展示对应状态 | 产品 | 阶段3 |
| U-015 | V1.1 首次爱签协议重签条件与 `canSign`、`/protocol` 的关系 | 待产品与 Server 确认协议范围及判定字段；前端不以本地记录推断 | 产品/后端 | 阶段2、阶段3 |
| U-016 | 即将到期（`entryStatus=6`）在 Figma 组件集 `PC电子签入口` 中无对应变体 | ~~待设计补图。当前前端已将 `EXPIRING_SOON` 整块注释，该状态下入口不渲染，与 R-006-2 偏离~~〔2026-11-16 解除〕入口已恢复放开（`19fe1c2f7`，文案「电子合同签章认证即将到期 / 需要重新认证 / 去认证」），与 R-006-2 偏离消除；独立页落地已对齐已过期：经办人先收集委托书再进完整认证环节。~~设计变体是否补图仍开口（当前入口文案非设计稿产出）~~〔2026-11-16 关闭〕用户确认入口为按设计图手动还原，无需设计补图 | 设计/产品 | 阶段3 |
| U-017 | `entryStatus=4` 一个枚举同时承载「审核未通过」与「核身有效但从未上传」 | 文案已按设计稿统一为「审核未通过」，未细分前从未上传的用户也会看到驳回语义。待确认：Server 是否拆分枚举，或产品接受该口径 | 后端/产品 | 阶段3 |
| U-018 | 认证成功态描述文案「状态仅曝光一次，刷新或再次进入后入口消失」读起来更像设计稿规则注释而非上屏文案 | ~~按用户“按设计稿完成”指令已采用原文；产品确认后再调整~~〔2026-11-16 关闭〕用户确认「成功描述没问题」，文案维持设计稿原文 | 产品 | 阶段3 |
| U-019 | `/status` 失败提示时机 | 当前实现：接口始终静默；自动查询和轮询不弹，用户主动操作后的失败由当前页面提示一次。页面初始化失败是否需要额外提示待产品确认。 | 产品 | 阶段3 |
| U-020 | 「认证成功」一次性曝光的**消耗口径**是全局还是仅个人中心 | ✅已确认（2026-11-12 用户拍板）：**全局一次性曝光**——任一入口展示成功卡片并调 `/success-seen` 即消耗，消耗后所有入口（含合同列表）不再展示。代码已调整：`ElectronicSignEntry.vue` 的 visible 与 seen watch 移除 `context==='profile'` 限制；`context` prop 因零消费点彻底删除（2026-11-12 review 处置，连同 supplier/provider/employer 三处调用方传参一并清理，雇主/服务商个人中心本就未传）。已知边界：`/success-seen` 在途时用户秒级切换页面/多开 tab，新实例拉到的 `showSuccessEntry` 可能仍为 true，存在秒级双曝光窗口，依赖服务端 seen 落地的时序（seen 接口应幂等），前端无法根除。阶段0 L43/L67/L231「合同入口成功态不展示」表述待按新口径修订 | 产品（用户拍板） | 阶段3 |
| CA 流程恢复 | `entryStatus=2` 继续认证与驳回后重传的流程号 | `2` 已按 Server 方案重新申请协议和新 `caFlowId`，不再作为缺失契约；`4` 驳回重传按 2026-11-11 B 口径执行：回第一步重新收集后重走协议+动态码，凭新 `caFlowId` 送审，不再要求 `/status` 下发流程号。联调点：RE_UPLOAD 重走 `check-sms-code` 须返回 `nextAction=UPLOAD_AUTH_FILE` | 后端 | 阶段3 |

## 需求变更日志
| 版本 | 变更时间 | 变更内容 | 影响的需求 | 回退阶段 | 处理结果 |
|---|---|---|---|---|---|
| R1 | 2026-11-23 | 老用户独立认证成功不再自动返回；经办人和非经办人重进 `entryStatus=7` 均显示认证完成落地页，点击“完成”才返回来源页。自动流转只保留在认证容器，避免影响新用户流程。 | `AuthLetterStatus.vue`、`ElectronicSign.vue`、阶段2/3 | 阶段3 | 已实现并完成静态验证；页面实机回归待执行。 |
| R1 | 2026-11-23 | 修正新用户认证缺少授权书时的错误回退：雇主、服务商认证容器均不再因 `UPLOAD_AUTH_FILE` 缺少 OSS code 自动切回 `submitMaterials`；前置缺材料检查也仅提示并停留当前视图。独立签章页的授权书上传分支保留。 | `ElectronicSign.vue`、两端 certification/index.vue、workflow-state | 阶段3 | 代码已改；quick-verify、vue-tsc 与页面联调待验证。 |
| R1 | 2026-11-20 | RZMP-11727 只读分析 + 新用户重传口径落档：用户确认 CA 审核失败重传走单独 authLetterUpload 上传页、不回退提交材料、StepBar 不动；代码核对（F-REQ-195-wxj HEAD 38fa12ece）与口径逐条一致，web 属设计内；APP 跳成功页为独立问题待 APP/Server。新建缺陷分析文档 v1.0（3 个待确认问题 + 实名终审无驳回态风险观察）；补充方案旧「驳回重传回提交材料」口径文末注记取代（历史快照正文不改写）；本文件置顶条目 + 11-17 旧口径注记 + 备注更正。 | RZMP-11727-缺陷分析（新建）、阶段0 v2.15、阶段2-补充方案（文末注记）、workflow-state | -（零代码改动，不回退） | 分析基线为开发分支（工作区检出已切 master 1b940e422 不含 REQ-195 全量改动，git grep 复核）；云效未回写；待确认：截图帧（QA 余星兰）、哪个审核（QA/产品）、APP 归属（盛瑞泽）、实名终审驳回口径（Server）。 |
| R1 | 2026-11-17 | RZMP-11265 口径二次修正（用户纠正「需求理解错了」）：判定维度改为承载页面——所有 /electronic-sign 独立页入口（合同签署+固定入口）「提交」，所有 /certification 认证容器「下一步」；contractFlow 口径作废，新增 standalonePage prop（旧 computed 注释保留），独立页传 standalone-page，两端容器零改动；原遗留「固定入口文案待裁决」关闭。 | ElectronicSign.vue、electronicSign/index.vue、审查报告 v1.6（R4-15 更正）、workflow-state | 阶段3 | ESLint 0 error、vue-tsc 110 存量持平零新增；受检 33 文件不变，SHA 二次更新 74a0be18…3e8a3f；云效未回写待授权。 |
| R1 | 2026-11-17 | RZMP-11265 修复（云效缺陷，用户明确口径）：电子签章页主按钮文案按入口场景区分——合同签署（contractFlow=true）「提交」，认证「下一步」；ElectronicSign.vue 新增 verifyButtonText computed，旧硬编码文案 HTML 注释保留；判定复用既有 contractFlow prop，独立页/两端认证容器三消费点零改动。 | ElectronicSign.vue、审查报告 v1.5（R4-15）、workflow-state | 阶段3 | ESLint 0 error、vue-tsc 110 存量持平零新增；受检 33 文件不变，SHA 更新 6813eb3c…1f5c83；云效未回写待授权。 |
| R1 | 2026-11-17 | RZMP-11254 雇主端补齐（用户追问后范围裁决）：更正上轮「雇主端无直调链路」错误结论；实测雇主订单/common/confirm/总分包 5 页签署出口均无守卫，用户裁决仅补雇主订单 list/detail 2 页入口守卫（employer 角色，沿用雇主合同页无参跳转写法），common/confirm 旁路与总分包范围另议。 | employer/order/list.vue、detail.vue、审查报告 v1.4（R4-13 更正+R4-14）、workflow-state | 阶段3 | ESLint 0 error、vue-tsc 110 存量持平零新增、回归 2/2；受检 31→33 文件，SHA 更新 a4d22803…850865；云效未回写待授权。 |
| R1 | 2026-11-17 | RZMP-11254 修复（云效缺陷，回退阶段3）：服务商订单列表/详情「签署合同」直调签署接口未接守卫，未认证不弹去认证弹窗。两处 handler 插入 guardBeforeSign + confirmAndGoElectronicSign（镜像合同页模式，原链路零删改）；第三消费点 ProviderOrderDetailBasicInfoCard.vue 确认为孤儿组件不动。 | provider/order/list.vue、detail.vue、审查报告、workflow-state | 阶段3 | ESLint 0 error、vue-tsc 110 存量持平、回归 2/2；受检 29→31 文件，SHA 更新 43fdb2a9…c3bad91；云效状态未回写待授权；mock 下守卫必拦截，真实放行待联调。 |
| R1 | 2026-11-17 | 协议详情描述文案统一（用户指令不区分业务）：ElectronicSign.vue 旧 contractFlow 三元改固定文案「请滑动阅读下方全部协议，确认同意后，获取验证码完成电子认证，方可签署合同。」，旧三元 HTML 注释保留；守卫弹窗同文案一处非点名范围未动待确认。 | ElectronicSign.vue、workflow-state | 阶段3 | ESLint 0 error；阶段4 SHA 更新 d2671832…d4abeb；随 bugfix 一并待提交。 |
| R1 | 2026-11-17 | entryStatus=3/4 分流 bug 修复（用户报障，回退阶段3）：两端容器 4 处前进 handler 只看 isAuthFileNeeded 未排除审核中/驳回结果态，致 3 态误入收集步、上传后协议页误显加载失败并覆盖审核中物料。types.ts 新增 CA_AUTH_LETTER_REVIEW_STATUS 共享集合，4 处补 includes 排除（用户指令避免双 !== 链），旧三元注释保留。 | api/electronicSign/types.ts、两端 certification/index.vue、审查报告、workflow-state | 阶段3 | ESLint 0 error、回归 2/2、vue-tsc 修复文件零报错；阶段4 SHA 更新 c21a72ce…1837195；待用户 mock 复验后提交。 |
| R1 | 2026-11-17 | 阶段4 审查通过：29 文件逐文件审查无代码 P0；双弹 toast 实测请求层排除；回归测试 2/2；P1 仅 R4-01 文档口径校准，P2 八项（R4-04~R4-11）待用户裁决零代码改动；受检 diff SHA-256 4ada5a17…a1c9d9 写入状态文件。 | 阶段4-审查报告 v1.1、workflow-state | 阶段5 | 阶段4 标完成；R4-01 阶段5 前校准；P2 逐项待裁决；联调必验项转阶段5/6。 |
| R1 | 2026-11-17 | 阶段3 收尾：用户手动提交推送 eac55dfa3（13 文件），出口门禁 ESLint 0 error + vue-tsc 110 存量持平，无范围漂移，R 类全部闭环；阶段3 标完成，阶段4 启动，审查范围限定 REQ-195 自身 19 笔提交 29 文件（排除 master 合并带入的他人改动）。 | workflow-state、阶段4 审查输入 | 阶段4 | U-015/T1/P-1 与联调必验项转阶段5/6；工作区仅剩两行行尾空格清理待顺带提交。 |
| R1 | 2026-11-17 | R-02 关闭依据升级：用户转达 Server 结论「send-sms-code / resend-sms-code 现行实现没问题」，保持 codeSent=false + 按 countdown 冷却 + 据 codeSent 选 send/resend 现状；R 类全部闭环，无待处理代码项。 | 逐条验证 v1.15、阶段3 v1.18、workflow-state | 阶段3 | 代码零改动；剩余开口仅 U-015/T1/P-1 等外部契约与联调必验项；commit 仍待确认（12 改 + 1 新增）。 |
| R1 | 2026-11-17 | 文案常量化已实施：用户裁决直接替换不注释保留；新建零依赖 src/constants/electronicSign.ts 导出 CA_CERT_NAME，复测活跃字面量 19 行/12 文件全部替换（守卫弹窗、两端合同 toast、两端认证步骤、独立页步骤+标题、入口 4 处、委托书上传/结果态、三端路由 meta.title），注释/JSDoc 7 处不动。 | constants/electronicSign.ts + 12 消费文件、workflow-state | 阶段3 | ESLint 0 error、vue-tsc 110 存量持平零新增、回搜活跃字面量零残留；commit 提案更新待确认（12 改 + 1 新增）。 |
| R1 | 2026-11-17 | R-06 关闭：用户确认「不处理」，需求原文未提及未上传提示文案（期望来自 xmind:2377），维持置灰现状，代码零改动；R 类仅剩 R-02（待 Server）。另用户指令「电子合同签章认证」文本提常量：实测活跃 14 处/10 文件，方案新建零依赖 src/constants/electronicSign.ts 导出 CA_CERT_NAME，待确认后实施。 | 逐条验证 v1.14、workflow-state；常量化待实施 | 阶段3 | R-06 代码零改动；常量化方案待确认；commit 仍待确认。 |
| R1 | 2026-11-17 | G-13 整条关闭：用户裁决主体信息展示「需求文档没提，不处理」，经核实需求原文确无该要求（用例 5.11 标题来自 XMind），埋点+主体信息均不处理；R-06 核实注记：需求原文未提及未上传提示文案（期望来自 xmind:2377），用例 5.4 核心预期已由置灰+点击拦截满足，建议不处理待用户确认。 | 逐条验证 v1.13、阶段3 v1.17、workflow-state | 阶段3 | 代码零改动；剩余开口 R-02（今日找 Server）/R-06（待确认关闭）；commit 仍待确认。 |
| R1 | 2026-11-16 | 用户逐项裁决落地：A4 文案统一 4 文件 5 处（旧文案注释保留）；A7 入口未实名短路 GET /status（autoRefresh:false + 门控 watch，共享 composable 零改动）；A1 succeed 不改（风险登记）、A2/R-02 待定（11-17 找 Server）、A3/R-03 判伪关闭（success-seen body {} 符合契约）、A5 到期 UI 同首次+埋点全不处理、A6 状态失败不处理+入口按现有实现、A8 文档按现状更新（即将到期与已过期落地页完全相同、StepBar 单步隐藏）、C1/C3 关闭 U-016/U-018、D1 授权阶段0 三处残留校准。 | ProviderAuthLetterUpload.vue、AuthLetterStatus.vue、两端合同页、ElectronicSignEntry.vue、逐条验证 v1.12、阶段0 v2.14、阶段3 v1.16、阶段2 v2.21 | 阶段3 | ESLint 0 error、vue-tsc 零新增（110 存量持平）；本轮 5 文件未暂存 + 暂存区 1 文件，提交待确认；遗留 R-06 / G-13 主体信息两问待确认。 |
| R1 | 2026-11-16 | 落地对齐：即将到期入口放开后，独立页落地逻辑与已过期（RE_AUTHENTICATE）一致——`IS_IN_SIGN_STATUS` 移出 `EXPIRING_SOON`，经办人先落委托书收集步再进协议+短信认证；跳转链路与 returnUrl 消费不变，组件侧零改动。同轮整体盘点同步 6 份文档（阶段3 v1.15、Apifox 契约 v1.1、阶段0 v2.13、阶段2 v2.20、逐条验证 v1.11、workflow-state）。 | electronicSign/index.vue、6 份文档 | 阶段3 | ESLint 0 error、vue-tsc 本文件 0 条、diff --check 通过；已暂存（含用户自改 StepBar v-if）待提交指令。 |
| R1 | 2026-11-16 | 二轮提交盘点：9 文件已随 `19fe1c2f7` 提交推送——认证环节送审统一 /auth-file、模板 URL 接口下发（auth_file_template，U-006 旧结论作废、核身接口 14→15）、恢复即将到期入口（U-016 偏离解除）、正向化清理按用户指令物理删除旧注释、mock 整块注释恢复真实 /status。更正 workflow-state 11-12 succeed 修正记录（超前于代码未落地，service/index.ts 禁改，风险待拍板）。 | api/electronicSign 两文件、downloadUrlAsFile.ts、useElectronicSignStatus.ts、ElectronicSign.vue、ElectronicSignEntry.vue、ProviderAuthLetterUpload.vue、两端认证容器、6 份文档 | 阶段3 | 已提交推送；落地对齐改动另暂存待提交。 |
| R1 | 2026-11-16 | 认证环节送审统一：认证环节与合同签署/独立页完全同一套处理逻辑，动态码通过后前端统一按 `nextAction=UPLOAD_AUTH_FILE` 调 `/auth-file` 送审，废弃「Server 自动送审」口径；旧 `certificationFlow` 提前返回分支与 `confirmAutoSubmit` 轮询注释保留。 | ElectronicSign.vue、两端认证容器与 ProviderAuthLetterUpload.vue 注释、对齐表 v2.9、阶段3 v1.14、U-012 | 阶段3 | ESLint 0 error、diff --check 通过、废弃符号无活跃引用残留；联调必验认证环节 check-sms-code 对经办人返回 nextAction=1；5 文件未提交。 |
| R1 | 2026-11-12 | 错误提示收口：`/status` 与 `success-seen` 静默，`check-sms-code` 错误在输入框下方展示；协议、短信发送、委托书接口失败由请求层提示，主动状态查询失败由调用页面提示。移除已撤销的 `notify`、`apiNotified` 路径。 | CA 接口封装、状态源、认证组件、两端认证与合同页面、阶段2、阶段3 | 阶段3 | 已核查提示分界；实机联调待验证。 |
| R1 | 2026-11-12 | 固定入口文案与配色按 Figma `PC电子签入口`（node 173925:63471）收口：RE_UPLOAD 改「审核未通过/请重新上传/重新上传/#efb7ba」；AUTHENTICATED 去掉前缀并取设计稿描述文案；EXPIRING_SOON 无设计变体整块注释（入口不渲染）；审核中与认证成功按设计稿无按钮。同时下线 `disabled` 字段四处死分支、清理调试残留。 | ElectronicSignEntry.vue、阶段0 v2.11、阶段2 v2.18、阶段3 v1.12、U-016/U-017/U-018 | 阶段3 | ESLint 0 error；旧文案与旧样式均注释保留可回溯；即将到期不展示与认证成功描述文案列为待确认。 |
| R1 | 2026-11-12 | 固定入口增加平台实名认证前置门控（R-006-1 回填实现口径）：`ElectronicSignEntry.vue` 新增可选 prop `authCompleted`，组件内 `platformAuthCompleted` 按雇主/服务商口径自取、供应商口径由消费页传入；未认证时 `visible`/`handleAction`/成功曝光 watch 三处均短路，入口不渲染。供应商页接 `:auth-completed="isSupplierProfileCertified"`。 | ElectronicSignEntry.vue、supplier/personalCenter/index.vue、阶段0 v2.10、阶段2 v2.17、阶段3 v1.11 | 阶段3 | ESLint 0 error；本轮只动入口显隐，CA 状态接口调用时机与签署守卫口径列为待确认，未自行扩大范围。 |
| R1 | 2026-11-12 | 固定入口终态无按钮：审核中/认证成功两态不再渲染操作按钮（原为置灰按钮「审核中」/「已认证」）。经用户纠偏，按钮显隐由 `buttonText` 缺省控制（`StatusConfig.buttonText/disabled` 改可选），`disabled` 保留自身「置灰不可点」语义，两者职责分离；终态原 `buttonText/disabled` 值注释保留可回退。 | ElectronicSignEntry.vue | 阶段3 | vue-tsc exit=0、ESLint 0 error。 |
| R1 | 2026-11-11 | 三轮缺陷修复（外部静态 check 复核）：修 A——5 秒等待 watch 由「3→7」放宽为「前值任何非成功态→成功均触发」（含 immediate 兜底独立页重进）；修 B——认证环节经办人验证码通过后新增 confirmAutoSubmit 送审确认循环（最多 5 次、间隔 5s，generation 防旧循环污染）；登记联调点：非经办人 canSign=true 后 GET /status 同步性；另 3 条质疑判定不成立（P-1 兜底设计/B 项拍板口径/白屏信息过期）。 | ElectronicSign.vue、workflow-state、阶段2 技术方案 | 阶段3 | vue-tsc exit=0、ESLint 0 error；四场景卡死路径均已消除，待页面联调验证。 |
| R1 | 2026-11-11 | 二轮口径拍板并落地：①认证环节经办人「收集即落库」（收集步调 `ca-auth-letter`，动态码通过后 Server 自动送审，前端不调 `/auth-file`）；非经办人动态码通过即放行。②经办人审核通过后静默 5 秒（常量 `CA_AUTH_PASS_ADVANCE_DELAY_MS`，无页面展示）进下一环节；独立页重进已是认证成功态自动 5 秒回退。③P1 重新上传定方案 a：重进先见驳回态，点重新上传后调 `user/info`/`/status` 刷状态，仍处 RE_UPLOAD 回委托书收集步。④雇主认证页补齐经办人收集步。 | ElectronicSign.vue、ProviderAuthLetterUpload.vue、authentication/const.ts、两端认证容器、U-012、阶段2 技术方案 | 阶段3 | 已编码落地：vue-tsc exit=0、ESLint 0 error；新增联调点：check-sms-code 后 Server 自动送审时序、非经办人 canSign 同步返回、RE_UPLOAD 重走返回 UPLOAD_AUTH_FILE。 |
| R1 | 2026-11-11 | 联调实证 P-1：/status 未下发 isAuthFileNeeded（entryStatus=2 响应无该字段），恢复门控后独立页白屏。经确认前端兼容降级：门控改 status 已加载即就绪，字段缺失按非经办人单步走、真经办人靠 UPLOAD_AUTH_FILE 兜底。 | electronicSign/index.vue、useElectronicSignStatus.ts（仅注释）、workflow-state、阶段2 v2.16 | 阶段3 | vue-tsc exit=0、ESLint 0 error；后端补字段后前端无需再改。 |
| R1 | 2026-11-11 | 二轮验证收尾（经用户逐项确认）：恢复独立页 L45 状态门控（identityReady + content-area v-if）；独立页收集步简化为显式 collect-only（旧 reuploading 三元/handleReUploadSubmitted 注释保留）；provider 页 reuploading/reuploadFlowId 死变量拍板保持注释标注现状。 | electronicSign/index.vue、workflow-state、阶段2 v2.16 | 阶段3 | vue-tsc exit=0、ESLint 0 error；后端联调点 4 项前端不动。 |
| R1 | 2026-11-11 | 用户澄清被拒后步骤条由接口状态驱动回第一步，并修订 U-012 为 B 口径：废除 11-10「原地替换（不重走协议/短信）」，改为重新收集委托书后重走协议+动态码，凭本轮新 `caFlowId` 调 `/auth-file`；「重传 `caFlowId` 来源」待确认项随之关闭。 | 独立页重传链路、U-012、CA 流程恢复项、阶段2 技术方案 | 阶段2/3 | 独立页 `reuploading` 直传路径注释保留，改为回第一步收集重走；workflow-state 与阶段2 已同步。 |
| R1 | 2026-11-10 | 校准经办人认证步骤及入口文案：平台认证不新增“补充授权委托书”总步骤；审核通过后沿用现有 `next` 流转，不增加成功态按钮。 | 阶段2、阶段3、接口对齐表、服务商认证页及签章组件 | 阶段2/3 | 代码与正式文档已调整；静态核对通过，页面和接口联调待完成。 |
| R1 | 2026-11-10 | 用户确认 `GET /status` 返回经办人布尔值 `isAuthFileNeeded`；经办人 UI 先上传委托书、再验短信，验证码成功后才提交委托书审核。 | 原始需求、阶段0～3、接口对齐表、workflow-state | 阶段0/2 | 已更新文档并交叉核对；Server 原方案未改，实际响应层级待联调；代码按用户要求等文档确认后再动。 |
| R1 | 2026-11-06 | 用户确认供应商也需要 PC 固定入口，补充截图定位在供应商个人中心主体资料卡下方、保证金提示上方。 | 原始需求、阶段0～3、接口对齐表、workflow-state | 阶段0/2 | 位置与范围已回填；本轮进一步确认供应商是特殊服务商，U-009 复用 `providerId` 与服务商 CA 契约。 |
| R1 | 2026-11-06 | 收到原始需求 V1.1 新导出稿：增加从未与平台签署爱签协议的重签要求、审核中不展示时间、合同提示文案及旧版 APP 提示扩展；工作台入口删除线与即将到期展示规则已明确。V1.1 内容已合入原始需求主 Markdown，保留旧稿中的埋点、非功能和验收章节及补充流程图；新图片使用独立文件名。 | 原始需求、阶段0、阶段2/3待校准 | 阶段0 | 已回填原始需求和阶段0的 PC 规则；APP 交互登记为范围外；重签语义待与 Server 核对。 |
| R0 | 2026-11-02 | 初始需求 | - | - | - |
| R0 | 2026-11-02 | 确认本次开发仅覆盖 PC；补齐雇主“我的”入口，并细化接口契约、消息上下文与签署入口范围待确认项 | 阶段0需求文档 | - | 已更新阶段0与待确认项追踪 |
| R1 | 2026-11-02 | 补充认证场景流程、签署合同场景流程的设计图；明确个人 / 法人认证弹窗、经办人授权委托书弹窗及审核结果态 | 阶段0、阶段1 | 阶段0 | 已完成阶段0与阶段1重新评估 |
| R1 | 2026-11-03 | grilling 确认：雇主端认证页也需插入电子签名认证环节；ElectronicSign.vue 跨两端复用；雇主无经办人分支；守卫函数放 src/composables/；供应商状态归入 U-004 | 阶段0、阶段1 | - | 已更新三份文档，补充雇主端认证页分析 |
| R1 | 2026-11-03 | 明确「电子合同签章认证」在认证流程和签署合同流程中均插入到签署协议之前；已完成认证的用户自动跳过该环节；数据来源接口获取，字段结构待定（U-008）；埋点只整理不开发 | 阶段0 | - | 已更新阶段0文档 v1.5，新增 U-008 |
| R1 | 2026-11-03 | 待确认项审查：U-004 合并至 U-008；U-006 补充旧版模板已确认为前端静态资源的代码事实；U-007 细化为协议内容交付形式确认；所有待确认项均不阻塞阶段2 | 阶段0 | - | 已更新阶段0文档 v1.6 |
| R1 | 2026-11-03 | 术语修正：“爱签”是底层 CA 服务提供方，不是本次新增功能名称；前端视角的接口/状态描述统一改为“电子合同签章认证”；保留经办人“通过爱签人工审核”等业务事实描述；同步更新阶段0 v1.7、阶段1 v1.2 | 阶段0、阶段1 | - | 已完成三份文档术语统一 |
| R1 | 2026-11-03 | 阶段0 v1.8：R-008 补充核心入口路由（/employer/my/contracts、/provider/contract）；新增 R-013 埋点规范（只整理不开发）；验证闭环证据更新至 v1.8；阶段1 验证证据更新至 v1.2 | 阶段0、workflow-state | - | 已完成文档补齐与验证记录同步 |
| R1 | 2026-11-03 | 阶段0 v2.0~v2.1：清理 U-004 删除线残留（正向输出约定）；新增 R-014 异常处理与容错（4条子规则：第三方接口超时重试、审核意见禁止虚构、上传失败留当前页、未登录消息跳转恢复）；签署入口范围明确为仅核心两入口 | 阶段0、workflow-state | - | PRD 非功能需求全部落盘 |
| R1 | 2026-11-03 | 阶段2建立接口契约确认清单（C-001~C-006）；U-007 已确认为 URL 外链；风险点表同步更新 | 阶段2、workflow-state | - | 技术方案补全契约确认清单 |
| R1 | 2026-11-03 | 阶段2 v1.3 + 阶段0 v2.3：C-003/U-006 已确认——授权委托书模板复用现有静态资源 `/files/authorization-letter-template.docx`，两端 `handleTemplateDownload` 已有实现，新组件照搬即可 | 阶段0、阶段2、workflow-state | - | U-006/U-007 均已闭环；当时待确认项含 C-006（authPhase 枚举），该项已于 2026-11-04 调整为“电子签章独立恢复状态”。 |
| R1 | 2026-11-03 | 新增「后端接口契约对齐表」：独立文档，含 4 项待确认 + 2 项已确认、6 个接口预估签名、数据结构预估、现有字段参考、比对指南 5 步 | 后端接口契约对齐表-REQ-195.md | - | 后端出方案后可逐项比对差异，定向更新前端技术方案 |
| R1 | 2026-11-04 | 代码状态机复核：服务商 `authPhase >= 3` 已进入原系统审核、雇主 `authPhase === 3` 已进入原认证成功态；电子签章流程不得复用或扩展该字段。同步更新阶段0 v2.4、阶段1 v1.3、阶段2 v1.5、接口契约表 v1.1，并新增 C-006 独立恢复状态确认项。 | 阶段0、阶段1、阶段2、接口契约表 | 阶段2 | 已完成文档纠偏；待后端确认 C-001/C-005/C-006 后进入编码。 |
| R1 | 2026-11-04 | 接口方案收敛：原“6 个新增接口”调整为前端能力清单与候选接入方式。状态、协议 URL、验证码发送、委托书审核均优先复用或合并；仅在既有能力无法满足时新增接口。 | 阶段2、接口契约表、workflow-state | 阶段2 | 已更新阶段2 v1.6、接口契约表 v1.2，待后端按能力确认最终契约。 |
| R1 | 2026-11-04 | 补齐供应商个人中心固定入口：需求已包含该入口，技术方案增加条件改动项；具体位置与供应商主体状态来源列为 U-009。 | 阶段0、阶段2、workflow-state | 阶段2 | 已更新阶段0 v2.5、阶段2 v1.7，待产品/后端确认 U-009。 |
| R1 | 2026-11-04 | 服务端契约表更新：增加 Server 回复清单和 C-007，按“状态、认证完成、短信、委托书、协议、消息回跳”逐项确认实际接口映射与同步/异步行为，不以候选接口数量作为后端实现约束。 | 阶段2、接口契约表、workflow-state | 阶段2 | 已更新阶段2 v1.8、接口契约表 v1.3，待 Server 书面回复。 |
| R1 | 2026-11-04 | 进入阶段3编码执行准备：拆分契约确认、接口状态层、认证组件、两端状态机、合同守卫、固定入口、消息异常处理和验证出口八步，每步明确目标与验收效果。 | 阶段3、workflow-state | - | 已生成阶段3编码执行计划；等待步骤1外部确认后开始业务代码改动。 |
| R1 | 2026-11-04 | 基于知识库 L5 精读文档交叉验证：技术方案 v1.8→v1.9（补断点恢复 phase 冲突风险、并发防护要求、经办人判断不能复用 needSupplementary、组件挂载策略差异、委托书审核失败不走容器 failure、businessSteps 动态化方案〔该项已于 2026-11-10 撤销〕）；对齐表 v1.3→v1.4（C-005 补充经办人身份判断、C-006 补充 phase 枚举区间约束与断点恢复插入位置）。 | 阶段2、接口契约表、workflow-state | - | 历史方案保留追溯；当前总步骤以阶段2“服务商端 ViewType 扩展”固定五步为准。 |
| R1 | 2026-11-05 | 以雇主/服务商认证精读交叉校准：服务商个人现有流程补回 `moreInfo`；经办人委托书由 `moreInfo` 后分流，不经过人脸；同步修正阶段0、阶段1、阶段2状态图/步骤/验收与阶段3执行约束。工作流登记当前未提交临时代码为不可验收占位。 | 阶段0、阶段1、阶段2、阶段3、workflow-state | - | 文档与当前认证状态机一致，后续编码须以 C-001/C-005/C-006/C-007 为前置。 |
| R1 | 2026-11-05 | Server 契约回填：三份后端方案（爱签核身验证、用户认证模块、11-05 评审纪要）逐项比对现有文档。对齐表补齐 7×2 核身 HTTP、`ca-auth-letter` 与 `/protocol` 强校验；阶段0补齐存量爱签用户免认证、企业主体维度与供应商范围；阶段2按 `caFlowId` 重写 API 流程与 C-007 结论。 | 对齐表、阶段0、阶段2、workflow-state | - | C-001/U-008 关闭；C-005/C-006/C-007 部分关闭；遗留 T1、经办人事前标识、验证码倒计时与供应商口径。 |
| R1 | 2026-11-05 | 对齐 Server 技术方案与评审纪要：状态查询、`caFlowId`、协议 URL、短信、授权书审核轮询和成功入口服务端标记已回填；保留 `authPhase=4` 与服务商既有 `phase>=3` 冲突、新认证经办人收集入口、供应商范围和接口计数口径等门禁。 | 阶段2、阶段3、接口契约表、workflow-state | - | 可启动状态层/API 适配设计，认证恢复和经办人分流待联合确认后编码。 |
| R1 | 2026-11-05 | C-001 确认为独立状态接口；移除服务商工作台固定入口（Figma 确认）；补建 useElectronicSignGuard.ts。 | 阶段2 v2.7、阶段3 v1.6、workflow-state | - | stores/user.ts 无需改动；dashboard 不接入；守卫 composable 已就绪。 |
| R1 | 2026-11-05 | 两端合同页 handleSign 复用改造：抽取 `confirmAndGoElectronicSign` 工具函数到 guard 文件，两端删除各自内联的 `needElectronicSign()` 占位函数和重复 Modal.confirm 代码块，改为消费 `useElectronicSignGuard(role).canSign`；同步清理过程追溯注释（v2.8 残留）。技术方案 v2.8→v2.9。 | 阶段2 v2.9、两端 contract/index.vue、guard composable | - | 两端合同页对称改造，净减约 10 行重复代码；ESLint 0 errors。 |
| R1 | 2026-11-06 | 电子签章页面审核结果态确认：U-010（结果态放 ElectronicSign.vue 内部根据 entryStatus 切换）、U-012（重新上传=原地替换）、U-014（合同签署跳转后认证页根据 entryStatus 展示）已闭环；U-011（轮询频率）、U-013（驳回原因）待产品+后端确认。技术方案 v2.9→v2.10。 | 阶段2 v2.10、workflow-state | - | 三种渲染形态已明确，待实现审核中/审核未通过 UI。 |
| R1 | 2026-11-06 | AuthLetterStatus.vue 组件落地：审核结果态 UI 从 ElectronicSign.vue 抽离为独立组件，采用「一个组件文件 + 多状态完整独立 DOM 分支 + 共享 BEM 样式」设计模式；ElectronicSign.vue 简化为单个 `<AuthLetterStatus v-if="showAuthLetterStatus">`。技术方案 v2.10→v2.11。 | 阶段2 v2.11、AuthLetterStatus.vue、ElectronicSign.vue | - | 组件设计规则确立：各状态 DOM 完全独立，新增状态只需加 v-else-if 分支。 |
| R1 | 2026-11-06 | C-001 最终收敛：电子签章状态只走独立 `GET /v1/{role}/ca-verification/status`；阶段文档、契约表与状态 composable 已统一。 | 阶段0、阶段2、阶段3、接口契约表、workflow-state、useElectronicSignStatus.ts | - | 电子签章状态来源唯一。 |
| R1 | 2026-11-06 | 轮询设计纳入需求文档：阶段2 v2.13→v2.14 新增「逻辑5 授权书审核结果轮询」（唯一场景 `entryStatus=3`、状态驱动启停、递归 setTimeout 防重入、失败降级、三处清理）+ 2 条风险 + 2 组验证；阶段3 v1.7→v1.8 在步骤2 状态层加轮询实现动作与验收、步骤3 明确结果态只消费统一状态源、步骤8 加轮询验证；契约表 v2.2→v2.3 补「委托书审核结果轮询」结论行。实现范式仅在知识库 L5 7.7 保留全文，需求文档只放设计决策与指针，避免两处维护。 | 阶段2、阶段3、接口契约表、workflow-state | - | 轮询设计可追踪；**U-011（轮询频率与终止条件）仍待产品+后端确认**，编码以单一常量占位，确认后只改常量值；U-013（驳回原因）状态不变。 |
| R1 | 2026-11-06 | 阶段3代码推进：修复服务商 `authPhase=4` 被旧系统审核分支截获；两端合同列表顶部补电子签章固定入口，个人中心入口按实名认证状态展示并跳对应 CA 独立页；固定入口移除无条件展示，成功态按主体一次性曝光，合同列表不展示成功态；`entryStatus=2` 按 Server 方案重新申请协议。 | wds-web 认证页、个人中心、两端合同页、状态层、固定入口、workflow-state | - | 供应商入口联调、驳回原地重传流程号、Server `user/info` 透传差异复核及联调/类型检查仍待处理。 |
| R1 | 2026-11-06 | 用户取消获取验证码前的协议内容滚动与 3 秒等待要求；短信发送后的重发冷却保留。 | 原始需求、阶段0～3、对齐表、workflow-state | 阶段0～3 | 已从当前需求、方案、计划和验收条件中移除相关门槛；前端无此门槛代码。 |
| R1 | 2026-11-10 | 三条待确认项依 Apifox 实测契约收口：U-008（字段名/类型/层级全部确定，`isAuthFileNeeded` 为 `StatusModel` 唯一 required）、C-005（分流字段与 `authStatus`/`authPhase` 已确认，来源字段已写入）、C-007（核身 14 接口映射 + 倒计时 `countdown` 落点）；同源行「新增遗留」同步剔除倒计时项。四条遗留开口保留：P-1 缺省规则、频控、T1、`ca-auth-letter` 口径。 | 不确定项追踪、新增遗留、workflow-state | - | 收口结论均来自契约文档，未做推测；遗留项仍为后端/产品开口 |
| R1 | 2026-11-10 | 接口契约开发依据切换：新增《电子签章接口契约-Apifox-REQ-195.md》（Apifox 项目 8677491 实测，14 个核身接口 + 20 个 schema，含枚举、错误文案与时序图）；《后端接口契约对齐表-REQ-195.md》自本日起不再作为开发依据，文件保留不删除。 | 电子签章接口契约（新增）、workflow-state | - | 接口字段以 Apifox 契约文档为准；对齐表 0.1 预估与实测的 8 处差异已口头同步；认证域接口契约仍只在对齐表内，待确认是否迁入新文档。 |
| R1 | 2026-11-23 | 雇主、服务商认证容器在 CA 缺料时不再自动跳回提交资料，保留提示并停留当前步骤；独立签署页补传行为及委托书 OSS code 取值逻辑不变。 | 雇主认证、服务商认证、ElectronicSign.vue、workflow-state | - | 已完成代码调整；OSS code 取值问题暂缓，待后续确认处理。 |

## 备注
- 本期功能：在现有认证流程（雇主端 `/employer/certification` + 服务商端 `/provider/certification`）中新增“电子合同签章认证”环节
- 涉及端：雇主端、服务商端、供应商端（Web PC）
- 关键决策：ElectronicSign.vue 跨两端复用；authLetterUpload 仅服务商端〔2026-11-20 更正：雇主认证容器也复用该视图承载 CA 驳回重传（role='employer'），见置顶 RZMP-11727 条目〕；useElectronicSignGuard.ts 放 src/composables/；认证成功一次性曝光由 Server `showSuccessEntry` / `success-seen` 维护；电子签章状态事实源为独立状态接口，`authPhase=4` 仅作恢复检查点。
- 入口显隐口径（2026-11-12）：固定入口显隐单点由 `ElectronicSignEntry.vue` 内部决策（含平台实名认证前置门控），消费页只传 props、不包 `v-if`；平台实名认证与 CA 认证是两个不同数据源，不得互替。
- 接口契约依据：自 2026-11-10 起以 `电子签章接口契约-Apifox-REQ-195.md` 为准，《后端接口契约对齐表-REQ-195.md》转为历史比对基线。
- 2026-11-23 16:12 review 注记（JL-02 修复代码 check，**只读**）：上方 11-23「已完成代码调整」一行对应的 5 个未提交文件已逐项复核，全文见《测试用例逐条验证-REQ-195》3.6.6。修复方向成立、雇主 / 服务商两端对称、独立签署页与个人认证流程无回归、eslint / vue-tsc 无新增问题；但发现两条**待处理**风险：① `ElectronicSign.vue:216` 一致性检查原以「本地有码 ⇐ 服务端要求委托书」为前提，去门控后前提失效，`nextAction=0/2` 且草稿残留委托书码时会误报并阻断认证（Apifox 契约 :228 / :386-388）；② `:209` 认证流程缺码改为仅报错后，CA 步骤模板无返回 / 重传出口，兜底断裂。两条**均未改代码**，待用户裁决与授权后再提交；旧表述不删。
- 2026-11-23 16:12 review 注记后续：用户决定本次**只保留不自动跳回提交资料**，OSS code 取值逻辑恢复原状、暂缓处理。因此风险①随取值门控恢复而不再适用；风险②对应的自动跳转不恢复，按用户最新要求保留当前 CA 步骤。独立签署页补传行为不变。
