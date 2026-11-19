---
name: financial-modelling
description: "Use when building or reviewing a financial model, forecast or spreadsheet: P&L, balance sheet, cash flow, unit economics, SaaS metrics, pricing economics, runway, burn, fundraising or scenarios. Not for go-to-market choices (use `marketing`) or analysing past product data (use `data-analysis`)."
license: MIT
---

# Financial Modelling

A model turns assumptions into a defensible range that informs a decision. It is an argument, not a
prophecy. Every output traces to a driver, every driver traces to a source. The spread between
the bull and bear cases matters more than any single figure.

## The rules that matter most

Read these before putting a single number into a model.

1. **Assumptions first.** List every assumption, with value, source and confidence label, before
   writing any formula.
2. **No constants inside formulas.** `=1500` in a calculation cell is a bug. It must read
   `=new_customers * price`, with both inputs named on the assumptions sheet.
3. **Outputs are computed, never typed.** If a result can be overwritten by hand, the model is broken.
4. **Three cases, always.** Base, bull and bear, produced by flexing named assumptions. Never by
   typing three different answers.
5. **Cash separately from profit.** Profitable companies run out of cash. Model both.
6. **Unit economics before the top line.** If one customer loses money, scale makes the loss larger.
7. **Backtest before you believe it.** Run the model forward from a past date on real data and
   compare with what happened. A model never checked against actuals is decoration.

## When not to use

- Choosing a go-to-market motion or channel: the `marketing` skill (it reads CAC and payback from
  here).
- Value metric, tiers and feature gating as product decisions: the `product-management` skill.
- Analysing historical behaviour (cohorts, funnels, experiments): the `data-analysis` skill.
- Building software that calculates money (decimal arithmetic, audit logs): see the finance-tool
  framework in the `project-frameworks` skill.

## 1. Structure

- **Three layers.** Assumptions feed calculations, which feed outputs. A formula never reaches past
  the layer below it, and no assumption hides inside a calculation.
- **Single source of truth.** Each variable lives in one cell. Everything else refers to it.
- **Confidence labels** on every assumption: measured (historical), benchmark, estimate or
  speculative. The labels tell the reader where the model is soft.
- **Driver based.** Build outputs from operational drivers (visits, conversion, price, churn), not a
  growth percentage typed onto last period. Change a driver and the whole model responds.
- **Bottom up for plans, top down as a ceiling.** Revenue from your own capacity (leads times
  conversion times price, or reps times quota times ramp). Market size times share only as a sanity
  check. When they disagree, trust bottom up and explain the gap.
- **Cohorts for subscriptions.** Apply a retention curve to each join cohort and sum. A blended
  average hides a decaying base.
- **Fixed and variable costs separated.** Misclassifying cost behaviour breaks every scenario.

## 2. Scenarios and sensitivity

- **Base**: most likely on current evidence. **Bull** and **bear**: the two or three most
  influential assumptions moved by a stated, defensible amount.
- **Sensitivity**: take the five most influential assumptions, move each by 10% with all else fixed,
  record the output change and rank. The top two or three are where better data pays.
- **The headline is the assumption that, if wrong, changes the conclusion.** Name it in the summary.
- Present ranges rounded to the precision the data supports. "1.2 to 1.6m" is honest; "1,247,913"
  claims precision nobody has.

## 3. Statements and cash

The three statements must tie out. Net income from the P&L flows into retained earnings on the
balance sheet and is the first line of the cash flow statement. Working capital changes
(receivables, payables, inventory, deferred revenue) explain the gap between profit and cash.
Assets equal liabilities plus equity in every period, not only the last.

Accrual measures profitability; cash measures survival. An annual plan billed upfront is cash now and
revenue over twelve months. A customer on 60-day terms is revenue now and cash later. Growth that
ties up cash faster than profit releases it bankrupts a profitable business.

## 4. Unit economics

- **CAC** = fully loaded sales and marketing spend / new customers. Fully loaded means salaries,
  tools and content, not only ad spend.
- **Gross margin** = (revenue - cost to deliver) / revenue. Cost to deliver includes hosting,
  third-party API calls, payment fees and support.
- **Contribution margin** = revenue per unit minus all variable cost per unit, including variable
  selling cost.
- **LTV** = monthly revenue per account x gross margin % / monthly churn rate. Always margin
  adjusted. Revenue LTV overstates value.
- **Payback** = CAC / (monthly revenue per account x gross margin %), in months.

Rules of thumb for SaaS, for calibration only: gross margin 70 to 80% or more, LTV:CAC around 3:1,
payback under 12 months. Below 1:1 you lose money on every customer; far above 5:1 often means
under-investment in growth. Interrogate a model that misses or beats these by a wide margin.

Read `references/business-models.md` when modelling a subscription (MRR bridge, retention, Rule of 40,
burn multiple), a marketplace, e-commerce, a services firm or usage-based pricing. It has the driver
tree and the metrics to show for each.

## 5. Pricing economics

- **Value based by default**, cost plus only as a floor. Willingness to pay comes from perceived
  value and the alternative, not from your cost. Probe it (interviews, Van Westendorp, live price
  tests) rather than assume it.
- **Margin is not markup.** A 50% markup on a cost of 10 gives a price of 15, which is a 33% margin.
  Label which one every figure is.
- **Metered cost gates features.** Any feature with a per-call cost (model inference, embeddings,
  third-party APIs, SMS) needs cost per call x calls per user per month in the model. It must clear
  its marginal cost or sit behind a paid tier. A generous free tier on a metered backend bleeds cash
  quietly and scales the loss with adoption.

## 6. Runway, burn and fundraising

- **Gross burn** = cash out per month. **Net burn** = cash out minus cash in. Runway uses net burn.
- **Runway** = cash / net monthly burn. If burn is rising, model the ramp month by month; dividing by
  today's burn flatters the answer.
- Runway sets the strategy. Under about six months the job is raising or cutting. Twelve to eighteen
  months buys room to reach a milestone that supports the next raise.
- **Post-money** = pre-money + amount raised. New investor ownership = amount raised / post-money.
- **Dilution**: model founder, option pool and each investor's share across rounds. An option pool
  created in the pre-money dilutes existing holders, not the incoming investor.

## Gotchas

| Mistake | Correction |
|---|---|
| Typed numbers in output cells | Every output is a formula from named drivers |
| A hockey stick with no named cause | Each inflection needs a dated, specific mechanism |
| Revenue modelled as cash | Model billing terms and working capital |
| One-off fees inside ARR | ARR is recurring revenue only |
| Margin and markup mixed | Label each; convert explicitly |
| No churn in a subscription model | A retention curve per cohort is required |
| Runway from today's burn while hiring | Model the burn ramp |
| Three cases made by editing outputs | Flex named assumptions only |
| Mean outcome from a skewed distribution | Show the distribution; a few large deals can carry the mean |
| A better backtest after two changes | Change one thing at a time; two errors can cancel and look like a fix |
| Circular reference left to iterate silently | Make it explicit with a switch (for example interest on average cash), or break it with prior-period balances |
| Model accepted because it balances | A balancing model can still be wrong. Check drivers against actuals |

## Verification

Before any model leaves your hands, attach evidence for each line. Read
`references/integrity-audit.md` for the full integrity checks and the checks specific to each model
type (three-statement, DCF, debt).

- [ ] Assumptions sheet exists; each has value, source and confidence label
- [ ] Search for constants inside formulas finds none outside the assumptions sheet
- [ ] Balance sheet balances in every period; cash on the balance sheet equals the cash flow
      statement's closing cash in every period
- [ ] Cash modelled separately from P&L, with working capital timing
- [ ] Unit economics shown before the top-line forecast
- [ ] Base, bull and bear driven by named assumptions
- [ ] Sensitivity ranked; the make-or-break assumption named in the summary
- [ ] Backtested against at least one past period, with the variance explained
- [ ] Results shown as ranges at honest precision
