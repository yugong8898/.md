# 统一二级频道页三处列表拖拽为 useDragSort composable

## 目标与范围
- 仅收敛 `activity-zone`（`ActivitySelectCard` + `ServiceProductCard`）与 `agent-market`（`index.vue`）三处**完全同构**的原生 HTML5 DnD 逻辑到一个 composable。
- `industry-news` 保持现状（当前无拖拽，不改）。
- **不碰**：`footer` / `marketing-position` / `top-banner` / `recommended-services` / `@/components/DraggableTable.vue`（非本次范围，属其它工作内容）。
- **行为完全不变**：模板、样式、DOM 结构、把手交互、写回时机、`activity-zone` 的「仅重排不触发服务产品清空」联动，全部保持等价。

## 一、新增文件：useDragSort composable
路径：`src/pages/secondary-channel/form/modules/composables/useDragSort.ts`
（新建 `modules/composables/`，与既有 `modules/components/DragHandleIcon.vue` 同层——二者服务同样这三个模块，co-located 最内聚）

```ts
import { computed, ref, type Ref } from 'vue';

interface UseDragSortOptions<T> {
  /** 数据源 getter：返回当前真实顺序的列表 */
  list: () => T[];
  /** 拖拽结束后写回新顺序 */
  onReorder: (list: T[]) => void;
  /** 是否允许拖拽，默认恒 true；三处传 () => !readonly && enabled */
  canDrag?: () => boolean;
}

/**
 * 列表行拖拽排序（原生 HTML5 DnD）：按住把手才激活 draggable，拖拽中用本地让位列表预览，
 * 松手一次性写回。收敛 agent-market / activity-zone(活动卡+服务卡) 三处同构实现。
 */
export function useDragSort<T>(options: UseDragSortOptions<T>) {
  const rowDraggable = ref(false);
  const isDragging = ref(false);
  const dragIndex = ref(-1);
  const dragList = ref<T[]>([]) as Ref<T[]>;

  const renderList = computed<T[]>(() =>
    isDragging.value ? dragList.value : options.list(),
  );

  function handleHandleMousedown() {
    if (options.canDrag && !options.canDrag()) return;
    rowDraggable.value = true;
  }

  function handleDragStart(event: DragEvent, index: number) {
    if (!rowDraggable.value) {
      event.preventDefault();
      return;
    }
    // Firefox 不 setData 不允许起拖
    event.dataTransfer?.setData('text/plain', String(index));
    if (event.dataTransfer) event.dataTransfer.effectAllowed = 'move';
    isDragging.value = true;
    dragIndex.value = index;
    dragList.value = [...options.list()];
  }

  function handleDragOver(index: number) {
    if (!isDragging.value || index === dragIndex.value) return;
    const list = [...dragList.value];
    const [moved] = list.splice(dragIndex.value, 1);
    list.splice(index, 0, moved);
    dragList.value = list;
    dragIndex.value = index;
  }

  function handleDragEnd() {
    if (isDragging.value) options.onReorder(dragList.value);
    isDragging.value = false;
    dragIndex.value = -1;
    rowDraggable.value = false;
  }

  return {
    rowDraggable, isDragging, dragIndex, renderList,
    handleHandleMousedown, handleDragStart, handleDragOver, handleDragEnd,
  };
}
```

## 二、改造点（仅动 `<script setup>`，模板/样式零改动）
三处模板已使用的 `renderList/renderServices/renderActivities`、`isDragging`、`dragIndex`、`rowDraggable`、四个 handler、以及 `@mouseup="rowDraggable = false"` 全部由 composable 返回值直接提供，**模板一行都不用改**。

### 1. `agent-market/index.vue`
移除现有拖拽块（约 185–231 行）与 `renderList` computed（约 194 行），替换为：
```ts
import { useDragSort } from '../composables/useDragSort';
// ...
const {
  rowDraggable, isDragging, dragIndex, renderList,
  handleHandleMousedown, handleDragStart, handleDragOver, handleDragEnd,
} = useDragSort<AgentCardDTO>({
  list: () => sortedItems.value,
  canDrag: () => !readonly.value && moduleData.value.enabled,
  onReorder: list => patchModuleData({ items: list }),
});
```

### 2. `activity-zone/components/ServiceProductCard.vue`
移除拖拽块（约 348–395 行），替换为（`renderList` 别名 `renderServices`）：
```ts
import { useDragSort } from '../../composables/useDragSort';
// ...
const {
  rowDraggable, isDragging, dragIndex, renderList: renderServices,
  handleHandleMousedown, handleDragStart, handleDragOver, handleDragEnd,
} = useDragSort<ProductDTO>({
  list: () => props.data.product,
  canDrag: () => !props.readonly && props.data.enabled,
  onReorder: list => emit('patch', { product: list }),
});
```

### 3. `activity-zone/components/ActivitySelectCard.vue`
移除拖拽块（约 249–298 行），替换为（`renderList` 别名 `renderActivities`）：
```ts
import { useDragSort } from '../../composables/useDragSort';
// ...
const {
  rowDraggable, isDragging, dragIndex, renderList: renderActivities,
  handleHandleMousedown, handleDragStart, handleDragOver, handleDragEnd,
} = useDragSort<ActivityBannerDTO>({
  list: () => props.data.banner,
  canDrag: () => !props.readonly && props.data.enabled,
  onReorder: list => emit('patch', { banner: list }),
});
```
> `onReorder` 仍只 emit `banner` 重排结果；`activity-zone/index.vue` 的 `activityIdsKey` watch 依据排序后 id 集合判断，重排不改变集合 → 不触发服务产品清空，与原逻辑一致。

## 三、旧逻辑处理方式（需你知晓的假设）
本次是**行为不变的「提取式重构」**：三处重复的拖拽逻辑整体迁入 composable（git 可完整追溯），源文件中旧拖拽块**直接移除而非注释保留**。依据：根 `AGENTS.md` 明确「企服线不适用 WLYD 的注释/原内容保留等工程约定」，且企服线以 Prettier/整洁代码为规范，注释掉约 45 行 × 3 会形成噪音。
- 若你要求按物流线规则「注释保留旧代码」，我改为注释保留，请在确认时说明。

## 四、验证
- **不跑 ESLint**（企服线豁免，你已明确「不要跑 eslint，有问题再说」）。
- 跑 `pnpm type-check`（`vue-tsc --noEmit`）确认 composable 与三处消费方类型无误。
- `pnpm dev` 手动回归三处：按住把手拖动、拖动中让位预览、松手写回新顺序、只读/模块禁用时不可拖；重点验 `activity-zone` 拖活动仅重排不清空服务产品、`agent-market` 顺序正确写回 context。

## 五、假设与风险
- 假设 1：`industry-news` 不补拖拽（按你的选择「只统一已有两处」）。
- 假设 2：composable 落位 `modules/composables/`；如你更希望复用既有 `form/composables/`（与 `useSecondaryChannelFormContext` 同目录），可一句话改。
- 风险：极低。模板/样式零改动，逻辑等价迁移；唯一实现注意点是泛型 `ref<T[]>([])` 需 `as Ref<T[]>` 断言。