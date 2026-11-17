import {
  createSketch, R, assertNoOverlap,
  INK, GREEN, VIOLET, BLUE, RED, GRAY, YELLOW, PAPER,
} from './sketch.mjs';

// ── 1. 页面布局架构图 ──────────────────────────────────────────
function layout() {
  const s = createSketch(1400, 880, { stroke: { roughness: 1.0, passes: 1 } });
  const bodyY = s.header({
    title: '服务商工作台 · 页面布局架构',
    sub: 'WelcomeSection 全宽 + 左右两列 · max-width 1440px',
  });

  const M = 56;
  const CW = 1400 - M * 2;

  // WelcomeSection (full width)
  const welcome = R(M, bodyY + 10, CW, 70, 'welcome');
  s.card(welcome.x, welcome.y, welcome.w, welcome.h, 'WelcomeSection\n问候语 · 信用标签 · 身份标签 · 了解接单规则 · 发布服务', {
    stroke: VIOLET, fill: YELLOW, fillStyle: 'hachure',
  });

  // main-content region
  const mainY = welcome.y + welcome.h + 30;
  const mainH = 580;
  s.rect(M, mainY, CW, mainH, { stroke: GRAY, dash: true, lint: false });
  s.text(M + 12, mainY + 6, 200, 'main-content (flex gap:16)', { size: 13, color: GRAY });

  // Left column
  const leftW = CW - 380;
  const leftX = M + 10;
  const colY = mainY + 28;
  s.rect(leftX, colY, leftW, mainH - 40, { stroke: BLUE, dash: true, fill: BLUE, fillStyle: 'solid', fillOpacity: 0.04, lint: false });
  s.text(leftX + 8, colY + 4, 200, 'left-column (flex:1)', { size: 14, color: BLUE, weight: 700 });

  // MetricCards
  const mc = R(leftX + 16, colY + 30, leftW - 32, 56, 'mc');
  s.card(mc.x, mc.y, mc.w, mc.h, 'MetricCards · 4 张指标卡 (grid 4列)', { stroke: BLUE });

  // OpportunityRecommendModule
  const opp = R(leftX + 16, mc.y + mc.h + 16, leftW - 32, 56, 'opp');
  s.card(opp.x, opp.y, opp.w, opp.h, 'OpportunityRecommendModule · 商机推荐 (上限6 · 左右滑动)', { stroke: VIOLET });

  // dynamic-row
  const dynY = opp.y + opp.h + 16;
  const halfW = (leftW - 48) / 2;
  const ord = R(leftX + 16, dynY, halfW, 80, 'ord');
  s.card(ord.x, ord.y, ord.w, ord.h, 'OrderDynamicModule\n订单动态 · 待缴保证金/待提交交付物', { stroke: GREEN });

  const aft = R(leftX + 16 + halfW + 16, dynY, halfW, 80, 'aft');
  s.card(aft.x, aft.y, aft.w, aft.h, 'AfterSaleDynamicModule\n售后动态 · 仅返工/仅退款/退款+返工', { stroke: GREEN });

  // dynamic-row label
  s.wireLabel(leftX + 16, dynY - 16, leftW - 32, 'dynamic-row (flex, gap:16)', { size: 12, color: GREEN });

  // CertificationPlaceholder (v-else)
  const cert = R(leftX + 16, dynY + 96, leftW - 32, 50, 'cert');
  s.card(cert.x, cert.y, cert.w, cert.h, 'CertificationPlaceholder (v-else) · 未认证占位图', {
    stroke: RED, dash: true,
  });
  s.wireLabel(leftX + leftW / 2, dynY + 86, 120, 'v-if certified', { size: 12, color: RED });

  // Right column
  const rightX = leftX + leftW + 16;
  const rightW = CW - leftW - 26;
  s.rect(rightX, colY, rightW, mainH - 40, { stroke: GRAY, dash: true, fill: YELLOW, fillStyle: 'solid', fillOpacity: 0.06, lint: false });
  s.text(rightX + 8, colY + 4, 200, 'right-column (461px)', { size: 14, color: INK, weight: 700 });

  // ActionCenter
  const ac = R(rightX + 12, colY + 30, rightW - 24, 120, 'ac');
  s.card(ac.x, ac.y, ac.w, ac.h, 'ActionCenter\n消息中心\nR-024 移至右列 · R-026 发布服务已迁出', { stroke: INK });

  // SupplierCtaCard
  const cta = R(rightX + 12, ac.y + ac.h + 20, rightW - 24, 200, 'cta');
  s.card(cta.x, cta.y, cta.w, cta.h, 'SupplierCtaCard\n供应商引导卡\n├ 未认证 → UncertifiedCard\n├ 已认证未入驻 → SupplierRegisterCard\n└ 已入驻 → SupplierWorkbenchCard', {
    stroke: RED,
  });

  // Floating layer
  const floatY = mainY + mainH + 16;
  const modal = R(M, floatY, 500, 40, 'modal');
  s.card(modal.x, modal.y, modal.w, modal.h, 'Modal 层 · Auth/Wallet/Eligibility', { stroke: GRAY });

  const guide = R(540, floatY, 300, 40, 'guide');
  s.card(guide.x, guide.y, guide.w, guide.h, 'ProviderGuideOverlay (新手引导)', { stroke: GRAY });

  return s;
}

// ── 2. 组件层级与数据流图 ──────────────────────────────────────
function dataflow() {
  const s = createSketch(1400, 880, { stroke: { roughness: 1.0, passes: 1 } });
  const bodyY = s.header({
    title: '组件层级与数据流',
    sub: 'Store → 编排层 → 组件层 · 单一数据源: userStore.isProviderCertified',
  });

  const M = 56;

  // ── Store 层 ──
  s.rect(M, bodyY, 1288, 80, { stroke: VIOLET, dash: true, fill: VIOLET, fillStyle: 'solid', fillOpacity: 0.04, lint: false });
  s.text(M + 12, bodyY + 4, 120, 'Store 层', { size: 15, color: VIOLET, weight: 700 });

  const userStore = R(M + 20, bodyY + 28, 220, 42, 'userStore');
  s.card(userStore.x, userStore.y, userStore.w, userStore.h, 'useUserStore\nisProviderCertified', { stroke: VIOLET });

  const dashStore = R(M + 280, bodyY + 28, 260, 42, 'dashStore');
  s.card(dashStore.x, dashStore.y, dashStore.w, dashStore.h, 'dashboardStore\ncertified = computed(...)', { stroke: BLUE });

  const becomeSupplier = R(M + 580, bodyY + 28, 220, 42, 'becomeSupplier');
  s.card(becomeSupplier.x, becomeSupplier.y, becomeSupplier.w, becomeSupplier.h, 'useBecomeSupplier\nModal state · 入驻流程', { stroke: GREEN });

  const api = R(M + 840, bodyY + 28, 200, 42, 'api');
  s.card(api.x, api.y, api.w, api.h, 'API Layer\nuser/info · onboarding', { stroke: GRAY });

  s.connect(userStore, 'e', dashStore, 'w', { stroke: VIOLET });
  s.connect(dashStore, 'e', becomeSupplier, 'w', { stroke: BLUE });
  s.connect(becomeSupplier, 'e', api, 'w', { stroke: GREEN });

  // ── 编排层 ──
  const orchY = bodyY + 110;
  s.rect(M, orchY, 1288, 70, { stroke: INK, dash: true, fill: YELLOW, fillStyle: 'solid', fillOpacity: 0.06, lint: false });
  s.text(M + 12, orchY + 4, 200, 'index.vue 编排层 (~420行)', { size: 15, color: INK, weight: 700 });

  const storeToRefs = R(M + 20, orchY + 28, 160, 34, 'storeToRefs');
  s.card(storeToRefs.x, storeToRefs.y, storeToRefs.w, storeToRefs.h, 'storeToRefs\ncertified', { stroke: INK });

  const vifCert = R(M + 220, orchY + 28, 160, 34, 'vifCert');
  s.card(vifCert.x, vifCert.y, vifCert.w, vifCert.h, 'v-if certified\n左列三模块/占位图', { stroke: INK });

  const propCert = R(M + 420, orchY + 28, 180, 34, 'propCert');
  s.card(propCert.x, propCert.y, propCert.w, propCert.h, ':certified prop\n→ SupplierCtaCard', { stroke: RED });

  const emitApply = R(M + 640, orchY + 28, 200, 34, 'emitApply');
  s.card(emitApply.x, emitApply.y, emitApply.w, emitApply.h, 'emit: apply/enterWorkbench\n→ useBecomeSupplier', { stroke: GREEN });

  s.connect(dashStore, 's', storeToRefs, 'n', { stroke: BLUE, label: 'dashboardStore' });

  // ── 组件层 ──
  const compY = orchY + 100;
  s.rect(M, compY, 1288, 440, { stroke: BLUE, dash: true, fill: BLUE, fillStyle: 'solid', fillOpacity: 0.02, lint: false });
  s.text(M + 12, compY + 4, 200, '组件层 (components/)', { size: 15, color: BLUE, weight: 700 });

  // Left column components
  const lx = M + 20;
  const lw = 400;

  const ws = R(lx, compY + 30, lw, 50, 'ws');
  s.card(ws.x, ws.y, ws.w, ws.h, 'WelcomeSection (纯展示)\nprops: userName, isProviderCertified', { stroke: VIOLET });

  const mc2 = R(lx, compY + 96, lw, 40, 'mc2');
  s.card(mc2.x, mc2.y, mc2.w, mc2.h, 'MetricCards (自包含 · 读 store)', { stroke: BLUE });

  const opp2 = R(lx, compY + 152, lw, 40, 'opp2');
  s.card(opp2.x, opp2.y, opp2.w, opp2.h, 'OpportunityRecommendModule/', { stroke: VIOLET });

  const dyn2 = R(lx, compY + 208, lw, 40, 'dyn2');
  s.card(dyn2.x, dyn2.y, dyn2.w, dyn2.h, 'OrderDynamic + AfterSaleDynamic', { stroke: GREEN });

  const certP = R(lx, compY + 264, lw, 40, 'certP');
  s.card(certP.x, certP.y, certP.w, certP.h, 'CertificationPlaceholder (v-else)', { stroke: RED, dash: true });

  // Right column components
  const rx = M + 460;
  const rw = 380;

  const ac2 = R(rx, compY + 30, rw, 50, 'ac2');
  s.card(ac2.x, ac2.y, ac2.w, ac2.h, 'ActionCenter (自包含 · 读 store)\n消息中心', { stroke: INK });

  const cta2 = R(rx, compY + 96, rw, 80, 'cta2');
  s.card(cta2.x, cta2.y, cta2.w, cta2.h, 'SupplierCtaCard/\nindex.vue + useSupplierCtaCard(certified)\n├ UncertifiedCard\n├ SupplierRegisterCard\n└ SupplierWorkbenchCard', {
    stroke: RED,
  });

  // Shared components
  const sx = M + 880;
  const sw = 380;

  const banner = R(sx, compY + 30, sw, 50, 'banner');
  s.card(banner.x, banner.y, banner.w, banner.h, 'CertificationBanner (共享)\nprops: hidden, preview · expose: openPreview', {
    stroke: VIOLET,
  });

  const dmh = R(sx, compY + 96, sw, 40, 'dmh');
  s.card(dmh.x, dmh.y, dmh.w, dmh.h, 'DynamicModuleHeader (共享)', { stroke: VIOLET });

  const udm = R(sx, compY + 152, sw, 40, 'udm');
  s.card(udm.x, udm.y, udm.w, udm.h, 'useDynamicModule.ts (composable)', { stroke: VIOLET });

  const modals = R(sx, compY + 208, sw, 50, 'modals');
  s.card(modals.x, modals.y, modals.w, modals.h, 'Modal 层\nAuth/Wallet/Eligibility', { stroke: GRAY });

  // Connections
  s.connect(storeToRefs, 's', ws, 'n', { stroke: VIOLET, label: 'props' });
  s.connect(propCert, 's', cta2, 'n', { stroke: RED, label: ':certified' });
  s.connect(cta2, 'e', modals, 'w', { stroke: GRAY, label: 'emit→Modal' });

  return s;
}

// ── 3. SupplierCtaCard 三态状态机 ──────────────────────────────
function states() {
  const s = createSketch(1300, 660, { stroke: { roughness: 1.0, passes: 1 } });
  const bodyY = s.header({
    title: 'SupplierCtaCard · 三态状态机',
    sub: 'useSupplierCtaCard(certified) · certified × supplierStatus 双维度',
  });

  const M = 56;

  // Data sources
  s.rect(M, bodyY, 1188, 60, { stroke: GRAY, dash: true, fill: GRAY, fillStyle: 'solid', fillOpacity: 0.04, lint: false });
  s.text(M + 12, bodyY + 4, 120, '数据源', { size: 14, color: GRAY, weight: 700 });

  const src1 = R(M + 20, bodyY + 22, 240, 30, 'src1');
  s.card(src1.x, src1.y, src1.w, src1.h, 'certified (prop ← store)', { stroke: VIOLET });

  const src2 = R(M + 300, bodyY + 22, 280, 30, 'src2');
  s.card(src2.x, src2.y, src2.w, src2.h, 'supplierStatus (onboarding/status)', { stroke: GREEN });

  const src3 = R(M + 620, bodyY + 22, 240, 30, 'src3');
  s.card(src3.x, src3.y, src3.w, src3.h, 'onboardingStatus (乐观值校准)', { stroke: BLUE });

  // Three states
  const stY = bodyY + 90;
  const stW = 360;
  const stH = 280;
  const gap = 30;

  // State 1: not_certified
  const s1 = R(M, stY, stW, stH, 's1');
  s.box(s1.x, s1.y, s1.w, s1.h, { stroke: RED, sw: 2.2 });
  s.text(s1.x + 16, s1.y + 12, stW - 32, '① not_certified', { size: 22, weight: 700, color: RED });
  s.text(s1.x + 16, s1.y + 44, stW - 32, '未认证用户', { size: 14, color: GRAY });
  s.line(s1.x + 16, s1.y + 66, s1.x + stW - 16, s1.y + 66, { stroke: RED, sw: 0.8 });
  s.text(s1.x + 16, s1.y + 80, stW - 32,
    '条件: !certified\nUI: UncertifiedCard.vue\n  3 条权益说明\n  "立即认证" 按钮\n背景: supplierRegisterBg\nclass: --uncertified\n埋点: go_certify',
    { size: 14, color: INK });

  // State 2: not_supplier
  const s2 = R(M + stW + gap, stY, stW, stH, 's2');
  s.box(s2.x, s2.y, s2.w, s2.h, { stroke: INK, sw: 2.2 });
  s.text(s2.x + 16, s2.y + 12, stW - 32, '② not_supplier', { size: 22, weight: 700, color: INK });
  s.text(s2.x + 16, s2.y + 44, stW - 32, '已认证 · 未入驻供应商', { size: 14, color: GRAY });
  s.line(s2.x + 16, s2.y + 66, s2.x + stW - 16, s2.y + 66, { stroke: INK, sw: 0.8 });
  s.text(s2.x + 16, s2.y + 80, stW - 32,
    '条件: certified\n  且 !showWorkbench\nUI: SupplierRegisterCard\n  平台供应商介绍\n  "立即申请入驻" 按钮\n背景: supplierRegisterBg\nclass: --register\n埋点: supplier_apply',
    { size: 14, color: INK });

  // State 3: supplier
  const s3 = R(M + (stW + gap) * 2, stY, stW, stH, 's3');
  s.box(s3.x, s3.y, s3.w, s3.h, { stroke: GREEN, sw: 2.2 });
  s.text(s3.x + 16, s3.y + 12, stW - 32, '③ supplier', { size: 22, weight: 700, color: GREEN });
  s.text(s3.x + 16, s3.y + 44, stW - 32, '已认证 · 已入驻供应商', { size: 14, color: GRAY });
  s.line(s3.x + 16, s3.y + 66, s3.x + stW - 16, s3.y + 66, { stroke: GREEN, sw: 0.8 });
  s.text(s3.x + 16, s3.y + 80, stW - 32,
    '条件: certified\n  且 showWorkbench\nUI: SupplierWorkbenchCard\n  供应商工作台介绍\n  "进入供应商工作台" 按钮\n背景: supplierDashboardBg\nclass: --workbench\n埋点: enter_workbench',
    { size: 14, color: INK });

  // Transition arrows
  s.connect(s1, 'e', s2, 'w', { stroke: RED, label: '认证完成' });
  s.connect(s2, 'e', s3, 'w', { stroke: GREEN, label: '入驻通过' });

  // Computed logic box
  const logicY = stY + stH + 24;
  s.rect(M, logicY, 1188, 100, { stroke: VIOLET, dash: true, fill: VIOLET, fillStyle: 'solid', fillOpacity: 0.04, lint: false });
  s.text(M + 16, logicY + 8, 300, 'computed 判定链', { size: 15, color: VIOLET, weight: 700 });
  s.text(M + 16, logicY + 32, 1100,
    'showSupplierWorkbenchCard = supplierStatus===ONBOARDED || onboardingStatus===APPROVED',
    { size: 14, color: INK });
  s.text(M + 16, logicY + 56, 1100,
    'supplierGuidanceStatus = !certified ? not_certified : showWorkbench ? supplier : not_supplier',
    { size: 14, color: INK });
  s.text(M + 16, logicY + 80, 1100,
    'loading 守卫: certified and loading and status==null (未认证跳过 loading)',
    { size: 13, color: RED });

  return s;
}

// ── 4. 动态模块通用数据流 ──────────────────────────────────────
function dynflow() {
  const s = createSketch(1300, 700, { stroke: { roughness: 1.0, passes: 1 } });
  const bodyY = s.header({
    title: 'useDynamicModule<T> · 通用数据流',
    sub: '接口无关中间层 · mock → 真实 API 替换 · 5 分钟轮询',
  });

  const M = 56;
  const CW = 1300 - M * 2;

  // Layer 1: API
  s.rect(M, bodyY, CW, 70, { stroke: RED, dash: true, fill: RED, fillStyle: 'solid', fillOpacity: 0.04, lint: false });
  s.text(M + 12, bodyY + 4, 200, 'API 层 (当前 mock)', { size: 15, color: RED, weight: 700 });

  const m1 = R(M + 20, bodyY + 28, 200, 34, 'm1');
  s.card(m1.x, m1.y, m1.w, m1.h, 'mockOrderList()', { stroke: RED });
  const m2 = R(M + 240, bodyY + 28, 220, 34, 'm2');
  s.card(m2.x, m2.y, m2.w, m2.h, 'mockAfterSaleList()', { stroke: RED });
  const m3 = R(M + 480, bodyY + 28, 240, 34, 'm3');
  s.card(m3.x, m3.y, m3.w, m3.h, 'mockOpportunityList()', { stroke: RED });
  const m4 = R(M + 740, bodyY + 28, 200, 34, 'm4');
  s.card(m4.x, m4.y, m4.w, m4.h, '真实 API (TODO)', { stroke: GRAY, dash: true });

  // Layer 2: Composable
  const compY = bodyY + 100;
  s.rect(M, compY, CW, 180, { stroke: VIOLET, dash: true, fill: VIOLET, fillStyle: 'solid', fillOpacity: 0.04, lint: false });
  s.text(M + 12, compY + 4, 400, 'useDynamicModule<T> (composable)', { size: 15, color: VIOLET, weight: 700 });

  const input = R(M + 20, compY + 30, 200, 50, 'input');
  s.card(input.x, input.y, input.w, input.h, 'fetchFn: () => T[]\n接口取数函数', { stroke: VIOLET });

  const core = R(M + 260, compY + 30, 280, 130, 'core');
  s.box(core.x, core.y, core.w, core.h, { stroke: VIOLET, sw: 2 });
  s.text(core.x + 16, core.y + 10, core.w - 32, '核心机制', { size: 16, weight: 700, color: VIOLET });
  s.text(core.x + 16, core.y + 34, core.w - 32,
    'data: Ref<T[]>\nloading: Ref<boolean>\nerror: Ref<string | null>\nrefresh() / startPolling() / stopPolling()',
    { size: 13, color: INK });

  const poll = R(M + 580, compY + 30, 200, 50, 'poll');
  s.card(poll.x, poll.y, poll.w, poll.h, '轮询控制\nDEFAULT_POLLING_INTERVAL', { stroke: GREEN });

  const lifecycle = R(M + 820, compY + 30, 240, 50, 'lifecycle');
  s.card(lifecycle.x, lifecycle.y, lifecycle.w, lifecycle.h, '生命周期\nonMounted → start', { stroke: GREEN });

  const race = R(M + 580, compY + 96, 480, 64, 'race');
  s.card(race.x, race.y, race.w, race.h, 'onUnmounted → stopPolling() 清除定时器\n每次 refresh 重置 requestVersion 防竞态', {
    stroke: GRAY,
  });

  s.connect(input, 'e', core, 'w', { stroke: VIOLET });

  // Layer 3: Components
  const modY = compY + 210;
  s.rect(M, modY, CW, 80, { stroke: BLUE, dash: true, fill: BLUE, fillStyle: 'solid', fillOpacity: 0.04, lint: false });
  s.text(M + 12, modY + 4, 400, '组件层 — 三个动态模块各自消费 useDynamicModule<T>', { size: 15, color: BLUE, weight: 700 });

  const c1 = R(M + 20, modY + 28, 340, 42, 'c1');
  s.card(c1.x, c1.y, c1.w, c1.h, 'OrderDynamicModule/\n<OrderDynamicItem>', { stroke: BLUE });
  const c2 = R(M + 380, modY + 28, 360, 42, 'c2');
  s.card(c2.x, c2.y, c2.w, c2.h, 'AfterSaleDynamicModule/\n<AfterSaleDynamicItem>', { stroke: BLUE });
  const c3 = R(M + 760, modY + 28, 380, 42, 'c3');
  s.card(c3.x, c3.y, c3.w, c3.h, 'OpportunityRecommendModule/\n<HallDemandItem>', { stroke: VIOLET });

  // Arrows from composable to components
  // Staggered connections to avoid edge overlap
  s.connect(c1, 'n', core, 's', { stroke: BLUE, label: 'order' });
  s.connect(c3, 'n', core, 's', { stroke: VIOLET, label: 'opportunity', allowOverlap: true });
  s.connect(c2, 'n', core, 's', { stroke: BLUE, label: 'afterSale', allowOverlap: true });

  // Layer 4: Four states
  const stY2 = modY + 110;
  s.rect(M, stY2, CW, 100, { stroke: GREEN, dash: true, fill: GREEN, fillStyle: 'solid', fillOpacity: 0.04, lint: false });
  s.text(M + 12, stY2 + 4, 400, '四态渲染 (各模块目录内独立状态组件)', { size: 15, color: GREEN, weight: 700 });

  const q1 = R(M + 20, stY2 + 28, 260, 60, 'q1');
  s.card(q1.x, q1.y, q1.w, q1.h, 'loading\nXxxSkeleton.vue\n骨架屏占位', { stroke: INK });
  const q2 = R(M + 300, stY2 + 28, 260, 60, 'q2');
  s.card(q2.x, q2.y, q2.w, q2.h, 'error\nXxxError.vue\n请求失败 + 重试', { stroke: RED });
  const q3 = R(M + 580, stY2 + 28, 260, 60, 'q3');
  s.card(q3.x, q3.y, q3.w, q3.h, 'empty\nXxxEmpty.vue\n暂无数据', { stroke: GRAY });
  const q4 = R(M + 860, stY2 + 28, 280, 60, 'q4');
  s.card(q4.x, q4.y, q4.w, q4.h, 'data\n模块主 index.vue\n正常渲染业务数据', { stroke: GREEN });

  return s;
}

export const FIGURES = [
  ['01-layout', layout],
  ['02-dataflow', dataflow],
  ['03-states', states],
  ['04-dynflow', dynflow],
];
