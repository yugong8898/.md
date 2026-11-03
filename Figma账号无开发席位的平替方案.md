# Figma账号无开发席位的平替方案

### 一、背景

对于前端开发，基于Figma的设计稿以及mcp工具可以快速实现D2C方案（快速做页面还原，生成代码），但是这里需要一个前提条件，Figma账号需要有开发权限的席位，而席位是需要去官方购买的。为了不影响开发效率，同时节省成本，我们从技术角度做了一些平替方案。

### 二、方案

#### 1、选型方案

|方案|原理|Figma侧要求|限流|额外操作|最适合|
|---|---|---|---|---|---|
|figmingo\-mcp|REST API \+ PAT|免费账号 \+ 读权限 Token|仅每分钟限流，无月度上限|无|希望最接近原流程、开箱即用|
|plumb\-mcp / figma\-mcp\-go|本地插件桥接|免费账号，桌面客户端运行插件|零限流|需启动配套插件|彻底摆脱 API 限制|
|figma\-clipboard\-mcp|剪贴板解析|任意席位（含 Viewer）|零调用|每次 `⌘C` 手动复制|极轻量、不想配置 Token|
|figma\-vault|一次性拉取 \+ Git 快照|仅拉取者需有权限|固定次数|需提交快照到仓库|团队中有人无 Figma 权限|

#### 2、**Figmingo\-mcp**

**最优方案**，它在免费账号下提供了无限月度读取，功能完整度最接近原本使用的官方 MCP，接入成本也最低。如果发现 REST API 的每分钟限流在实际高频对话中仍有影响，再考虑切换到插件桥接方案（plumb\-mcp） 获得完全零限流的体验

#### 2\.1 安装前准备

在运行安装命令前，请确保你的电脑已满足以下条件：  

- 安装 Node\.js：版本需不低于 18。安装脚本会自动检测，如果没有安装，需要先自行安装。

- 准备 Figma Personal Access Token \(PAT\)：这是 figmingo\-mcp 调用 Figma REST API 的凭证。你需要登录 Figma，在 `Settings` → `Security` → `Personal access tokens` 页面生成一个具有读取权限的 Token，安装完成后会用到它。

#### 2\.2 安装

根据你的操作系统，在终端（Terminal）或 PowerShell 中执行对应的命令即可。

macOS / Linux

打开终端，执行以下命令：

```Bash
curl -fsSL https://raw.githubusercontent.com/wenym8/figmingo-mcp/main/scripts/install.sh | bash
```

Windows

以管理员身份打开 PowerShell，执行以下命令：

```PowerShell
iwr -useb https://raw.githubusercontent.com/wenym8/figmingo-mcp/main/scripts/install.ps1 | iex
```

执行上述命令后，安装脚本会自动完成以下工作：

1. 检查 Node\.js 版本（需 ≥ 18）。

2. 安装 figmingo\-mcp 包及其依赖。

3. 安装 Playwright Chromium 浏览器（约 170MB，用于 HTML 渲染和对比功能，这是一次性操作）。

4. 自动将 MCP 配置写入 Cursor。配置文件路径为 `~/.cursor/mcp.json`，脚本会自动创建或更新该文件，将 `figmingo-mcp` 添加为 MCP 服务器。

5. 复制配套的 Figma 插件到 `~/.figmingo/plugin` 目录，并在你的桌面上生成一个 `figmingo-plugin`快捷方式，方便后续在 Figma 中导入。

#### 2\.2 安装后的配置与验证

安装脚本执行完毕后，你还需要完成最后几步：

1. 重启 Cursor：为了让 Cursor 加载新的 MCP 配置，请完全关闭并重新打开 Cursor。

2. 在 Cursor 中配置 Figma PAT：打开 Cursor 的设置（`Settings` → `MCP` 或 `Cursor Settings` → `MCP Servers`），找到 `figmingo-mcp` 服务器。你需要在环境变量或相关配置项中填入之前准备好的 Figma Personal Access Token。

3. （可选）启用写回画布功能：如果你需要将设计写回 Figma 画布，需要在 Figma 桌面客户端中，通过 `Plugins` → `Development` → `Import plugin from manifest...`，选择桌面上的 `figmingo-plugin`快捷方式所指向的 `manifest.json` 文件，导入并运行配套插件。

4. 验证连接：在 Cursor 的 MCP 面板中，查看 `figmingo-mcp` 服务器的状态是否显示为已连接（通常是绿色或“Connected”）。你也可以尝试对 Cursor 的 AI 说 “Use figmingo\-mcp to get metadata from this Figma link: \[你的Figma文件链接\]”，来测试它是否能成功调用。

