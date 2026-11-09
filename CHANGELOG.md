# Changelog

### 变更（引用同步：Victor 项目更名为 trading-agent，2026-11-09）

- **为什么改**：Victor 的 Agent 项目 2026-11-09 按新命名规定（agent 项目名一律 `<职责>-agent`、全小写）由 `DayTradingAgent` 更名为 `trading-agent`。本项目是该项目名下的子项目，README / AGENTS / 证明源码里指代主项目的名字与链接都要同步，否则文档链接会指向旧名。
- **改了什么**：`README.md` / `README_cn.md` / `AGENTS.md` / `docs/proofs.md` / `TradingProofs/Equity.lean` / `TradingProofs/Growth.lean` / `scripts/twice-kelly-scan.py` 中的 `DayTradingAgent` → `trading-agent`（含 GitHub 链接；证明内容本身不变）。

All notable changes to this project will be documented in this file.

## [Unreleased]

### 新增（子项目专属硬规则 `.pi/APPEND_SYSTEM.md`，对齐 Leader / Worker 分工）

- **为什么改**：团队 2026-11-07 用户定下全局 Leader / Worker 分工——Agent 项目根的会话是 Leader（同步子项目 local main、建 worktree、派任务、收尾），子项目根 / 子项目 worktree 的会话是 Worker（干具体的活）。Worker 启动时只加载「全局 + cwd 这一层」的上下文文件，所以子项目特有的硬规则必须写进本仓库自己的 `.pi/APPEND_SYSTEM.md` 才能被 Worker 读到；写进父项目 `AGENTS.md` 会污染其它子项目。此前的口径是「子项目规则以父项目会话为准」，Worker 模型下不再成立。
- **改了什么**：新增 `.pi/APPEND_SYSTEM.md`（仅追加、不动基线规则），只写本仓库特有约束：① 与实盘执行完全隔离（不产信号、不接证券账户、不碰凭证）；② Lean 工具链固定 + `lake exe cache get` / `lake build` 验证流程与 CI 门禁；③ 定理红线（已证定理的签名与假设不得削弱、禁 `sorry` / 新增 `axiom`、陈述里不许出现 `≈`、必标来源章节与假设、两倍凯利类只做条件表述）；④ 文档数值须由 `scripts/` 脚本复现 + 中英双语 README 同步 + 状态表口径一致；⑤ 构建产物与临时文件的位置。不重述全局与父项目的通用规则。
- **回归检查**：纯新增文件，不改任何 Lean 源码、`.pi/settings.json`、README 或 CI 配置；`lake build` 不受影响。`AGENTS.md` 软链接、`.pi` 目录引用关系保持原样。

### 变更（移除访问量徽章，配合停用集中式流量采集）

- **为什么改**：用户 2026-11-04 决定停用 xhqing 仓库的集中式访问量采集，同时不再在各仓库 README 展示访问量徽章。徽章的数据源必须由采集任务每天刷新，采集停掉之后徽章会冻结在旧值，而徽章文案写的是「Visits/day (14d)」——数字不再更新却仍显示成实时数据，留着反而误导读者。
- **改了什么**：`README.md` / `README_cn.md` 顶部徽章区删除那一枚 shields.io 访问量徽章（整行删除，数据源 `https://raw.githubusercontent.com/xhqing/xhqing/main/traffic/badges/<仓库名>.json`）；License / Version / Type 等其它徽章与正文一个字未动。
- **回归检查**：只删这一整行，徽章区所在的 `<p align="center">` / `<div>` 结构与相邻徽章不受影响；README 其余内容零改动。

### Changed（`.pi` 由软链接改为真实目录 + 资源引用，2026-10-29）

- **为什么改**：团队 2026-10-30 用户修订了子项目「智能体专属文件」的归属规则（见全局 `~/.pi/agent/docs/agents-registry.md`「智能体专属文件归属与子项目映射（2026-10-30 修订）」节）。旧做法把整个 `.pi` 挂成指向 DayTradingAgent 的软链接——好处是技能 / 扩展自动同步，坏处是本仓库**根本没法拥有自己的 pi 配置**：往 `.pi` 写任何东西都直接落进父项目的目录，影响父项目与全部兄弟子项目、并且进父项目的 git 历史。
- **改了什么**：
  - 删除 `.pi → ../DayTradingAgent/.pi` 软链接，换成真实目录 `.pi/`。
  - 新增 `.pi/settings.json`：用路径把父项目的四个资源目录引用进来（`extensions` / `skills` / `prompts` / `themes`，内容即 `~/Developer/DayTradingAgent/.pi/<目录>`），再加本仓库自己的同名本地目录（`./extensions`、`./skills`、`./prompts`、`./themes`，当前尚未创建，以后有本地内容再建即可）。引用的是**目录**而不是逐个文件，父项目以后新增的技能 / 扩展会自动带过来、零同步动作；本仓库往自己的目录里写东西也不会再回流到父项目。
  - `AGENTS.md` 软链接保持不动（仍指向 `../DayTradingAgent/AGENTS.md`）——它表征身份，必须与父项目一致，且 pi 的上下文文件机制没有 include，超集只能靠复制、复制必然漂移。
- **验证（2026-10-29 实测）**：在本仓库目录跑 `pi --approve -p`，技能从父项目目录加载成功（可用技能含 `trade`）；项目级扩展同样生效（`AskUserQuestion` 工具存在）。
- **纪律**：本仓库的 `.pi` 只允许追加自己的东西，不允许重述或覆盖父项目的基座规则（一旦重述就有两套说法、必然打架）；需要子项目专属规则时用 `.pi/APPEND_SYSTEM.md` 追加，不要用 `.pi/SYSTEM.md`（那是整体替换，会把 agent 身份冲掉）。
- **边界**：`.pi/settings.json` 里写的是父项目的绝对路径（`~` 开头）——单独 clone 本仓库到别处时引用会失效（无害，仅表现为拿不到父项目的技能 / 扩展）；这是「本仓库是 DayTradingAgent 子项目」的显式关联标记，见全局规则第 3 条。

### Changed（全局权威源迁移对齐：TODO 头部规则指针更新，2026-10-17）

- 全局能力源 2026-10-17 从 `~/.claude/` 迁至 `~/.pi/agent/`（见 `~/.claude/MOVED-TO-PI.md`），本仓库 `TODO.md` / `TODO-archive.md` 头部的全局规则指针同步改为 `~/.pi/agent/CLAUDE.md`。纯路径引用更新，规则内容不变。

## [0.1.4] - 2026-10-17

### Changed（智能体专属文件归属新规：挂两条指回父项目的软链接，2026-10-17）

- 按团队 2026-10-17 用户修订（取代 2026-10-12 的「子项目不得有智能体专属文件」规则），在仓库根新增两条相对路径软链接：`AGENTS.md → ../DayTradingAgent/AGENTS.md`、`.pi → ../DayTradingAgent/.pi`（随仓库提交）——在子项目目录直接开会话即继承 Victor 的身份 / 规则 / 技能 / 扩展 / 设置（「Agent 进驻子项目」）。规则的权威来源仍是 DayTradingAgent 一份，本仓库不放置实体副本；形式化口径纪律仍在 README 中英双语「形式化纪律」节。细则见全局 `~/.claude/docs/agents-registry.md`「智能体专属文件归属与子项目映射（2026-10-17 修订）」节。

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


