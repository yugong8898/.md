# TMS 结算服务迁移 - 提测单

## 一、需求概述

将 TMS 结算相关模块（客户对账、日常收支、在途费用）的接口从老服务 `/lmt-user` 迁移到新服务 `/ltms-settlement`。采用**接口级灰度开关**方案：由后端下发的开关 map 决定单个接口走新服务还是老服务，前端无需发版即可控制迁移范围，失败自动兜底老接口。

- 需求编号：#CHJY-23808
- 需求文档：`.md/需求/TMS结算业务梳理和迁移方案 2/TMS结算业务梳理和迁移方案.md`

## 二、分支与改动范围

- 分支：`F-tms-migration-wxj`（基于 `origin/master`，共 4 个 commit）
- 改动文件：15 个，+238 / -60 行
- 关键文件：
  - 新增 `src/api/tms-settlement-prefix.ts`（开关前缀解析器）
  - 新增 `src/stores/tms-switch.ts`（开关 Store）
  - 改动 `src/config/project-config.ts`（新增 `ltmsSettlement` 前缀）
  - 改动 `src/main.ts`（登录后拉取开关）
  - 改动 5 个 api 文件（reconciliation / inTransit / waybill / daily-income / daily-expense）
  - 改动 5 个页面视图（列表页 `onMounted` 调 `refreshSwitch()`）

## 三、核心迁移机制

| 文件 | 职责 |
|------|------|
| `src/api/tms-settlement-prefix.ts` | `ltmsUrl(relativePath)`：按相对路径生成开关 key（斜杠转下划线），开关开→`/ltms-settlement`，关/异常/未命中→`/lmt-user` 兜底 |
| `src/stores/tms-switch.ts` | 开关 Store：`initSwitches()`（登录后拉取）、`isNewEnabled(key)`、`refreshSwitch()`（列表页刷新，10s 内防重复）；静默请求，失败保留旧缓存；`loading` + `fetchingPromise` 双重防竞态 |
| `src/config/project-config.ts` | 新增 `ltmsSettlement: '/ltms-settlement'` |
| `src/main.ts` | 登录态就绪后 `await initSwitches()`，失败不阻断挂载 |

**开关 key 规则（与后端约定）**：相对路径去首斜杠、剩余斜杠转下划线。
例：`/income/costList` → `income_costList`；`/lscWaybill/page` → `lscWaybill_page`

## 四、迁移接口清单

代码侧实际生效的迁移接口 = **42 个**（按需求文档 5 大模块，剔除已无调用的 `customer-statement/init`，详见第五章）。

### 4.1 客户对账管理 - 客户汇总（3 个）

| 接口 | 说明 |
|------|------|
| `/lscWaybill/queryTotalAmount` | 查询对账总金额 |
| `/lscWaybill/page` | 分页查询运单池 |
| `/customer-statement/create-v2` | 创建对账单 |

### 4.2 客户对账管理 - 客户对账单（12 个）

| 接口 | 说明 |
|------|------|
| `/lsc-common-statement/query/page` | 分页查询对账单 |
| `/lsc-common-statement/status/audit-pass` | 审核通过 |
| `/lsc-common-statement/status/audit-reject` | 审核驳回 |
| `/lsc-common-statement/status/cancel-pass` | 取消审核 |
| `/lsc-common-statement/status/transfer-settlement` | 转结算 |
| `/lsc-common-statement/status/cancel-settlement` | 取消结算 |
| `/lsc-common-statement/status/delete-by-id` | 删除对账单 |
| `/common-statement/detail-query` | 查询对账单详情 |
| `/common-statement/update` | 更新对账单 |
| `/stmt-detail/page-query` | 分页查询对账明细 |
| `/stmt-detail/batch-create` | 批量新增对账明细 |
| `/stmt-detail/batch-delete` | 批量删除对账明细 |

### 4.3 日常收支 - 日常收入（8 个）

| 接口 | 说明 |
|------|------|
| `/income/costList` | 查询企业收入费用项 |
| `/income/page` | 分页查询日常收入 |
| `/income/detail` | 收入流水详情 |
| `/income/attachList` | 收入附件列表 |
| `/income/create` | 创建日常收入 |
| `/income/update` | 修改日常收入 |
| `/income/audit` | 审核日常收入 |
| `/income/delete` | 删除日常收入 |

### 4.4 日常收支 - 日常支出（8 个）

| 接口 | 说明 |
|------|------|
| `/expenditure/costList` | 查询企业支出费用项 |
| `/expenditure/page` | 分页查询日常支出 |
| `/expenditure/detail` | 支出流水详情 |
| `/expenditure/attachList` | 支出附件列表 |
| `/expenditure/create` | 创建日常支出 |
| `/expenditure/update` | 修改日常支出 |
| `/expenditure/audit` | 审核日常支出 |
| `/expenditure/delete` | 删除日常支出 |

### 4.5 在途管理 - 在途费用（11 个）

| 接口 | 说明 |
|------|------|
| `/route-cost-query/cost-apply-list` | 分页查询费用记录 |
| `/route-cost-query/cost-item-list` | 获取企业可用费用项 |
| `/route-cost-query/cost-apply-detail` | 费用详情 |
| `/route-cost-query/find-same-cost-apply` | 查同单费用列表 |
| `/route-cost/cost-apply` | 在途费用上报 |
| `/route-cost/cost-edit` | 在途费用编辑 |
| `/route-cost/cost-delete` | 在途费用删除 |
| `/route-cost/cost-audit` | 在途费用审核 |
| `/route-cost/cost-revoke-audit` | 在途费用撤销审核 |
| `/route-cost/cost-revoke-pay` | 在途费用取消支付 |
| `/payment/batch-transfer` | 在途费用批量发起支付 |

## 五、废弃/残留接口说明

以下接口虽在代码中仍定义，但**已无业务调用**，不计入生效迁移清单：

- `customer-statement/init`：原 `initCustomerStatementApi`，页面已改为"直接跳转，不再调用"。代码残留两处定义：
  - `src/api/reconciliation/index.ts:207` 已走 `ltmsUrl`（@deprecated）
  - `src/views/.../customer-summary/api/index.ts:44` 仍走老 `/lmt-user`（@deprecated）
  - TODO: wxj `customer-statement/init` 已无调用，两处废弃定义待清理（确认后端新链路不需要后删除）

## 六、与需求文档对账

最新需求文档列应迁接口 43 个（不含标注"不用"的 `init`），代码生效迁移 42 个，差异如下：

| 接口 | 文档状态 | 代码状态 | 结论 |
|------|------|------|------|
| `customer-statement/init` | 标注"不用" | 无调用（残留定义） | 一致，不计入迁移 |
| `payment/cancel-transfer` | 列（待定位） | 全仓无此调用点 | 前端无入口，非漏迁，文档维持待定位 |

其余 42 个接口与文档完全一致，数量已对齐。

## 七、验证清单

- [ ] 开关接口拉取成功，前端 `switchMap` 写入各接口 key
- [ ] 开关 key=1 的接口请求走 `/ltms-settlement`，返回数据正常（客户对账、收支流水、在途费用）
- [ ] 开关 key=0 或未命中 → 自动走 `/lmt-user` 老接口，功能不受影响
- [ ] 开关接口失败（断网/502）→ 静默兜底老接口，页面不报错、不白屏
- [ ] `main.ts` 登录后 `initSwitches` 失败不阻断应用挂载
- [ ] 列表页 `onMounted` 触发 `refreshSwitch`，10s 内重复进入不重复请求
- [ ] `customer-statement/init` 确认页面无调用，废弃定义待清理
- [ ] 客户汇总/对账单、收支、在途费用各页面全链路验证（列表/详情/创建/审核/删除）

## 八、风险点与待确认

- **开关 key 命名一致性**：前端 key 生成规则（斜杠转下划线）必须与后端下发 key 完全一致，否则全部兜底走老接口。建议测试环境抓包核对每个 key。
- **GATEWAY 差异**：`inTransit` 原请求带 `GATEWAY = { urlGateway: '/gateway/lmt-user' }`，新方案改为 `ltmsUrl` 不再走该网关头，需确认新服务是否仍需要该网关参数。
- **`payment/cancel-transfer`**：需求文档列出但前端无调用，维持"待定位"，确认后端是否仍需前端补充入口。
- **废弃接口清理**：`customer-statement/init` 两处 @deprecated 定义待后端确认新链路无依赖后删除。

## 九、遗留问题

无（工作区干净，5 个多迁接口已改回老前缀，init 已确认无调用）。

---

**文档版本**: v1.0
**最后更新**: 2026年08月
**整理人**: 王新骏
