[中文](/README.md)

# LitRadar
[![License](https://img.shields.io/github/license/fastbiography-hue/litradar-harmonyos?style=flat-square)](LICENSE)
[![Version](https://img.shields.io/badge/version-M2-2F5496?style=flat-square)](#)
[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-PC-black?style=flat-square&logo=huawei)](https://developer.huawei.com/consumer/cn/harmonyos/)
[![ArkTS](https://img.shields.io/badge/ArkTS-API_23-blue?style=flat-square)](#)

> 📚 A biomedical literature tracking & filtering tool for **medical genetics / neurodegenerative disease** research.
>
> Zero backend · Pure native · Distributable

---

## Introduction

LitRadar is the first biomedical literature tracking tool on the HarmonyOS PC platform, supporting **multi-source parallel search**, **intelligent relevance scoring**, **offline local caching**, **scheduled auto-fetch**, and **HarmonyOS notification push**.

No Python backend required. No server needed. One HAP, install and go.

---

## Features

- 🔬 **Multi-source search**: Native direct connection to PubMed + Europe PMC APIs, concurrent multi-source fetching with auto deduplication
- 🧠 **Smart scoring engine**: 0–10 auto-scoring based on keyword hits, journal impact, citation count, and publication year. Deviation from Python reference ≤ 0.1
- 💾 **Offline-first storage**: All papers persisted to HarmonyOS local RDB. Browse history without network
- ⏰ **Scheduled auto-fetch**: WorkScheduler-based daily background task — auto-retrieve new papers at configured time
- 🔔 **Notification push**: System notification after background fetch: "X new papers today, Y high-scoring"
- 🎨 **Three-panel layout**: Left: search strategies · Center: paper list · Right: details & abstract
- 🔒 **Data privacy**: All data stored locally on device. No content uploaded to any third-party server

---

## Architecture

```
M2 Architecture (pure native, zero backend):
  ArkTS UI  →  Local RDB (primary storage)
           ↕  FetchEngine (PubMed + Europe PMC direct API)
           ↕  ScoreEngine (Jaccard dedup + 0-10 scoring)
           ↕  ConfigService (local Preferences config)
           ↕  SchedulerService + LitRadarWorker (background tasks)
           ↕  NotifyService (HarmonyOS notification center)
```

---

## Quick Start

### Option 1: DevEco Studio (Recommended)

1. Open `harmonyos_app/` with DevEco Studio (API 23/6.1.0)
2. Connect HarmonyOS PC device or emulator
3. Build → Run

Three preset search strategies are auto-configured on first launch. Click "立即抓取" (Fetch Now) to start.

### Option 2: Sideload HAP

Download the latest `.hap` from [Releases](https://github.com/fastbiography-hue/litradar-harmonyos/releases), install via [DevEcho Testing](https://developer.huawei.com/consumer/cn/deveco-testing/) or `hdc install`.

> [!NOTE]
> Self-signed HAPs are valid for 14 days by default. [Developer real-name authentication](https://developer.huawei.com/consumer/cn/verified/enrollment) extends this to 180 days.

> [!IMPORTANT]
> FetchEngine connects directly to PubMed (eutils.ncbi.nlm.nih.gov) and Europe PMC (ebi.ac.uk). A free [NCBI API Key](https://www.ncbi.nlm.nih.gov/account/) provides 3× rate limit boost.

---

## Versions

| Version | Tag | Description |
|---------|-----|-------------|
| **M2 (Current)** | `v2.0.0` | Pure ArkTS native engine, direct API calls, zero backend |
| M1 | `v1.0.0` | Python Flask backend + ArkTS frontend |

---

## Disclaimer

1. LitRadar accesses only official public APIs (PubMed E-utilities, Europe PMC REST). No scraping or paywall circumvention
2. PubMed access must comply with [NCBI Terms](https://www.ncbi.nlm.nih.gov/home/about/policies/). Registration of a free API Key is recommended
3. This software does not provide full-text PDF downloads (PDF viewer only for OA PMC papers)
4. All literature data is stored locally. No user data is collected or uploaded

---

## License

MIT © 2026 LitRadar

## Contact

GitHub Issues: [Submit Feedback](https://github.com/fastbiography-hue/litradar-harmonyos/issues)
