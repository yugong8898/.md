# TMS 结算服务迁移 - 提测单

## 一、概述

- 需求：#CHJY-23808（TMS 结算服务迁移，老 `/lmt-user` → 新 `/ltms-settlement`）
- 机制：接口级灰度开关。开关开走新服务，关/异常/未命中自动兜底老接口，前端无需发版

## 二、迁移模块与接口（42 个）

- **客户对账管理 - 客户汇总（3 个）**：运单池查询、对账总金额、创建对账单（含 `lscWaybill/*`、`customer-statement/create-v2`）
- **客户对账管理 - 客户对账单（12 个）**：对账单分页/审核/转结算/明细等（`lsc-common-statement/*`、`common-statement/*`、`stmt-detail/*`）
- **日常收支 - 日常收入（8 个）**：收入流水列表/详情/创建/审核/删除等（`income/*`）
- **日常收支 - 日常支出（8 个）**：支出流水列表/详情/创建/审核/删除等（`expenditure/*`）
- **在途管理 - 在途费用（11 个）**：费用上报/编辑/审核/支付等（`route-cost-query/*`、`route-cost/*`、`payment/batch-transfer`）

> 注：需求文档所列 `customer-statement/init` 已无调用，不计入；`payment/cancel-transfer` 前端无调用点，维持待定位。

## 三、验证清单

- [ ] 开关 key=1 的接口走 `/ltms-settlement`，数据正常
- [ ] 开关 key=0 / 未命中 → 兜底走 `/lmt-user`，功能不受影响
- [ ] 开关接口失败（断网/502）→ 静默兜底老接口，页面不报错不白屏
- [ ] `main.ts` 登录后 `initSwitches` 失败不阻断挂载
- [ ] 列表页 `onMounted` 调 `refreshSwitch`，10s 内不重复请求
- [ ] 五大模块全链路验证（列表/详情/创建/审核/删除）


**文档版本**: v1.0
**最后更新**: 2026年08月
**整理人**: 王新骏
