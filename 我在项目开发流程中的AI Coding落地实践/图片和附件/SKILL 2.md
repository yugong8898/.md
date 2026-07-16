---
name: git-commit
description: 自动分析git变更并生成符合Angular规范的commit信息，包含任务ID。当用户要求git提交、commit、提交代码时使用。
---

# Git Commit Helper

## 工作流程

### Step 1: 分析变更

执行以下命令获取变更信息：

```bash
git status
git diff --stat
git diff --cached --stat
```

如果没有暂存的文件，先执行 `git add .` 暂存所有变更。

### Step 2: 询问任务ID

**必须**在生成commit信息前确认任务ID。

#### 任务ID记忆规则

1. 先检查当前分支：执行 `git branch --show-current` 获取当前分支名
2. 如果在本次会话中，用户**已经为当前分支提供过任务ID**，则带上该ID让用户确认：
   - "当前分支上次使用的任务ID是 `#XXX-YYYY`，是否继续使用？"
   - 提供"继续使用"和"使用新ID"选项
3. 如果当前分支**没有历史任务ID**，则要求用户提供新的：
   - "请提供本次提交的任务ID（格式如：TASK-12345）"

### Step 3: 生成Commit信息

根据变更内容，按Angular规范生成commit信息。

#### Commit格式

```
<type>(<scope>): <subject> #<task-id>
```

#### Type类型

| type     | 说明                   |
| -------- | ---------------------- |
| feat     | 新功能                 |
| fix      | 修复bug                |
| docs     | 文档变更               |
| style    | 代码格式（不影响逻辑） |
| refactor | 重构                   |
| perf     | 性能优化               |
| test     | 测试相关               |
| chore    | 构建/工具变更          |
| ci       | CI配置变更             |

#### Scope

scope为变更影响的模块名，从变更的文件路径中推断，如：

- `src/views/capacity/` -> `capacity`
- `src/views/order/` -> `order`
- `src/components/` -> `components`
- `src/utils/` -> `utils`

#### Subject

- 用中文简要描述变更内容
- 不超过50个字符
- 不以句号结尾

#### 完整示例

```
fix(login): 重置密码功能修复正则表达式 #TASK-12345
feat(capacity): 新增车辆详情页面 #BUG-67890
refactor(order): 优化订单列表查询逻辑 #TASK-11111
```

### Step 4: 确认Commit信息

将生成的commit信息展示给用户，使用 AskUserQuestion 工具让用户确认：

- 展示完整的commit命令
- 提供"确认提交"和"修改文案"选项

**用户确认后才执行提交。**

### Step 5: 执行提交

```bash
git commit -m '<commit message>'
```

### Step 6: 处理提交失败

如果提交失败，检查错误信息：

**如果是eslint/lint-staged导致的失败**（错误信息包含 eslint、lint-staged、husky 等关键字）：

- **不修复代码**
- 直接使用 `--no-verify` 重新提交：

```bash
git commit -m '<commit message>' --no-verify
```

**如果是其他原因导致的失败**：

- 分析错误原因
- 告知用户具体问题

## 注意事项

- 任务ID是**必填项**，不可跳过
- commit信息必须包含 `#任务ID` 后缀
- scope使用英文小写
- subject使用中文描述
- 一次只生成一条commit信息，如果变更较大可建议用户拆分提交
