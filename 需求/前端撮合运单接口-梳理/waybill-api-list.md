# 运单相关接口梳理

> 颜色标注说明：
> - 🟢 **logisticsweb 使用**
> - 🔴 **logisticsweb 未使用**
> - 🟡 **待确认**
>
> ⚠️ **梳理范围**：本次仅覆盖 `logisticsweb`（PC 端）。`wlyd-app-consigner`（托运人小程序/H5）等其他项目对同一批接口的使用情况未在本次范围内，需另行梳理。

---

## lmt-orch-user

| 类型 | URL | 是否使用 | 是否涉及网货运单 | 是否需要调整 | 功能描述 | 页面截图 | 备注 |
|------|-----|---------|----------------|------------|---------|---------|------|
| | /lmt-user/waybill/place-order | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/confirm-receipt | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/cancel | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/pay | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/pay-modify | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/eval | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/addEval | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/page-query | 🔴 未使用 | | | | | |
| 查询 | /lmt-user/waybill/query-document-rel | 🟢 使用 | | | 根据运单号查询关联的撮合订单id（父级订单id） | | `userBase.waybillSettlement.js` → `getCHOrderIdByWaybillId`，由 `utils/gotoWaybillDetail.js` 工具函数调用，用于运单结算处理页跳转撮合订单 |
| | /lmt-user/waybill/detail | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/tracking | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/modify-load-unload-info | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/page-query-by-order-cascade | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/page-query-by-goods-cascade | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/page-query-by-goods-ids | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/freight-flow | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/freight-record | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/operate-record-page | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/page-query-downstream-sync | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/page-query-downstream | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/detail-downstream-sync | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/get-downstream-sync-waybill-fields | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/query-downstream-sync-waybill-fields | 🔴 未使用 | | | | | |
| | /lmt-user/waybill/reset-upstream-customer-query-to-default | 🔴 未使用 | | | | | |
| | /lmt-user/waybill-track/query-waybill-real-time-location | 🔴 未使用 | | | | | |
| | /lmt-user/waybill-track/query-waybill-real-time-track | 🔴 未使用 | | | | | |
| 查询 | /lmt-user/waybill-track/query-waybill-his-track | 🟢 使用 | | | 查询司机历史轨迹 | | `userBase.transport.js` → `gpsDriverTrackList`，用于运输在途/轨迹回放页 |
| | /lmt-user/waybill-track/query-waybill-his-track-detail | 🔴 未使用 | | | | | |
| | /lmt-user/waybill-statistical/vehicle-operation-report | 🔴 未使用 | | | | | |
| | /lmt-user/waybill-statistical/org-operation-report | 🔴 未使用 | | | | | |
| 查询 | /lmt-user/waybill-summary/network-main-body-page | 🟢 使用 | | | 网货主体运单分页查询 | | `networkFreightWaybill.js` → `waybillSummaryNetworkMainBodyPage`，用于网货主体运单页 |
| 查询 | /lmt-user/waybill-fence-info/query-by-waybill | 🟢 使用 | | | 查询运单围栏信息 | | `userBase.transport.js` → `queryByWaybill`，用于运单详情页围栏展示 |
| | /lmt-user/bill/waybill-fee-detl/trial-calc | 🔴 未使用 | | | | | |
| | /lmt-user/bill/waybill-fee-detl/batch-recalc | 🔴 未使用 | | | | | |
| 查询 | /lmt-user/sett/bms-waybill-pool-query/list-waybill-pool-and-tms-waybill | 🟢 使用 | | | 运单数据汇总列表查询（结算池+TMS运单） | | `userBase.waybillSettlement.js` → `loadWaybillDataSummaryList`，用于运单数据汇总页 |

---

## lmt-orch-dispatcher

| 类型 | URL | 是否使用 | 是否涉及网货运单 | 是否需要调整 | 功能描述 | 页面截图 | 备注 |
|------|-----|---------|----------------|------------|---------|---------|------|
| | /lmt-dispatcher/waybill/page-query | 🔴 未使用（易达宝PC） | | | | | |
| | /lmt-dispatcher/waybill/detail | 🔴 未使用（易达宝PC） | | | | | |
| | /lmt-dispatcher/waybill/tracking | 🔴 未使用（易达宝PC） | | | | | |
| | /lmt-dispatcher/waybill/eval | 🔴 未使用（易达宝PC） | | | | | |
| | /lmt-dispatcher/waybill/addEval | 🔴 未使用（易达宝PC） | | | | | |
| | /lmt-dispatcher/waybill/status-statistics | 🔴 未使用（易达宝APP&小程序） | | | | | |
| | /lmt-dispatcher/waybill/performance-statistics | 🔴 未使用（易达宝PC） | | | | | |
| | /lmt-dispatcher/waybill-track/query-waybill-real-time-location | 🔴 未使用（易达宝PC） | | | | | |
| | /lmt-dispatcher/waybill-track/query-waybill-his-track-detail | 🔴 未使用（易达宝PC） | | | | | |
| | /lmt-dispatcher/waybill-track/query-waybill-real-time-track | 🔴 未使用 | | | | | |

---

## lmt-orch-shipper

| 类型 | URL | 是否使用 | 是否涉及网货运单 | 是否需要调整 | 功能描述 | 页面截图 | 备注 |
|------|-----|---------|----------------|------------|---------|---------|------|
| 查询 | /lmt-shipper/waybill/page-query | 🔴 未使用 | | | | | |
| 查询 | /lmt-shipper/waybill/detail | 🔴 未使用 | | | | | |
| 查询 | /lmt-shipper/waybill/tracking | 🔴 未使用 | | | | | |
| 操作 | /lmt-shipper/waybill/modify-load-unload-info | 🔴 未使用（易达宝PC/APP&小程序） | | | | | |
| 操作 | /lmt-shipper/waybill/place-order | 🔴 未使用（易达宝PC/APP&小程序） | | | | | |
| 操作 | /lmt-shipper/waybill/confirm-receipt | 🔴 未使用（易达宝PC/APP&小程序） | | | | | |
| 操作 | /lmt-shipper/waybill/cancel | 🔴 未使用（易达宝PC/APP&小程序） | | | | | |
| 操作 | /lmt-shipper/waybill/pay | 🔴 未使用（易达宝PC/APP&小程序） | | | | | |
| 操作 | /lmt-shipper/waybill/pay-modify | 🔴 未使用（易达宝PC/APP&小程序） | | | | | |
| 操作 | /lmt-shipper/waybill/eval | 🔴 未使用 | | | | | |
| 操作 | /lmt-shipper/waybill/addEval | 🔴 未使用 | | | | | |
| | /lmt-shipper/waybill/statistics | 🔴 未使用 | | | | | |
| | /lmt-shipper/waybill/status-statistics | 🔴 未使用 | | | | | |
| | /lmt-shipper/waybill/freight-flow | 🔴 未使用 | | | | | |
| | /lmt-shipper/waybill/freight-record | 🔴 未使用 | | | | | |
| | /lmt-shipper/waybill/page-query-by-order-cascade | 🔴 未使用 | | | | | |
| | /lmt-shipper/waybill-track/query-waybill-real-time-location | 🔴 未使用 | | | | | |
| | /lmt-shipper/waybill-track/query-waybill-real-time-track | 🔴 未使用 | | | | | |
| | /lmt-shipper/waybill-track/query-waybill-his-track-detail | 🔴 未使用 | | | | | |

---

## lmt-orch-driver

| 类型 | URL | 是否使用 | 是否涉及网货运单 | 是否需要调整 | 功能描述 | 页面截图 | 备注 |
|------|-----|---------|----------------|------------|---------|---------|------|
| 操作 | /lmt-driver/waybill/create | 🔴 未使用（易达宝PC/APP&小程序） | | | | | |
| 操作 | /lmt-driver/waybill/fulfillment | 🔴 未使用（易达宝PC/APP&小程序） | | | | | |
| 操作 | /lmt-driver/waybill/pay-info-fee | 🔴 未使用（易达宝PC） | | | | | |
| 操作 | /lmt-driver/waybill/pay-confirm | 🔴 未使用（易达宝PC/APP&小程序） | | | | | |
| 操作 | /lmt-driver/waybill/pay-modify-confirm | 🔴 未使用（易达宝PC/APP&小程序） | | | | | |
| 操作 | /lmt-driver/waybill/bank-card-upd | 🔴 未使用 | | | | | |
| 操作 | /lmt-driver/waybill/cancel-confirm | 🔴 未使用 | | | | | |
| 操作 | /lmt-driver/waybill/modify-load-unload-info | 🔴 未使用 | | | | | |
| 操作 | /lmt-driver/waybill/eval | 🔴 未使用 | | | | | |
| 操作 | /lmt-driver/waybill/addEval | 🔴 未使用 | | | | | |
| 查询 | /lmt-driver/waybill/page-query | 🔴 未使用 | | | | | |
| 查询 | /lmt-driver/waybill/detail | 🔴 未使用 | | | | | |
| 查询 | /lmt-driver/waybill/tracking | 🔴 未使用 | | | | | |
| 查询 | /lmt-driver/waybill/query-checkin-record | 🔴 未使用 | | | | | |
| | /lmt-driver/waybill/precision-load-unload | 🔴 未使用 | | | | | |
| | /lmt-driver/waybill/find-waybill-attachment | 🔴 未使用 | | | | | |
| | /lmt-driver/waybill/operate-record-list | 🔴 未使用 | | | | | |
| | /lmt-driver/waybill/query-status | 🔴 未使用 | | | | | |
| 查询 | /lmt-driver/waybill/appoint-user-list | 🔴 未使用 | | | | | |
| | /lmt-driver/waybill/check-driver-latest-waybill-timeout | 🔴 未使用 | | | | | |

---

## lgi-orch-waybill

| 类型 | URL | 是否使用 | 是否涉及网货运单 | 是否需要调整 | 功能描述 | 页面截图 | 备注 |
|------|-----|---------|----------------|------------|---------|---------|------|
| | /lgi-waybill/driver/waybill-query/page-query | 🔴 未使用 | | | | | |
| | /lgi-waybill/driver/waybill-query/waybill-count | 🔴 未使用 | | | | | |
| | /lgi-waybill/lwc-company-checkin-config/save | 🔴 未使用 | | | | | |
| | /lgi-waybill/lwc-company-checkin-config/update-by-id | 🔴 未使用 | | | | | |
| | /lgi-waybill/lwc-company-checkin-config/get-by-company-id | 🔴 未使用 | | | | | |
| | /lgi-waybill/party3-rwaybill/page-query-platform | 🔴 未使用 | | | | | |
| | /lgi-waybill/party3-rwaybill/page-query-user | 🔴 未使用 | | | | | |
| | /lgi-waybill/party3-rwaybill/detail | 🔴 未使用 | | | | | |
| | /lgi-waybill/rwaybill/page-query-platform | 🔴 未使用 | | | | | |
| | /lgi-waybill/rwaybill/page-query-user | 🔴 未使用 | | | | | |
| | /lgi-waybill/rwaybill/page-query-by-order-cascade-code | 🔴 未使用 | | | | | |
| | /lgi-waybill/rwaybill/detail | 🔴 未使用 | | | | | |
| | /lgi-waybill/rwaybill/create | 🔴 未使用 | | | | | |
| | /lgi-waybill/rwaybill/track | 🔴 未使用 | | | | | |
| | /lgi-waybill/rwaybill/batchunbind | 🔴 未使用 | | | | | |
| | /lgi-waybill/shipper/waybill-query/page-query-downstream | 🔴 未使用 | | | | | |
| | /lgi-waybill/shipper/waybill-query/page-query | 🔴 未使用 | | | | | |
| | /lgi-waybill/tms-config/get-by-config-key | 🔴 未使用 | | | | | |
| | /lgi-waybill/tms-config/insert | 🔴 未使用 | | | | | |
| | /lgi-waybill/tms-config/update | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-attachment-query/find-attachment-by-waybill-id-status | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-check/checkin | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-check/get-by-waybill-and-type | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-create/common-create | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-delete/delete | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-fee/infofee | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-fee/recalculate-fee | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-modify/tms-modify | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-modify/modify-waybill-alias | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-opt/batch-confirm-receipt | 🔴 未使用 | | | | | |
| | /lgi-waybill/tmslog/save | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-query/page-query-by-waybill-id-fuzzy | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-query/tms-waybill-detail | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-query/page-query-by-goods-id | 🔴 未使用 | | | | | |
| 查询 | /lgi-waybill/waybill-query/tms-waybill-bizext | 🟢 使用 | | | 查询TMS运单扩展业务信息（车货照/水印配置） | | `userBase.orderSendOrderManagement.js` → `getTmsWaybillBizext`，由 `components/TransportationManagement/HighwayWriteMessageDriver.vue` 调用，用于派车录入司机信息时查询水印配置 |
| | /lgi-waybill/waybill-receipt/page-query | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-receipt/operate | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-receipt/list-status-by-receipt-id | 🔴 未使用 | | | | | |
| | /lgi-waybill/waybill-statistical/vehicle-operation-report | 🔴 未使用 | | | | | |

---

## lgi-orch-wbquery

| 类型 | URL | 是否使用 | 是否涉及网货运单 | 是否需要调整 | 功能描述 | 页面截图 | 备注 |
|------|-----|---------|----------------|------------|---------|---------|------|
| | /lgi-wbquery/waybill-query/page-query-by-waybill-id-fuzzy | 🔴 未使用 | | | | | |
| | /lgi-wbquery/waybill-query/tms-waybill-detail | 🔴 未使用 | | | | | |
| | /lgi-wbquery/waybill-query/get-waybill-status-single | 🔴 未使用 | | | | | |
| | /lgi-wbquery/waybill-query/find-accept-waybill-by-goods-id | 🔴 未使用 | | | | | |
| | /lgi-wbquery/waybill-query/waybill-summary | 🔴 未使用 | | | | | |
| | /lgi-wbquery/waybill-query/find-waybill-by-order-id | 🔴 未使用 | | | | | |
| | /lgi-wbquery/waybill-query/find-status-list-by-waybill-id | 🔴 未使用 | | | | | |
| | /lgi-wbquery/waybill-query/get-waybill-trace-deviation | 🔴 未使用 | | | | | |
| | /lgi-wbquery/waybill-query/app-waybill-address | 🔴 未使用 | | | | | |
| | /lgi-wbquery/waybill-query/waybill-track-pay | 🔴 未使用 | | | | | |
| | /lgi-wbquery/waybill-query/count-missing-collection-proof | 🔴 未使用 | | | | | |
| 查询 | /lgi-wbquery/waybill-attachment-query/find-attachment-by-waybill-id-status | 🟢 使用 | | | 按运单号+状态+附件类型查询磅单附件列表 | | `userBase.transport.js` → `fetchWeighBillImages`，由 `waybillSettlement/components/WeighBillCarousel.vue` 调用，被 `SettlementInfo.vue` 引用，用于运单结算处理页磅单图片展示 |
| | /lgi-wbquery/shipper/waybill-query/page-query | 🔴 未使用 | | | | | |
| | /lgi-wbquery/shipper/waybill-query/page-query-downstream | 🔴 未使用 | | | | | |
| 查询 | /lgi-wbquery/shipper/waybill-query/page-query-shipper-net-waybill | 🟢 使用 | | | 托运人端网货运单分页查询 | | `userBase.transport.js` → `pageQueryShipperNetWaybill`，用于托运人运单查看页 |
| | /lgi-wbquery/shipper/waybill-query/detail-downstream-sync | 🔴 未使用 | | | | | |
| 查询 | /lgi-wbquery/shipper/waybill-query/waybill-load-unload | 🟢 使用 | | | 查询运单装卸点信息 | | `userBase.transport.js` → `getWaybillLoadUnload`，用于运单详情装卸货信息展示 |
| | /lgi-wbquery/shipper/waybill-query/waybill-weight-info-query | 🔴 未使用 | | | | | |
| | /lgi-wbquery/shipper/waybill-query/waybill-status-query | 🔴 未使用 | | | | | |
| | /lgi-wbquery/platform/waybill-query/page-query | 🔴 未使用 | | | | | |
| 查询 | /lgi-wbquery/tms-waybill/page-query | 🟢 使用 | | | TMS运单分页查询 | | `userBase.transport.js` → `getTransportSendListV2`，用于公路运单管理列表；⚠️ 与旧版接口（`tmsUrl + /tmsWaybill/tmsWaybillPaging`）并存，通过 `useLgiWbQueryPageApi` 开关切换 |
| | /lgi-wbquery/water-tran/waybill/page-query | 🔴 未使用 | | | | | |
| | /lgi-wbquery/water-tran/waybill/detail | 🔴 未使用 | | | | | |
| | /lgi-wbquery/water-tran/waybill/tracking | 🔴 未使用 | | | | | |
| | /lgi-wbquery/water-tran/shipper/waybill/page-query | 🔴 未使用 | | | | | |
| | /lgi-wbquery/water-tran/platform/waybill/page-query | 🔴 未使用 | | | | | |
| | /lgi-wbquery/water-tran/platform/waybill/detail | 🔴 未使用 | | | | | |
| | /lgi-wbquery/water-tran/platform/waybill/page-query-by-goods | 🔴 未使用 | | | | | |
| | /lgi-wbquery/water-tran/waybill/page-query-by-goods-parent-id | 🔴 未使用 | | | | | |
| | /lgi-wbquery/waybill-fee/infofee | 🔴 未使用 | | | | | |
| | /lgi-wbquery/waybill-statistical/vehicle-operation-report | 🔴 未使用 | | | | | |
| | /lgi-wbquery/waybill-statistical/org-operation-report | 🔴 未使用 | | | | | |
| 查询 | /lgi-wbquery/waybill-summary/business-belong-page | 🟢 使用 | | | 业务归属运单分页查询 | | `businessOwnershipWaybill.js` → `lgi_wbquery_API + '/waybill-summary/business-belong-page'`，用于业务归属运单页 |
| | /lgi-wbquery/waybill-summary/network-main-body-page | 🔴 未使用 | | | | | |
| | /lgi-wbquery/financial-management/customer-summary | 🔴 未使用 | | | | | |

---

**文档版本**: v1.5
**最后更新**: 2026年07月
**整理人**: 王新骏
