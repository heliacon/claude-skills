# Experiment (A/B test) design

Read this before writing acceptance criteria for any story that ships as an experiment. Every item below is decided and written down before the test starts.

## Checklist

- [ ] **Hypothesis**: "If we change X, metric Y moves by Z because R."
- [ ] **Primary metric**: one metric decides success or failure. Not a dashboard of ten.
- [ ] **Guardrail metrics**: what must not get worse (revenue, error rate, latency, unsubscribes), each with the threshold that stops the test.
- [ ] **Minimum detectable effect (MDE)**: the smallest change worth acting on, for example +2 percentage points of conversion.
- [ ] **Sample size**: from the baseline rate, the MDE, power (default 80%) and significance (default α = 0.05). Compute it; do not guess it.
- [ ] **Duration**: at least two full weekly cycles, so weekday and weekend behaviour both appear. Longer if the sample needs it.
- [ ] **Randomisation unit**: user, session or device. Keep it constant. Analyse at the same unit you randomised.
- [ ] **Stopping rule**: the test runs to its planned end. No stopping early because an interim look is positive. If early stopping is a real need, use a sequential method designed for it and say so up front.
- [ ] **Analysis method**: two-proportion z-test or chi-squared for conversions; Welch's t-test for continuous means; Mann-Whitney U for heavily skewed values.

## Sample size in Python

```python
from statsmodels.stats.power import NormalIndPower
from statsmodels.stats.proportion import proportion_effectsize

baseline, target = 0.10, 0.12            # 10% now, MDE of +2 points
effect = proportion_effectsize(target, baseline)
n_per_arm = NormalIndPower().solve_power(effect_size=effect, alpha=0.05, power=0.8, ratio=1.0)
print(round(n_per_arm))                  # about 1,917 users per arm (3,835 in total)
```

## Traps

- **Peeking.** Checking significance daily and stopping at the first p < 0.05 inflates false positives far above 5%.
- **Statistical is not practical significance.** A significant 0.1% lift may not be worth the code. Report the effect size and its confidence interval as well as the p-value.
- **Many metrics, one winner.** Test twenty metrics and one will be "significant" by chance. The primary metric decides; the others are exploratory.
- **Sample ratio mismatch.** If a 50/50 split lands at 52/48 on a large sample, the assignment is broken. Check the split before reading any result.
- **Novelty effect.** A new design can win for a week because it is new. Look at the trend over the test, not only the total.
