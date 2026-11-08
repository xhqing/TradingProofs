# TradingProofs · 项目硬约束

本文件只写本仓库（Lean 4 + Mathlib 形式化证明）特有的硬约束。通用规则（提交流程、敏感信息、TODO / CHANGELOG、输出风格等）见本仓库根 `AGENTS.md` 与全局 `~/.pi/agent/AGENTS.md`，此处不重述。

## 1. 与实盘执行完全隔离

- 本仓库只做数学证明：**不产出交易信号、不接证券账户、不执行任何下单 / 持仓 / 行情查询动作**。
- 不碰实盘凭证：`accounts.json`、`~/.tigeropen/`、任何 token / 账户号一律不读；证明需要账户相关的量时用符号变量，不引真实数据。
- 父项目的交易规则、护栏、盯盘流程在这里不适用；反过来本仓库的定理也不构成父项目策略变更的依据——要改父项目策略，按父项目的全样本统计验证流程走。

## 2. 构建与验证命令

- 工具链固定：`lean-toolchain` 锁 `leanprover/lean4:v4.35.0-rc4`，`lake-manifest.json` 锁 Mathlib commit——**不得擅自升级**。升级属独立任务，须全量 `lake build` 通过并单独提交。
- 标准验证流程（每次改完定理都跑）：

  ```bash
  lake exe cache get   # 拉预编译 Mathlib oleans（首次或依赖变更后）
  lake build           # 必须 0 error、0 warning、无 sorry
  ```

- CI（`.github/workflows/ci.yml`，lean-action，required check 名 `build`）必须绿才能合并；本地构建不过不许推 PR。

## 3. 定理红线

- **已证明通过的定理不得削弱**：`TradingProofs/Equity.lean` / `TradingProofs/Growth.lean` 里已通过验证的定理，其**签名与假设前提不得放宽、删除或改动**——删掉一个前提，等于把已证的结论换成了更强的断言，那个更强的断言并没有被证明过。
- 要改已证结论，先写清理由（原陈述哪里不准确、需要换成什么形式），改完附完整 `lake build` 结果；不许「只改陈述、不做验证」。
- **禁止 `sorry` 与新增 `axiom`**：证不出来就改陈述（补假设、写成带误差界或渐近形式），不许留洞、不许用公理凑。
- 定理陈述里**不许出现 `≈`**：近似一律写成显式余项界，或 `IsBigO` / `Tendsto` 等渐近形式。
- 每个定理必须标注来源章节（父项目 `notes/cumulative-return-derivation.md` 的 § 编号）与全部假设；假设与真实市场的差距写在注释 / 文档里，不混进定理陈述。
- 「两倍凯利」类命题只做条件或带误差界的表述（离散两结果模型有显式反例），不得写成全称断言。

## 4. 文档与数据一致性

- 文档 / 注释里引用的每个数值都必须能由 `scripts/` 下的脚本复现（如 `scripts/twice-kelly-scan.py`），不许心算后直接写死。
- `README.md` 与 `README_cn.md` 同步修改，语义内容保持一致。
- 定理状态（已证 / 计划）在 `README` 状态表、`docs/proofs.md`、`TODO.md` 三处口径一致；做完一条待办按 TODO 规则归档。

## 5. 产物与临时文件

- 构建产物 `.lake/`、`*.olean`、`*.ilean` 已 gitignore，不入库。
- 一次性验证脚本、中间输出、实验快照放 `tmp/`（已 gitignore）；不放 `TradingProofs/`、`scripts/`、`docs/`。
- 需要保留、需要复现的正式脚本放 `scripts/` 并随仓库提交。
