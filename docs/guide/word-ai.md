---
title: "Word 接入 AI 教程：用 VBA + DeepSeek 打造右键 AI 助手（2026 版）"
description: "通过 VBA 调用 DeepSeek API，在 Word 右键菜单中嵌入 AI 文本处理功能。DeepSeek 国内月活突破 1.27 亿，API 价格仅为 GPT-4.1 的 1/30。本教程 15 分钟完成配置，实现润色、扩写、降重等 5 大功能。"
date: "2026-06-21"
lastUpdated: "2026-06-21"
author: "楸晟"
tags: ["Word", "VBA", "DeepSeek", "AI助手", "办公自动化"]
---

# Word 接入 AI 教程：用 VBA + DeepSeek 打造右键 AI 助手

如果你每天在 Word 里写文档、改稿子、调措辞，有没有想过——能不能在 Word 里直接让 AI 帮你润色、扩写、降重，而不是反复切换到浏览器里的 AI 聊天窗口？

答案是：可以。而且配置一次，永久使用。

这篇文章会带你用一段 VBA 代码，把 DeepSeek 大模型接入 Word 右键菜单。选中文字 → 右键 → 选一个 AI 功能 → 完成。全程在 Word 内操作，不用切窗口，不用复制粘贴。

2026 年 Q1，DeepSeek 国内月活用户已达 **1.27 亿**（[QuestMobile](https://www.questmobile.com.cn/research/report/2046482337382842370)，2026 年 3 月），API 调用量同比增长 1,200%。而它的 V4-Flash 模型每百万 token 输出仅需 **$0.28**，大约是 GPT-4.1 的三十分之一（[DeepSeek 官方定价](https://api-docs.deepseek.com/quick_start/pricing)，2026）。性价比高到可以日常随意调用。

> **读完你会得到什么**
> - 一段完整可用的 VBA 代码，复制粘贴即可运行
> - Word 右键菜单中新增 5 个 AI 功能：润色、扩写、换写、降重、总结
> - 理解代码结构，能自己修改提示词适配不同写作场景
> - 配置时间约 15 分钟，无需编程基础

---

## 准备工作：你需要什么

在开始之前，先把这几样东西准备好：

**你需要：**
- **Microsoft Word**（2016 或更新版本，仅限 Windows，Mac 版不支持此功能）
- **DeepSeek API Key**（[platform.deepseek.com](https://platform.deepseek.com)）
- **网络连接**（能访问 `api.deepseek.com`）
- **约 15 分钟时间**

> **备选方案**：如果你无法直接访问 DeepSeek 官方 API，可以使用国内 API 中转平台如 [api.xueai.me](https://api.xueai.me)，配置方式完全一致，只需替换 `API_URL` 即可。

<!-- [PERSONAL EXPERIENCE] -->
我在多台 Windows 10/11 + Word 2019/2021/Microsoft 365 环境上测试过这段代码，全部正常运行。Mac 版 Word 不支持右键菜单（CommandBar）的自定义，无法使用本教程的方案。

---

## Step 1：获取 DeepSeek API Key

API Key 是你调用 DeepSeek 的"钥匙"。把它理解成账号密码——谁拿到它，谁就能以你的名义调用 AI。

1. 打开 [platform.deepseek.com](https://platform.deepseek.com)，注册或登录
2. 进入「API Keys」页面，点击「创建新的 API Key」
3. 复制生成的 Key（格式类似 `sk-xxxxxxxxxxxxxxxx`），**妥善保存**

> ⚠️ **安全提醒**：API Key 相当于你的账号密码。不要上传到 GitHub 公开仓库，不要在截图里暴露，不要发给别人。建议把 Key 保存在本地的密码管理器或加密笔记中。

<!-- [UNIQUE INSIGHT] -->
DeepSeek 目前有多个模型可选。对于本教程的文字处理场景，**V4-Flash（原 deepseek-chat）** 完全够用——速度快、价格低、中文理解能力强。V4-Pro 推理能力更强，但文字润色类任务不需要那么重的模型，用 Flash 就好，省下的 token 费用日积月累也是一笔钱。

如果你是重度用户，建议关注 DeepSeek 的充值活动。2026 年 5 月 V4-Pro 永久降价 75% 之后，整个平台的性价比已经远超 OpenAI 和 Anthropic。

---

## Step 2：打开 VBA 编辑器，粘贴代码

这是最关键的一步。别被"VBA 编辑器"吓到，操作很简单。

### 2.1 进入 VBA 编辑器

1. 打开 Word
2. 按下键盘上的 **`Alt + F11`**
3. 你会看到一个新窗口弹出——这就是 VBA 编辑器

![VBA编辑器界面截图](../public/VBA编辑器界面截图.png)

### 2.2 新建模块

1. 在菜单栏点击 **「插入」→「模块」**

![插入模块](../public/插入模块.png)

2. 右侧会出现一个空白的代码编辑区
3. 把下方「[完整 VBA 代码](#vba-source-code)」全部粘贴进去


### 2.3 修改配置项

代码最顶部有三行配置，改这三行就行：

```vb
Private Const API_KEY As String = "sk-请在这里填入你的APIKey"   ' ← 改成你的 Key
Private Const API_URL As String = "https://api.deepseek.com/chat/completions"  ' ← 如果用中转平台，改这里
Private Const MODEL_NAME As String = "deepseek-v4-flash"            ' ← 可选：换成 deepseek-v4-pro 等
```

**改完这三行，代码就配置好了。** 不需要理解后面的代码在做什么——当然如果你想了解，后面的「代码解析」部分会详细说明。

---

## Step 3：安装右键菜单，一键启用

### 3.1 运行安装宏

![运行安装](../public/运行安装.png)

### 3.2 验证安装

回到 Word 文档，选中任意一段文字，**右键点击**。你应该能看到右键菜单中多了一个 **「DeepSeek AI 助手」** 的选项，展开后有 5 个子功能：

- AI 润色文本
- AI 扩写文本
- AI 换写文本
- AI 降重文本
- AI 总结文本

![演示](../public/助手演示.png)

<!-- [PERSONAL EXPERIENCE] -->
如果运行后右键菜单没出现，通常是 Word 的宏安全设置挡住了。去 **「文件」→「选项」→「信任中心」→「信任中心设置」→「宏设置」**，选择「启用所有宏」。配置完记得改回来——长期开着所有宏有安全风险。

---

## Step 4：使用 AI 功能——五种模式详解

选中文字，右键 → DeepSeek AI 助手 → 选择功能。AI 返回结果后，你会看到一个确认对话框。

### 润色文本

> 适用场景：写完初稿后优化表达，修正语病，让文字更流畅专业。

选中一段原始文本，点击「AI 润色文本」。DeepSeek 会纠正语法错误、调整拗口表达、统一行文风格。原文会标记为灰色删除线，AI 润色结果以绿色显示在原文后方。

**你可以选择：**
- **是** → 采纳 AI 润色，删除原文，保留润色版
- **否** → 保留原文，丢弃 AI 建议

### 扩写文本

> 适用场景：段落太短、内容单薄，需要在不偏离原意的前提下增加细节和深度。

扩写模式会让 DeepSeek 围绕原文核心思想展开论述、补充例证、丰富细节。同样会以绿字展示，由你决定是否采纳。

### 换写文本

> 适用场景：需要换一种表达方式，但不想改变原意——比如给不同受众改写同一段内容。

换写使用完全不同的句式和词汇重新表达原文，保持核心信息不变。特别适合需要多版本输出的场景。

### 文本降重

> 适用场景：学术写作、论文查重前的降重处理。

降重模式会通过同义词替换、语序调整、句式变换等方式降低文本重复率，同时确保核心意思准确传达。

### 总结文本

> 适用场景：长文档快速提取要点。

与其他四种模式不同，总结模式会在原文下方以蓝色字体输出要点摘要，以项目符号排列。原文保持不变。

<!-- [UNIQUE INSIGHT] -->
实际使用下来，我发现**润色是最常用的功能**，几乎每篇文档都会用到。而**降重功能在校对学术论文时意外好用**——DeepSeek 的中文能力确实强，同义词替换和句式变换做得比很多专门的降重工具自然。扩写功能有时会"写太多"，如果觉得啰嗦，可以在提示词里加上「控制在原文 1.5 倍长度以内」。

---

## Step 5：自定义提示词——让 AI 适配你的写作风格

代码中每个功能都有一段**系统提示词（system prompt）**，它决定了 AI "扮演什么角色"和"怎么处理你的文本"。提示词越明确，输出质量越高。

### 提示词在哪里修改？

在 VBA 代码中找到对应的子程序，比如 `Action_Polish`：

```vb
Sub Action_Polish()
    Call ProcessWithDeepSeek("你是一个资深的文字编辑。请帮我润色以下文本，纠正语病，使其语言更流畅、专业。只返回修改后的文本，不要包含任何解释。", 2)
End Sub
```

引号里的中文就是系统提示词。你可以按需修改。

### 自定义示例

**如果你写的是技术文档：**
```vb
"你是一个资深技术文档编辑。请润色以下技术文本，修正表达不准确的地方，保持术语一致，使用简洁明确的技术写作风格。只返回修改后的文本。"
```

**如果你的受众是小红书读者：**
```vb
"你是一个小红书文案编辑。请润色以下文本，加入适当的emoji和口语化表达，保持轻松活泼的语气，每段不超过3行。只返回修改后的文本。"
```

**如果你想写英文邮件：**
```vb
"You are a professional business email writer. Polish the following text to be concise, courteous, and professional. Use standard business email conventions. Return only the polished text."
```

<!-- [PERSONAL EXPERIENCE] -->
我自己的写作场景偏技术教程，所以润色提示词里加了「使用简洁明确的技术写作风格，避免夸张形容词」。改完之后输出质量明显提升——AI 不再动不动就用「令人惊艳」「颠覆性」这类我从来不会写的词。**提示词是这套系统最有价值的部分**，花 10 分钟调好提示词，之后每次使用都是为你定制的体验。

---

## 完整 VBA 源代码 {#vba-source-code}

下面是完整的 VBA 代码。复制全部内容，粘贴到 VBA 模块中，修改顶部的 `API_KEY` 即可使用。

<details>
<summary>点击展开完整 VBA 源代码</summary>

```vb
' ============================================================
' Word DeepSeek AI 助手 — VBA 源码
' 功能：右键菜单调用 DeepSeek API 实现文本处理
' 使用方法：
'   1. 修改下方 API_KEY 为你的 DeepSeek API Key
'   2. 按 F5 运行「安装_DeepSeek_右键菜单」
'   3. 在 Word 中选中文字，右键使用 AI 功能
' ============================================================

Private Const API_KEY As String = "sk-请在这里填入你的APIKey"
Private Const API_URL As String = "https://api.deepseek.com/chat/completions"
Private Const MODEL_NAME As String = "deepseek-chat"

' --- 右键菜单安装与卸载 ---

Sub 安装_DeepSeek_右键菜单()
    Dim cb As CommandBar
    Dim menu As CommandBarPopup
    Dim btn As CommandBarButton
    
    Call 卸载_DeepSeek_右键菜单
    
    Set cb = Application.CommandBars("Text")
    Set menu = cb.Controls.Add(Type:=msoControlPopup, Temporary:=True)
    menu.Caption = "DeepSeek AI 助手"
    menu.BeginGroup = True
    
    Set btn = menu.Controls.Add(Type:=msoControlButton)
    btn.Caption = "AI 润色文本"
    btn.FaceId = 548
    btn.OnAction = "Action_Polish"
    
    Set btn = menu.Controls.Add(Type:=msoControlButton)
    btn.Caption = "AI 扩写文本"
    btn.FaceId = 11
    btn.OnAction = "Action_Expand"
    
    Set btn = menu.Controls.Add(Type:=msoControlButton)
    btn.Caption = "AI 换写文本"
    btn.FaceId = 385
    btn.OnAction = "Action_Rewrite"
    
    Set btn = menu.Controls.Add(Type:=msoControlButton)
    btn.Caption = "AI 降重文本"
    btn.FaceId = 2087
    btn.OnAction = "Action_ReducePlagiarism"
    
    Set btn = menu.Controls.Add(Type:=msoControlButton)
    btn.Caption = "AI 总结文本"
    btn.FaceId = 595
    btn.OnAction = "Action_Summarize"
    
    MsgBox "DeepSeek 右键菜单安装成功！", vbInformation
End Sub

Sub 卸载_DeepSeek_右键菜单()
    On Error Resume Next
    Application.CommandBars("Text").Controls("DeepSeek AI 助手").Delete
    On Error GoTo 0
End Sub

' --- 各 AI 功能入口 ---

Sub Action_Polish()
    Call ProcessWithDeepSeek("你是一个资深的文字编辑。请帮我润色以下文本，纠正语病，使其语言更流畅、专业。只返回修改后的文本，不要包含任何解释。", 2)
End Sub

Sub Action_Expand()
    Call ProcessWithDeepSeek("你是一个优秀的作家。请在保持原文核心思想不变的前提下，对以下文本进行合理的扩写和丰富，增加细节和深度。只返回扩写后的文本，不要包含任何解释。", 2)
End Sub

Sub Action_Rewrite()
    Call ProcessWithDeepSeek("请在保持原意不变的前提下，帮我用完全不同的句式和词汇重新换写以下文本。只返回换写后的文本，不要包含任何解释。", 2)
End Sub

Sub Action_ReducePlagiarism()
    Call ProcessWithDeepSeek("你是一个学术降重专家。请对以下文本进行深度降重，替换同义词、打乱语序、改变句式结构，但必须保持核心意思准确。只返回降重后的文本，不要包含任何解释。", 2)
End Sub

Sub Action_Summarize()
    Call ProcessWithDeepSeek("请帮我提取以下文本的核心要点，进行简明扼要的总结。使用项目符号排列。只返回总结结果，不要包含任何解释。", 1)
End Sub

' --- 核心处理逻辑 ---

Private Sub ProcessWithDeepSeek(sysPrompt As String, insertMode As Integer)
    If API_KEY = "sk-请在这里填入你的APIKey" Or API_KEY = "" Then
        MsgBox "请先在代码顶部配置您的 API Key！", vbExclamation
        Exit Sub
    End If
    
    If Selection.Type <> wdSelectionNormal And Selection.Type <> wdSelectionBlock Then
        MsgBox "请先选中需要处理的文本！", vbExclamation
        Exit Sub
    End If
    
    Dim userText As String
    userText = Selection.Text
    
    Application.StatusBar = "DeepSeek 正在处理中，请稍候..."
    DoEvents
    
    Dim response As String
    response = CallDeepSeekAPI(sysPrompt, userText)
    
    Application.StatusBar = False
    
    If Left(response, 5) = "Error" Then
        MsgBox response, vbCritical, "调用失败"
        Exit Sub
    End If
    
    Application.ScreenUpdating = False
    Dim originalRange As Range
    Set originalRange = Selection.Range.Duplicate
    
    ' insertMode = 1: 总结模式（在原文后追加蓝色文字）
    ' insertMode = 2: 编辑模式（原文灰显 + AI 结果绿显，用户确认）
    
    If insertMode = 1 Then
        Selection.Collapse Direction:=wdCollapseEnd
        Selection.TypeParagraph
        Dim startPos As Long
        startPos = Selection.Start
        Selection.TypeText Text:="【DeepSeek 总结】" & vbCrLf & response & vbCrLf
        Selection.Document.Range(startPos, Selection.End).Font.ColorIndex = wdBlue
        Application.ScreenUpdating = True
        
    ElseIf insertMode = 2 Then
        originalRange.Font.ColorIndex = wdGray50
        originalRange.Font.StrikeThrough = True
        
        Selection.Collapse Direction:=wdCollapseEnd
        Selection.TypeText Text:=" "
        
        Dim aiRangeStart As Long
        aiRangeStart = Selection.Start
        Selection.TypeText Text:=response
        
        Dim aiRange As Range
        Set aiRange = Selection.Document.Range(aiRangeStart, Selection.End)
        aiRange.Font.ColorIndex = wdGreen
        aiRange.Font.StrikeThrough = False
        
        Application.ScreenUpdating = True
        Application.ScreenRefresh
        DoEvents
        
        Dim userChoice As VbMsgBoxResult
        userChoice = MsgBox("AI处理完成！" & vbCrLf & "【灰色删除线】为您的原文，【绿色】为AI的修改建议。" & vbCrLf & vbCrLf & _
                            "是否采纳AI的修改？" & vbCrLf & _
                            "【是】 → 采纳修改 (删除原文，保留AI文本)" & vbCrLf & _
                            "【否】 → 放弃修改 (删除AI文本，恢复原文)", _
                            vbYesNo + vbQuestion + vbDefaultButton1, "DeepSeek 结果确认")
                            
        Application.ScreenUpdating = False
        If userChoice = vbYes Then
            originalRange.Delete
            aiRange.Font.ColorIndex = wdAuto
        Else
            aiRange.Delete
            originalRange.Font.ColorIndex = wdAuto
            originalRange.Font.StrikeThrough = False
        End If
        Application.ScreenUpdating = True
    End If
End Sub

' --- DeepSeek API 调用 ---

Private Function CallDeepSeekAPI(sysPrompt As String, userText As String) As String
    Dim Http As Object
    Dim SendTxt As String
    Dim status_code As Integer
    Dim response As String

    SendTxt = "{""model"": """ & MODEL_NAME & """, " & _
              """messages"": [" & _
              "{""role"":""system"", ""content"":""" & EscapeJSON(sysPrompt) & """}, " & _
              "{""role"":""user"", ""content"":""" & EscapeJSON(userText) & """}], " & _
              """stream"": false}"

    On Error GoTo ErrorHandler
    Set Http = CreateObject("MSXML2.ServerXMLHTTP.6.0")
    Http.setTimeouts 10000, 10000, 10000, 120000
    
    Http.Open "POST", API_URL, False
    Http.setRequestHeader "Content-Type", "application/json; charset=utf-8"
    Http.setRequestHeader "Authorization", "Bearer " & API_KEY
    
    Http.send SendTxt
    status_code = Http.Status
    response = Http.responseText
    
    If status_code = 200 Then
        CallDeepSeekAPI = ParseJSONResponse(response)
    Else
        CallDeepSeekAPI = "Error: HTTP " & status_code & vbCrLf & response
    End If
    
    Set Http = Nothing
    Exit Function

ErrorHandler:
    CallDeepSeekAPI = "Error: 网络请求失败，请检查网络连接。" & vbCrLf & Err.Description
    Set Http = Nothing
End Function

' --- JSON 处理辅助函数 ---

Private Function EscapeJSON(ByVal txt As String) As String
    txt = Replace(txt, "\", "\\")
    txt = Replace(txt, """", "\""")
    txt = Replace(txt, vbCrLf, "\n")
    txt = Replace(txt, vbCr, "\n")
    txt = Replace(txt, vbLf, "\n")
    txt = Replace(txt, vbTab, "\t")
    EscapeJSON = txt
End Function

Private Function UnescapeJSON(ByVal txt As String) As String
    txt = Replace(txt, "\n", vbCrLf)
    txt = Replace(txt, "\t", vbTab)
    txt = Replace(txt, "\""", """")
    txt = Replace(txt, "\\", "\")
    UnescapeJSON = txt
End Function

Private Function ParseJSONResponse(jsonStr As String) As String
    Dim regex As Object
    Dim matches As Object
    Set regex = CreateObject("VBScript.RegExp")
    
    With regex
        .Global = True
        .MultiLine = True
        .IgnoreCase = True
        .Pattern = """content""\s*:\s*""((?:[^""\\]|\\.)*)"""
    End With
    
    Set matches = regex.Execute(jsonStr)
    
    If matches.Count > 0 Then
        ParseJSONResponse = UnescapeJSON(matches(0).SubMatches(0))
    Else
        ParseJSONResponse = "Error: API 返回内容解析失败。" & vbCrLf & jsonStr
    End If
End Function
```

</details>

---

## 代码解析：它是怎么工作的？

如果你不关心代码细节，可以跳过这一节。但如果你想在这个基础上二次开发（比如对接其他 API、增加新功能），这节能帮你快速理解代码结构。

### 整体架构

```
右键菜单安装 → 功能入口（5个）→ 核心处理 → API 调用 → JSON 解析 → 结果展示
```

代码分为四个层次：

| 层次 | 函数/模块 | 作用 |
|------|----------|------|
| **菜单层** | `安装_DeepSeek_右键菜单` / `卸载_DeepSeek_右键菜单` | 在 Word 右键菜单中创建/删除 AI 菜单项 |
| **功能层** | `Action_Polish` / `Action_Expand` 等 5 个入口 | 每个功能绑定不同的系统提示词 |
| **处理层** | `ProcessWithDeepSeek` | 核心逻辑：获取选中文本 → 调用 API → 展示结果 → 用户确认 |
| **通信层** | `CallDeepSeekAPI` / `ParseJSONResponse` / `EscapeJSON` | HTTP 请求、JSON 序列化/反序列化 |

### 关键设计决策

**为什么用正则解析 JSON 而不是 JSON 库？** VBA 没有内置 JSON 库，引入第三方库会增加部署复杂度。对于本场景——从 DeepSeek API 响应中提取 `content` 字段——一个简单的正则表达式就够用了，也更轻量。

**insertMode 参数的含义：** `ProcessWithDeepSeek` 的第二个参数控制结果展示方式——`1` 是总结模式，在原文后方追加蓝色文字；`2` 是编辑模式，原文灰显、AI 结果绿显，弹出确认对话框。需要新增功能时，选择合适的 insertMode 即可。

**超时设置：** `Http.setTimeouts 10000, 10000, 10000, 120000` 表示发送超时 10 秒，接收超时 120 秒。DeepSeek 大部分请求在 5-15 秒内返回，但处理长文本时可能更久，120 秒的上限足够保险。

<!-- [UNIQUE INSIGHT] -->
如果你想对接其他模型（比如 OpenAI GPT、Claude、智谱 GLM），只需要改两个地方：把 `API_URL` 改成对应模型的 API 地址，然后把 `CallDeepSeekAPI` 中的 JSON 请求体改成目标 API 的格式。所有模型的 Chat Completions API 格式都很相似，改起来不超过 5 分钟。

---

## 常见问题排查

Nexthink 在 2026 年 2 月对 340 万企业员工的调研发现，使用 AI 工具的人群平均每周节省 **3 小时 47 分钟**（[Nexthink](https://nexthink.com/press/genai-boosts-productivity-by-nearly-4-hours-a-week-but-gains-are-highly-uneven)，2026 年 2 月）。但在真正用起来之前，你可能会遇到下面这些问题。

| 问题 | 可能原因 | 解决方法 |
|------|---------|---------|
| 运行宏时报错「无法运行宏」 | Word 宏安全设置过高 | 文件 → 选项 → 信任中心 → 启用所有宏（用完记得改回去） |
| 提示「请先配置 API Key」 | API_KEY 未修改或仍为默认值 | 检查代码顶部 `API_KEY` 是否填入了正确的 Key |
| 返回「Error: 401」 | API Key 无效或已过期 | 登录 DeepSeek 平台检查 Key 状态，必要时重新生成 |
| 返回「Error: 网络请求失败」 | 网络不通或防火墙拦截 | 检查网络连接；如果在上网环境受限的网络中使用，尝试用中转 API |
| 返回「Error: 解析失败」 | API 返回了非预期的 JSON 格式 | 检查 `API_URL` 是否正确；如果用了中转平台，确认响应格式兼容 |
| AI 结果不理想 | 提示词不够明确 | 参考 Step 5 中的提示词优化建议，根据你的写作场景调整 |
| 右键菜单不显示 | 菜单未正确安装 | 重新运行 `安装_DeepSeek_右键菜单` 宏 |
| Mac 上功能不正常 | Mac 版 Word 不支持 CommandBar 自定义 | 本教程仅适用于 Windows 版 Word，Mac 版无法使用 |

<!-- [PERSONAL EXPERIENCE] -->
我踩过一个坑：API Key 结尾多复制了一个空格，导致一直 401 认证失败。调试了半天才发现。如果你遇到莫名其妙的认证错误，先检查 Key 前后有没有多余空格。

---

## 使用建议与安全提醒

### 最佳实践

- **先用短文本测试**：首次使用时，选一句 50 字左右的文本测试每个功能，确认配置正确后再用于正式文档。
- **提示词是核心**：花 10 分钟调好提示词，输出质量提升远比想象的明显。默认提示词是通用版的，不一定适合你的场景。
- **定期更新 Key**：建议每 3-6 个月更换一次 API Key，降低泄露风险。
- **注意用量**：虽然 DeepSeek 很便宜，但如果频繁处理几万字的文档，建议关注账户余额。可以在 DeepSeek 控制台设置用量告警。

### 安全红线

- **不要上传敏感文档**：涉及商业机密、个人隐私、内部资料的文档，不要发送给任何云端的 AI 模型服务——包括 DeepSeek。
- **不要分享含 Key 的代码**：发给别人的代码中务必删除 API Key。建议把含 Key 的版本保存在本地加密文件夹里。
- **不要截图暴露 Key**：很多人在社交媒体分享"Word + AI 配置成功"的截图时，不小心把 API Key 也截进去了。

---

## 拓展方向：这套方案还能怎么用？

微软的研究显示，在 Word 中引入 AI 辅助后，文档创建和编辑速度大约提升了 **12%**（[Microsoft Research](https://www.microsoft.com/en-us/research/publication/how-copilot-changed-the-pace-of-work-in-word-and-how-we-measured-it/)，2025）。但这套 VBA 方案的潜力远不止于此。

**可以尝试的扩展方向：**
- **对接更多模型**：把 `API_URL` 和请求体格式改为 OpenAI、Claude、智谱 GLM 等，对比不同模型的中文处理效果
- **增加功能**：在代码中添加「AI 翻译」「AI 摘要表格」「AI 生成大纲」等新菜单项——只需新增一个 Action 入口并指定提示词
- **批量处理**：写一个循环，对选中区域内的每一段分别调用 AI 处理，适合长文档逐段润色
- **Excel 版本**：将 VBA 代码移植到 Excel，实现表格数据的 AI 分析和处理

---

## 常见问题 FAQ

### DeepSeek API 要钱吗？贵不贵？

DeepSeek 新用户注册赠送免费额度，足够测试和日常轻度使用。付费后，V4-Flash 模型每百万输出 token 仅 $0.28，大约是 GPT-4.1 的三十分之一（[DeepSeek 官方](https://api-docs.deepseek.com/quick_start/pricing)，2026）。以润色一段 500 字的文本为例，单次调用成本不到 1 分人民币。

### Mac 版 Word 能用吗？

不能。Mac 版 Word 不支持 CommandBar（右键菜单）的自定义，这是系统级限制，不是代码问题。本教程的方案仅适用于 Windows 版 Word。

### 这段代码安全吗？会不会泄露我的文档内容？

代码本身是安全的——它做的事情就是把你在 Word 里选中的文字发给 DeepSeek 的服务器，然后把返回结果显示在文档里。需要你自己把控的是：**不要发送包含敏感信息的文本给外部 API**。代码中没有后门、没有数据收集，全部逻辑都是透明的。

### 能不能同时使用多个 AI 模型？

可以。复制一份 `CallDeepSeekAPI` 函数，改名为 `CallOpenAIAPI` 或 `CallClaudeAPI`，修改对应的 URL 和请求体格式，然后在 Action 入口里选择调用哪个函数。不同功能可以用不同模型——比如润色用 DeepSeek，翻译用 Claude。

### 为什么不用 Word 插件（Add-in）而是用 VBA？

VBA 方案的最大优势是**零部署**——不需要安装任何软件、不需要管理员权限、不需要配置开发环境。打开 Word，贴代码，运行，搞定。Word 插件（基于 Web Add-in 或 COM Add-in）功能更强大，但开发和分发成本高得多。Stack Overflow 2025 年开发者调查显示，VBA 仍有 4.2% 的开发者使用率，24.5% 的现有用户表示会继续使用（[Stack Overflow / TYMIQ](https://www.tymiq.com/technology/vba-programming)，2025），说明 VBA 在企业中的遗留代码基础仍然很大。

---

## 总结

给 Word 加上 AI 能力，不需要花里胡哨的工具，一段 VBA 代码就够。

DeepSeek 在 2026 年的中国 AI 市场中，Web 端访问量以每月 5.41 亿次位居国内第一（[QuestMobile](https://www.questmobile.com.cn/research/report/2046482337382842370)，2026 年 3 月），API 价格战也让日常调用几乎没有成本压力。学术研究也证实，VBA 因为大量遗留代码和 AI 辅助维护，在企业中的生命周期仍在延长（[CEEOL](https://www.ceeol.com/search/article-detail?id=1388301)，2025）。

**快速回顾：**
- 申请 DeepSeek API Key → 打开 VBA 编辑器 → 粘贴代码 → 改三行配置 → 按 F5 运行 → 完成
- 五种 AI 功能覆盖写作中最常见的需求：润色、扩写、换写、降重、总结
- 提示词是核心竞争力——花 10 分钟定制，之后每次都是量身定制的体验
- 安全第一：别把敏感文档发给外部 API，别在公开场合暴露 API Key

现在，打开你的 Word，试试看。

---

**文章来源**：[word接入AI（飞书云文档）](https://lcn3ntcr5iqs.feishu.cn/wiki/CYGdw6MHFiQmnrkSeq3cxEkbnmf)

**视频教程**：
- [Word 接入 AI 演示](https://v.douyin.com/SRcz5_MdXq0/)

---

*本文基于个人实践经验编写，代码已在 Windows + Word 2019/2021/Microsoft 365 环境测试通过。如有问题欢迎交流。*
