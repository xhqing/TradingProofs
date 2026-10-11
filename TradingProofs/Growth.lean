/-
Copyright (c) 2026 All Contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
module

public import Mathlib.Probability.StrongLaw

public import TradingProofs.Equity

/-!
# Exponential growth of fixed-fraction equity (strong law of large numbers)

Formalizes the core of §3–§6 of `notes/cumulative-return-derivation.md` in
DayTradingAgent: the compounding product `∏ (1 + f·Rᵢ)` grows at geometric rate
`e^g` with `g = E[ln(1 + f·R)]`, and the sign of `g` decides growth vs decay.

Stated hypotheses (all explicit):

* `Rᵢ` pairwise independent and identically distributed — Etemadi's strong law of
  large numbers needs no more than this;
* `ln(1 + f·R)` integrable;
* `1 + f·Rᵢ > 0` pointwise (no wipeout; two-outcome model: `f·‖R_L‖ < 1`).
-/

open MeasureTheory Filter
open scoped Topology

namespace TradingProofs

@[expose] public section

variable {Ω : Type*} {mΩ : MeasurableSpace Ω} {μ : Measure Ω}

/-- §0: per-trade log return `ln(1 + f·Rᵢ)`. -/
noncomputable def logReturn (f : ℝ) (R : ℕ → Ω → ℝ) (i : ℕ) : Ω → ℝ :=
  fun ω => Real.log (1 + f * R i ω)

/-- §0: log growth rate `g = E[ln(1 + f·R)]` (per trade). -/
noncomputable def logGrowthRate (f : ℝ) (R : ℕ → Ω → ℝ) (μ : Measure Ω) : ℝ :=
  ∫ ω, Real.log (1 + f * R 0 ω) ∂μ

/-- §3, §5: the strong law of large numbers for the log-equity walk,
`n⁻¹·Σᵢ₌₀ⁿ⁻¹ ln(1 + f·Rᵢ) → g` almost surely. -/
theorem tendsto_log_mean (f : ℝ) (R : ℕ → Ω → ℝ)
    (hRindep : Pairwise (Function.onFun (fun x y => ProbabilityTheory.IndepFun x y μ) R))
    (hRident : ∀ i, ProbabilityTheory.IdentDistrib (R i) (R 0) μ μ)
    (hint : Integrable (fun ω => Real.log (1 + f * R 0 ω)) μ) :
    ∀ᵐ ω ∂μ, Tendsto
      (fun n : ℕ => (n : ℝ)⁻¹ * ∑ i ∈ Finset.range n, Real.log (1 + f * R i ω))
      atTop (𝓝 (logGrowthRate f R μ)) := by
  have hφ : Measurable fun x : ℝ => Real.log (1 + f * x) := by fun_prop
  have hindep : Pairwise (Function.onFun
      (fun x y => ProbabilityTheory.IndepFun x y μ) fun i => logReturn f R i) :=
    fun _ _ hij => (hRindep hij).comp hφ hφ
  have hident : ∀ i, ProbabilityTheory.IdentDistrib (logReturn f R i) (logReturn f R 0) μ μ :=
    fun i => (hRident i).comp hφ
  have hint' : Integrable (logReturn f R 0) μ := hint
  have h := ProbabilityTheory.strong_law_ae (fun i => logReturn f R i) hint' hindep hident
  filter_upwards [h] with ω hω
  simpa [logReturn, smul_eq_mul, logGrowthRate] using hω

/-- §5: the geometric growth rate of the compounding product is `e^g`,
`(∏ᵢ₌₀ⁿ⁻¹ (1 + f·Rᵢ))^(1/n) → e^g` almost surely. -/
theorem tendsto_prod_rpow_logGrowthRate (f : ℝ) (R : ℕ → Ω → ℝ)
    (hRindep : Pairwise (Function.onFun (fun x y => ProbabilityTheory.IndepFun x y μ) R))
    (hRident : ∀ i, ProbabilityTheory.IdentDistrib (R i) (R 0) μ μ)
    (hint : Integrable (fun ω => Real.log (1 + f * R 0 ω)) μ)
    (hpos : ∀ i ω, 0 < 1 + f * R i ω) :
    ∀ᵐ ω ∂μ, Tendsto
      (fun n : ℕ => (∏ i ∈ Finset.range n, (1 + f * R i ω)) ^ ((n : ℝ)⁻¹))
      atTop (𝓝 (Real.exp (logGrowthRate f R μ))) := by
  filter_upwards [tendsto_log_mean f R hRindep hRident hint] with ω hω
  have hexp : Tendsto
      (fun n : ℕ => Real.exp ((n : ℝ)⁻¹ * ∑ i ∈ Finset.range n, Real.log (1 + f * R i ω)))
      atTop (𝓝 (Real.exp (logGrowthRate f R μ))) :=
    (Real.continuous_exp.tendsto (logGrowthRate f R μ)).comp hω
  refine hexp.congr fun n => ?_
  have hP : 0 < ∏ i ∈ Finset.range n, (1 + f * R i ω) :=
    Finset.prod_pos fun i _ => hpos i ω
  rw [Real.rpow_def_of_pos hP, Real.log_prod fun i _ => ne_of_gt (hpos i ω)]
  exact congrArg Real.exp
    (mul_comm ((n : ℝ)⁻¹) (∑ i ∈ Finset.range n, Real.log (1 + f * R i ω)))

/-- §6: if `g > 0`, equity eventually grows at least like `e^{c·n}` for every `c < g`
(in particular the cumulative return is unbounded, exponentially). -/
theorem eventually_equity_ge_exp {W₀ : ℝ} (f : ℝ) (R : ℕ → Ω → ℝ) (hW : 0 < W₀)
    (hRindep : Pairwise (Function.onFun (fun x y => ProbabilityTheory.IndepFun x y μ) R))
    (hRident : ∀ i, ProbabilityTheory.IdentDistrib (R i) (R 0) μ μ)
    (hint : Integrable (fun ω => Real.log (1 + f * R 0 ω)) μ)
    (hpos : ∀ i ω, 0 < 1 + f * R i ω)
    (hg : 0 < logGrowthRate f R μ) (c : ℝ) (hc : c < logGrowthRate f R μ) :
    ∀ᵐ ω ∂μ, ∃ N : ℕ, ∀ n : ℕ, n ≥ N →
      W₀ * Real.exp (c * n) ≤ equity W₀ f (fun i => R i ω) n := by
  have _ := hg
  filter_upwards [tendsto_log_mean f R hRindep hRident hint] with ω hω
  have hc' : ∀ᶠ n : ℕ in atTop,
      c < (n : ℝ)⁻¹ * ∑ i ∈ Finset.range n, Real.log (1 + f * R i ω) :=
    (tendsto_order.1 hω).1 c hc
  obtain ⟨N, hN⟩ := eventually_atTop.1 hc'
  refine ⟨max N 1, fun n hn => ?_⟩
  have hn1 : 1 ≤ n := le_trans (le_max_right N 1) hn
  have hnN : N ≤ n := le_trans (le_max_left N 1) hn
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn1
  have hdiv : c < (∑ i ∈ Finset.range n, Real.log (1 + f * R i ω)) / (n : ℝ) := by
    simpa [div_eq_mul_inv, mul_comm] using hN n hnN
  have hS : c * n < ∑ i ∈ Finset.range n, Real.log (1 + f * R i ω) :=
    (lt_div_iff₀ hnpos).mp hdiv
  have hprod : (∏ i ∈ Finset.range n, (1 + f * R i ω)) =
      Real.exp (∑ i ∈ Finset.range n, Real.log (1 + f * R i ω)) := by
    rw [← Real.exp_log (Finset.prod_pos fun i _ => hpos i ω),
      Real.log_prod fun i _ => ne_of_gt (hpos i ω)]
  calc W₀ * Real.exp (c * n)
      ≤ W₀ * ∏ i ∈ Finset.range n, (1 + f * R i ω) := by
        refine mul_le_mul_of_nonneg_left ?_ hW.le
        rw [hprod]
        exact Real.exp_le_exp.mpr hS.le
    _ = equity W₀ f (fun i => R i ω) n := by rw [equity]

/-- §6: if `g < 0`, equity eventually decays at least like `e^{c·n}` for every
`g < c < 0` (in particular the cumulative return tends to zero exponentially). -/
theorem eventually_equity_le_exp {W₀ : ℝ} (f : ℝ) (R : ℕ → Ω → ℝ) (hW : 0 < W₀)
    (hRindep : Pairwise (Function.onFun (fun x y => ProbabilityTheory.IndepFun x y μ) R))
    (hRident : ∀ i, ProbabilityTheory.IdentDistrib (R i) (R 0) μ μ)
    (hint : Integrable (fun ω => Real.log (1 + f * R 0 ω)) μ)
    (hpos : ∀ i ω, 0 < 1 + f * R i ω)
    (hg : logGrowthRate f R μ < 0) (c : ℝ) (hc : logGrowthRate f R μ < c) (hc0 : c < 0) :
    ∀ᵐ ω ∂μ, ∃ N : ℕ, ∀ n : ℕ, n ≥ N →
      equity W₀ f (fun i => R i ω) n ≤ W₀ * Real.exp (c * n) := by
  have _ := hg
  have _ := hc0
  filter_upwards [tendsto_log_mean f R hRindep hRident hint] with ω hω
  have hc' : ∀ᶠ n : ℕ in atTop,
      (n : ℝ)⁻¹ * ∑ i ∈ Finset.range n, Real.log (1 + f * R i ω) < c :=
    (tendsto_order.1 hω).2 c hc
  obtain ⟨N, hN⟩ := eventually_atTop.1 hc'
  refine ⟨max N 1, fun n hn => ?_⟩
  have hn1 : 1 ≤ n := le_trans (le_max_right N 1) hn
  have hnN : N ≤ n := le_trans (le_max_left N 1) hn
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn1
  have hdiv : (∑ i ∈ Finset.range n, Real.log (1 + f * R i ω)) / (n : ℝ) < c := by
    simpa [div_eq_mul_inv, mul_comm] using hN n hnN
  have hS : ∑ i ∈ Finset.range n, Real.log (1 + f * R i ω) < c * n :=
    (div_lt_iff₀ hnpos).mp hdiv
  have hprod : (∏ i ∈ Finset.range n, (1 + f * R i ω)) =
      Real.exp (∑ i ∈ Finset.range n, Real.log (1 + f * R i ω)) := by
    rw [← Real.exp_log (Finset.prod_pos fun i _ => hpos i ω),
      Real.log_prod fun i _ => ne_of_gt (hpos i ω)]
  calc equity W₀ f (fun i => R i ω) n
      = W₀ * ∏ i ∈ Finset.range n, (1 + f * R i ω) := by rw [equity]
    _ ≤ W₀ * Real.exp (c * n) := by
        refine mul_le_mul_of_nonneg_left ?_ hW.le
        rw [hprod]
        exact Real.exp_le_exp.mpr hS.le

end

end TradingProofs
