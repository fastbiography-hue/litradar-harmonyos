[English](/README_en.md)

# LitRadar
[![License](https://img.shields.io/github/license/fastbiography-hue/litradar-harmonyos?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/version-M2-2F5496?style=flat-square)](#)
[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-PC-black?style=flat-square&logo=huawei)](https://developer.huawei.com/consumer/cn/harmonyos/)
[![ArkTS](https://img.shields.io/badge/ArkTS-API_23-blue?style=flat-square)](#)

> 📚 面向**医学遗传学 / 神经退行性疾病**研究的文献自动追踪与智能筛选工具。
>
> 零后端 · 纯原生 · 可分发

---

## 介绍

LitRadar 是首个基于 HarmonyOS PC 平台的生物医学文献追踪工具，支持**多数据源并行检索**、**智能相关性评分**、**本地离线缓存**与**AI 辅助分析**。

无需 Python 后端，无需服务器，一个 HAP 安装即用。

使用前请仔细阅读[免责声明](#免责声明)。

---

## 软件特色

- 🔬 **多源并行检索**：原生直连 PubMed · Europe PMC，自由搜索任意关键词，自动去重合并
- 🧠 **智能评分引擎**：0–10 分自动打分，与 Python 版偏差 ≤ 0.1
- 💾 **本地离线优先**：所有文献持久化到鸿蒙本地 RDB，无网络时可浏览历史数据
- 🤖 **AI 辅助**：5 个 Provider 可选，摘要结构化解析、中文→检索式生成
- 📋 **12 种引用格式**：GB/T 7714 / APA / BibTeX / RIS 等一键导出
- 🎨 **三栏交互布局**：左栏检索策略 · 中栏文献列表 · 右栏详情摘要
- 🔒 **数据隐私**：所有数据存储在本地设备，不上传文献内容到任何第三方服务器

---

## 架构

```
M2 架构（纯原生，零后端）：
  ArkTS UI  → 本地 RDB（主存储）
           ↕  FetchEngine（PubMed + Europe PMC 直连）
           ↕  ScoreEngine（Jaccard 去重 + 0-10 评分）
           ↕  ConfigService（本地 Preferences 配置）
           ↕  SchedulerService + LitRadarWorker（后台定时）
           ↕  NotifyService（鸿蒙通知中心）
```

| 模块 | 功能 | 文件 |
|------|------|------|
| FetchEngine | PubMed E-utilities + Europe PMC REST API 直连 | `engine/FetchEngine.ets` |
| ScoreEngine | DOI/PMID/Jaccard 三级去重 + 0-10 评分 | `engine/ScoreEngine.ets` |
| DbService | 本地 RDB 读写，离线降级 | `service/DbService.ets` |
| ConfigService | 检索策略本地持久化，首次启动自动写入默认配置 | `service/ConfigService.ets` |
| SchedulerService | WorkScheduler 每日定时注册 | `service/SchedulerService.ets` |
| NotifyService | 通知中心推送新文献提醒 | `service/NotifyService.ets` |

---

## 食用方法

### 方式一：DevEco Studio 运行（推荐）

1. 用 DevEco Studio (API 23/6.1.0) 打开 `harmonyos_app/` 目录
2. 连接鸿蒙 PC 设备或模拟器
3. Build → Run

首次启动自动写入 3 组预设检索策略（AD_APOE / longread_variant / metabolic_genetics），点击"立即抓取"即可。

### 方式二：侧载 HAP

从 [Releases](https://github.com/fastbiography-hue/litradar-harmonyos/releases) 下载最新的 `.hap` 文件，使用 [DevEcho Testing](https://developer.huawei.com/consumer/cn/deveco-testing/) 或 `hdc install` 安装。

> [!NOTE]
> 自签名 HAP 默认有效期 14 天，进行[开发者实名认证](https://developer.huawei.com/consumer/cn/verified/enrollment)后可延长至 180 天。

> [!IMPORTANT]
> FetchEngine 直连 PubMed (eutils.ncbi.nlm.nih.gov) 和 Europe PMC (ebi.ac.uk)，因服务在海外，国内网络可能较慢。建议在 `ConfigService.ets` 中注册免费的 [NCBI API Key](https://www.ncbi.nlm.nih.gov/account/) 以获得 3× 速率提升。

---

## 项目结构

```
litradar-harmonyos-mvp/
├── backend/                                # Python 后端 (M1 保留，M2 不再依赖)
│   ├── litradar.py                         # 文献检索引擎 + Flask REST API
│   ├── config.yaml                         # 检索策略 & 配置
│   └── requirements.txt
│
└── harmonyos_app/                          # ArkTS 鸿蒙工程
    ├── build-profile.json5                 # API 23 (6.1.0)
    ├── hvigorfile.ts                       # Hvigor 构建入口
    ├── AppScope/app.json5                  # com.litradar.harmonyos
    ├── hvigor/
    └── entry/src/main/ets/
        ├── entryability/EntryAbility.ets
        ├── model/PaperModel.ets            # 22 字段数据模型 + API 映射
        ├── engine/                          # 原生检索引擎
        │   ├── FetchEngine.ets              # PubMed + Europe PMC 直连
        │   └── ScoreEngine.ets              # 去重 + 评分
        ├── service/
        │   ├── ConfigService.ets            # 本地配置持久化
        │   ├── DbService.ets                # RDB 读写
        │   ├── SchedulerService.ets         # 后台定时任务
        │   └── NotifyService.ets            # 通知推送
        ├── worker/LitRadarWorker.ets        # WorkScheduler Worker
        └── pages/
            ├── Index.ets                    # 三栏总布局
            ├── QueryPanel.ets               # 左栏
            ├── PaperList.ets                # 中栏
            └── PaperDetail.ets              # 右栏
```

---

## 版本演进

| 版本 | 标签 | 说明 |
|------|------|------|
| **M2 (当前)** | `v2.0.0` | 纯 ArkTS 原生引擎，直连外部 API，零后端依赖 |
| M1 | `v1.0.0` | Python Flask 后端 + ArkTS 前端 |

### M2 vs M1

```
                M1                         M2 (当前)
                ────                       ────────
架构             前后端分离                   纯原生单 HAP
后端依赖          Python/Flask                无
检索方式          Python → API                ArkTS → API (直连)
配置存储          config.yaml (文件)          Preferences (本地 KV)
评分引擎          Python score_papers()       ArkTS ScoreEngine (Jaccard)
定时任务          APScheduler                 WorkScheduler
离线可用          ❌ (API 离线则不可用)         ✅ (本地 RDB 主存储)
分发难度          需部署 Python 环境           单个 HAP 文件
```

---

## 贡献

欢迎提交 Issue 和 Pull Request。请确保代码风格与现有代码保持一致：

- 所有 ArkTS 文件使用 `@ohos.*` 系统 API，不引入第三方 npm 包
- 数据库 `papers` 表 schema 保持不变
- 接口函数名、字段名与现有代码一致

---

## 免责声明

1. LitRadar 仅通过官方公开 API（PubMed E-utilities、Europe PMC REST API）获取文献元数据，不爬取、不破解付费内容
2. PubMed 检索需遵守 [NCBI 使用条款](https://www.ncbi.nlm.nih.gov/home/about/policies/)，建议注册免费 API Key
3. 本软件不提供任何文献的全文下载功能（PDF 阅读器仅展示已 OA 的 PMC 文献）
4. 所有文献数据存储在用户本地设备，开发方不收集、不上传任何用户数据

---

## 许可证

MIT © 2026 LitRadar

## 联系

GitHub Issues: [提交反馈](https://github.com/fastbiography-hue/litradar-harmonyos/issues)
