# Model integrity audit

Run this on any model before it is shared, and on any model you are handed before you trust it.
Record each check as pass or fail with the cell, sheet or period that shows it.

## Contents
1. Structural checks
2. Three-statement checks
3. Model-type checks
4. Reading a model someone else built

## 1. Structural checks

- **Hard-coded values.** Search formulas for numeric literals. Any constant outside the assumptions
  sheet is a finding (allowed exceptions: 12 months, 100% and similar unit conversions, named).
- **Inconsistent formulas.** A row whose formula changes partway across the periods. Usually an
  overwritten cell.
- **Broken references.** `#REF!`, `#N/A`, links to other files, references to empty cells.
- **Circular references.** List each one. Intended circularity (interest on average debt or cash)
  needs a switch to break it and a note. Unintended circularity is a bug.
- **Units and signs.** One convention for costs (positive or negative) throughout. Thousands and
  units not mixed. Currency stated.
- **Periods.** Monthly and annual columns aligned; annual totals sum the right months; partial first
  and last periods handled.
- **Error checks sheet.** Every check below returns zero or TRUE, and the summary shows it.

## 2. Three-statement checks

- Balance sheet balances in **every** period: assets - liabilities - equity = 0.
- Closing cash on the cash flow statement equals cash on the balance sheet in every period.
- Net income on the P&L equals the first line of the cash flow statement.
- Retained earnings move by net income minus dividends.
- Working capital movements on the cash flow statement match the balance sheet changes.
- Depreciation on the P&L matches the fixed asset roll-forward; capex appears in investing cash.
- Debt roll-forward: opening + drawdowns - repayments = closing, and interest ties to the balance.
- Deferred revenue roll-forward: opening + billings - recognised revenue = closing.

A model that fails any of these has a wrong number somewhere. Find it; do not insert a plug.

## 3. Model-type checks

**Forecast or operating model**
- Revenue built from drivers, not growth percentages.
- Headcount plan drives salary cost, with start dates and ramp.
- Backtest: run from a past date and compare to actuals. Explain each large variance.

**Discounted cash flow (DCF)**
- Free cash flow definition stated (to firm or to equity) and the discount rate matches it.
- Terminal growth rate below the long-run growth of the economy and below the discount rate.
- Show the terminal value as a share of total value. If it is most of the value, say so: the
  valuation rests on the terminal assumptions, so show a sensitivity table on discount rate and
  terminal growth.
- Mid-year convention used or not, stated.

**Debt and credit**
- Covenants computed every period (for example debt to EBITDA, interest coverage) and breaches
  flagged.
- Cash sweep and minimum cash balance logic visible.

## 4. Reading a model someone else built

1. Find the assumptions. If there is no assumptions sheet, the first finding is that the model is
   unauditable.
2. Trace the three most important outputs back to their drivers, cell by cell.
3. Run the structural and statement checks above.
4. Flex the top assumption by 10% and check the outputs move in the expected direction and size.
5. Report findings as: what is wrong, where, its effect on the headline output and the fix.
