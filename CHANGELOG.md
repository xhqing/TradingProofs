# Changelog

All notable changes to this project will be documented in this file.

## [0.1.3] - 2026-10-12

### Changed（智能体专属文件清理：随附指南迁入 README，2026-10-12）

- 按团队 2026-10-12 新规（智能体专属文件只有 Agent 项目允许拥有，非 Agent 项目一律不得存在），移除本仓库的 `CLAUDE.md` 与 `AGENTS.md`（指向 CLAUDE.md 的软链）。原「项目指南 + 父项目 CLAUDE.md 全文随附」中值得保留的形式化口径纪律已并入 README 中英双语「形式化纪律」节（补上 `W₀ > 0` 前提、可积性的用途说明、「两倍凯利」类命题只做带条件 / 带误差界形式、假设边界不混进定理陈述）；随附的父项目 CLAUDE.md 全文与过时的 `.claude/` 说明段直接删除。子项目的工作规则以父项目 DayTradingAgent 会话为准（细则见全局 `~/.claude/docs/agents-registry.md`「智能体专属文件归属与子项目映射（2026-10-12 修订）」节）。
- 顺带修一处版本一致性漂移：两份 README 的 Version 徽章从 `0.1.0` 同步到当前 `VERSION`（`0.1.2`）——0.1.1 / 0.1.2 两次 bump 只改了 VERSION 与 CHANGELOG，徽章漏更新。

## [0.1.2] - 2026-10-11

### Added（docs/proofs.md：已证结论的可读推导，2026-10-11）

- 新增 `docs/proofs.md`：把已机器验证的结论（§1–§6 共 9 条）写成带 LaTeX 公式的人类可读推导——每条标注对应的 Lean 定理名与用到的前提（H1–H5），并列出未覆盖的边界（§4 泰勒余项、§7 凯利最优、§7.3 两倍凯利 → TODO T4–T6）；README 中英双语同步加链接。

## [0.1.1] - 2026-10-11

### Notes（构建环境备忘）

- **踩坑（2026-10-11 实测）**：`lake update` 会触发 Mathlib 的 `post_update` 钩子、自动执行**全量** `lake exe cache get`（9023 个缓存文件）——本机首次立项时三分钟就把磁盘吃到只剩 1.4 GB（任务已主动中止，随后清理未完成产物）。**官方逃生口**（已核实 Mathlib `lakefile.lean` 源码第 191 行）：`MATHLIB_NO_CACHE_ON_UPDATE=1 lake update` 可整段跳过该钩子，之后按需增量拉取。磁盘紧张环境下建议始终带这个环境变量跑 `lake update`。

## [0.1.0] - 2026-10-11

### Added

- **建立本仓库（DayTradingAgent 子项目，负责人 Victor）**：把交易数学做成 Lean 4 + Mathlib 的机器可验证证明，与实盘执行完全隔离。首个目标为父项目 `notes/cumulative-return-derivation.md`（固定比例下注下的累计收益率推导）。
- **核心定理链已机器验证**（Lean `v4.35.0-rc4` / Mathlib `2da3ab0a`；`lake build` 全绿（3037 项以上）、无 `sorry`、无警告）：
  - `TradingProofs/Equity.lean`（§1–2）：`equity_succ` 单笔递推、`single_trade_return` 单笔收益率恒等于 `f·Rₙ`、`equity_pos` 不爆仓前提下的正性、`log_equity` 乘积的对数分解。
  - `TradingProofs/Growth.lean`（§3–§6）：`tendsto_log_mean` 对数收益均值的强大数定律（几乎必然收敛到 `g`）、`tendsto_prod_rpow_logGrowthRate` 几何增长率（`(∏(1+fRᵢ))^(1/n) → e^g` a.s.）、`eventually_equity_ge_exp`（`g>0` 时对任意 `c<g` 最终 `≥ W₀·e^{cn}`）与 `eventually_equity_le_exp`（`g<0` 时对任意 `g<c<0` 最终 `≤ W₀·e^{cn}`）。
- 项目脚手架：README 中英双语 + LOGO + 徽章、MIT LICENSE、CHANGELOG、VERSION、TODO、`.gitignore`、GitHub Actions CI（`lean-action` + Mathlib 缓存）、反例扫描脚本 `scripts/twice-kelly-scan.py`。
- **立项前的可行性核对（2026-10-11，实测）**：① 用 Loogle 核实 Mathlib 现成支柱（`ProbabilityTheory.strong_law_ae` 强大数定律、`strictConcaveOn_log_Ioi`、`ConcaveOn.le_map_sum`、`Real.abs_log_sub_add_sum_range_le` 泰勒余项界等）；② 数值复核源文档 §7.3 的 `f_crit = 2f*` 结论：文档例子中 `g(2f*) = −0.41% ≠ 0`（源文档自身也标注「近似形式下」），且随机扫描 50 万组两结果参数（其中约 25 万组满足 EV > 0 且 f* 可行）发现约 20% 的参数下真实临界点 `f_c > 2f*`，最极端一组 `f_c ≈ 2.19 × (2f*)` 且 `g(2f*) ≈ +0.242 > 0`——即「超过两倍凯利必然缩水」在离散两结果模型里**不是普遍成立的**，形式化时必须写成带条件的命题。

### Changed

- 父项目 `notes/cumulative-return-derivation.md` 的两处口径修正已落地（§3 不等式改渐近形式、§7.3 补边界与反例、附录二补核对脚本），记录在 DayTradingAgent 仓库的 CHANGELOG（2026-10-11 条）。

### Notes（构建环境备忘）

- 本仓库按需拉取 Mathlib 缓存：`lake exe cache get Mathlib/Probability/StrongLaw.lean` 只下依赖闭包（~2766 个 olean、~2.4 GB），比全量缓存省不少磁盘；闭包覆盖率用脚本统计（StrictLaw 的传递依赖约占 Mathlib 全库 32%）。


