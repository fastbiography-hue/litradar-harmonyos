# M3-T01: AiService — 可插拔 AI 后端统一接口

## 目标
实现可插拔 AI 后端统一接口，支持 DeepSeek / OpenAI / Anthropic / 豆包 / 通义。

## 允许修改
- `engines/AiService.ets`（新增）
- `models/AiModel.ets`（新增）
- `services/AiConfigService.ets`（新增）
- `TASKS.md`

## 统一接口
```typescript
AiService.chat(prompt: string, model?: string): Promise<string>
AiService.translate(text: string, targetLang?: string): Promise<string>
AiService.summarize(abstractText: string, lang?: string): Promise<string>
```

## 配置字段
provider, model, apiKey, baseUrl, enabled

## 安全要求
- [ ] 不写死 API Key
- [ ] 默认不启用任何 provider
- [ ] 无 API Key 时返回明确错误
- [ ] 网络失败返回明确错误
- [ ] 所有 provider 走统一 request builder

## Commit
`feat(ai): add pluggable AI service interface`
