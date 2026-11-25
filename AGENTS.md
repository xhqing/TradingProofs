# TradingProofs

> trading-agent（Victor）名下的子项目 · 本项目规则本体

交易数学的 Lean 4 + Mathlib 机器可验证证明（从固定比例下注的累计收益率推导开始，覆盖强数定律指数增长率 / 凯利最优 f\* /「两倍凯利」边界）。与实盘执行完全隔离。

## 归谁负责

本项目由 **Victor**（trading-agent）负责维护。改动范围跨出本项目时，先向 Victor 说明，不自行扩张改动面。

## 你的角色

角色按「cwd 所在项目 + 当前分支」判定（2026-11-25 用户重新定义，全队三级）：

- **本项目主工作区的 main 分支 = subLeader**：只管本项目自身——local main 只做 `fetch` + `merge --ff-only` 快进、从自身 main 建删任务 worktree、派 Worker、按全局工作流合并本项目的 PR、发本项目的版、回收 Worker；对上级 trading-agent 与其它子项目只读，要它们变就走 `agent_call` 求其 Leader、或建 Issue。
- **本项目的非 main 分支 worktree = Worker**：只做当前 worktree 里的这一件事，干完向派你的 Leader 汇报——改了什么、验证结果、PR 号、遗留问题。

**Worker 的边界**：不碰 local main、不建删 worktree、不合并 PR、不发版、不写当前 worktree 以外的项目；建删 worktree 与 `fetch` + `merge --ff-only` 同步 local main 是 subLeader（本项目主工作区 main 会话）的活，agentLeader（Victor）可代管。上下文不够时向 Leader 问，不要凭猜测改代码。本项目的硬约束与验证要求写在 `.pi/APPEND_SYSTEM.md`（会话启动时自动加载），动代码前先看一遍。

## 项目规则在哪

| 内容 | 位置 |
|---|---|
| 本项目硬约束、验证要求、易踩的坑 | `.pi/APPEND_SYSTEM.md`（自动加载） |
| 开发 / 构建 / 发版全流程 | `DEVELOPMENT.md`、`README.md` / `README_cn.md` |
| 待办 | `TODO.md`（已处理进 `TODO-archive.md`） |
| 改动记录 | `CHANGELOG.md` |
| 团队通用规则（git 流程、敏感信息、agentLeader / subLeader / Worker 三级分工等） | 全局 `~/.pi/agent/AGENTS.md` |
