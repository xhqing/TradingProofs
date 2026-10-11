# 固定比例下注的指数增长：已机器验证的推导

> **本文是什么**：把 `TradingProofs/Equity.lean` 与 `TradingProofs/Growth.lean` 里**已经过 Lean 4 + Mathlib 机器验证**的结论，用人类可读的数学推导写一遍，每条结论标注对应的 Lean 定理名与前提。
>
> **与源文档的关系**：非形式化的原始推导见 DayTradingAgent 仓库的 [`notes/cumulative-return-derivation.md`](https://github.com/xhqing/DayTradingAgent/blob/main/notes/cumulative-return-derivation.md)；本文只覆盖**已形式化**的部分，未覆盖的部分在 §7 列出。
>
> **构建状态**：Lean `v4.35.0-rc4` / Mathlib `2da3ab0a`，`lake build` 全绿（0 error、0 warning、无 `sorry`）。结论中的每一条都可以在源码里检索到同名定理。

---

## 0. 模型与假设

在概率空间 $(\Omega,\mathcal F,\mathbb P)$ 上考虑一串交易。

| 符号 | 含义 |
|---|---|
| $W_0>0$ | 初始权益 |
| $f>0$ | 固定风险比例——每笔的最大损失 = 笔前权益的 $f$ 倍 |
| $R_i$ | 第 $i$ 笔的 R 倍数（随机变量；赢 $>0$、亏 $<0$） |
| $W_i$ | 第 $i$ 笔后的权益 |
| $n$ | 交易笔数 |
| $g$ | 对数增长率 $g:=\mathbb E[\ln(1+fR)]$ |

**假设（本文结论的全部前提）**

- **(H1) 两两独立**：$R_i$ 与 $R_j$ 独立（$i\neq j$）；
- **(H2) 同分布**：$R_i$ 与 $R_1$ 同分布；
- **(H3) 对数可积**：$\mathbb E\,|\ln(1+fR)|<\infty$；
- **(H4) 不爆仓**：$\mathbb P\big(\forall i,\ 1+fR_i>0\big)=1$（两结果模型下即 $f\,|R_L|<1$）；
- **(H5) 正初始权益**：$W_0>0$。

三条容易误解的地方：

1. **不需要全独立**——两两独立就够（强大数定律用 Etemadi 版本，Mathlib 的 `ProbabilityTheory.strong_law_ae` 就是这么证的）；
2. **不需要二阶矩**——只要对数收益可积，不要求 $R$ 有界、不要求方差有限；
3. **(H4) 是「取对数」与「不归零」的保证**，不是额外的经济假设——它就是止损设计里的 `f·|R_L| < 1`。

---

## 1. 单笔交易：从风险比例到权益递推

第 $i$ 笔的风险敞口按**笔前权益**的固定比例确定：

$$M_i = f\,W_{i-1}.$$

盈亏金额 = 风险敞口 × R 倍数：

$$P_i = M_i\,R_i = f\,W_{i-1}R_i.$$

笔后权益 = 笔前权益 + 盈亏：

$$W_i = W_{i-1} + P_i = W_{i-1}\,(1+fR_i). \qquad\text{(1.1)}$$

**单笔收益率**（在 $W_{i-1}\neq 0$ 时）：

$$\frac{W_i - W_{i-1}}{W_{i-1}} = \frac{fW_{i-1}R_i}{W_{i-1}} = fR_i. \qquad\text{(1.2)}$$

即单笔收益率恒等于 $fR_i$、**与权益大小无关**——这是固定比例下注的核心性质（10 万和 100 万的账户，每笔收益率的刻度一样）。

> **Lean**：式 (1.1) = `equity_succ`；式 (1.2) = `single_trade_return`（前提 $W_{i-1}\neq0$）。

---

## 2. 累计权益与累计收益率（精确恒等式）

把 (1.1) 从 $i=1$ 连乘到 $n$：

$$W_n = W_0\prod_{i=1}^{n}(1+fR_i). \qquad\text{(2.1)}$$

**累计收益率**（相对初始本金的涨幅）：

$$\frac{W_n}{W_0}-1 \;=\; \prod_{i=1}^{n}(1+fR_i)-1. \qquad\text{(2.2)}$$

(2.1)–(2.2) 是**精确恒等式**：不含任何近似、不需要任何概率假设。

> **Lean**：`equity W₀ f R n = W₀ * ∏ i ∈ range n, (1 + f * R i)`（定义即式 (2.1)）；正性 `equity_pos`（需 H4、H5）。

---

## 3. 对数变换：乘积变求和

在 (H4) 下每项 $1+fR_i>0$，对 (2.1) 取对数——乘积变成求和：

$$\ln\frac{W_n}{W_0} \;=\; \sum_{i=1}^{n}\ln(1+fR_i). \qquad\text{(3.1)}$$

两边除以 $n$：

$$\frac1n\ln\frac{W_n}{W_0} \;=\; \frac1n\sum_{i=1}^{n}\ln(1+fR_i).$$

由 (H1)(H2)(H3) 与**强大数定律**（两两独立即可）：

$$\frac1n\sum_{i=1}^{n}\ln(1+fR_i) \;\xrightarrow[\;n\to\infty\;]{}\; g:=\mathbb E\big[\ln(1+fR)\big] \qquad (\mathbb P\text{-几乎必然}). \qquad\text{(3.2)}$$

> **Lean**：`logReturn`（每笔对数收益）、`logGrowthRate`（$g$ 的定义）、`tendsto_log_mean`（式 (3.2)）；有限版本的式 (3.1) = `Equity.log_equity`（需 H4、H5）。

---

## 4. 几何增长率恰好是 $e^{g}$

由 (3.1)：

$$\left(\frac{W_n}{W_0}\right)^{1/n} \;=\; \exp\!\left(\frac1n\sum_{i=1}^{n}\ln(1+fR_i)\right).$$

代入 (3.2)，再用 $\exp$ 的连续性：

$$\boxed{\ \left(\frac{W_n}{W_0}\right)^{1/n} \;\xrightarrow[\;n\to\infty\;]{}\; e^{g}\quad(\text{几乎必然})\ } \qquad\text{(4.1)}$$

即累计权益的**几何增长率精确等于 $e^g$**——这是「极限」，不是「约等于」；源文档里所有的「$\approx$」到此为止。

> **Lean**：`tendsto_prod_rpow_logGrowthRate`（需 H1–H4）。

---

## 5. $g$ 的符号决定生死

### 5.1 $g>0$：指数增长

任取 $0<c<g$。由 (3.2)，几乎必然地当 $n$ 足够大时 $\frac1n\sum\ln(1+fR_i)>c$，即

$$\ln W_n \;>\; \ln W_0 + cn \qquad\Longrightarrow\qquad W_n \;\ge\; W_0\,e^{cn}\quad(\forall n\ge N). \qquad\text{(5.1)}$$

因为 $c$ 可以任意接近 $g$，增长率 $e^{g}$ 就是最紧的指数下界——累计收益率指数增长。

> **Lean**：`eventually_equity_ge_exp`——「对任意 $c<g$，几乎必然存在 $N$，使 $n\ge N$ 时 $W_0e^{cn}\le W_n$」（需 H1–H5）。

### 5.2 $g<0$：指数衰减

任取 $g<c<0$，同一推理给出几乎必然地最终

$$W_n \;\le\; W_0\,e^{cn} \qquad\Longrightarrow\qquad W_n\to 0 \quad(\text{指数衰减}). \qquad\text{(5.2)}$$

> **Lean**：`eventually_equity_le_exp`（需 H1–H5）。

### 5.3 $g=0$：不增不减

由 (4.1) 直接得到 $(W_n/W_0)^{1/n}\to e^0=1$：长期既不增长也不缩水（路径仍可大幅波动）。

---

## 6. 结论一览（对照 Lean 源码）

| # | 数学结论 | 公式 | Lean 定理 | 需用前提 |
|---|---|---|---|---|
| 1 | 单笔递推 | (1.1) | `equity_succ` | — |
| 2 | 单笔收益率 $=fR_i$ | (1.2) | `single_trade_return` | $W_{i-1}\neq0$ |
| 3 | 连乘公式 / 累计收益率 | (2.1)(2.2) | `equity`（定义） | — |
| 4 | 不爆仓 ⇒ 权益恒正 | — | `equity_pos` | H4, H5 |
| 5 | 对数分解 | (3.1) | `log_equity` | H4, H5 |
| 6 | 对数均值 → $g$（强大数定律） | (3.2) | `tendsto_log_mean` | H1–H3 |
| 7 | **几何增长率 → $e^g$** | (4.1) | `tendsto_prod_rpow_logGrowthRate` | H1–H4 |
| 8 | $g>0$ ⇒ 指数增长 | (5.1) | `eventually_equity_ge_exp` | H1–H5 |
| 9 | $g<0$ ⇒ 指数衰减 | (5.2) | `eventually_equity_le_exp` | H1–H5 |

> 形式化细节：Mathlib 的 `strong_law_ae` 甚至**不预先假设** $\mu$ 是概率测度（非退化情形下自动推出）；本文按概率模型书写只是便于阅读。

---

## 7. 边界：这里没有覆盖什么

1. **没有证明 $g>0$。** 是否 $g>0$ 取决于策略的真实分布，只能靠样本统计估计；已证的是条件命题「$g>0$ ⇒ 指数增长」。
2. **结论是「几乎必然 + 最终成立」，不是「每个有限 $n$、每条路径」。** 有限样本里的连赢连亏不违反任何一条。
3. **模型假设是否贴合真实市场不在证明范围。** $R_i$ 是否近似独立同分布、$f$ 是否恒定、成本与滑点是否可忽略——Lean 钉死的是「假设 ⇒ 结论」这一层。
4. **尚未形式化的部分**（仓库 TODO T4–T6）：
   - §4 的方差惩罚（对数函数二阶泰勒展开的精确余项界）；
   - §7 的凯利最优 $f^{*}=\dfrac{p}{|R_L|}-\dfrac{q}{R_W}$ 与正增长区间；
   - §7.3 的「两倍凯利」边界——该结论在离散两结果模型下**不是普遍成立**，已有实算反例（见 `scripts/twice-kelly-scan.py` 与源文档附录二）。

---

验证方式：`lake build`；定理名可在 [`TradingProofs/Equity.lean`](../TradingProofs/Equity.lean) 与 [`TradingProofs/Growth.lean`](../TradingProofs/Growth.lean) 中检索。
