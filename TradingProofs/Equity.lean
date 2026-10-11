/-
Copyright (c) 2026 All Contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
module

public import Mathlib.Algebra.BigOperators.Group.Finset.Basic
public import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Fixed-fraction equity and its product form

Formalizes §1–2 of `notes/cumulative-return-derivation.md` in DayTradingAgent.

With risk fraction `f`, R-multiple sequence `R` and initial equity `W₀`, the equity
after `n` trades is

`equity W₀ f R n = W₀ * ∏ i ∈ range n, (1 + f * R i)`,

satisfying the single-trade recursion `W_{i} = W_{i-1} * (1 + f * R_{i-1})` and the
per-trade return identity `(W_{i} - W_{i-1}) / W_{i-1} = f * R_{i-1}`.

The positivity hypothesis `∀ i, 0 < 1 + f * R i` is the *no-wipeout* condition (in the
two-outcome model: `f * ‖R_L‖ < 1`); it is what makes the logarithms well defined.
-/

namespace TradingProofs

@[expose] public section

variable {W₀ f : ℝ} {R : ℕ → ℝ}

/-- §1–2: equity after `n` fixed-fraction trades, `Wₙ = W₀·∏ᵢ₌₀ⁿ⁻¹ (1 + f·Rᵢ)`. -/
noncomputable def equity (W₀ f : ℝ) (R : ℕ → ℝ) (n : ℕ) : ℝ :=
  W₀ * ∏ i ∈ Finset.range n, (1 + f * R i)

@[simp]
theorem equity_zero : equity W₀ f R 0 = W₀ := by
  simp [equity]

/-- §1: the single-trade recursion `W_{n+1} = W_n·(1 + f·Rₙ)`. -/
theorem equity_succ (n : ℕ) :
    equity W₀ f R (n + 1) = equity W₀ f R n * (1 + f * R n) := by
  simp only [equity, Finset.prod_range_succ]
  ring

/-- §1: the per-trade return is exactly `f·Rₙ`, independent of the equity level. -/
theorem single_trade_return (n : ℕ) (h : equity W₀ f R n ≠ 0) :
    (equity W₀ f R (n + 1) - equity W₀ f R n) / equity W₀ f R n = f * R n := by
  rw [equity_succ]
  field_simp
  ring

/-- No-wipeout: if every `1 + f·Rᵢ` is positive and `W₀ > 0`, equity stays positive. -/
theorem equity_pos (hW : 0 < W₀) (hpos : ∀ i, 0 < 1 + f * R i) (n : ℕ) :
    0 < equity W₀ f R n := by
  rw [equity]
  exact mul_pos hW (Finset.prod_pos fun i _ => hpos i)

/-- §2–§3: the log of equity is a sum — the product becomes an additive walk. -/
theorem log_equity (hW : 0 < W₀) (hpos : ∀ i, 0 < 1 + f * R i) (n : ℕ) :
    Real.log (equity W₀ f R n) =
      Real.log W₀ + ∑ i ∈ Finset.range n, Real.log (1 + f * R i) := by
  have hprod : (∏ i ∈ Finset.range n, (1 + f * R i)) ≠ 0 :=
    Finset.prod_ne_zero_iff.mpr fun i _ => ne_of_gt (hpos i)
  rw [equity, Real.log_mul (ne_of_gt hW) hprod,
    Real.log_prod fun i _ => ne_of_gt (hpos i)]

end

end TradingProofs
