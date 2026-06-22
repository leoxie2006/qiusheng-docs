---
title: 常见问题
description: 安装和配置过程中常见的问题及解决方法。
lastUpdated: 2026-06-20
---

# 常见问题

记录在安装、配置和使用过程中经常遇到的问题及解决方案。

[[toc]]

## Windows 终端

### PowerShell 执行策略限制

**错误信息：**

```
无法加载文件 C:\script.ps1，因为在此系统上禁止运行脚本。
有关详细信息，请参阅 about_Execution_Policies。
```

**解决方法：**

以管理员身份运行终端，执行以下命令：

```powershell
Set-ExecutionPolicy Unrestricted
```

### xxxx 不是内部或外部命令

**错误信息：**

```
'xxxx' 不是内部或外部命令，也不是可运行程序或批处理文件。
```

**解决方法：**

1. 先重启终端再次尝试
2. 如果是通过网页下载安装的，需要手动将安装目录添加到系统环境变量 `PATH` 中
3. 如果是通过 winget 安装的，可能是文件损坏，尝试卸载后重新安装
