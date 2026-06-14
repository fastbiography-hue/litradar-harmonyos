# LitRadar HarmonyOS MVP

生物医学文献追踪系统 — 鸿蒙PC版。

**SQLite 做脑 · Excel 做脸 · 鸿蒙三栏做交互**

---

## 项目结构

```
litradar-harmonyos-mvp/
├── backend/                         # Python REST API 后端
│   ├── litradar.py                  # 文献检索引擎 + Flask API
│   ├── config.yaml                  # 检索策略 & 配置
│   └── requirements.txt             # Python 依赖
│
└── harmonyos_app/                   # ArkTS 鸿蒙工程
    ├── build-profile.json5          # 工程级配置 (API 23)
    ├── hvigorfile.ts                # Hvigor 构建入口
    ├── AppScope/                    # 应用级配置
    ├── hvigor/                      # 构建系统
    └── entry/                       # 主模块
        └── src/main/ets/
            ├── entryability/        # EntryAbility
            ├── model/               # PaperModel 数据定义
            ├── service/             # ApiService + DbService
            └── pages/               # 三栏 UI (Index/QueryPanel/PaperList/PaperDetail)
```

---

## 快速启动

### 1. 启动 Python 后端

```bash
cd backend
pip install -r requirements.txt
python litradar.py serve --host 0.0.0.0 --port 7749
```

验证：
```bash
curl http://127.0.0.1:7749/api/health
# {"status":"ok","version":"3.1"}
```

### 2. 配置鸿蒙端 API 地址

编辑 `harmonyos_app/entry/src/main/ets/model/PaperModel.ets`：

```typescript
static readonly API_BASE = 'http://你的服务器IP:7749'
```

### 3. 用 DevEco Studio 打开 `harmonyos_app/`，Build → Run

---

## API 端点

| 方法 | 路径 | 功能 |
|------|------|------|
| GET | `/api/health` | 健康检查 |
| GET | `/api/queries` | 检索策略列表 |
| GET | `/api/papers?query_name=&limit=` | 文献查询 |
| GET | `/api/stats` | 数据库统计 |
| POST | `/api/run` | 触发文献抓取 |

---

## 数据流

```
Python 后端 (Flask :7749)
     ↑ HTTP
鸿蒙 App (ArkTS)
     ├── ApiService  ← 远程数据
     └── DbService   ← 本地 RDB 缓存 (离线降级)
```

---

## 技术栈

| 层 | 技术 |
|----|------|
| 后端 | Python 3.10+, Flask, BioPython, paperscraper, openpyxl |
| 前端 | ArkTS (API 23), Stage 模型, @ohos.net.http, @ohos.data.relationalStore |
| 数据 | SQLite (后端) + RDB (鸿蒙本地缓存) |

---

## 已知边界

- 不实现 PDF 下载（M2）
- 不实现后台定时追踪（M2）
- 不实现通知推送（M2）
- 不安装第三方 npm 包，仅使用 `@ohos.*` 系统 API

---

## License

MIT
