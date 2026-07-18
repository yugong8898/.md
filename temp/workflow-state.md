# 工作流进度

## 需求信息
- 需求名称：C161 线上问题
- 开始时间：2026-07-16
- 需求来源：.md/需求/【C161】线上问题.md

## 阶段进度
| 阶段 | 状态 | 产物文件 | 完成时间 |
|------|------|---------|---------|
| 阶段0 需求分析 | ✅已完成 | .md/temp/需求文档-C161线上问题.md | 2026-07-16 |
| 阶段1 代码分析 | ✅已完成 | .md/temp/代码分析-C161线上问题.md | 2026-07-18 |
| 阶段2 技术方案 | ⏳待开始 | - | - |
| 阶段3 编码执行 | ⏳待开始 | - | - |
| 阶段4 代码审查 | ⏳待开始 | - | - |
| 阶段5 提测清单 | ⏳待开始 | - | - |

## 当前阶段
阶段1 代码分析 ✅ → 仍暂停，等待不确定项确认后进入阶段2 技术方案

## 阶段1 关键发现
- 三个模块均无公共金额汇总组件，各自在 `watch(selection)` 用 BigNumber 直接累加接口字段，前端未做加减修正
- 三处「运费差价」汇总均直接累加 `serviceCharge`（未减 `oilDiscountAmount`）→ 确认 Bug 点
- ⚠️ 重复扣减风险：司机对账 index.vue:1023 注释称「应付后端已含油气优惠扣除」，若属实，前端再套 `应付=A+E-D` 会重复扣减 → 需后端确认字段口径
- 字段名已基本定位（候选值见代码分析文档第六节）：油气优惠 `oilDiscountAmount`+`oilDiscountFlag`，保障服务 `listPremiumAmount`/`insurAmount`
- 需求文档模块归属偏差：「应到付/应回单付」实际位于运单结算处理页（waybillSettlement），不在运单付款页（carrierPayment）

## 已处理文件（阶段3用）
- `logisticsweb/src/views/userBase/driverChecking/index.vue`：selection watch 1013-1032、批量弹窗 1742-1773
- `logisticsweb/src/views/userBase/carrierPayment/index.vue`：handleBatchPost 1358-1364
- `logisticsweb/src/views/userBase/waybillSettlement/index.vue`：selection watch 1138-1161、tableData watch 1223-1252

## 不确定项追踪
| # | 问题 | 状态 | 确认人 |
|---|------|------|--------|
| 1 | 油气优惠/保障服务字段名（候选 `oilDiscountAmount`/`oilDiscountFlag`/`listPremiumAmount`/`insurAmount`）；"未支付货主油气优惠"是否独立新增字段 | 部分确认（已定位候选），待后端 | 后端 |
| 2 | 运费差价 C-D 出现负数时，前端展示负数还是显示 0 | 待确认 | 产品 |
| 3 | 应回单付是否也需要减去货主油气优惠 | 待确认 | 产品 |
| 4 | 勾选混合运单时，油气优惠/保障服务是否只对网货运单生效 | 待确认 | 产品/后端 |
| 5 | 运单结算处理应付/运费差价是"检查已有实现"还是"新增修改"；尤其 `waybillToConsignorPrice`/`payableFpFreight` 是否已含油气扣除 | 代码层面发现口径疑点（司机对账注释称已含），需后端+产品确认 | 后端/产品 |
| 6 | "货主沟通货物保障服务金额" 与 "货主购买保费E" 是否同字段（候选均指 `insurAmount`/`listPremiumAmount`） | 部分确认（已定位候选），待后端 | 后端 |

## 备注
- 需求涉及 3PL 司机对账、运单付款、运单结算处理三个模块
- 代码分析已收窄不确定项（字段名基本定位），但字段语义/口径（尤其重复扣减风险）与纯业务口径仍需后端/产品确认后方可进入阶段2
- 代码分析产物：.md/temp/代码分析-C161线上问题.md
