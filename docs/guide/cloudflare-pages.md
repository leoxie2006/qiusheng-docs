---
title: Cloudflare Pages 部署
description: 当前文档站在 Cloudflare Pages 上的推荐构建配置。
---

# Cloudflare Pages 部署

当前仓库保留了 VitePress 源码结构，Cloudflare Pages 需要构建 `docs` 目录下的文档站。

## 推荐配置

在 Cloudflare Pages 项目中使用下面的设置：

| 配置项 | 值 |
| --- | --- |
| Framework preset | None |
| Build command | `pnpm docs:build` |
| Build output directory | `docs/.vitepress/dist` |
| Root directory | 留空 |
| Node.js version | 20 或更高 |

## 为什么之前会显示官网首页

这个仓库原本包含 VitePress 官方文档内容，构建入口会读取 `docs` 目录。没有替换配置和首页时，Cloudflare Pages 正常构建出来的就是 VitePress 官网文档。

现在站点配置已经改成 `楸晟文档`，并且旧的多语言官方文档目录已经从构建源中排除。

## 发布流程

1. 本地修改 `docs` 目录中的 Markdown 文档。
2. 运行 `pnpm docs:build` 确认可以构建。
3. 推送到 GitHub。
4. Cloudflare Pages 自动拉取仓库并重新发布。
