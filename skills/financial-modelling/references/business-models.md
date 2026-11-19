# Business model templates

## Contents
1. Subscription (SaaS)
2. Marketplace
3. E-commerce
4. Services
5. Usage-based pricing

Each section gives the driver tree to build and the metrics to show. Build drivers first, then
derive the metrics from them. Never type a metric in.

## 1. Subscription (SaaS)

Recurring revenue is a stock. Model the movements, not only the level.

**MRR bridge**, built before anything else:

```
opening MRR + new + expansion - contraction - churned = closing MRR
```

- **MRR and ARR**: recurring only. ARR = MRR x 12. Exclude set-up fees, services and overages that
  do not recur.
- **Net revenue retention** = (opening MRR + expansion - contraction - churn) / opening MRR, on a
  fixed cohort with no new logos. Above 100% means the base grows on its own.
- **Logo churn and revenue churn** differ when churn concentrates in small or large accounts. Show
  both.
- **Gross and net revenue churn**: gross ignores expansion; net can go negative.
- **Rule of 40** (rule of thumb): growth % + profit margin % around 40 or above. A sniff test, not
  a covenant.
- **Magic number** = net new ARR in a quarter / sales and marketing spend in the prior quarter.
  Around 0.75 or above is often called efficient.
- **Burn multiple** = net burn / net new ARR. Lower is better. Useful at every stage.

Annual prepaid plans create deferred revenue: cash arrives upfront, revenue is recognised monthly.
Put deferred revenue on the balance sheet and the cash flow statement.

## 2. Marketplace

Driver tree: active buyers x orders per buyer x average order value = GMV. Revenue = GMV x take rate.

- Show **GMV, take rate and net revenue** separately. GMV is not revenue.
- Model both sides. Supply growth, demand growth and the **match rate** (share of searches or
  requests that end in a transaction) decide liquidity.
- Incentives and subsidies on either side reduce net revenue; model them as a cost or a contra
  revenue line, not as marketing that is outside unit economics.
- Watch payments float and refunds: the marketplace may hold cash that is owed to sellers. It is a
  liability, not runway.

## 3. E-commerce

Driver tree: sessions x conversion rate x average order value = revenue. Add repeat orders by cohort.

- **Contribution per order** after product cost, shipping, packaging, payment fees, returns and
  discounts. Gross margin before fulfilment flatters the business.
- **Repeat purchase rate by cohort** drives LTV. First-order economics are often negative.
- **Inventory** ties up cash before sale. Model purchase timing, lead times, minimum order quantities
  and stock write-downs.
- Returns rates differ hugely by category. Use measured rates, not a single blended figure.

## 4. Services

Driver tree: billable headcount x available hours x utilisation x realised rate = revenue.

- **Utilisation** (billed hours / available hours) and **realisation** (billed value / standard rate)
  are the two levers. Model both; a full diary at a discounted rate is a margin problem.
- Revenue grows roughly with headcount, so hiring lead time and ramp are the main constraint.
- Fixed-price work carries overrun risk. Model a contingency or an overrun scenario.
- Payment terms create a long receivables tail. Cash lags revenue by the terms plus late payment.

## 5. Usage-based pricing

Driver tree: active accounts x units per account x price per unit, with a usage curve per cohort.

- Revenue is volatile and seasonal. Model usage per cohort over time, not a flat per-account figure.
- Cost of delivery is usually also per unit. Model gross margin per unit, including third-party
  metered costs, at each volume tier.
- Committed-use contracts (prepaid minimums) behave like subscriptions; overage behaves like usage.
  Separate them.
- A price per unit that covers cost at today's volume can fail at a heavy user's volume. Check the
  margin for the top 1% of accounts.
