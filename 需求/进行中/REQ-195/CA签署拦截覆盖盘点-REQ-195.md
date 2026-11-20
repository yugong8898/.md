# CA 签署拦截覆盖盘点与待确认清单（REQ-195）

> 用途：全项目盘点「签署合同前的 CA 认证拦截」覆盖情况，列出遗漏场景与待确认问题，供产品 / 后端 / 测试逐项确认后决定补齐范围。
> 盘点基线：wds-web 分支 `F-REQ-195-wxj`，HEAD `a4414a07f` + 工作区供应商守卫 3 文件（2026-11-20 晚实测；首轮盘点基线为 HEAD `066a7681d`）。
> 范围：wds-web 用户侧三身份（雇主 employer / 服务商 provider / 供应商 supplier）。wds-admin-web 为运营后台，不以用户身份发起合同签署，不在本次范围。

## 目录

- [一、盘点方法](#一盘点方法)
- [二、已覆盖守卫的签署出口](#二已覆盖守卫的签署出口)
- [三、遗漏场景与待确认问题](#三遗漏场景与待确认问题)
  - [P0-A：buy.vue 下单后立即签署主流程无守卫](#p0-abuyvue-下单后立即签署主流程无守卫)
  - [P0-B：合同确认页最终签署动作页内无守卫](#p0-b合同确认页最终签署动作页内无守卫)
  - [P1-C：供应商订单签署无守卫（已知缺口）](#p1-c供应商订单签署无守卫已知缺口)
  - [P2-D：需产品确认是否属 CA 范围的场景](#p2-d需产品确认是否属-ca-范围的场景)
- [四、确认记录表（找人确认时填写）](#四确认记录表找人确认时填写)
- [五、搜索证据（负结论支撑）](#五搜索证据负结论支撑)
- [六、确认后的建议处理顺序](#六确认后的建议处理顺序)

---

## 一、盘点方法

双轨并行，结果取并集：

1. **API 层**：grep 全部 sign 相关封装函数，逐一追踪全部消费点；
2. **视图层**：grep 签署 handler（`handleSign*` / `onSign*` / `sign*` / `confirmSign`）+ 签署文案（去签署 / 签署合同 / 立即签署），交叉核对守卫（`checkBeforeSign`）接入位置。

守卫统一实现：`useElectronicSignGuard(role).checkBeforeSign()`（零参），未认证弹「去认证」引导跳独立认证页，查询失败拒绝放行。

## 二、已覆盖守卫的签署出口

共 10 处守卫点，覆盖以下全部出口（实测核对，无遗漏；9/10 为 2026-11-20 晚 P1-C 收口新增）：

| # | 签署出口 | 守卫位置 | 覆盖消费页 |
|---|---|---|---|
| 1 | 雇主合同列表「立即签署」 | `employer/contract/index.vue` handleSign | 本页 |
| 2 | 服务商合同列表「立即签署」 | `provider/contract/index.vue` handleSign | 本页 |
| 3 | 雇主订单列表「签署合同」 | `employer/order/list.vue` handleSignContract | 本页 |
| 4 | 雇主订单详情「签署合同」 | `employer/order/detail.vue` handleSignContract | 本页 |
| 5 | 服务商订单列表「签署合同」 | `provider/order/list.vue` handleSignContract | 本页 |
| 6 | 服务商订单详情「签署合同」 | `provider/order/detail.vue` handleSignContract | 本页 |
| 7 | 选择合同弹窗（模板 / 自定义上传） | `SelectContractDialog.vue` onTemplate / onCustom | 雇主合同列表、雇主订单列表 / 详情、buy 页（4 消费点） |
| 8 | 总分包确认弹窗「去签署」 | `SubpackageSignConfirmDialog.vue` onConfirm | general-contract list / detail、agent-contract list / detail / child-detail（5 页，弹窗内聚守卫，消费页零改动） |
| 9 | 供应商订单列表「签署合同」 | `supplier/order/list.vue` sign() | SupplierOrderListCard 按钮（纯 emit，零改动） |
| 10 | 供应商订单详情「签署合同」 | `supplier/order/detail.vue` signContract() | SupplierOrderContractCard 按钮（纯 emit，零改动） |

供应商两处均以 `useElectronicSignGuard('provider', { authPath: SUPPLIER_ELECTRONIC_SIGN_PATH })` 接入，去认证跳供应商专属独立页（方案②，见 P1-C 收口注记）。

补充核实：总分包 5 页的 `confirmSign` 仅经弹窗 `@confirm` 触发（全仓 11 处命中均为「函数定义 + 弹窗监听」），无模板直调旁路。

## 三、遗漏场景与待确认问题

### P0-A：buy.vue 下单后立即签署主流程无守卫

- **位置**：`employer/purchase/buy.vue` L866 `handleSignContract`，由 L1190 下单成功（后端落单 orderType=2，先签后付）后直接调用。
- **现状**：
  - briefStatus 返回 signUrl 时**直接 `window.open` 打开爱签页**，CA 校验完全绕过；
  - 无 signUrl 时路由到合同确认页 / 自主上传页（页内也无守卫，见 P0-B）。
- **易误判点**：buy 页的 SelectContractDialog 已有守卫，但只覆盖「选择合同」分支；**下单后直签分支是漏网的**。
- **待确认**：先签后付下单后是否必须先完成 CA 认证才能进入签署？（预期答案：是，与其余签署出口一致）
- **拟改方案（确认后实施）**：handleSignContract 顶部加 `checkBeforeSign()`，1 处改动，role='employer'。

### P0-B：合同确认页最终签署动作页内无守卫

- **位置**：
  - `employer/contract/common.vue` L506 `handleConfirm`：确认信息无误 → `generateEmployerContract` → 打开签署链接；
  - `employer/contract/confirm.vue` L115 `handleConfirm`：同上（旧版页面，现仅剩老路径 `contracts/confirm/:orderId` redirect 引用，无主动跳转入口，但路由仍注册可直达）。
- **现状**：现有守卫都在**入口**（列表 / 弹窗），这两页自身无守卫。
- **绕过路径**：
  1. P0-A 的无守卫路由直达；
  2. **直接 URL 访问 / push 站内信链接 / 浏览器历史回退**直达页面后点「确认信息无误」。
- **待确认**：
  1. 守卫口径是「入口拦」还是「最终动作拦」？若要求防直达绕过，需在页内 handleConfirm 补守卫；
  2. confirm.vue 旧版页面是否仍有线上流量（push 旧链接 / 收藏）？是否顺带补守卫或下线路由？
- **拟改方案（确认后实施）**：common.vue / confirm.vue handleConfirm 顶部各加 `checkBeforeSign()`。

### P1-C：供应商订单签署无守卫（已知缺口）〔2026-11-20 已收口：用户裁决纳入拦截 + 方案②，已实施〕

- **位置**：`supplier/order/list.vue` `sign()`、`supplier/order/detail.vue` `signContract()`，直调 `postSupplierSignContract` 后 `window.open(signUrl)`。
- ~~**待确认**~~〔2026-11-20 用户已裁决并实施〕：
  1. 供应商签署纳入 CA 拦截：✅ 已接入 `useElectronicSignGuard('provider', { authPath: SUPPLIER_ELECTRONIC_SIGN_PATH })`，守卫落在两父页 handler，卡片组件零改动；
  2. 跳转路径裁决：✅ 选方案②，hook 新增可选 `authPath` 参数（显式传入优先，缺省仍按 role 推导，既有 7 接入点行为不变），供应商去认证跳 `/supplier/my/electronic-sign`。
  - 门禁：ESLint 3 文件 0 error、vue-tsc 全仓 0 error、回归 4/4；改动 3 文件 +20/-2。

### P2-D：需产品确认是否属 CA 范围的场景

| # | 场景 | 现状 | 待确认问题 |
|---|---|---|---|
| D1 | 自主上传合同「重新上传」 | 合同列表 `handleReuploadContract` / `handleAuditOpinionReupload` 直跳 custom.vue，无守卫；custom.vue `handleSubmit` 是**提交审核**（签署发生在审核通过后第三方短信），首次上传入口 SelectContractDialog.onCustom 已有守卫 | 审核失败后重新上传是否要求 CA 认证？ |
| D2 | 钱包开户签约 | personalCenter `handleGoSignAgreement` → `postProviderWalletSignUrl`，属**钱包开户**业务 | 是否属电子合同签章 CA 范围？（前端默认判断：不属于，不同业务线） |
| D3 | SignContractModal.vue（provider/order） | 全仓零引用的静态 mock 死代码（金额 / 日期写死），无运行时风险 | 仅报备存在，是否清理另行决定，不属 CA 拦截问题 |

## 四、确认记录表（找人确认时填写）

| 编号 | 问题摘要 | 确认人 | 结论 | 日期 |
|---|---|---|---|---|
| P0-A | 先签后付下单后直签是否补 CA 守卫 | | | |
| P0-B-1 | 守卫口径：入口拦 vs 最终动作拦（防直达绕过） | | | |
| P0-B-2 | confirm.vue 旧版页是否补守卫 / 下线路由 | | | |
| P1-C-1 | 供应商订单签署是否纳入 CA 拦截 | 用户（wang 工） | ✅ 纳入，已实施（守卫落两父页 handler） | 2026-11-20 |
| P1-C-2 | 供应商去认证跳转路径：方案①等价跳转 / 方案②路径映射 | 用户（wang 工） | ✅ 方案②，hook 新增可选 authPath，跳供应商专属 URL | 2026-11-20 |
| P2-D1 | 重新上传合同是否要求 CA | | | |
| P2-D2 | 钱包开户签约是否属 CA 范围 | | | |

## 五、搜索证据（负结论支撑）

- **API 层 sign 封装全集**（逐一追完消费点）：
  - 合同签署类：`postEmployerOrderSignContract` / `postProviderSignContract` / `signProviderContract` / `postSupplierSignContract` / `generateEmployerContract` / `createEmployerCustomContract`；
  - 非合同签署（排除）：`batchSignEmployerCertificationFiles` / `batchSignProviderCertificationFiles`（OSS 上传批量签名）、`getPresignedUrl` / `getEmployerOrderPresignedUrl`（OSS 预签名 URL）、`postProviderWalletSignUrl`（钱包开户，见 D2）。
- **视图层**：`function handleSign*/onSign*/sign*` handler grep + 「去签署 / 签署合同 / 立即签署 / 合同签署 / 签署协议」文案 grep 双轨核对。
- **零命中核实**：两端 `agreement.vue` 无签署动作（sign / submit / window.open 零命中）；`SignContractModal` 全仓零引用；总分包 `confirmSign` 无模板直调。
- **守卫接入点全集**：`checkBeforeSign` 全仓 14 处命中 = hook 定义 3 处 + 接入 11 处（10 个守卫点，SelectContractDialog 含 2 处；2026-11-20 晚实测，含供应商新增 2 处）。

## 六、确认后的建议处理顺序

1. **P0-A**：buy.vue handleSignContract 补守卫（1 处，影响主流程，优先级最高）；
2. **P0-B**：common.vue / confirm.vue 页内补守卫（防直达绕过；confirm.vue 按确认结论处理）；
3. ~~**P1-C**：供应商订单 list / detail 接守卫（按路径方案裁决实施）~~〔2026-11-20 已完成，方案②〕；
4. **P2-D**：按产品结论决定，默认不落代码。

> 以上均待确认后实施，本文档不包含任何已执行的遗漏修复。〔2026-11-20 更正〕P1-C 已经用户裁决并实施（见三节 P1-C 注记）；P0-A / P0-B / P2-D 仍待确认，未落代码。

---

**文档版本**: v1.2
**最后更新**: 2026年11月
**整理人**: 王新骏