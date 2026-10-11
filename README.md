<div align="center">
  <img src="assets/logo.svg" alt="TradingProofs" width="640">

  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow)](LICENSE.md)
  [![Version](https://img.shields.io/badge/Version-0.1.0-blue)](CHANGELOG.md)
  [![Type](https://img.shields.io/badge/Type-Formal%20Verification-4F46E5)](#)
  [![Visitors](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/xhqing/xhqing/main/traffic/badges/TradingProofs.json)](https://github.com/xhqing)

  [简体中文](README_cn.md)
</div>

# TradingProofs

Machine-checked proofs, in **Lean 4 + Mathlib**, of the trading math behind [DayTradingAgent](https://github.com/xhqing/DayTradingAgent) — the compounding and position-sizing formulas that decide how much capital each trade may risk.

## Why this exists

DayTradingAgent sizes every trade as a fixed fraction of pre-trade equity (`Mᵢ = f·Wᵢ₋₁`) and reads its long-run prospects off the log-growth rate `g = E[ln(1 + f·R)]`. Those derivations are what real sizing decisions stand on, which is exactly why they should not rest on a hand-waved "≈". Lean re-checks every step down to the axioms, and forces informal phrases like *"the product is approximately `e^{ng}`"* into precise statements with explicit hypotheses.

The first review round (2026-10-11) already surfaced two claims that are not literally true and must be restated:

- `∏(1 + f·Rᵢ) ≤ (1 + f·EV)ⁿ` holds only asymptotically, not term-by-term for every finite `n`;
- "over-betting beyond twice Kelly always shrinks" is **false** in the discrete two-outcome model — there is an explicit numerical counterexample (`g(2f*) ≈ +0.24 > 0` for `p ≈ 0.104, R_W ≈ 17.7, |R_L| ≈ 0.05`), so it has to become a conditional or asymptotic statement.

The source derivation is [notes/cumulative-return-derivation.md](https://github.com/xhqing/DayTradingAgent/blob/main/notes/cumulative-return-derivation.md) in the DayTradingAgent repository; both review findings have been corrected there (2026-10-11).

## Status (0.1.0)

🚧 Core done, next layers in progress: the finite-equity algebra and the strong-law growth theorem are machine-checked — `lake build` is green (Lean `v4.35.0-rc4` / Mathlib `2da3ab0a`), with no `sorry` and no warnings.

| # | Result | Source § | Status |
|---|---|---|---|
| 1 | Equity recursion and the product formula | §1–2 | ✅ `Equity.equity_succ`, `Equity.single_trade_return` |
| 2 | Log decomposition of the product | §3 | ✅ `Equity.log_equity` |
| 3 | Growth rate `(Wₙ/W₀)^(1/n) → e^g` a.s. (strong law) | §3, §5 | ✅ `Growth.tendsto_prod_rpow_logGrowthRate` |
| 4 | `g > 0` ⇒ exponential growth; `g < 0` ⇒ exponential decay | §5–6 | ✅ `Growth.eventually_equity_ge_exp`, `Growth.eventually_equity_le_exp` |
| 5 | Sample AM–GM and population Jensen | §3–4 | planned |
| 6 | Exact two-outcome Kelly `f*` and the positive-growth interval | §6–7 | planned |
| 7 | The exact/approximate boundary of "twice Kelly" | §7.3 | planned |

The full human-readable derivation — every proven result written out with LaTeX and mapped to its Lean theorem — is in [docs/proofs.md](docs/proofs.md).

## Build

```bash
git clone https://github.com/xhqing/TradingProofs.git
cd TradingProofs
lake exe cache get   # prebuilt Mathlib oleans
lake build
```

The toolchain is pinned in `lean-toolchain`, Mathlib in `lake-manifest.json`. CI (GitHub Actions, `lean-action`) builds the same way.

## Formalization rules

- Every theorem carries its source section and its hypotheses — including `1 + f·Rᵢ > 0` (no wipeout; in the two-outcome model `f·|R_L| < 1`) and integrability of `ln(1 + f·R)`.
- No "≈" in theorem statements: approximations appear only as explicit remainder bounds or `IsBigO` asymptotics.
- Numerics quoted in comments or docs are reproduced by a script under `scripts/`.

## License & Attribution

Copyright (c) 2026 All Contributors. Released under the [MIT License](LICENSE.md).

Attribution: if you use or reference this project, please keep the copyright notice and credit the source: [TradingProofs](https://github.com/xhqing/TradingProofs).
