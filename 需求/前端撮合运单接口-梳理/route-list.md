# 页面路由梳理（funcName / actionName / url）

> 共 333 条（以完整三元组去重，保留所有 actionName 变体）

> 备注说明：
> - ⚠️ 标记：同一 url 被多个 actionName 指向（多路由复用同一文件）
> - 🔀 标记：同一 actionName 指向不同 url（配置异常，需关注）

| funcName | actionName | url（文件目录）| 备注 |
|----------|------------|-------------|------|
| 维修保养 | userBase/VehicleMaintenance | /views/userBase/VehicleMaintenance |  |
| 车辆维修保养详情页 | userBase/VehicleMaintenance/:type/:id | /views/userBase/VehicleMaintenance/edit | ⚠️ 多路由复用 |
| 查看详情按钮 | userBase/VehicleMaintenance/:type/:id | /views/userBase/VehicleMaintenance/edit | ⚠️ 多路由复用 |
| 运单数据汇总旧 | userBase/WaybillData | /views/userBase/WaybillData/index |  |
| 运单数据汇总 | userBase/WaybillDataNew | /views/userBase/WaybillDataNew/index |  |
| 常用地址 | userBase/address | /views/userBase/address |  |
| 常用地址 | userBase/addressMerge | /views/userBase/addressMerge |  |
| 协议规则 | userBase/agreementRules | /views/userBase/agreementRules |  |
| 违规报警管理 | userBase/alarmManagement | /views/userBase/alarmManagement |  |
| 违规报警管理详情页面 | userBase/alarmManagement/:id | /views/userBase/alarmManagement/detail |  |
| 年检年审 | userBase/annualinspection | /views/userBase/annualinspection |  |
| 车辆年检年审详情页 | userBase/annualinspection/:type/:id | /views/userBase/annualinspection/annualinspection | ⚠️ 多路由复用 |
| 查看详情按钮 | userBase/annualinspection/:type/:id | /views/userBase/annualinspection/annualinspection | ⚠️ 多路由复用 |
| 装卸货打卡异常 | userBase/anomalyStatistics | /views/userBase/anomalyStatistics |  |
| 承运人申请开票 | userBase/applyForInvoice/edit | /views/userBase/applyForInvoice/edit |  |
| 查看承运人申请开票 | userBase/applyForInvoice/view | /views/userBase/applyForInvoice/view |  |
| 申请开票 | userBase/applyForInvoiceMerge | /views/userBase/applyForInvoiceMerge |  |
| 基本信息 | userBase/baseInfo | /views/userBase/baseInfo | ⚠️ 多路由复用 |
| 公路运输服务申请按钮 | userBase/baseInfo | /views/userBase/baseInfo | ⚠️ 多路由复用 |
| 批量转移 | userBase/batchTransferSettlement | /views/userBase/batchTransferSettlement |  |
| 开票记录 | userBase/billingRecord | /views/userBase/billingRecord |  |
| 开票详情页 | userBase/billingRecord/edit | /views/userBase/billingRecord/view | ⚠️ 多路由复用 |
| 查看开票详情页 | userBase/billingRecord/view | /views/userBase/billingRecord/view | ⚠️ 多路由复用 |
| 代收人黑名单 | userBase/blackList/company | /views/userBase/blackListManage/company/index |  |
| 代收人黑名单(网货) | userBase/blackList/network | /views/userBase/blackListManage/network/index |  |
| 业务归属运单 | userBase/businessOwnershipWaybill | /views/userBase/businessOwnershipWaybill/index |  |
| 司机绑车绑卡 | userBase/carBank/index | /views/userBase/carBank/index |  |
| 车主管理详情页 | userBase/carOwnerManager/:id | /views/userBase/carOwnerManager/detail.vue |  |
| 车主管理 | userBase/carOwnerManager | /views/userBase/carOwnerManager/index.vue |  |
| 承运人开票历史 | userBase/carrierBillingHistory/view | /views/userBase/carrierBillingHistory/view |  |
| 申请付款 | userBase/carrierPayment/edit | /views/userBase/carrierPayment/edit | ⚠️ 多路由复用 |
| 申请付款 | userBase/freightMerge/carrierPayment/edit | /views/userBase/carrierPayment/edit | ⚠️ 多路由复用 |
| 委托转账明细管理 | userBase/carrierPayment/manage | /views/userBase/carrierPayment/manage | 🔀 actionName 指向多 url |
| 委托转账明细管理 | userBase/carrierPayment/manage | /views/userBase/carrierPayment/manage.vue | 🔀 actionName 指向多 url |
| 查看付款申请 | userBase/carrierPayment/view | /views/userBase/carrierPayment/view | ⚠️ 多路由复用 |
| 查看付款申请 | userBase/freightMerge/carrierPayment/view | /views/userBase/carrierPayment/view | ⚠️ 多路由复用 |
| 承运人付款审核 | userBase/carrierPaymentAudit | /views/userBase/carrierPaymentAudit |  |
| 承运人付款审核-归档 | userBase/carrierPaymentAudit/carrierPaymentAuditMigrate | /views/userBase/carrierPaymentAudit/carrierPaymentAuditMigrate |  |
| 审核 | userBase/carrierPaymentAudit/examine | /views/userBase/carrierPaymentAudit/examine |  |
| 查看 | userBase/carrierPaymentAudit/view | /views/userBase/carrierPaymentAudit/view |  |
| 车辆管理详情页(车辆) | userBase/carsmanagement/:action/:id | /views/userBase/carsmanagement/edit | ⚠️ 多路由复用 |
| 查看车辆详情按钮(车辆) | userBase/carsmanagement/:action/:id | /views/userBase/carsmanagement/edit | ⚠️ 多路由复用 |
| 车辆管理 | userBase/carsmanagement | /views/userBase/carsmanagement/index |  |
| 收票申请 | userBase/collectTicket | /views/userBase/collectTicket |  |
| 新增收票申请 | userBase/collectTicket/edit | /views/userBase/collectTicket/edit | ⚠️ 多路由复用 |
| 收票申请详情页 | userBase/collectTicket/view | /views/userBase/collectTicket/edit | ⚠️ 多路由复用 |
| 预警线路 | userBase/commonlinesAddress | /views/userBase/commonlines/crmcompanyline |  |
| 常用线路 | userBase/commonlines | /views/userBase/commonlines/crmcompanylineaddress |  |
| 投诉建议 | userBase/complaintConsultation | /views/userBase/complaintConsultation |  |
| 新增按钮 | userBase/complaintConsultation/edit | /views/userBase/complaintConsultation/edit | ⚠️ 多路由复用 |
| 新增投诉建议页 | userBase/complaintConsultation/edit | /views/userBase/complaintConsultation/edit | ⚠️ 多路由复用 |
| 查看按钮 | userBase/complaintConsultation/view | /views/userBase/complaintConsultation/view | ⚠️ 多路由复用 |
| 查看投诉建议页 | userBase/complaintConsultation/view | /views/userBase/complaintConsultation/view | ⚠️ 多路由复用 |
| 费用项管理 | userBase/constManagement | /views/userBase/constManagement |  |
| 业务费用录入 | userBase/constRecord | /views/userBase/constRecord |  |
| 业务费用详情页 | userBase/constRecord/:action/:id | /views/userBase/constRecord/add | ⚠️ 多路由复用 |
| 查看业务费用详情按钮 | userBase/constRecord/:action/:id | /views/userBase/constRecord/add | ⚠️ 多路由复用 |
| 合同穿透 | userBase/contractAdministration | /views/userBase/contractAdministration/index |  |
| 合同台账 | userBase/contractLedger | /views/userBase/contractLedger/index |  |
| 查看合同按钮 | userBase/contractManagement/:action/:id | /views/userBase/contractManagement/add |  |
| ETC发票 | userBase/credentials | /views/userBase/credentials/index |  |
| 查看用信申请 | userBase/freightMerge/creditAuth/detail | /views/userBase/creditAuth/detail |  |
| 客户管理 | userBase/customerManagement | /views/userBase/customerManagement |  |
| 客户管理详情(客户) | userBase/customerManagement/:action/:id | /views/userBase/customerManagement/edit | ⚠️ 多路由复用 |
| 查看详情按钮(客户) | userBase/customerManagement/:action/:id | /views/userBase/customerManagement/edit | ⚠️ 多路由复用 |
| 客商管理 | userBase/customerManagementMerge | /views/userBase/customerManagementMerge |  |
| 客户对账 | userBase/customerReconciliation | /views/userBase/customerReconciliation |  |
| 客户对账详情页 | userBase/customerReconciliation/:action/:id | /views/userBase/customerReconciliation/edit | ⚠️ 多路由复用 |
| 查看客户对账详情按钮 | userBase/customerReconciliation/:action/:id | /views/userBase/customerReconciliation/edit | ⚠️ 多路由复用 |
| 客户月结账单 | userBase/customerSettlement | /views/userBase/customerSettlement |  |
| 对账审核页 | userBase/customerSettlement/checkCustomer | /views/userBase/customerSettlement/checkCustomer |  |
| 明细单核对页 | userBase/customerSettlement/examineCustomer | /views/userBase/customerSettlement/examineCustomer |  |
| 账单详情页 | userBase/customerSettlement/lookUpcustomer | /views/userBase/customerSettlement/lookUpcustomer |  |
| 优惠券 | userBase/discountCoupon | /views/userBase/discountCoupon |  |
| 司机账户预警 | userBase/driverAccountWarning | /views/userBase/driverAccountWarning |  |
| 月收入详情 | userBase/driverAccountWarning/view | /views/userBase/driverAccountWarning/view |  |
| 查看排名 | userBase/driverAccountWarning/viewRanking | /views/userBase/driverAccountWarning/viewRanking |  |
| 批量导入司机管理详情页 | userBase/driverCarsImport/driver/:type/:id | /views/userBase/driverCarsImport/driverDetail |  |
| 司机对账 | userBase/driverChecking | /views/userBase/driverChecking |  |
| 司机对账详情页 | userBase/driverChecking/:action/:id | /views/userBase/driverChecking/add | ⚠️ 多路由复用 |
| 查看司机对账详情按钮 | userBase/driverChecking/:action/:id | /views/userBase/driverChecking/add | ⚠️ 多路由复用 |
| 司机对账账单页 | userBase/driverCheckingBill | /views/userBase/driverChecking/bill |  |
| 司机管理详情页 | userBase/driverManager/:id | /views/userBase/driverManager/detail.vue |  |
| 司机管理 | userBase/driverManager | /views/userBase/driverManager/index.vue |  |
| 司机货源 | userBase/driverSupplymanagement | /views/userBase/driverSupplymanagement |  |
| 详情 | userBase/detail/:id | /views/userBase/driverSupplymanagement/details | ⚠️ 多路由复用 |
| 详情 | userBase/goodsOnlineDetail/:id | /views/userBase/driverSupplymanagement/details | ⚠️ 多路由复用 |
| 撮合详情 | userBase/matchDetail/:id | /views/userBase/driverSupplymanagement/details | ⚠️ 多路由复用 |
| 货源详情页 | userBase/shipSupplyDriverDetail/:id | /views/userBase/driverSupplymanagement/details | ⚠️ 多路由复用 |
| 发布货源 | userBase/shipSupplyForm | /views/userBase/driverSupplymanagement/publish/index |  |
| 司机管理 | userBase/drivermanagement | /views/userBase/drivermanagement |  |
| 司机管理详情页(司机) | userBase/drivermanagement/:type/:id | /views/userBase/drivermanagement/addDriver | ⚠️ 多路由复用 |
| 查看司机详情按钮(司机) | userBase/drivermanagement/:type/:id | /views/userBase/drivermanagement/addDriver | ⚠️ 多路由复用 |
| 能源订单详情 | userBase/energyOrderManagementDetail/:id | /views/userBase/energyOrderManagement/detail |  |
| 能源订单管理 | userBase/energyOrderManagement | /views/userBase/energyOrderManagement/index |  |
| 设备管理 | userBase/equipmentManagement/index | /views/userBase/equipmentManagement/index |  |
| 设备管理 | /userBase/equipmentManagement/index | /views/userBase/equipmentManagement/index.vue |  |
| 申请付款 | userBase/freight/edit | /views/userBase/freight/edit |  |
| 查看付款申请 | userBase/freight/view | /views/userBase/freight/view |  |
| 开票审核 | userBase/freightInvoiceAuditBodyNetwork | /views/userBase/freightInvoiceAuditBodyNetwork |  |
| 开票和邮寄 | userBase/freightInvoiceAuditBodyNetwork/invoicingAndMailing | /views/userBase/freightInvoiceAuditBodyNetwork/invoicingAndMailing |  |
| 审核 | userBase/freightInvoiceAuditBodyNetwork/review | /views/userBase/freightInvoiceAuditBodyNetwork/review |  |
| 修改 | userBase/freightInvoiceAuditBodyNetwork/revise | /views/userBase/freightInvoiceAuditBodyNetwork/revise |  |
| 查看 | userBase/freightInvoiceAuditBodyNetwork/view | /views/userBase/freightInvoiceAuditBodyNetwork/view |  |
| 运单付款 | userBase/freightMerge | /views/userBase/freightMerge |  |
| 运单付款-归档 | userBase/migrate | /views/userBase/freightMerge/migrate |  |
| 申请付款 | userBase/freightMerge/freightNew/edit | /views/userBase/freightNew/edit | ⚠️ 多路由复用 |
| 申请付款 | userBase/freightNew/edit | /views/userBase/freightNew/edit | ⚠️ 多路由复用 |
| 查看付款申请 | userBase/freightMerge/freightNew/view | /views/userBase/freightNew/view | ⚠️ 多路由复用 |
| 查看付款申请 | userBase/freightNew/view | /views/userBase/freightNew/view | ⚠️ 多路由复用 |
| 新增 | userBase/goodsManagement/add | /views/userBase/goodsManagement/add |  |
| 常用货品 | userBase/goodsManagement | /views/userBase/goodsManagement/index |  |
| 网货管理 | userBase/goodsOnlineManagement | /views/userBase/goodsOnlineManagement |  |
| 发布货源 | userBase/goodsOnlineManagement/publish | /views/userBase/goodsOnlineManagement/publish |  |
| 货品同步 | userBase/goodsSynchronous | /views/userBase/goodsSynchronous/index |  |
| 线路预警 | userBase/gpsWarning | /views/userBase/gpsWarning/index |  |
| 公路订单 | userBase/highwayOrderManagement | /views/userBase/highwayOrderManagement |  |
| 公路订单详情页 | userBase/highwayOrderManagement/edit/:id | /views/userBase/highwayOrderManagement/edit |  |
| 物流合作协议 | userBase/logisticsCollaborationDoc | /views/userBase/logisticsCollaborationDoc |  |
| 物流计划单 | userBase/logisticsPlan | /views/userBase/logisticsPlan |  |
| 现金申请管理 | userBase/mainstay/application/cashList | /views/userBase/mainstay/application/cashList |  |
| 测试四级 | userBase/mainstay/application/creditList | /views/userBase/mainstay/application/creditList | ⚠️ 多路由复用 |
| 授信申请管理 | userBase/mainstay/application/creditList | /views/userBase/mainstay/application/creditList | ⚠️ 多路由复用 |
| 测试三级 | userBase/mainstay/application/creditList11 | /views/userBase/mainstay/application/creditList | ⚠️ 多路由复用 |
| 测试三级 | userBase/mainstay/application/creditList333 | /views/userBase/mainstay/application/creditList | ⚠️ 多路由复用 |
| 测试5 | userBase/mainstay/application/creditList444 | /views/userBase/mainstay/application/creditList | ⚠️ 多路由复用 |
| 交易申请管理 | userBase/mainstay/application/transactionList | /views/userBase/mainstay/application/transactionList |  |
| 现金申请审核 | userBase/mainstay/examine/cashList | /views/userBase/mainstay/examine/cashList |  |
| 授信申请审核 | userBase/mainstay/examine/creditList | /views/userBase/mainstay/examine/creditList |  |
| 3PL冻结详情 | userBase/mainstay/freeze/3pl | /views/userBase/mainstay/freeze/3pl |  |
| 绑卡 | userBase/mainstay/freeze/bindCard | /views/userBase/mainstay/freeze/bindCard |  |
| 货运主体冻结详情 | userBase/mainstay/freeze/mainstay | /views/userBase/mainstay/freeze/mainstay |  |
| 查看冻结运单 | userBase/mainstay/freeze/waybill | /views/userBase/mainstay/freeze/waybill |  |
| 申请审核 | userBase/mainstay/organization/application | /views/userBase/mainstay/organization/application |  |
| 组织机构 | userBase/mainstay/organization/manager | /views/userBase/mainstay/organization/manager |  |
| 账户流水 | userBase/mainstay/3pl/turnover | /views/userBase/mainstay/turnover/3pl |  |
| 授信打款流水 | userBase/mainstay/examine/creditTurnover | /views/userBase/mainstay/turnover/credit |  |
| 账户流水 | userBase/mainstay/mainstay/turnover | /views/userBase/mainstay/turnover/mainstay |  |
| 我的钱包 | userBase/mainstay/mainstay/wallet | /views/userBase/mainstay/wallet/mainstay |  |
| 我的钱包 | userBase/mainstay/3pl/wallet | /views/userBase/mainstay/wallet/mine |  |
| 我的银行卡 | userBase/mainstay/3pl/wallet/myBankCard | /views/userBase/mainstay/wallet/myBankCard | ⚠️ 多路由复用 |
| 我的银行卡 | userBase/mainstay/mainstay/wallet/myBankCard | /views/userBase/mainstay/wallet/myBankCard | ⚠️ 多路由复用 |
| 我的银行卡详情 | userBase/mainstay/3pl/wallet/myBankCardDetail | /views/userBase/mainstay/wallet/myBankCardDetail | ⚠️ 多路由复用 |
| 我的银行卡详情 | userBase/mainstay/mainstay/wallet/myBankCardDetail | /views/userBase/mainstay/wallet/myBankCardDetail | ⚠️ 多路由复用 |
| 撮合管理 | userBase/matchmanagement | /views/userBase/matchManagement |  |
| 撮合发布 | userBase/shipSupplyMatchForm | /views/userBase/matchManagement/publish/index |  |
| 修改密码 | userBase/modifypwd | /views/userBase/modifypwd |  |
| 网货主体运单 | userBase/networkFreightWaybill | /views/userBase/networkFreightWaybill/index |  |
| 发票记录 | userBase/newBillingHistory | /views/userBase/newBillingHistory |  |
| 开票历史新 | userBase/newCarrierBillingHistory | /views/userBase/newCarrierBillingHistory |  |
| 查看详情 | userBase/newCarrierBillingHistory/view | /views/userBase/newCarrierBillingHistory/view |  |
| 收款管理-ToB | userBase/newReceivablesTob | /views/userBase/newReceivablesTob |  |
| 我的消息 | userBase/news | /views/userBase/news |  |
| 油气发票管理 | userBase/oilGasInvoiceManagement | /views/userBase/oilGasInvoiceManagement/index |  |
| 油气清单管理 | userBase/oilGasListManagement | /views/userBase/oilGasListManagement/index |  |
| 编辑清单按钮 | userBase/oilGasListManagement/view | /views/userBase/oilGasListManagement/view | ⚠️ 多路由复用 |
| 查看按钮 | userBase/oilGasListManagement/view | /views/userBase/oilGasListManagement/view | ⚠️ 多路由复用 |
| 生成清单页面 | userBase/oilGasListManagement/view | /views/userBase/oilGasListManagement/view | ⚠️ 多路由复用 |
| 油气提现 | userBase/basics/oilGasWithdraw | /views/userBase/oilGasWithdraw |  |
| 油气提现记录 | userBase/basics/oilGasWithdrawRecord | /views/userBase/oilGasWithdrawRecord |  |
| 订单变更 | userBase/orderSendOrderChangeManagement | /views/userBase/orderSendOrderChangeManagement |  |
| 订单管理 | userBase/orderSendOrderManagement | /views/userBase/orderSendOrderManagement |  |
| 订单详情页 | userBase/orderSendOrderManagement/:action/:id | /views/userBase/orderSendOrderManagement/orderSendOrderManagementRead | ⚠️ 多路由复用 |
| 订单详情页(测试使用) | userBase/orderSendOrderManagement/:action/:id | /views/userBase/orderSendOrderManagement/orderSendOrderManagementRead | ⚠️ 多路由复用 |
| 查看订单详情按钮 | userBase/orderSendOrderManagement/:action/:id | /views/userBase/orderSendOrderManagement/orderSendOrderManagementRead | ⚠️ 多路由复用 |
| 查看订单详情按钮(测试使用) | userBase/orderSendOrderManagement/:action/:id | /views/userBase/orderSendOrderManagement/orderSendOrderManagementRead | ⚠️ 多路由复用 |
| 订单结算处理 | userBase/orderSettlement | /views/userBase/orderSettlement |  |
| 订单变更 | userBase/orderTransportOrderChangeManagement | /views/userBase/orderTransportOrderChangeManagement |  |
| 订单管理 | userBase/orderTransportOrderManagement | /views/userBase/orderTransportOrderManagement |  |
| 手工新增订单页 | userBase/orderTransportOrderManagement/addnew | /views/userBase/orderTransportOrderManagement/orderAdd | ⚠️ 多路由复用 |
| 手工新增订单页(测试使用) | userBase/orderTransportOrderManagement/addnew | /views/userBase/orderTransportOrderManagement/orderAdd | ⚠️ 多路由复用 |
| 订单详情页 | userBase/orderTransportOrderManagement/:action/:id | /views/userBase/orderTransportOrderManagement/orderTransportOrderManagementRead | ⚠️ 多路由复用 |
| 查看订单详情按钮 | userBase/orderTransportOrderManagement/:action/:id | /views/userBase/orderTransportOrderManagement/orderTransportOrderManagementRead | ⚠️ 多路由复用 |
| 订单详情页(测试使用) | userBase/orderTransportOrderManagement/:action/:id | /views/userBase/orderTransportOrderManagement/orderTransportOrderManagementRead | ⚠️ 多路由复用 |
| 查看订单详情按钮(测试使用) | userBase/orderTransportOrderManagement/:action/:id | /views/userBase/orderTransportOrderManagement/orderTransportOrderManagementRead | ⚠️ 多路由复用 |
| 订单转交易页 | userBase/orderTransportOrderManagement/publish | /views/userBase/orderTransportOrderManagement/publish | ⚠️ 多路由复用 |
| 订单转交易页(测试使用) | userBase/orderTransportOrderManagement/publish | /views/userBase/orderTransportOrderManagement/publish | ⚠️ 多路由复用 |
| 查看公路订单详情按钮 | userBase/orderTransportOrderManagement/read/:id | /views/userBase/orderTransportOrderManagement/read |  |
| 参数设置 | userBase/paramSet | /views/userBase/paramSet |  |
| 伙伴报价 | userBase/partnerQuote | /views/userBase/partnerQuote |  |
| 付款管理 | userBase/payment | /views/userBase/payment |  |
| 付款管理页 | userBase/payment/administration | /views/userBase/payment/administration |  |
| 查看付款详情页 | userBase/payment/lookUp | /views/userBase/payment/lookUp | ⚠️ 多路由复用 |
| 查看付款详情按钮 | userBase/payment/lookUp | /views/userBase/payment/lookUp | ⚠️ 多路由复用 |
| 付款管理-ToB | userBase/paymentTob | /views/userBase/paymentTob |  |
| 付款管理页 | userBase/paymentTob/administration | /views/userBase/paymentTob/administration |  |
| 查看付款详情页 | userBase/paymentTob/lookUp | /views/userBase/paymentTob/lookUp |  |
| 预审 | userBase/preliminaryReview/edit | /views/userBase/preliminaryReview/edit |  |
| 查看 | userBase/preliminaryReview/view | /views/userBase/preliminaryReview/view |  |
| 预付费及油气管理 | userBase/prepaidOilGasManagement | /views/userBase/prepaidOilGasManagement/index |  |
| 查看运单按钮 | userBase/prepaidOilGasManagement/view | /views/userBase/prepaidOilGasManagement/view |  |
| 货源码管理 | userBase/qRcodeManagement | /views/userBase/qRcodeManagement |  |
| 货源码新增 | userBase/qRcodeManagement/add | /views/userBase/qRcodeManagement/add |  |
| 报价管理 | userBase/quote | /views/userBase/quote |  |
| 下游询价详情页 | userBase/quote/askresult | /views/userBase/quote/askresult | ⚠️ 多路由复用 |
| 查看下游询价按钮 | userBase/quote/askresult | /views/userBase/quote/askresult | ⚠️ 多路由复用 |
| 代报价详情页 | userBase/partnerQuote/details | /views/userBase/quote/detalis | ⚠️ 多路由复用 |
| 报价详情页 | userBase/quote/detalis | /views/userBase/quote/detalis | ⚠️ 多路由复用 |
| 查看报价详情按钮 | userBase/quote/detalis | /views/userBase/quote/detalis | ⚠️ 多路由复用 |
| 铁路订单 | userBase/railwayOrderManagement | /views/userBase/railwayOrderManagement |  |
| 铁路订单详情页 | userBase/railwayOrderManagement/:id | /views/userBase/railwayOrderManagement/edit |  |
| 铁路运单 | userBase/railwayWaybillManagement | /views/userBase/railwayWaybillManagement |  |
| 收款管理 | userBase/receivables | /views/userBase/receivables |  |
| 收款管理详情页 | userBase/receivables/:action/:id | /views/userBase/receivables/edit | ⚠️ 多路由复用 |
| 查看收款详情按钮 | userBase/receivables/:action/:id | /views/userBase/receivables/edit | ⚠️ 多路由复用 |
| 收款管理-ToB（旧） | userBase/receivablesTob | /views/userBase/receivablesTob |  |
| 收款管理详情页 | userBase/receivablesTob/:action/:id | /views/userBase/receivablesTob/edit |  |
| 推荐运力查询 | userBase/recommentCapacityQuery | /views/userBase/recommentCapacityQuery |  |
| 手动新增请款页 | userBase/requestFunds/addPayment | /views/userBase/requestFunds/addPayment |  |
| 请款审核页 | userBase/requestFunds/examinePayment | /views/userBase/requestFunds/examinePayment |  |
| 请款详情页 | userBase/requestFunds/lookPayment | /views/userBase/requestFunds/lookPayment | ⚠️ 多路由复用 |
| 查看请款详情按钮 | userBase/requestFunds/lookPayment | /views/userBase/requestFunds/lookPayment | ⚠️ 多路由复用 |
| 请款修改页 | userBase/requestFunds/paymentPage | /views/userBase/requestFunds/paymentPage |  |
| 角色管理 | userBase/role | /views/userBase/role |  |
| 角色管理详情页 | userBase/role/:action/:id | /views/userBase/role/editItem | ⚠️ 多路由复用 |
| 详情按钮 | userBase/role/:action/:id | /views/userBase/role/editItem | ⚠️ 多路由复用 |
| 运力服务单详情页 | userBase/serviceDocTransDocMent/edit/:id | /views/userBase/serviceDocManagement/transDocMent/edit |  |
| 运力服务单 | userBase/serviceDocTransDocMent | /views/userBase/serviceDocManagement/transDocMent/index |  |
| 接单情况详情页 | userBase/orderReceivingDetails/:id | /views/userBase/serviceDocManagement/transDocMent/orderReceivingDetails |  |
| 服务伙伴管理 | userBase/servicePartnerManagement | /views/userBase/servicePartner/partnerManagement |  |
| 结算处理 | userBase/servicebillSettlement | /views/userBase/servicePartner/servicebillSettlement |  |
| 调整结算信息 | userBase/servicebillSettlement/edit | /views/userBase/servicePartner/servicebillSettlement/edit | ⚠️ 多路由复用 |
| 查看结算信息 | userBase/servicebillSettlement/read | /views/userBase/servicePartner/servicebillSettlement/edit | ⚠️ 多路由复用 |
| 服务费申请 | userBase/servicefeeApply | /views/userBase/servicePartner/servicefeeApply |  |
| 申请结算 | userBase/servicefeeApply/apply | /views/userBase/servicePartner/servicefeeApply/apply |  |
| 查看 | userBase/servicefeeApply/read | /views/userBase/servicePartner/servicefeeApply/read |  |
| 上传 | userBase/servicefeeApply/upload | /views/userBase/servicePartner/servicefeeApply/upload |  |
| 服务费审核 | userBase/servicefeeAudit | /views/userBase/servicePartner/servicefeeAudit |  |
| 审核 | userBase/servicefeeAudit/audit | /views/userBase/servicePartner/servicefeeAudit/audit | ⚠️ 多路由复用 |
| 查看 | userBase/servicefeeAudit/read | /views/userBase/servicePartner/servicefeeAudit/audit | ⚠️ 多路由复用 |
| 未申请运单 | userBase/servicefeeAudit/unpaidWaybill | /views/userBase/servicePartner/servicefeeAudit/unpaidWaybill |  |
| 服务费确认 | userBase/servicefeeConfirm | /views/userBase/servicePartner/servicefeeConfirm |  |
| 审核 | userBase/servicefeeConfirm/audit | /views/userBase/servicePartner/servicefeeConfirm/confirm | ⚠️ 多路由复用 |
| 确认 | userBase/servicefeeConfirm/confirm | /views/userBase/servicePartner/servicefeeConfirm/confirm | ⚠️ 多路由复用 |
| 查看 | userBase/servicefeeConfirm/read | /views/userBase/servicePartner/servicefeeConfirm/confirm | ⚠️ 多路由复用 |
| 货源列表 | userBase/shipSupplyList | /views/userBase/shipSupplyList |  |
| 撮合发货 | userBase/shipSupplyShipmentMatch | /views/userBase/shipmentMatch | ⚠️ 多路由复用 |
| 企业货源 | userBase/shipmentMatch | /views/userBase/shipmentMatch | ⚠️ 多路由复用 |
| 托运人运单 | userBase/shipperOrderManage | /views/userBase/shipperOrderManage |  |
| 轨迹回放 | userBase/shipperOrderManage/edit | /views/userBase/shipperOrderManage/edit |  |
| 托运人运单汇总 | userBase/shipperWaybillData | /views/userBase/shipperWaybillData/index |  |
| 场站计划单 | userBase/smartStation/planSheet | /views/userBase/smartStation/planSheet |  |
| 供应商管理 | userBase/supplierManagement | /views/userBase/supplierManagement |  |
| 供应商管理详情页(供应商) | userBase/supplierManagement/:action/:id | /views/userBase/supplierManagement/edit | ⚠️ 多路由复用 |
| 查看详情按钮(供应商) | userBase/supplierManagement/:action/:id | /views/userBase/supplierManagement/edit | ⚠️ 多路由复用 |
| 供应商对账 | userBase/supplierReconciliation | /views/userBase/supplierReconciliation |  |
| 供应商对账详情 | userBase/supplierReconciliation/:action/:id | /views/userBase/supplierReconciliation/edit | ⚠️ 多路由复用 |
| 查看供应商对账详情按钮 | userBase/supplierReconciliation/:action/:id | /views/userBase/supplierReconciliation/edit | ⚠️ 多路由复用 |
| 供应商月结账单 | userBase/supplierSettlement | /views/userBase/supplierSettlement |  |
| 账单审核页 | userBase/supplierSettlement/examineSettlement | /views/userBase/supplierSettlement/examineSettlement |  |
| 账单详情页 | userBase/supplierSettlement/lookSettlement | /views/userBase/supplierSettlement/lookSettlement | ⚠️ 多路由复用 |
| 查看供应商月结账单详情按钮 | userBase/supplierSettlement/lookSettlement | /views/userBase/supplierSettlement/lookSettlement | ⚠️ 多路由复用 |
| 货源列表 | userBase/supplyList | /views/userBase/supplyList |  |
| 货源详情页 | userBase/supplyList/details | /views/userBase/supplyList/details | ⚠️ 多路由复用 |
| 查看货源详情按钮 | userBase/supplyList/details | /views/userBase/supplyList/details | ⚠️ 多路由复用 |
| 企业货源(旧) | userBase/supplymanagement | /views/userBase/supplymanagement |  |
| 企业货源详情页 | userBase/shipSupplyDetail/:id | /views/userBase/supplymanagement/detalis | ⚠️ 多路由复用 |
| 货源详情页 | userBase/supplymanagementDetail/:id | /views/userBase/supplymanagement/detalis | ⚠️ 多路由复用 |
| 查看货源详情按钮 | userBase/supplymanagementDetail/:id | /views/userBase/supplymanagement/detalis | ⚠️ 多路由复用 |
| 货源详情页 | userBase/supplymanagementDetailHN/:id | /views/userBase/supplymanagement/detalis | ⚠️ 多路由复用 |
| 企业发布货源页 | userBase/shipSupplymanagement/:action/:id | /views/userBase/supplymanagement/publish | ⚠️ 多路由复用 |
| 发布货源页 | userBase/supplymanagementHN/:action/:id | /views/userBase/supplymanagement/publish | ⚠️ 多路由复用 🔀 actionName 指向多 url |
| 货源详情页 | userBase/supplymanagementHNDetail/:id | /views/userBase/supplymanagementHN/detalis |  |
| 发布货源页 | userBase/supplymanagementHN/:action/:id | /views/userBase/supplymanagementHN/publish | 🔀 actionName 指向多 url |
| 招标管理 | userBase/tenderManagement | /views/userBase/tenderManagement |  |
| 招标详情页 | userBase/shipSupplyTenderDetail/:id | /views/userBase/tenderManagement/detalis | ⚠️ 多路由复用 |
| 招标详情页 | userBase/tenderManagementDetail/:id | /views/userBase/tenderManagement/detalis | ⚠️ 多路由复用 |
| 发布招标页 | userBase/shipSupplyTender/:action/:id | /views/userBase/tenderManagement/publish |  |
| 查看模板页 | userBase/tenderManagement/viewPdf | /views/userBase/tenderManagement/viewPdf |  |
| 运单付款 | userBase/threePartyWaybillPayment | /views/userBase/threePartyWaybillPayment |  |
| 运单付款-归档 | userBase/threePartyWaybillPayment/threePartyWaybillPaymentMigrate | /views/userBase/threePartyWaybillPayment/threePartyWaybillPaymentMigrate |  |
| 运单推送 | userBase/threePartyWaybillPush | /views/userBase/threePartyWaybillPush |  |
| 调整结算信息 | userBase/threePartyWaybillPush/edit | /views/userBase/threePartyWaybillPush/edit |  |
| 查看 | userBase/threePartyWaybillPush/read | /views/userBase/threePartyWaybillPush/read |  |
| TOB对账管理 | userBase/tobReconciliation/carrier | /views/userBase/tobReconciliation/carrier |  |
| 申请开票 | userBase/tobReconciliation/carrier/applyInvoice | /views/userBase/tobReconciliation/carrier/applyInvoice |  |
| 账单详情 | userBase/tobReconciliation/carrier/info | /views/userBase/tobReconciliation/carrier/info |  |
| TOB对账确认 | userBase/tobReconciliation/supplier | /views/userBase/tobReconciliation/supplier |  |
| 账单详情 | userBase/tobReconciliation/supplier/info | /views/userBase/tobReconciliation/supplier/info |  |
| 应付三方对账 | userBase/tobReconciliation/tripartite | /views/userBase/tobReconciliation/tripartite |  |
| 账单详情 | userBase/tobReconciliation/tripartite/info | /views/userBase/tobReconciliation/tripartite/info |  |
| 运单调账明细 | userBase/tobReconciliation/waybillDetail | /views/userBase/tobReconciliation/waybillDetail |  |
| 挂车管理 | userBase/trailerManagement | /views/userBase/trailerManagement |  |
| 挂车管理详情页(挂车) | userBase/trailerManagement/:action/:id | /views/userBase/trailerManagement/trailerAdd | ⚠️ 多路由复用 |
| 查看挂车详情按钮(挂车) | userBase/trailerManagement/:action/:id | /views/userBase/trailerManagement/trailerAdd | ⚠️ 多路由复用 |
| 交易明细 | userBase/transactionRecords | /views/userBase/transactionRecords |  |
| 车辆监控记录 | userBase/transporVehicleMonitor | /views/userBase/transporVehicleMonitor |  |
| 运力管理 | userBase/transportCapacityManagement | /views/userBase/transportCapacityManagement |  |
| 回单管理 | userBase/transportReceiptManagement | /views/userBase/transportReceiptManagement |  |
| 铁路运单详情页 | userBase/railwayWaybillManagement/detail/:id | /views/userBase/transportSendDetail | ⚠️ 多路由复用 |
| 查看铁路运单详情 | userBase/railwayWaybillManagement/detail/:id | /views/userBase/transportSendDetail | ⚠️ 多路由复用 |
| 查看运单详情按钮 | userBase/railwayWaybillManagement/detail/:id | /views/userBase/transportSendDetail | ⚠️ 多路由复用 |
| 公路运单详情页 | userBase/transportSendDetail/detail/:id | /views/userBase/transportSendDetail | ⚠️ 多路由复用 |
| 查看公路运单详情按钮 | userBase/transportSendDetail/detail/:id | /views/userBase/transportSendDetail | ⚠️ 多路由复用 |
| 水路运单详情页 | userBase/waterwayWaybillManagement/detail/:id | /views/userBase/transportSendDetail | ⚠️ 多路由复用 |
| 查看水运运单详情按钮 | userBase/waterwayWaybillManagement/detail/:id | /views/userBase/transportSendDetail | ⚠️ 多路由复用 |
| 查看运单详情按钮 | userBase/waterwayWaybillManagement/detail/:id | /views/userBase/transportSendDetail | ⚠️ 多路由复用 |
| 查看运单详情按钮 | userBase/waterwayWaybillManagement/detail/:id,userBase/railwayWaybillManagement/detail/:id,userBase/transportSendDetail/detail/:id | /views/userBase/transportSendDetail,/views/userBase/transportSendDetail,/views/userBase/transportSendDetail |  |
| 公路运单 | userBase/transportSendManagement/:action | /views/userBase/transportSendManagement |  |
| 三方订单 | userBase/tripleOrder | /views/userBase/tripleOrder |  |
| 三方订单详情 | userBase/tripleOrder/:action/:id | /views/userBase/tripleOrder/tripleOrderView |  |
| 用户管理 | userBase/user | /views/userBase/user |  |
| 用户管理详情页 | userBase/user/:action/:id | /views/userBase/user/editItem | ⚠️ 多路由复用 |
| 详情按钮 | userBase/user/:action/:id | /views/userBase/user/editItem | ⚠️ 多路由复用 |
| 发布车源页 | userBase/vehicle/:action | /views/userBase/vehicle/details | ⚠️ 多路由复用 |
| 车源管理详情页 | userBase/vehicle/:action/:id | /views/userBase/vehicle/details | ⚠️ 多路由复用 |
| 车辆运费统计 | userBase/vehicleFreightStatistics | /views/userBase/vehicleFreightStatistics |  |
| 保险管理 | userBase/vehicleInsurance | /views/userBase/vehicleInsurance | ⚠️ 多路由复用 |
| 跳转车辆保险按钮(挂车) | userBase/vehicleInsurance | /views/userBase/vehicleInsurance | ⚠️ 多路由复用 |
| 跳转车辆保险按钮(车辆) | userBase/vehicleInsurance | /views/userBase/vehicleInsurance | ⚠️ 多路由复用 |
| 车辆保险管理详情页 | userBase/vehicleInsurance/:type/:id | /views/userBase/vehicleInsurance/edit | ⚠️ 多路由复用 |
| 查看详情按钮 | userBase/vehicleInsurance/:type/:id | /views/userBase/vehicleInsurance/edit | ⚠️ 多路由复用 |
| 车辆管理详情页 | userBase/vehicleManager/:id | /views/userBase/vehicleManager/detail.vue |  |
| 车辆管理 | userBase/vehicleManager | /views/userBase/vehicleManager/index.vue |  |
| 车辆监控查看 | userBase/vehicleMonitoring | /views/userBase/vehicleMonitoring |  |
| 运输在途查看 | userBase/vehicleMonitoringPositioning | /views/userBase/vehicleMonitoringPositioning |  |
| 轨迹路径详情 | userBase/routeVisualization/routeDetail | /views/userBase/vehicleMonitoringPositioning/routeDetail |  |
| 水运订单 | userBase/waterwayOrderManagement | /views/userBase/waterwayOrderManagement |  |
| 水运订单详情页 | userBase/waterwayOrderManagement/:id | /views/userBase/waterwayOrderManagement/edit |  |
| 水运运单 | userBase/waterwayWaybillManagement | /views/userBase/waterwayWaybillManagement |  |
| 派车详情 | userBase/waybillCollection/edit | /views/userBase/waybillCollection/edit |  |
| 节点维护 | userBase/waybillCollection/indexSpecially | /views/userBase/waybillCollection/indexSpecially |  |
| 订单维护 | userBase/waybillCollection/order | /views/userBase/waybillCollection/order |  |
| 新增订单详情 | userBase/waybillCollection/orderAdd | /views/userBase/waybillCollection/orderAdd |  |
| 运单维护 | userBase/waybillCollection/waybill | /views/userBase/waybillCollection/waybill |  |
| 运单数据汇总 | userBase/waybillDataSummary | /views/userBase/waybillDataSummary |  |
| 应付三方-承运商 | userBase/waybillPayment | /views/userBase/waybillPayment |  |
| 运单结算处理 | userBase/waybillSettlement | /views/userBase/waybillSettlement |  |
| 调整结算信息 | userBase/waybillSettlement/edit | /views/userBase/waybillSettlement/edit |  |
| 查看结算信息 | userBase/waybillSettlement/read | /views/userBase/waybillSettlement/read |  |
| 批量维护 | userBase/batch-supplement | /views/userBase/waybillSupplement/batch-supplement |  |
| 运单接收 | userBase/waybill-receive | /views/userBase/waybillSupplement/waybill-receive |  |
| 工作台 | userBase/workspace | /views/userBase/workspace |  |

---

## 异常汇总

### ⚠️ 同一 url 被多个 actionName 指向（共用文件）

**`/views/userBase/VehicleMaintenance/edit`**
- `userBase/VehicleMaintenance/:type/:id`
- `userBase/VehicleMaintenance/:type/:id`

**`/views/userBase/annualinspection/annualinspection`**
- `userBase/annualinspection/:type/:id`
- `userBase/annualinspection/:type/:id`

**`/views/userBase/baseInfo`**
- `userBase/baseInfo`
- `userBase/baseInfo`

**`/views/userBase/billingRecord/view`**
- `userBase/billingRecord/edit`
- `userBase/billingRecord/view`

**`/views/userBase/carrierPayment/edit`**
- `userBase/carrierPayment/edit`
- `userBase/freightMerge/carrierPayment/edit`

**`/views/userBase/carrierPayment/view`**
- `userBase/carrierPayment/view`
- `userBase/freightMerge/carrierPayment/view`

**`/views/userBase/carsmanagement/edit`**
- `userBase/carsmanagement/:action/:id`
- `userBase/carsmanagement/:action/:id`

**`/views/userBase/collectTicket/edit`**
- `userBase/collectTicket/edit`
- `userBase/collectTicket/view`

**`/views/userBase/complaintConsultation/edit`**
- `userBase/complaintConsultation/edit`
- `userBase/complaintConsultation/edit`

**`/views/userBase/complaintConsultation/view`**
- `userBase/complaintConsultation/view`
- `userBase/complaintConsultation/view`

**`/views/userBase/constRecord/add`**
- `userBase/constRecord/:action/:id`
- `userBase/constRecord/:action/:id`

**`/views/userBase/customerManagement/edit`**
- `userBase/customerManagement/:action/:id`
- `userBase/customerManagement/:action/:id`

**`/views/userBase/customerReconciliation/edit`**
- `userBase/customerReconciliation/:action/:id`
- `userBase/customerReconciliation/:action/:id`

**`/views/userBase/driverChecking/add`**
- `userBase/driverChecking/:action/:id`
- `userBase/driverChecking/:action/:id`

**`/views/userBase/driverSupplymanagement/details`**
- `userBase/detail/:id`
- `userBase/goodsOnlineDetail/:id`
- `userBase/matchDetail/:id`
- `userBase/shipSupplyDriverDetail/:id`

**`/views/userBase/drivermanagement/addDriver`**
- `userBase/drivermanagement/:type/:id`
- `userBase/drivermanagement/:type/:id`

**`/views/userBase/freightNew/edit`**
- `userBase/freightMerge/freightNew/edit`
- `userBase/freightNew/edit`

**`/views/userBase/freightNew/view`**
- `userBase/freightMerge/freightNew/view`
- `userBase/freightNew/view`

**`/views/userBase/mainstay/application/creditList`**
- `userBase/mainstay/application/creditList`
- `userBase/mainstay/application/creditList`
- `userBase/mainstay/application/creditList11`
- `userBase/mainstay/application/creditList333`
- `userBase/mainstay/application/creditList444`

**`/views/userBase/mainstay/wallet/myBankCard`**
- `userBase/mainstay/3pl/wallet/myBankCard`
- `userBase/mainstay/mainstay/wallet/myBankCard`

**`/views/userBase/mainstay/wallet/myBankCardDetail`**
- `userBase/mainstay/3pl/wallet/myBankCardDetail`
- `userBase/mainstay/mainstay/wallet/myBankCardDetail`

**`/views/userBase/oilGasListManagement/view`**
- `userBase/oilGasListManagement/view`
- `userBase/oilGasListManagement/view`
- `userBase/oilGasListManagement/view`

**`/views/userBase/orderSendOrderManagement/orderSendOrderManagementRead`**
- `userBase/orderSendOrderManagement/:action/:id`
- `userBase/orderSendOrderManagement/:action/:id`
- `userBase/orderSendOrderManagement/:action/:id`
- `userBase/orderSendOrderManagement/:action/:id`

**`/views/userBase/orderTransportOrderManagement/orderAdd`**
- `userBase/orderTransportOrderManagement/addnew`
- `userBase/orderTransportOrderManagement/addnew`

**`/views/userBase/orderTransportOrderManagement/orderTransportOrderManagementRead`**
- `userBase/orderTransportOrderManagement/:action/:id`
- `userBase/orderTransportOrderManagement/:action/:id`
- `userBase/orderTransportOrderManagement/:action/:id`
- `userBase/orderTransportOrderManagement/:action/:id`

**`/views/userBase/orderTransportOrderManagement/publish`**
- `userBase/orderTransportOrderManagement/publish`
- `userBase/orderTransportOrderManagement/publish`

**`/views/userBase/payment/lookUp`**
- `userBase/payment/lookUp`
- `userBase/payment/lookUp`

**`/views/userBase/quote/askresult`**
- `userBase/quote/askresult`
- `userBase/quote/askresult`

**`/views/userBase/quote/detalis`**
- `userBase/partnerQuote/details`
- `userBase/quote/detalis`
- `userBase/quote/detalis`

**`/views/userBase/receivables/edit`**
- `userBase/receivables/:action/:id`
- `userBase/receivables/:action/:id`

**`/views/userBase/requestFunds/lookPayment`**
- `userBase/requestFunds/lookPayment`
- `userBase/requestFunds/lookPayment`

**`/views/userBase/role/editItem`**
- `userBase/role/:action/:id`
- `userBase/role/:action/:id`

**`/views/userBase/servicePartner/servicebillSettlement/edit`**
- `userBase/servicebillSettlement/edit`
- `userBase/servicebillSettlement/read`

**`/views/userBase/servicePartner/servicefeeAudit/audit`**
- `userBase/servicefeeAudit/audit`
- `userBase/servicefeeAudit/read`

**`/views/userBase/servicePartner/servicefeeConfirm/confirm`**
- `userBase/servicefeeConfirm/audit`
- `userBase/servicefeeConfirm/confirm`
- `userBase/servicefeeConfirm/read`

**`/views/userBase/shipmentMatch`**
- `userBase/shipSupplyShipmentMatch`
- `userBase/shipmentMatch`

**`/views/userBase/supplierManagement/edit`**
- `userBase/supplierManagement/:action/:id`
- `userBase/supplierManagement/:action/:id`

**`/views/userBase/supplierReconciliation/edit`**
- `userBase/supplierReconciliation/:action/:id`
- `userBase/supplierReconciliation/:action/:id`

**`/views/userBase/supplierSettlement/lookSettlement`**
- `userBase/supplierSettlement/lookSettlement`
- `userBase/supplierSettlement/lookSettlement`

**`/views/userBase/supplyList/details`**
- `userBase/supplyList/details`
- `userBase/supplyList/details`

**`/views/userBase/supplymanagement/detalis`**
- `userBase/shipSupplyDetail/:id`
- `userBase/supplymanagementDetail/:id`
- `userBase/supplymanagementDetail/:id`
- `userBase/supplymanagementDetailHN/:id`

**`/views/userBase/supplymanagement/publish`**
- `userBase/shipSupplymanagement/:action/:id`
- `userBase/supplymanagementHN/:action/:id`

**`/views/userBase/tenderManagement/detalis`**
- `userBase/shipSupplyTenderDetail/:id`
- `userBase/tenderManagementDetail/:id`

**`/views/userBase/trailerManagement/trailerAdd`**
- `userBase/trailerManagement/:action/:id`
- `userBase/trailerManagement/:action/:id`

**`/views/userBase/transportSendDetail`**
- `userBase/railwayWaybillManagement/detail/:id`
- `userBase/railwayWaybillManagement/detail/:id`
- `userBase/railwayWaybillManagement/detail/:id`
- `userBase/transportSendDetail/detail/:id`
- `userBase/transportSendDetail/detail/:id`
- `userBase/waterwayWaybillManagement/detail/:id`
- `userBase/waterwayWaybillManagement/detail/:id`
- `userBase/waterwayWaybillManagement/detail/:id`

**`/views/userBase/user/editItem`**
- `userBase/user/:action/:id`
- `userBase/user/:action/:id`

**`/views/userBase/vehicle/details`**
- `userBase/vehicle/:action`
- `userBase/vehicle/:action/:id`

**`/views/userBase/vehicleInsurance`**
- `userBase/vehicleInsurance`
- `userBase/vehicleInsurance`
- `userBase/vehicleInsurance`

**`/views/userBase/vehicleInsurance/edit`**
- `userBase/vehicleInsurance/:type/:id`
- `userBase/vehicleInsurance/:type/:id`

### 🔀 同一 actionName 指向不同 url（配置异常）

**`userBase/carrierPayment/manage`**
- `/views/userBase/carrierPayment/manage`
- `/views/userBase/carrierPayment/manage.vue`

**`userBase/supplymanagementHN/:action/:id`**
- `/views/userBase/supplymanagement/publish`
- `/views/userBase/supplymanagementHN/publish`

---
**文档版本**: v1.1
**最后更新**: 2026年07月
**整理人**: 王新骏