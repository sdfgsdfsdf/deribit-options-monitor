# deribit-options-monitor

Deribit BTC/ETH 期权分析工具，支持 DVOL 信号、Sell Put 推荐、大宗异动监控。

基于 [lianyanshe-ai/deribit-options-monitor](https://github.com/lianyanshe-ai/deribit-options-monitor) 改进，新增 Claude Code skill 支持和深度分析框架。

## 功能特性

- **DVOL 信号分析**: Z-Score + 趋势判断 + 动态阈值 + 置信度
- **Sell Put 推荐**: APR 排序 + 流动性过滤 (spread/OI)
- **大宗异动监控**: 组合单识别 + 机构意图解读 + 市场情绪判断
- **双币种支持**: BTC 和 ETH
- **三种输出模式**: report (中文报告) / json / alert (短告警)
- **无需 API Key**: 只使用 Deribit 公共 API

## 安装 — Claude Code

```bash
git clone https://github.com/sdfgsdfsdf/deribit-options-monitor.git
cd deribit-options-monitor
bash install-claude-code.sh
```

安装完成后打开 Claude Code，直接说：

- "BTC 期权怎么样"
- "有什么收租机会"
- "ETH 期权波动率健康吗"
- "机构在做什么"

Claude 会自动调用工具获取实时数据，并做深度分析（识别组合单、解读机构意图、给出建仓建议）。

## 安装 — OpenClaw

```bash
git clone https://github.com/sdfgsdfsdf/deribit-options-monitor.git
cd deribit-options-monitor
bash install.sh
```

## 手动使用 (CLI)

```bash
# 环境准备
python3 -m venv .venv
source .venv/bin/activate
pip install requests

# 健康检查
python3 deribit-options-monitor/__init__.py doctor

# 完整报告
python3 deribit-options-monitor/__init__.py report --currency BTC --mode report

# DVOL 信号
python3 deribit-options-monitor/__init__.py dvol --currency BTC

# Sell Put 推荐
python3 deribit-options-monitor/__init__.py sell-put --currency BTC --max-delta 0.25 --min-apr 15

# 大宗异动
python3 deribit-options-monitor/__init__.py large-trades --currency BTC --min-usd-value 500000

# ETH
python3 deribit-options-monitor/__init__.py report --currency ETH --mode report
```

## CLI 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--currency` | BTC | 币种 (BTC/ETH) |
| `--min-usd-value` | 500000 | 大宗成交最小 USD 金额 |
| `--lookback-minutes` | 60 | 大宗成交回溯分钟数 |
| `--max-delta` | 0.25 | 最大 Delta 绝对值 |
| `--min-apr` | 15.0 | 最小 APR (%) |
| `--min-dte` | 7 | 最小到期天数 |
| `--max-dte` | 45 | 最大到期天数 |
| `--top-k` | 5 | 推荐合约数量 |
| `--max-spread-pct` | 10.0 | 最大 bid-ask spread (%) |
| `--min-open-interest` | 100.0 | 最小未平仓合约数 |
| `--mode` | report | 输出模式 (report/json/alert) |

## 环境要求

- Python 3.10+
- `requests` 库

## 项目结构

```
.
├── README.md
├── LICENSE
├── install.sh                  # OpenClaw 安装脚本
├── install-claude-code.sh      # Claude Code 安装脚本
├── claude-code/
│   └── skill.md                # Claude Code skill 定义
├── deribit-options-monitor/
│   ├── SKILL.md                # OpenClaw skill 定义
│   ├── __init__.py             # CLI 入口
│   ├── deribit_options_monitor.py  # 核心分析逻辑
│   └── agents/openai.yaml
├── CHANGELOG.md
└── .gitignore
```

## Claude Code Skill vs 原版的区别

原版工具的 `render_report()` 是模板化文本拼接。Claude Code skill 在此基础上增加了深度分析框架：

1. **波动率环境解读** — 不只列 DVOL 数据，解读 7d/24h 分位差异的含义
2. **Sell Put 推荐** — 计算安全垫、对比风险收益比、给出最优选及理由
3. **大宗异动深度分析** — 识别组合单（日历价差、跨式、展期）、解读机构意图、关注短期到期异动
4. **综合建仓建议** — 明确推荐合约、时机判断、风险提示

## License

MIT — 基于 [lianyanshe-ai/deribit-options-monitor](https://github.com/lianyanshe-ai/deribit-options-monitor)
