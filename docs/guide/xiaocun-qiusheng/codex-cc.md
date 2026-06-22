---
title: Codex / Claude Code 安装与配置
description: 在 Windows 上安装 OpenAI Codex 和 Anthropic Claude Code，通过 cc-switch 接入中转站或官方 API，实测可用的完整步骤。
author: 楸晟
lastUpdated: 2026-06-20
---

# Codex / Claude Code 安装与配置

OpenAI Codex 和 Anthropic Claude Code（简称 CC）是两款终端 AI 编程助手，可以直接在命令行中帮你写代码、排查问题、生成脚本。两者都通过 npm 全局安装，配合 [cc-switch](https://github.com/farion1231/cc-switch) 可以灵活切换不同的 API 来源，解决国内网络和支付门槛问题。

本教程基于 Windows 环境实测整理，每一步都有截图对应。

> **Key Takeaways**
> - Node.js 通过 winget 一键安装，npm 源切换到阿里云镜像后下载更快
> - Codex 和 CC 都是 `npm install -g` 全局安装，装完用 `--version` 验证
> - cc-switch 是桌面代理工具，不管是中转站还是其他 API 供应商，配置方式都一样：选择渠道，填写地址和 Key，启用即可
> - PowerShell 执行策略报错见 [常见问题](/guide/faq)

[[toc]]

## 前置准备：安装 Node.js

Codex 和 Claude Code 都依赖 Node.js 运行，先把它装好。

打开终端（PowerShell 或 Windows Terminal）：

![打开终端](/xiaocun-qiusheng/codex-cc/打开终端.png)

使用 winget 安装 Node.js LTS 版本：

```bash
winget install OpenJS.NodeJS.LTS
```

> 如果没有 winget，请前往 [Microsoft 官方文档](https://learn.microsoft.com/zh-cn/windows/package-manager/winget/) 安装。

![安装 Node.js](/xiaocun-qiusheng/codex-cc/安装nodejs.png)

> **常见问题**：如果提示「在此系统上禁止运行脚本」，请参考 [常见问题](/guide/faq#powershell-执行策略限制)。

安装完成后，**重启终端**，验证安装：

```bash
node --version
npm --version
```

如果提示找不到命令，先重启终端再试。如果仍然不行，建议卸载后重新安装。

## 配置 npm 镜像源

npm 默认从国外服务器拉包，国内下载速度可能很慢。切换为阿里云镜像可以有效提速：

```bash
# 配置阿里云源为默认源
npm config set registry https://registry.npmmirror.com

# 验证配置是否生效
npm config get registry
# 预期输出：https://registry.npmmirror.com
```

实测切换镜像源后，Codex 和 CC 的安装包下载时间从几分钟缩短到十几秒。

## 安装 Codex 和 Claude Code

镜像源配好后，直接全局安装：

```bash
# 安装 OpenAI Codex
npm install -g @openai/codex

# 安装 Anthropic Claude Code
npm install -g @anthropic-ai/claude-code
```

安装完成后验证是否成功：

```bash
codex --version
claude --version
```

如果两个命令都能正常输出版本号，说明安装成功。如果提示找不到命令，先重启终端再试。

## 安装与配置 cc-switch

装好 Codex 和 CC 只是第一步，要让它们正常工作还需要接入 API。OpenAI 和 Anthropic 的官方 API 需要海外信用卡，对国内用户门槛较高。[cc-switch](https://github.com/farion1231/cc-switch) 是一个桌面代理工具，帮你统一管理不同 API 来源，在中转站、官方 API、第三方供应商之间灵活切换。

> **实测经验**：cc-switch 的渠道机制是通用的——不管你是用中转站、官方直连还是其他 API 供应商，操作流程完全一样：选择对应的渠道类型，填写请求地址和 API Key，启用即可。供应商那边通常会提供接入地址和 Key，拿到后在这里填入就行。

### 下载 cc-switch

前往 [cc-switch Releases](https://github.com/farion1231/cc-switch/releases) 下载最新版本。

![下载 cc-switch](/xiaocun-qiusheng/codex-cc/安装ccswitch.png)

> 如果网页打不开，也可以加 QQ 群获取安装包，群二维码见 [关于](/about#联系与交流) 页面。

### 配置通道

打开 cc-switch，选择 Claude Code 或 Codex，点击右上角 **+** 添加渠道：

![cc-switch 配置](/xiaocun-qiusheng/codex-cc/ccswitch配置1.png)

填写中转站的请求地址和 API Key：

![填写中转站信息](/xiaocun-qiusheng/codex-cc/ccswitch配置2.png)

部分中转站支持一键导入，省去手动填写的麻烦：

![一键导入](/xiaocun-qiusheng/codex-cc/中转一键导入ccswitch.png)

同样的方式也适用于其他 API 供应商——在渠道类型中选择对应的供应商，填入对方提供的地址和 Key 即可。添加完成后点击启用：

![启用通道](/xiaocun-qiusheng/codex-cc/ccswitch配置3.png)

## 常见问题

### 装完输入 codex 提示找不到命令？

先重启终端。如果还不行，检查 npm 全局安装路径是否在系统 PATH 中。可以在终端执行 `npm root -g` 查看全局安装路径，确认该路径已加入环境变量。

### cc-switch 启用后 Codex/CC 仍然连不上？

按顺序排查：① 确认 cc-switch 通道已勾选启用 ② 检查请求地址末尾是否多了或少了 `/` ③ 确认 API Key 没有过期 ④ 切换到其他渠道试试，排除单个供应商的故障。

### 怎么判断是哪个环节出了问题？

在终端直接运行 `codex` 或 `claude`，看报错信息。如果是网络相关报错（timeout、connection refused），问题在 cc-switch 或供应商；如果是命令找不到，问题在安装环节。

