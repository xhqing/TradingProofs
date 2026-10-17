<div align="center">
  <img src="assets/logo.svg" alt="TradingProofs" width="640">

  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow)](LICENSE.md)
  [![Version](https://img.shields.io/badge/Version-0.1.4-blue)](CHANGELOG.md)
  [![Type](https://img.shields.io/badge/Type-Formal%20Verification-4F46E5)](#)
  [![Visitors](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/xhqing/xhqing/main/traffic/badges/TradingProofs.json)](https://github.com/xhqing)

  [English](README.md)
</div>

# TradingProofs

用 **Lean 4 + Mathlib** 把 [DayTradingAgent](https://github.com/xhqing/DayTradingAgent) 的交易数学做成机器可验证的证明——这些数学决定每笔交易能动用多少资金。

## 为什么做这个

DayTradingAgent 每笔按笔前权益的固定比例下注（`Mᵢ = f·Wᵢ₋₁`），并靠对数增长率 `g = E[ln(1 + f·R)]` 判断策略的长期前景。实盘仓位决策就站在这些推导之上——正因为如此，它们不该建立在「≈ 约等于」的口头保证上。Lean 会把每一步推理检查到公理级，并把「乘积大约等于 `e^{ng}`」这类口语表述逼成带明确前提的精确命题。

第一轮评审（2026-10-11）已经发现其中两处按字面不成立、必须改写的表述：

- `∏(1 + f·Rᵢ) ≤ (1 + f·EV)ⁿ` 只在渐近意义下成立，对每个有限的 `n` 并不成立；
- 「超过两倍凯利必然缩水」在离散两结果模型里**不成立**——有具体数值反例（`p ≈ 0.104`、`R_W ≈ 17.7`、`|R_L| ≈ 0.05` 时 `g(2f*) ≈ +0.24 > 0`），必须改写成带条件的或渐近形式的命题。

源推导文档在 DayTradingAgent 仓库：[notes/cumulative-return-derivation.md](https://github.com/xhqing/DayTradingAgent/blob/main/notes/cumulative-return-derivation.md)；两处评审发现的边界问题已在文档修订（2026-10-11）。

## 进展（0.1.0）

🚧 核心已就位、后续分层推进中：有限代数部分与强数定律增长率定理已经过机器验证——`lake build` 全绿（Lean `v4.35.0-rc4` / Mathlib `2da3ab0a`），无 `sorry`、无警告。

| # | 结论 | 出处 § | 状态 |
|---|---|---|---|
| 1 | 权益递推与连乘公式 | §1–2 | ✅ `Equity.equity_succ`、`Equity.single_trade_return` |
| 2 | 乘积的对数分解 | §3 | ✅ `Equity.log_equity` |
| 3 | 增长率 `(Wₙ/W₀)^(1/n) → e^g`（几乎必然，强大数定律） | §3、§5 | ✅ `Growth.tendsto_prod_rpow_logGrowthRate` |
| 4 | `g > 0` ⇒ 指数增长；`g < 0` ⇒ 指数衰减 | §5–6 | ✅ `Growth.eventually_equity_ge_exp`、`Growth.eventually_equity_le_exp` |
| 5 | 样本 AM-GM 与总体 Jensen 不等式 | §3–4 | 计划中 |
| 6 | 两结果精确凯利 `f*` 与正增长区间 | §6–7 | 计划中 |
| 7 | 「两倍凯利」的精确 / 近似边界 | §7.3 | 计划中 |

已证结论的完整可读推导（含 LaTeX 公式、逐条对应 Lean 定理）见 [docs/proofs.md](docs/proofs.md)。

## 构建

```bash
git clone https://github.com/xhqing/TradingProofs.git
cd TradingProofs
lake exe cache get   # 拉取 Mathlib 预编译产物
lake build
```

工具链版本锁在 `lean-toolchain`，Mathlib 版本锁在 `lake-manifest.json`；CI（GitHub Actions，`lean-action`）走同样流程。

## 形式化纪律

- 每个定理都注明出处章节与前提——`W₀ > 0`、不爆仓条件 `1 + f·Rᵢ > 0`（两结果模型即 `f·|R_L| < 1`）、`ln(1 + f·R)` 的可积性（强大数定律所需）。
- 定理陈述里不出现「≈」：近似只以显式余项界或 `IsBigO` 渐近式的形式出现。
- 「两倍凯利」类命题（「超过 `2f*` 增长率必为负」）只形式化为带条件或带误差界的版本，禁止全称断言——上文离散两结果模型的反例正说明原因。
- 定理钉死的是「写明的假设 ⇒ 结论」；假设是否贴合真实市场（收益独立、`f` 恒定、成本与滑点）在文档里单独说明，不混进定理陈述。
- 注释与文档里引用的数字都由 `scripts/` 下的脚本复算。

## 版权与署名

Copyright (c) 2026 All Contributors。基于 [MIT License](LICENSE.md) 发布。

署名：使用或引用本项目时，请保留版权声明并注明来源：[TradingProofs](https://github.com/xhqing/TradingProofs)。
