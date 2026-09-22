# CodeBuddy 强依赖 cursor-agent 排查报告

- 排查时间：2026-09-17 20:35 ~ 20:46 (GMT+8)
- 机器：MacBook Pro / Apple Silicon (arm64) / macOS darwin
- 结论一句话：机器上 `/Applications/cursor-agent.app` **不是 Cursor 官方组件**，是第三方「Cursor 账号池 + 本地 MITM 转 API」工具；它把两个编辑器的 HTTP 代理改成了 `127.0.0.1:9182`，从而造成 CodeBuddy 对它的强依赖。

---

## 1. 问题现象

使用 CodeBuddy 的 AI 能力时，必须保持 `cursor-agent` 这个 App 运行；一旦它没启动，CodeBuddy 的 AI 请求就失败。

## 2. 根因

### 2.1 代理配置被改写（直接原因）

以下两处用户设置被写入了相同的两行：

| 文件 | 行号 |
| --- | --- |
| `~/Library/Application Support/CodeBuddy CN/User/settings.json` | L185-186 |
| `~/Library/Application Support/Cursor/User/settings.json` | L172-173 |

内容：

```json
"http.proxy": "http://127.0.0.1:9182",
"http.proxySupport": "override"
```

`"http.proxySupport": "override"` 会**强制**编辑器内所有网络请求（含 AI 插件的请求）走该代理。
9182 端口由 `cursor-agent` 进程监听；它不启动 → 端口无监听 → 请求 `connection refused` → CodeBuddy AI 不可用。

> 注：这个配置不是 CodeBuddy 自身行为。Cursor 和 CodeBuddy CN 同为 VS Code 系，该工具扫描到后一并接管。

### 2.2 9182 端口归属确认

```
$ lsof -nP -iTCP:9182
COMMAND     PID       USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
cursor-ag 20388 limengxiao   21u  IPv4 ... TCP 127.0.0.1:9182 (LISTEN)
```

---

## 3. `/Applications/cursor-agent.app` 身份鉴定

### 3.1 基础信息

| 项 | 值 | 说明 |
| --- | --- | --- |
| Bundle ID | `com.cursor-agent.app` | 非 Cursor 官方（`com.todesktop.*` / `ai.cursor.*`） |
| 显示名 / 版本 | cursor-agent / 4.0.15 | CFBundleVersion `20260813.123125` |
| 版权 | `Copyright (c) 2025 Sanyela, Copyright (c) 2025 cali996` | 第三方个人/团队 |
| 代码签名 | `Signature=adhoc`，`TeamIdentifier=not set` | 无开发者 ID、未公证 |
| 最低系统 | macOS 10.13 | — |
| ATS | `NSExceptionDomains: ""` + `NSAllowsInsecureHTTPLoads` | 全局放行明文 HTTP |
| 安装时间 | 2026-08-13 20:31 | 与本机 9182 相关记录出现时间吻合 |

### 3.2 实际行为

配置文件：`~/Library/Application Support/com.cursor-agent.app/proxy_ca/proxy_ca_config.json`

```json
{
  "proxy": { "host": "127.0.0.1", "port": 9182 },
  "intercept": {
    "domains": ["api2.cursor.sh", "api3.cursor.sh", "api.cursor.sh", "cursor.sh"]
  },
  "upstream": {
    "selectedChannel": "2",
    "url": "https://hk.92ee.cn/v1/messages",
    "apiFormat": "anthropic",
    "selectedModel": "claude-opus-5"
  },
  "quota": { "enabled": true, "baseUrl": "https://ca.ypbin.cn:8443/api" },
  "certs": { "rootCA": { "commonName": "Cursor Hook Root CA", "organization": "Cursor Hook", "validityDays": 3650 } }
}
```

即：**本地 MITM 代理**——拦截 Cursor 官方 API 域名的 HTTPS 流量，解密后转发到第三方上游 `hk.92ee.cn`，配额计费走 `ca.ypbin.cn`。

二进制中提取到的其他能力（strings）：

- 注入 / 改机：`reset_machine_id_direct`、`hook_main_js`、`disable_cursor_auto_update_for_injection`、`restore_hook`、`forceKill`、`machineId`
- 账号体系：`wechat_login`、`check_wechat_qrcode_status`、`send_code`、`email`、`change_password`、`reset_password`、`switch_kiro_account_new`
- 远程操作面：`shell`、`shell_stream`、`write`、`delete`、`ls`、`download_update`
- 其他目标：`src/kiro/commands.rs`（Kiro 也在接管范围）
- 版本 / 控制服务器：`https://ca.ypbin.cn:8443/...`、`https://admin.92xx.vip/api/blade-system/...`、请求头 `Blade-Auth`

### 3.3 已安装的根证书（重点）

已在**系统钥匙串**中发现自签根证书：

```
名称: Cursor Hook Root CA
主体: /CN=Cursor Hook Root CA/O=Cursor Hook/C=CN
签发: 同上（自签）
有效期: 2026-08-14 05:35:12 GMT ~ 2036-08-11 05:35:12 GMT (10 年)
```

配套私钥就在 App 包内：`/Applications/cursor-agent.app/Contents/MacOS/proxy_ca_certs/root.key`

---

## 4. 风险评估

| 级别 | 风险 | 说明 |
| --- | --- | --- |
| 🔴 高 | 系统级 CA 信任 | 自签根证书装入 System Keychain，配合代理具备解密本机 HTTPS 流量的能力；私钥随包分发 |
| 🔴 高 | 代码中意外泄 | 提示词、源码、文件内容经 `hk.92ee.cn` 等第三方服务器中转，无合规保障 |
| 🟠 中 | 远程执行面 | 二进制含 shell / write / delete 等命令通道，且会关闭官方自动更新以维持注入 |
| 🟠 中 | 供应链不可信 | ad-hoc 签名、来源不明、无公证，无法验证作者身份 |
| 🟡 低 | 可用性绑定 | 上游或配额服务（ca.ypbin.cn）一挂，AI 功能立即中断 |

---

## 5. 顺带发现的遗留配置

1. `~/.zshrc` L8
   ```sh
   export ANTHROPIC_BASE_URL="https://claudecode.top"
   ```
   另一个第三方 Claude Code 中转站，同类性质。

2. `~/.codebuddy/models.json` 中**明文**存放 API Key：
   - GLM-5.2 → `https://open.bigmodel.cn/api/coding/paas/v4`
   - KIMI-K3 → `https://api.moonshot.cn/v1`
   建议尽快轮换。

3. 当前 shell 的 `HTTP_PROXY=127.0.0.1:62732` 属于 WorkBuddy 自身进程，与 9182 无关，不必处理。

---

## 6. 清理方案（需确认后执行）

> 以下操作涉及 `~/Library/Application Support/...` 与系统钥匙串，位于 WorkBuddy 目录之外，执行前需明确授权。执行前先备份。

1. 备份
   - `~/Library/Application Support/Cursor/User/settings.json`
   - `~/Library/Application Support/CodeBuddy CN/User/settings.json`
2. 删除两处 `"http.proxy"` 与 `"http.proxySupport"` 配置，重启编辑器
3. 从系统钥匙串移除 `Cursor Hook Root CA`
4. 退出并移除 `/Applications/cursor-agent.app`
   （可选一并清理 `~/Library/Application Support/com.cursor-agent.app`）
5. 处理 `~/.zshrc` 中的 `ANTHROPIC_BASE_URL`
6. 轮换 `~/.codebuddy/models.json` 中的 API Key

**前置确认**：若正在通过该渠道使用 Cursor / CodeBuddy 的模型，第 2 步之后 AI 功能会立即不可用，需先切换为官方订阅或正规 API。

---

## 附录：排查命令

```sh
# 定位 App 与二进制
find /Applications ~/.cursor /usr/local -maxdepth 6 -name "cursor-agent*"
defaults read /Applications/cursor-agent.app/Contents/Info.plist
codesign -dv /Applications/cursor-agent.app 2>&1 | head

# 端口归属
lsof -nP -iTCP:9182
netstat -an -p tcp | grep 9182

# 代理配置来源
grep -rn "9182" "~/Library/Application Support/Cursor/User/settings.json" \
                "~/Library/Application Support/CodeBuddy CN/User/settings.json"

# 根证书
security find-certificate -a -Z /Library/Keychains/System.keychain | grep -i cursor

# 二进制能力面
strings /Applications/cursor-agent.app/Contents/MacOS/cursor-agent | grep -E "9182|hook|machine_id|shell"

# MITM 配置
cat "~/Library/Application Support/com.cursor-agent.app/proxy_ca/proxy_ca_config.json"
```
