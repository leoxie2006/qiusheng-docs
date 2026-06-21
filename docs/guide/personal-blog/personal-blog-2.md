---
title: 阶段 2：组件化和基础样式
description: 把阶段 1 的几个页面拆成可复用的组件，加上响应式布局和空状态处理——让代码更清晰，网站更像正经产品。
author: 楸晟
lastUpdated: 2026-06-22
---

# 阶段 2：组件化和基础样式

::: tip 📌 阅读时间约 12 分钟
读完你会知道：页面和组件的区别是什么，为什么要拆组件，以及如何让你的博客在任何屏幕上都好看。
:::

## TL;DR

- 阶段 1 你用 Vue 做了 4 个页面，但现在代码可能都堆在一起——阶段 2 把公共部分拆成独立组件
- 你会得到：`Header`、`Footer`、`BlogCard`、`Layout`、`EmptyState`、`NotFound` 六个组件
- 加上响应式布局，手机上看也不乱
- 学完后你能回答：页面和组件到底有什么区别？拆组件有什么好处？404 页面为什么要有？

## 回顾阶段 1

阶段 1 你做出了能看、能跳转的博客网站。但如果你回头看一眼代码，很可能会发现：

- 每个页面都重复写了一遍导航栏
- 每个页面都重复写了一遍页脚
- 博客卡片的结构在列表页和首页各写了一次

这不是你写错了——这是阶段 1 故意这样做的，让你先看到东西跑起来。阶段 2 的目标就是**消除这些重复，让代码更干净**。
ps:当然很可能ai并没有这样重复写，有进行拆分，这样当然是极好的。

::: tip 还没做完阶段 1？
先回 [阶段 1：做出你的第一个页面](./personal-blog-1) 把静态页面和路由跑通，再来看组件化。
:::

## 为什么要把页面拆成组件？

打个比方：阶段 1 你做的是一个"一次性纸杯"——能用，但换个场景就得重新做。阶段 2 你要做的是一套"乐高积木"——每个积木独立，但可以随意组合。

拆组件有三个最直接的好处：

1. **改一处，到处生效**：导航栏的样式改了，所有页面自动更新，不用一个个改
2. **代码更短更清晰**：每个文件只干一件事，看起来不累
3. **后面加页面更快**：新页面只需要 `<Header />` + 你的内容 + `<Footer />`，三行搞定

## 让 AI 帮你做组件化改造

打开 Trae，把这段话发给 AI：

```text
现在进入阶段 2：组件化和基础样式。
请在 Vue 前端中把现有页面拆成可复用的组件：
1. Header 组件（导航栏，显示当前在哪个页面）
2. Footer 组件（页脚，版权信息等）
3. BlogCard 组件（博客卡片，列表页和首页通用）
4. Layout 组件（套在所有页面外面，包含 Header + 内容区 + Footer）
5. EmptyState 组件（列表为空时显示的友好提示）
6. NotFound 组件（404 页面，输错 URL 时显示）

另外要求：
- 所有页面改用 Layout 包裹，不要在每个页面里单独写 Header 和 Footer
- 加上响应式布局，手机和电脑上都能正常显示
- 保持阶段 1 的路由功能正常工作
```

![AI 组件化改造过程](/personal-blog/personal-blog-2/stage2-component-refactor.png)

AI 执行完后，你的 `frontend/src/` 目录大概长这样：

```text
src/
├── components/
│   ├── Header.vue          # 导航栏组件
│   ├── Footer.vue          # 页脚组件
│   ├── BlogCard.vue        # 博客卡片组件
│   ├── Layout.vue          # 布局组件（套在所有页面外面）
│   ├── EmptyState.vue      # 空状态提示组件
│   └── NotFound.vue        # 404 组件
├── views/
│   ├── Home.vue            # 首页（现在用组件拼装）
│   ├── BlogList.vue        # 博客列表（用 BlogCard 渲染）
│   ├── BlogDetail.vue      # 博客详情
│   └── About.vue           # 关于我
├── data/
│   └── posts.js            # 静态博客数据
├── router/
│   └── index.js            # 路由配置（新增 404 兜底路由）
├── App.vue
└── main.js
```

::: tip 目录结构是 AI 生成的参考
你的实际目录可能略有不同，没关系。关键是**六个组件都在，Layout 套住了所有页面**。
:::

![组件化后的目录结构](/personal-blog/personal-blog-2/stage2-structure.png)

## 这些概念搞懂了吗？

### 页面和组件有什么区别？

| | 页面（View） | 组件（Component） |
| --- | --- | --- |
| 对应什么 | 一个 URL / 路由 | 页面里的一个积木块 |
| 谁来调用 | Vue Router 根据 URL 自动匹配 | 页面或其他组件通过 `<组件名 />` 引入 |
| 举例 | `/` → `Home.vue`，`/about` → `About.vue` | `<Header />`、`<BlogCard />` |
| 能复用吗 | 通常不，一个路由对应一个页面 | 能，同一个组件可以在多处使用 |

一句话总结：**页面是目的地，组件是砖块。** 页面由组件拼装而成。

### 为什么要拆 Layout 组件？

Layout 是"套在所有页面外面的壳"。它解决了每个页面都要重复写 Header 和 Footer 的问题。

不用 Layout 时，每个页面都长这样：

```vue
<template>
  <div>
    <Header />     <!-- 每个页面都要写一遍 -->
    <main>...</main>
    <Footer />     <!-- 每个页面都要写一遍 -->
  </div>
</template>
```

用了 Layout 之后，页面只需要关心自己的内容：

```vue
<!-- Layout.vue -->
<template>
  <div>
    <Header />
    <main><slot /></main>    <!-- slot 就是"内容插在这里" -->
    <Footer />
  </div>
</template>

<!-- Home.vue —— 只写自己的内容 -->
<template>
  <Layout>
    <h1>欢迎来到我的博客</h1>
    <!-- 首页特有内容 -->
  </Layout>
</template>
```

### 组件复用的价值到底在哪？

`BlogCard` 是最直观的例子。阶段 1 你在首页和博客列表页各写了一份卡片结构。现在抽成 `BlogCard` 组件后：

- 首页用 `<BlogCard v-for="post in featuredPosts" :post="post" />`
- 列表页用 `<BlogCard v-for="post in allPosts" :post="post" />`

同一个组件，不同的数据，渲染出不同的内容。如果以后要做"相关推荐"、"搜索结果"，还是用同一个 `BlogCard`，一行代码搞定。

### 响应式布局是什么？

你打开同一个网站，在 27 寸显示器和手机上看到的布局不一样——这就是响应式布局。

核心思路：**根据屏幕宽度，自动调整布局**。

```css
/* 电脑上：一排显示 3 张卡片 */
.blog-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
}

/* 手机上（屏幕宽度 ≤ 768px）：一排只显示 1 张 */
@media (max-width: 768px) {
  .blog-grid {
    grid-template-columns: 1fr;
  }
}
```

你不用手写这些 CSS，AI 会帮你生成。但你要理解 `@media (max-width: 768px)` 这句话的意思：**当屏幕宽度小于等于 768 像素时，用这里面的样式**。

![响应式布局：电脑端](/personal-blog/personal-blog-2/stage2-responsive-desktop.png)

![响应式布局：手机端](/personal-blog/personal-blog-2/stage2-responsive-mobile.png)

### 为什么要有空状态和 404？

这两个组件属于"用户兜底体验"——不是给正常情况用的，而是给异常情况用的。

**EmptyState**：博客列表为空时，不能只显示一片空白。用户会以为页面坏了。用一个图标 + "还没有文章，敬请期待"的提示，让用户知道"这里没内容，但系统是好的"。

**NotFound（404）**：用户输错了 URL，比如 `/blgo` 而不是 `/blog`。如果没有 404 页面，用户看到的是 Vue 的默认空白页，一头雾水。加一个"页面不存在 → 返回首页"的提示，体验好得多。

```js
// router/index.js 里加一条兜底路由
{ path: '/:pathMatch(.*)*', component: NotFound }
```

这条规则的意思是：**所有没匹配到的 URL，统统走 NotFound 组件**。注意它必须放在路由数组的最后面，因为 Vue Router 是按顺序匹配的。

## 一步步跟着做

按下面 6 步走：

1. **让 AI 创建 components 目录和六个组件**
2. **把现有页面的重复代码替换成组件引用**
3. **确保 Layout 套在所有页面外面**
4. **检查路由——确认 404 兜底路由在最后**
5. **加上响应式 CSS，在不同屏幕宽度下测试**
6. **跑起来验证：所有页面正常显示、跳转正常、手机端不乱**

## 代码提交

做完验收，按照规范提交：

```bash
git checkout -b feature/components-layout
git status
git add .
git commit -m "feat: 完成组件化拆分和基础样式"
```

如果你想分得更细（推荐）：

```bash
git checkout -b feature/components-layout
# 先拆组件
git add src/components/
git commit -m "feat: 拆出 Header、Footer、BlogCard、Layout 组件"
# 再加空状态和404
git add src/components/EmptyState.vue src/components/NotFound.vue src/router/
git commit -m "feat: 添加空状态和404页面"
# 最后加响应式
git add .
git commit -m "style: 添加响应式布局适配移动端"
```

三次分开提交的好处是：如果响应式改出了问题，回退不影响已经拆好的组件。

## 学完检查：这些你都能做到吗？

做完上面所有步骤，来逐条自查：

- [ ] `Header` 和 `Footer` 各只有一个文件，所有页面通过 `Layout` 复用它们
- [ ] 改一下 `Header` 的导航文字，所有页面的导航栏一起变
- [ ] `BlogCard` 在至少两个地方被使用（首页和列表页）
- [ ] 全部页面都用 `Layout` 包裹，没有哪个页面单独引入 Header 和 Footer
- [ ] 路由最后有一条 `/:pathMatch(.*)*` 的 404 兜底规则
- [ ] 输一个不存在的 URL，能看到友好的 404 提示，而不是白屏
- [ ] 博客列表为空时，显示空状态提示，不是一片空白
- [ ] 把浏览器窗口拉窄到手机宽度，布局不会乱
- [ ] 阶段 1 的路由跳转全部正常——拆组件不应该影响功能

## 几个重要提醒

- **拆组件不改功能**：组件化的目的是整理代码结构，不是加新功能。阶段 1 的所有路由和页面内容应该保持不变
- **Layout 是关键**：如果 Layout 没套对，每个页面还是会重复 Header 和 Footer，等于白拆
- **404 路由必须放最后**：Vue Router 按顺序匹配，404 放前面会把所有正常路由都吞掉
- **响应式是加分项**：先确保组件拆分正确、路由正常，再调响应式。不要本末倒置
- **每个组件只做一件事**：Header 只管导航，Footer 只管版权，BlogCard 只管渲染一张卡片。如果 AI 给你一个巨复杂的组件，让它拆

## 常见问题

### 页面和组件，什么时候该拆，什么时候不用拆？

一个简单的判断标准：**如果一段代码在 2 个以上的地方出现，就拆成组件。** 只出现一次的东西，先不拆。过度拆分会让项目更乱。

### Layout 的 slot 是什么？

`<slot />` 是 Vue 的"插槽"机制。你可以把它理解成一个占位符——Layout 说"我这里有 Header 和 Footer，中间这块空着，你用的时候往里填内容"。具体用法去看 [Vue 官方文档的插槽章节](https://cn.vuejs.org/guide/components/slots.html)，或者直接问 AI。

### 响应式布局，手机上还是乱怎么办？

三件事排查：
1. 在浏览器开发者工具里切换到手机模式（F12 → 点左上角的手机图标），看控制台有没有 CSS 报错
2. 检查有没有 `@media (max-width: 768px)` 的样式覆盖
3. 如果 AI 没用 `viewport` meta 标签，在 `index.html` 里加上：`<meta name="viewport" content="width=device-width, initial-scale=1.0">`

### 拆完组件后路由跳不动了？

检查两件事：
1. `Layout.vue` 里有没有 `<slot />`——没有的话内容塞不进去
2. `App.vue` 里是不是还保留了 `<router-view />`——组件化改造时 AI 可能误删了它

### 404 页面和空状态要不要拆成组件？

它们就是组件。404 = `NotFound.vue`，空状态 = `EmptyState.vue`。拆出来的好处是：以后如果要在别的地方显示空状态（比如搜索结果为空），直接用就行。

### 拆完组件后，阶段 1 的验收还能过吗？

能。组件化不应该影响任何功能。路由、跳转、静态数据、页面内容——这些都不变。如果你发现某个功能坏了，优先排查是不是 AI 改代码时误删了关键部分。

---

::: tip 往前翻
[阶段 0：从零搭建项目骨架](./personal-blog-0) ← 还没搭好项目骨架的话先回去补。  
[阶段 1：做出你的第一个页面](./personal-blog-1) ← 静态页面和路由还没跑通的话先回去补。
:::

::: tip 下一步
验收全部打勾了？下一步将进入“阶段 3：Express API 和假数据”，开始第一次引入后端。
:::
