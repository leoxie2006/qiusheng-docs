import { defineAdditionalConfig, type DefaultTheme } from 'vitepress'

export default defineAdditionalConfig({
  description: '楸晟的个人知识库与项目文档。',

  themeConfig: {
    nav: nav(),

    sidebar: {
      '/guide/': { base: '/guide/', items: sidebarGuide() }
    },

    editLink: {
      pattern:
        'https://github.com/leoxie2006/qiusheng-docs/edit/main/docs/:path',
      text: '在 GitHub 上编辑此页'
    },

    footer: {
      message: '记录、沉淀、迭代。',
      copyright: 'Copyright © 2026 楸晟'
    }
  }
})

function nav(): DefaultTheme.NavItem[] {
  return [
    {
      text: '首页',
      link: '/'
    },
    {
      text: '文档',
      link: '/guide/start',
      activeMatch: '/guide/'
    },
    {
      text: '关于',
      link: '/about'
    }
  ]
}

function sidebarGuide(): DefaultTheme.SidebarItem[] {
  return [
    {
      text: '开始',
      collapsed: false,
      items: [
        { text: '文档站说明', link: 'start' },
        { text: 'Codex / CC 安装配置', link: 'codex-cc' },
        { text: 'Cloudflare Pages 部署', link: 'cloudflare-pages' },
        { text: 'Word 接入 AI (VBA + DeepSeek)', link: 'word-ai' }
      ]
    },
    {
      text: '个人博客 0-1 课程',
      collapsed: false,
      items: [
        {
          text: '阶段 0：从零搭建项目骨架',
          link: 'personal-blog/personal-blog-0'
        },
        {
          text: '阶段 1：做出你的第一个页面',
          link: 'personal-blog/personal-blog-1'
        },
        {
          text: '阶段 2：组件化和基础样式',
          link: 'personal-blog/personal-blog-2'
        }
      ]
    },
    {
      text: '常见问题',
      collapsed: false,
      items: [{ text: 'FAQ', link: 'faq' }]
    }
  ]
}
