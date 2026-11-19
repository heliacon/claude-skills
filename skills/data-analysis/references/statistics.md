# Statistics and experiments for practitioners

## Contents
1. Sample size and base rates
2. Effect size, significance and intervals
3. Confounders and bias
4. Simpson's paradox, worked
5. Regression to the mean
6. Multiple comparisons
7. Experiment design
8. Choosing a test

## 1. Sample size and base rates

Small samples lie loudly. 2 conversions from 4 visitors is not a 50% conversion rate. Judge every
rate against its base rate and its sample size, and show the denominator next to the rate.

## 2. Effect size, significance and intervals

- Statistical significance says a difference is unlikely to be chance. It does not say the
  difference matters. A 0.1% lift can clear p below 0.05 on ten million sessions and still not be
  worth shipping.
- Always report the effect size (absolute and relative) with a confidence interval:
  "conversion 3.1% (95% CI 2.6 to 3.6%)". Overlapping intervals are a warning that two numbers may
  not really differ; compute the interval of the difference to be sure.
- Decide the smallest effect that would change the decision before you look. That is the
  practical threshold.

## 3. Confounders and bias

- **Confounder**: a third variable driving both things you compare. Users of a new feature convert
  better, but they were already your most engaged users. Control for it or the conclusion is wrong.
- **Selection bias**: groups that chose themselves differ in ways you cannot see.
- **Survivorship**: you only see the accounts that stayed or the pages that ranked. Ask who is
  missing.
- **Absence in the frame**: "this barely exists" may describe your sample, not the world. Check
  whether the thing you looked for lives outside the population you drew from.
- **Correlation is not causation.** Two lines moving together may share a cause, be coincidence or
  run the other way. Only randomisation, or a careful natural experiment, earns a causal claim.

## 4. Simpson's paradox, worked

```
                 New template          Old template
Mobile           30 / 1000  = 3.0%     18 /  900  = 2.0%
Desktop          80 /  200  = 40.0%    140 / 400  = 35.0%
Overall         110 / 1200  = 9.2%     158 / 1300 = 12.2%
```

The new template wins in both segments and loses overall, because it received more low-converting
mobile traffic. The aggregate is the opposite of the truth. Segment by the variables that change
the mix (device, channel, region) before concluding.

## 5. Regression to the mean

Extreme values tend to be followed by less extreme ones with no intervention. A page that spiked
then "recovered" may have done nothing. Selecting the worst performers, fixing them and watching
them improve proves nothing without an untreated comparison group selected the same way.

## 6. Multiple comparisons

Test twenty segments at p below 0.05 and expect one false positive by chance. Pre-register the
primary metric and segments. If you explore many, correct for it (Bonferroni for a few tests,
Benjamini-Hochberg false discovery rate for many) and label exploratory findings as hypotheses for
the next test.

## 7. Experiment design

- One hypothesis, one primary metric, named guardrails, written before launch.
- Random assignment to control and treatment, with one consistent unit (user, session or device).
  Check the split ratio after launch: a significant mismatch (sample ratio mismatch) means the
  assignment or logging is broken, and the result cannot be trusted.
- **Size it first** from the baseline rate, the minimum detectable effect, power (0.8 is the usual
  default) and significance (0.05). An underpowered test produces false negatives and wastes time.
- **Run to the planned end.** Stopping when the result looks good inflates false positives. If you
  must look early, use a sequential method designed for it. Cover at least one full weekly cycle.
- Ship only if the primary metric wins and no guardrail degrades.
- Novelty effects fade. For changes users notice, check whether the effect holds in the later part
  of the test.

## 8. Choosing a test

Check the assumptions before trusting the output.

| Situation | Default |
|---|---|
| Two proportions (conversion rates) | Two-proportion z-test, or chi-square |
| Two means, roughly normal or large samples | Welch's t-test (does not assume equal variance) |
| Skewed values (revenue per user) | Bootstrap the difference, or Mann-Whitney for ranks; report which |
| Before and after on the same units | Paired test |
| Many groups | ANOVA or chi-square first, then corrected pairwise tests |
| Small counts | Fisher's exact test |

Revenue and time-on-page are usually heavily skewed. A few large values dominate the mean. Report
both mean and median, and use a method that does not assume normality.
