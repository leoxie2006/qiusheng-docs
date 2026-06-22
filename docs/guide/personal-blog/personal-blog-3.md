---
title: 阶段 3：Express API 和假数据
description: 第一次引入后端——用 Express 写接口返回假数据，前端用 Axios 请求，先跑通前后端联调流程，数据库后面再说。
author: 楸晟
lastUpdated: 2026-06-22
---

# 阶段 3：Express API 和假数据

::: tip 📌 阅读时间约 15 分钟
读完你会知道：后端是什么，API 是怎么让前端拿到数据的，为什么前端不能直接读后端的变量——还要搞定跨域这个前后端联调最常见的坑。
:::

## TL;DR

- 阶段 1 和 2 所有博客数据都硬编码在前端 `.js` 文件里——阶段 3 第一次把数据源搬到后端
- 你会得到 3 个 API 接口：`GET /api/posts`、`GET /api/posts/:id`、`GET /api/profile`，前端改用 Axios 请求
- 数据库先不动，数据还是假的（写在后端变量里），目标是**先把"前端 → HTTP → 后端 → 数据"这条链路跑通**
- 学完后你能回答：API 到底是什么？GET 请求是怎么一回事？为什么前端一开就报跨域错误？

## 回顾阶段 2

阶段 2 你把代码拆成了组件——`Header`、`Footer`、`BlogCard`、`Layout`。代码干净了，响应式也有了。但现在有一个绕不过去的问题：

**所有博客数据还写在前端的 `.js` 文件里。**

一个博客网站的数据写死在前端，就像餐厅的菜单刻在墙上——要改一个字都得砸墙重来。真实项目里，数据归后端管，前端只管展示。阶段 3 要做的就是把数据从"前端写死"升级到"后端提供"。

别慌——数据库留到阶段 4。这一步只是把数据搬到后端变量里。换句话说：前后端通了，数据还是假的，但架构已经和真项目一样了。

::: tip 还没做完阶段 2？
先回 [阶段 2：组件化和基础样式](./personal-blog-2) 把组件拆好、响应式调通，再来看后端。
:::

## 前后端分离到底长什么样？

在动手之前，先把"前后端分离"这四个字具象化。看一下你马上要搭出来的架构：

![前后端分离架构：前端（Vue + Axios）与后端（Express + CORS + 假数据）通过 HTTP 通信](/personal-blog/personal-blog-3/stage3-architecture.svg)

关键点就三个：
- **前端和后端跑在不同的端口上**（5173 vs 3000）——它们是两个独立的进程
- **前端通过 HTTP 请求问后端要数据**——不是直接读变量，不是 import，就是发 HTTP 请求
- **CORS 是必经之路**——浏览器默认不允许 5173 访问 3000，后端必须明确说"我允许"

## 让 AI 帮你搭建后端 API

打开 Trae，把这段话发给 AI：

```text
现在进入阶段 3：Express API 和假数据。
请在 backend 目录中创建 Express 后端，提供以下 API 接口：

1. GET /api/posts —— 返回博客列表（数组，每篇文章包含 id、title、summary、
   content、cover、createdAt）
2. GET /api/posts/:id —— 根据 id 返回单篇博客详情
3. GET /api/profile —— 返回个人信息（名字、简介、头像、社交链接）

要求：
- 数据暂时用后端变量存储（假数据），至少有 5 篇文章，先不接数据库
- 配置 CORS，允许前端跨域请求
- 前端改用 Axios 请求后端 API，不再使用静态数据文件
- 前端请求时加上 loading 和错误处理
```

![AI 搭建后端 API 过程](/personal-blog/personal-blog-3/stage3-backend-setup.png)

AI 执行完后，你的 `backend/src/` 目录大概长这样：

```text
backend/
├── src/
│   ├── data/
│   │   ├── posts.js          # 博客假数据（至少 5 篇）
│   │   └── profile.js        # 个人信息假数据
│   ├── routes/
│   │   ├── posts.js          # /api/posts 和 /api/posts/:id 路由
│   │   └── profile.js        # /api/profile 路由
│   └── index.js              # Express 入口：注册 CORS + 挂载路由
├── package.json
└── .env                      # 端口等配置（阶段 4 会加数据库配置）
```

前端也会多出变化：

```text
frontend/src/
├── api/
│   └── index.js              # Axios 实例 + 统一请求封装
├── views/
│   ├── Home.vue              # 数据从 API 获取（不再是 import 静态数据）
│   ├── BlogList.vue          # 同上
│   ├── BlogDetail.vue        # 同上
│   └── About.vue             # 同上
├── components/               # 阶段 2 的组件保持不变
│   ├── Header.vue
│   ├── Footer.vue
│   ├── BlogCard.vue
│   ├── Layout.vue
│   ├── EmptyState.vue
│   └── NotFound.vue
└── ...
```

::: tip 目录结构是 AI 生成的参考
实际可能略有不同，没关系。关键是**后端 3 个 API 都能访问到 JSON 数据，前端所有页面的数据都来自 HTTP 请求**。
:::

![后端 API 目录结构](/personal-blog/personal-blog-3/stage3-structure.png)

## 后端代码长什么样？

AI 帮你生成的 Express 入口大致是这样的（不用手写，看懂就行）：

```js
// backend/src/index.js
const express = require('express')
const cors = require('cors')
const postsRouter = require('./routes/posts')
const profileRouter = require('./routes/profile')

const app = express()
const PORT = process.env.PORT || 3000

// 1. 先注册 CORS——必须在路由前面
app.use(cors())

// 2. 注册路由
app.use('/api/posts', postsRouter)
app.use('/api/profile', profileRouter)

// 3. 启动服务器
app.listen(PORT, () => {
  console.log(`后端跑起来了：http://localhost:${PORT}`)
})
```

路由文件也很直观：

```js
// backend/src/routes/posts.js
const router = require('express').Router()
const posts = require('../data/posts')   // 假数据数组

// GET /api/posts —— 返回全部文章
router.get('/', (req, res) => {
  res.json(posts)
})

// GET /api/posts/:id —— 返回单篇文章
router.get('/:id', (req, res) => {
  const post = posts.find(p => p.id === parseInt(req.params.id))
  if (!post) {
    return res.status(404).json({ message: '文章不存在' })
  }
  res.json(post)
})

module.exports = router
```

看点在哪？三件事：
1. `router.get('/')` 对应 `GET /api/posts`——路径是拼起来的（`/api/posts` + `/`）
2. `router.get('/:id')` 里的 `:id` 是动态参数——`req.params.id` 能拿到 URL 里的值
3. `res.json(...)` 把数据转成 JSON 返回给前端——前端 Axios 收到的就是这个

## 前端怎么接后端数据？

以前你的前端是这样拿数据的：

```js
// ❌ 阶段 1/2 的做法：import 静态数据
import { posts } from '../data/posts'
const blogList = posts
```

现在换成这样：

```js
// ✅ 阶段 3 的做法：通过 HTTP 请求拿数据
import api from '../api'

const blogList = ref([])
const loading = ref(true)
const error = ref(null)

async function fetchPosts() {
  loading.value = true
  error.value = null
  try {
    const res = await api.get('/api/posts')
    blogList.value = res.data
  } catch (err) {
    error.value = '加载失败，请确认后端已启动'
  } finally {
    loading.value = false
  }
}
```

注意多了什么？`loading` 和 `error`。阶段 1 和 2 数据是本地的、同步的，拿数据不花时间。现在数据要走网络——后端可能没启动、网络可能慢、可能返回 500。不给用户反馈就是白屏，体验极差。

`api/index.js` 长这样——封装一次，全部页面共用：

```js
// frontend/src/api/index.js
import axios from 'axios'

const api = axios.create({
  baseURL: 'http://localhost:3000',   // 后端地址
  timeout: 5000                        // 5 秒超时
})

export default api
```

以后要改接口地址？只改这一个文件就行。这就是封装的价值。

## 这些概念搞懂了吗？

### 什么是 API？

API 全称 Application Programming Interface。不用记全称——一句话：**API 是前端和后端之间的约定——前端说"我要这个"，后端说"给你这个"**。

| 前端（浏览器） | → HTTP 请求 → | 后端（服务器） |
| --- | --- | --- |
| "博客列表有吗？" | `GET /api/posts` | `[{id:1, title:"..."}, ...]` |
| "第 3 篇是啥？" | `GET /api/posts/3` | `{id:3, title:"...", content:"..."}` |
| "你是谁？" | `GET /api/profile` | `{name:"...", bio:"..."}` |

URL 就是问题，JSON 就是答案。就这么简单。

### 什么是 HTTP 请求？

浏览器地址栏输网址按回车，背后就是一个 HTTP 请求。每个请求包含三要素：

- **方法**：想干什么？`GET` 是拿数据，`POST` 是提交数据（阶段 5）
- **URL**：找谁？比如 `/api/posts/3`
- **响应**：后端回了什么？JSON、HTML、或一个错误状态码

阶段 3 你只用 `GET`——只读不写，还没到提交和修改的阶段。但理解了这个，后面的 `POST`、`PUT`、`DELETE` 只是方法名不同而已，套路完全一样。

### 前端为什么不能 import 后端的数据文件？

你可能想过：前后端都在我电脑上，前端直接 `import` 后端的数据文件不就行了？

**不行。** 前端代码跑在**浏览器**里，后端代码跑在 **Node.js** 里——这是两个完全隔离的运行时。浏览器没有文件系统权限，读不到你硬盘上的 `posts.js`；Node.js 也没有 DOM，操作不了页面。

通信只能靠 HTTP：后端启动一个服务器监听端口，前端通过浏览器向这个端口发请求，后端收到后返回 JSON。这就是"前后端分离"最底层的逻辑。

### 跨域到底是怎么回事？

这是阶段 3 最常见的坑，踩一次记一辈子。前端请求 `localhost:3000`，浏览器控制台大概率报：

```text
Access to XMLHttpRequest at 'http://localhost:3000/api/posts'
from origin 'http://localhost:5173' has been blocked by CORS policy
```

翻译：**浏览器不允许 `localhost:5173` 访问 `localhost:3000`，因为端口不同——浏览器认为这是两个不同的"域"**。

为什么浏览器要这样设计？安全。如果没有同源策略，你打开一个恶意网站，它就能偷偷请求你本地 3000 端口的服务，把数据偷走。

那你怎么合法跨域？后端装 `cors` 包，明确告诉浏览器"我允许跨域访问"：

```js
const cors = require('cors')
app.use(cors())   // 必须在路由注册之前
```

搞定。加完这一行，前端就能正常请求了。

### GET 和其他 HTTP 方法的区别？

阶段 3 只用 `GET`，但提前看一眼全局没坏处：

| 方法 | 干什么 | 举例 | 什么时候用 |
| --- | --- | --- | --- |
| `GET` | 拿数据 | 获取文章列表 | 阶段 3 ← 你现在在这 |
| `POST` | 新建 | 发布一篇新文章 | 阶段 5 |
| `PUT` / `PATCH` | 修改 | 编辑文章标题 | 阶段 5 |
| `DELETE` | 删除 | 删掉一篇文章 | 阶段 5 |

`GET` 的特点：只读、幂等（请求 10 次结果一样）、参数拼在 URL 上。万丈高楼从 GET 起，后面几个阶段只是方法名换一下。

## 一步步跟着做

按下面 7 步走，每一步做完验证了再进下一步：

1. **初始化后端项目**
   ```bash
   cd backend
   npm init -y
   npm install express cors
   npm install -D nodemon    # 自动重启，改了代码不用手动重启
   ```
   在 `package.json` 里加启动脚本：`"dev": "nodemon src/index.js"`

2. **创建假数据和路由**——让 AI 生成 `data/posts.js`（至少 5 篇文章）、`data/profile.js`、`routes/posts.js`、`routes/profile.js`、`src/index.js`

3. **启动后端验证**——`npm run dev`，浏览器访问 `http://localhost:3000/api/posts`，看到 JSON 数据就是对了

4. **前端装 Axios 并封装**
   ```bash
   cd ../frontend
   npm install axios
   ```
   创建 `src/api/index.js`，封装 `axios.create({ baseURL: 'http://localhost:3000' })`

5. **改造前端页面**——找到每个用了 `import ... from '../data/posts'` 的地方，换成 `api.get('/api/posts')`，加上 `loading` / `error` 状态

6. **同时启动前后端**——开两个终端窗口，一个跑 `npm run dev`（后端），一个跑 `npm run dev`（前端），在浏览器验证全部页面

7. **故意关掉后端，看前端表现**——确认前端不会白屏，而是显示"加载失败"之类的提示

## 代码提交

做完验收，按规范提交：

```bash
git checkout -b feature/posts-api
git status
git add .
git commit -m "feat: Express API 和假数据，前后端联调"
```

推荐分三次提交，出问题好回退：

```bash
git checkout -b feature/posts-api

# 第一次：后端
git add backend/
git commit -m "feat: 创建 Express 后端和假数据 API"

# 第二次：前端对接
git add frontend/src/api/ frontend/src/views/
git commit -m "feat: 前端改用 Axios 请求后端 API"

# 第三次：loading 和错误处理
git add .
git commit -m "feat: 添加请求 loading 状态和错误提示"
```

## 学完检查：这些你都能做到吗？

做完上面所有步骤，逐条自查：

- [ ] 后端 `npm run dev` 能启动，浏览器访问 `localhost:3000/api/posts` 能看到 JSON 数组
- [ ] 访问 `localhost:3000/api/posts/1` 只返回第 1 篇文章，不是全部
- [ ] 访问 `localhost:3000/api/profile` 能拿到个人信息 JSON
- [ ] 访问一个不存在的 id（比如 `/api/posts/999`），能返回 404 而不是崩掉
- [ ] 前端所有页面的数据都来自 HTTP 请求，不再 import 静态数据文件
- [ ] 打开浏览器 F12 → Network 面板，能看到前端发出的 API 请求
- [ ] 控制台不报 CORS 跨域错误
- [ ] 后端关掉后刷新前端，页面显示错误提示而不是白屏
- [ ] 阶段 2 的所有功能（路由跳转、组件展示、响应式布局）不受影响
- [ ] 改一下后端假数据里的文章标题，刷新前端能看到变化

## 几个重要提醒

- **先别碰数据库**：阶段 3 只管跑通"前端 → HTTP → 后端 → 数据"这条链路。数据在后端变量里完全够用，加数据库反而把问题搅在一起
- **CORS 是第一个要过的关**：跨域不搞定，什么都调不通。如果 AI 没加 CORS，手动让它补上——就两行代码的事
- **字段名要对齐**：后端返回的 JSON key（`title`、`summary`、`createdAt`）必须和前端模板里用的字段名完全一致。大小写不同、下划线和中划线搞混——这是联调阶段最常见的 bug，一查一下午
- **loading 和 error 不是可选项**：阶段 3 之前数据是同步的，现在变成异步了。网络有延迟，后端也可能挂。不给用户反馈的页面，用户会以为你的网站坏了
- **API 封装到一个文件**：不要在 4 个 `.vue` 文件里各写一遍 `axios.get('http://localhost:3000/api/...')`。建一个 `api/index.js` 统一管理，以后换端口、加拦截器、加 token，都只改这一个文件

## 常见问题

### 后端启动了，前端请求一直转圈？

三步排查：
1. 前端 Axios 的 `baseURL` 是不是 `http://localhost:3000`？端口号对得上吗？
2. 后端有没有注册 `app.use(cors())`？而且是在路由注册**之前**？
3. 后端终端有没有报错？路由路径拼对了吗？

### CORS 配了还是报跨域？

确认 `app.use(cors())` 写在 `app.use('/api/posts', ...)` **前面**。Express 中间件按顺序执行——CORS 写后面等于请求到了路由还没过 CORS，照样拦截。

### 改了后端数据，前端刷新不更新？

两件事：
1. F12 → Network 面板 → 勾选 "Disable cache"——浏览器可能缓存了旧响应
2. 确认后端真的重启了——用 `nodemon` 而不是 `node`，改代码自动重启

### 页面刷新后数据丢了？

阶段 3 数据在后端变量里，只要后端进程不重启，数据就在。刷新丢数据？大概率是前端还在用本地的静态数据文件，检查 `import` 语句清干净了没。

### 假数据和真数据的区别到底在哪？

现在没区别——都是 JavaScript 变量。区别是来源：假数据是代码里手写的数组，真数据在 MySQL 数据库里。阶段 4 会把 `require('../data/posts')` 换成 `db.query('SELECT * FROM posts')`，但 API 接口的 URL 和返回格式**完全不变**——这就是前后端分离的好处。

### 前端一定要用 Axios？浏览器自带的 fetch 不行吗？

可以。但 Axios 对新手有四个实打实的好处：自动解析 JSON（fetch 要多写一行 `.json()`）、能设超时时间、有拦截器、错误处理更直观。现阶段用 Axios 是为了让你关注"前后端怎么通信"，而不是花时间研究请求工具怎么用。

---

::: tip 往前翻
[阶段 0：从零搭建项目骨架](./personal-blog-0) ← 还没搭好项目骨架的话先回去补。  
[阶段 1：做出你的第一个页面](./personal-blog-1) ← 静态页面和路由还没跑通的话先回去补。  
[阶段 2：组件化和基础样式](./personal-blog-2) ← 组件还没拆好的话先回去补。
:::

::: tip 下一步
验收全部打勾了？去 [阶段 4：接入 MySQL 数据库](./personal-blog-4)，把后端假数据换成真正的数据库——数据持久化，重启也不会丢。
:::
