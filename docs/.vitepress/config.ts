import { defineConfig } from 'vitepress'

export default defineConfig({
  lang: 'zh-CN',
  title: '楸晟文档',
  description: '楸晟的个人知识库与项目文档。',

  lastUpdated: true,
  cleanUrls: true,
  metaChunk: true,
  srcExclude: [
    'en/**',
    'es/**',
    'fa/**',
    'ja/**',
    'ko/**',
    'pt/**',
    'ru/**',
    'zh/**'
  ],

  markdown: {
    math: true
  },

  head: [
    [
      'link',
      { rel: 'icon', type: 'image/svg+xml', href: '/qiusheng-logo.svg' }
    ],
    ['meta', { name: 'theme-color', content: '#157a6e' }],
    ['meta', { property: 'og:site_name', content: '楸晟文档' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:locale', content: 'zh_CN' }]
  ],

  themeConfig: {
    logo: { src: '/qiusheng-logo.svg', width: 28, height: 28 },
    siteTitle: '楸晟文档',
    outline: { label: '本页目录' },
    skipToContentLabel: '跳到内容',
    returnToTopLabel: '回到顶部',
    sidebarMenuLabel: '菜单',
    darkModeSwitchLabel: '外观',
    lightModeSwitchTitle: '切换到浅色模式',
    darkModeSwitchTitle: '切换到深色模式',
    docFooter: {
      prev: '上一页',
      next: '下一页'
    },
    lastUpdated: {
      text: '最后更新',
      formatOptions: {
        dateStyle: 'long',
        forceLocale: true
      }
    },
    notFound: {
      title: '页面未找到',
      quote: '这个页面还没有被写进文档。',
      linkLabel: '返回首页',
      linkText: '回到首页'
    },

    search: {
      provider: 'local',
      options: {
        translations: {
          button: {
            buttonText: '搜索文档',
            buttonAriaLabel: '搜索文档'
          },
          modal: {
            displayDetails: '显示详情',
            resetButtonTitle: '清空搜索',
            backButtonTitle: '关闭搜索',
            noResultsText: '没有找到结果',
            footer: {
              selectText: '选择',
              selectKeyAriaLabel: '回车',
              navigateText: '切换',
              navigateUpKeyAriaLabel: '上箭头',
              navigateDownKeyAriaLabel: '下箭头',
              closeText: '关闭',
              closeKeyAriaLabel: 'Esc'
            }
          }
        }
      }
    }
  }
})
