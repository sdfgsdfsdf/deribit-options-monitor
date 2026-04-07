---
name: deribit-options-monitor
description: Deribit BTC/ETH 期权分析工具，支持 DVOL 波动率信号、Sell Put 收租推荐、大宗异动监控和综合报告。当用户提到 Deribit、BTC 期权、ETH 期权、DVOL、Sell Put、收租、卖 Put、大宗异动、期权波动率、卖波动率，或问"现在 BTC 有什么好的收租机会"、"期权波动率健康吗"、"ETH 期权怎么样"等意图时使用此技能。注意：只要涉及加密货币期权分析，即使用户没有明确说 Deribit 也应触发。
argument-hint: [report] [dvol] [sell-put] [large-trades] [scan] [doctor] [--currency ETH]
allowed-tools: Bash
---

Python 路径：`__PYTHON_PATH__`
工作目录：`__WORK_DIR__`

## 这个技能做什么

通过 Deribit 公共 API（无需 API Key）对 BTC/ETH 期权市场进行扫描，输出 DVOL 信号、Sell Put 收租推荐、大宗异动数据。工具同时输出结构化 JSON 数据和模板报告文本，你需要以模板报告的结构为骨架，结合 JSON 原始数据做深度分析。

## 命令映射

所有命令的基本格式：
```
cd __WORK_DIR__ && __PYTHON_PATH__ __init__.py <子命令> [参数]
```

### 参数解析

从用户输入中识别意图，映射到对应子命令：

| 用户意图 | 子命令 | 示例 |
|---------|--------|------|
| 综合分析（默认） | `report --mode report` | "BTC 期权怎么样"、"收租机会"、"看看期权" |
| 简短告警 | `report --mode alert` | "快速看一下 BTC 期权" |
| JSON 数据 | `report --mode json` | "给我 JSON 格式的期权数据" |
| DVOL 信号 | `dvol` | "波动率健康吗"、"DVOL 怎么样" |
| Sell Put 推荐 | `sell-put` | "有什么好的卖 Put 机会" |
| 大宗异动 | `large-trades` | "机构在做什么"、"大单异动" |
| 完整扫描 | `scan` | "全面扫描一下" |
| 健康检查 | `doctor` | "检查连接"、"测试一下" |

### 币种参数
- 默认 BTC，用户提到 ETH/以太坊时加 `--currency ETH`
- 用户说"两个都看"时，分别执行 BTC 和 ETH 两次

### 可选参数（用户明确提到时才使用）

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--max-delta` | 0.25 | 最大 Delta 绝对值 |
| `--min-apr` | 15.0 | 最小年化收益率 (%) |
| `--min-dte` | 7 | 最小到期天数 |
| `--max-dte` | 45 | 最大到期天数 |
| `--top-k` | 5 | 推荐合约数量 |
| `--min-usd-value` | 500000 | 大宗成交最小 USD 金额 |
| `--lookback-minutes` | 60 | 大宗成交回溯分钟数 |
| `--max-spread-pct` | 10.0 | 最大 bid-ask spread (%) |
| `--min-open-interest` | 100.0 | 最小未平仓合约数 |

## 报告结构与分析框架

`report --mode report` 输出的 JSON 包含以下关键字段：
- `spot_price`：现货价格
- `dvol`：DVOL 数据（current_dvol, z_score_7d, iv_percentile_7d, iv_percentile_24h, trend, signal, confidence, recommendation, dynamic_thresholds 等）
- `sell_put`：Sell Put 候选列表（instrument_name, strike, dte, delta, apr, premium_usd, breakeven, liquidity_score, open_interest, spread_pct 等）
- `large_trades`：大宗成交列表（instrument_name, direction, strike, dte, delta, underlying_notional_usd, premium_usd, flow_label, severity, timestamp 等）
- `report_text`：工具生成的模板报告文本
- `alert_text`：简短告警文本

### 输出方式

以工具生成的 `report_text` 模板报告结构为骨架（6个章节：市场结论 → DVOL 健康度 → Sell Put 推荐表 → 大宗异动分析 → 解读 → 策略建议），在每个章节基础上叠加你的深度分析。具体来说：

### 第一章：市场快照
在报告标题行加入现货价格和 DVOL，一眼看到全局。

### 第二章：波动率环境（基于 dvol 字段深度解读）
模板报告只列数据。你要做的额外分析：
- DVOL 当前值与 7d 均值（mean_7d）的关系，Z-Score 是否极端（±2 为极端）
- **7d 分位 vs 24h 分位的差异意味着什么**：如 24h 分位远高于 7d 说明日内波动率在抬升；反之说明在回落
- 置信度（confidence）低于 50% 说明信号较弱，不宜强烈押注方向
- 动态阈值（dynamic_thresholds 的 cv 值）反映近 30 天波动率本身的波动性
- **明确结论**：当前适合卖波动率、买波动率、还是观望？

### 第三章：Sell Put 推荐（基于 sell_put 字段深度解读）
模板报告只列表格。你要做的额外分析：
- **给出最优选及理由**（综合 APR、流动性评分 liquidity_score、Delta、spread_pct）
- **计算安全垫**：(spot_price - breakeven) / spot_price × 100%，说明现货要跌多少才会亏
- **对比各候选的风险收益比**：高 APR 但高 Delta 的合约（如 risk_emoji 为 🟡）适合激进型；低 Delta + 高流动性适合稳健型
- 如果有多个到期日的候选，分析 DTE 长短的权衡

### 第四章：大宗异动深度解读（基于 large_trades 字段——这是最关键的差异化分析）
模板报告只做简单分类统计。你要做的额外分析：

1. **识别组合单**：检查 timestamp 相近（差值 < 5000ms）的交易，可能是同一机构的组合策略：
   - 同一到期日不同 strike 的 call+put → 跨式/宽跨式
   - 同一 strike 不同到期日的买+卖 → 日历价差/展期
   - 同一合约连续多笔同方向 → 大资金分批建仓
   - 同一到期日的 sell 近月 + buy 远月 → 展期操作

2. **解读 flow_label 背后的机构意图**：
   - `premium_collect`（收取权利金）= 机构在做收租，方向中性偏多
   - `call_momentum`（Call追涨）= 看涨押注
   - `call_overwrite`（Call改仓/Covered Call）= 持有现货卖 Call 增强收益
   - `call_speculative`（投机买Call）= 长线看涨下注
   - `protective_hedge`（保护性对冲）= 买 Put 做保险，说明多头在保护头寸
   - `speculative_put`（投机Put）= 可能看空或在做价差
   - `covered_call`（备兑卖Call）= 有现货头寸的增强收益操作

3. **关注短期到期的异动**：DTE <= 3 天的大单特别值得注意，可能暗示对近期事件的对冲（宏观数据发布、链上异常等）。密集的短期 put 买盘 = 尾部风险保险信号。

4. **统计多空力量**：
   - Call buy 总额 vs Put buy 总额
   - 对冲（hedge）笔数 vs 权利金收取（premium）笔数
   - severity 为 high 的交易重点关注

### 第五章：综合结论
用表格总结：

| 维度 | 判断 |
|------|------|
| 波动率 | 中性/偏高/偏低，适合卖/买/观望 |
| 机构方向 | 偏多/偏空/中性，依据是什么 |
| 短期情绪 | 谨慎/乐观/恐慌，有无尾部风险信号 |
| 最优策略 | 具体合约 + APR + 安全垫 |
| 风险提示 | 是否应该等待，理由是什么 |

### 第六章：建仓建议
给出明确的操作建议：
- 推荐哪个合约、为什么
- 建仓时机（立刻 or 等某个到期/事件之后）
- 如果有风险信号（如短期 put 异动密集），明确说"建议等 xx 之后再入场"

## 输出格式

用中文输出，使用 markdown 格式，层次清晰。每个分析模块配合数据表格。核心原则：**不是展示数据，而是解释数据意味着什么、应该怎么做**。
