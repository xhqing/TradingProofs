# TODO 归档

> 已完成 / 已更新 / 已放弃的 TODO 条目归档。规则见全局 `~/.claude/CLAUDE.md`「待办（TODO）管理」节。

## 已完成

- [x] **T1**（记录：2026-10-11 12:45）搭建 Lean 4 + Mathlib 环境，让本仓库首个模块通过 `lake build`（本地或 CI）。✅**已完成**（完成：2026-10-11 13:13）——本机 elan 4.2.4 + Lean `v4.35.0-rc4` + Mathlib `2da3ab0a`（按需拉取 StrongLaw 闭包缓存：2766 个 olean、约 2.4 GB），`lake build` 3047 项全绿。
- [x] **T2**（记录：2026-10-11 12:45）形式化有限代数部分：§1 权益递推 `W_i = W_{i-1}(1 + f·R_i)`、§2 连乘公式 `W_n = W_0·∏(1 + f·R_i)`、单笔收益率 `= f·R_i`，以及不爆仓前提与正性引理。✅**已完成**（完成：2026-10-11 13:11）——`TradingProofs/Equity.lean`：`equity` / `equity_succ` / `single_trade_return` / `equity_pos` / `log_equity`，构建通过。
- [x] **T3**（记录：2026-10-11 12:45）形式化核心定理：强大数定律下 `(W_n/W_0)^(1/n) → e^g`（a.s.），以及 `g > 0` ⇒ 指数增长下界、`g < 0` ⇒ 指数衰减（§3、§5、§6 的精确版本）。✅**已完成**（完成：2026-10-11 13:13）——`TradingProofs/Growth.lean`：`logReturn` / `logGrowthRate` / `tendsto_log_mean` / `tendsto_prod_rpow_logGrowthRate` / `eventually_equity_ge_exp` / `eventually_equity_le_exp`，构建通过、无 `sorry`。
