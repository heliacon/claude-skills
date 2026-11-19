# Prioritisation and metric frameworks

Read this when you need a formula, a category definition or the known failure mode of a framework. The defaults and rules are in `SKILL.md`.

## Prioritisation

| Framework | Use when | Watch out for |
|---|---|---|
| MoSCoW | Scoping one release | Everything becomes a must. Enforce the Won't list. |
| RICE | Ranking many comparable items with rough data | Effort in the denominator punishes big bets. Garbage in, garbage out. |
| Kano | Basics versus delighters in a feature set | Delighters decay into expectations. Re-survey. |
| Cost of Delay / WSJF | Sequencing when speed has value | Needs honest cost-of-delay estimates. |
| Opportunity score | Choosing which need to serve | Needs survey data on importance and satisfaction. |

### RICE

Score = (Reach × Impact × Confidence) ÷ Effort.

| Factor | Meaning | Scale |
|---|---|---|
| Reach | Users affected per period | A count, from analytics or research |
| Impact | Movement of the target metric per user | 3 massive, 2 high, 1 medium, 0.5 low, 0.25 minimal |
| Confidence | How sure you are of the other three | 100% evidence, 80% some data, 50% gut |
| Effort | Person-weeks | Engineering estimate |

Example: A = (1000 × 2 × 0.8) ÷ 2 = 800. B = (5000 × 1 × 0.5) ÷ 5 = 500. A wins on lower effort and higher confidence.

Rank within a MoSCoW tier only. Record every input. Re-score when an input changes.

### Kano

- **Basic**: absence angers, presence goes unnoticed. Ship all basics before any delighter.
- **Performance**: more is better, roughly linear.
- **Delighter**: unexpected, drives love. Decays to basic over time.
- **Indifferent**: nobody cares. Cut.

### WSJF

WSJF = Cost of Delay ÷ Job Duration. Cost of Delay blends user value, time criticality and risk reduction. Highest first.

### Opportunity score

Survey users on importance and satisfaction (1 to 10) for each need. Score = importance + max(importance − satisfaction, 0). Above roughly 10 is under-served; low scores are over-served and may be cut back.

## Metric frameworks

### HEART (feature-level experience health)

Happiness, Engagement, Adoption, Retention, Task success. For each one you use, write Goal → Signal → Metric. Skip the dimensions that do not matter for this feature.

### AARRR (funnel and growth)

Acquisition, Activation, Retention, Referral, Revenue. Fix Activation and Retention before Acquisition.

### Metric tree

```
North Star (value delivered, leading indicator of revenue)
├─ Input 1 (e.g. new activated users)
│   └─ Team levers (onboarding completion, time to first value)
├─ Input 2 (e.g. retention)
└─ Input 3 (e.g. frequency of the value event)
```

Each node names: definition, owner, data source, review cadence. A node with no owner is not managed.

### Guardrails

Typical guardrails: latency, error rate, refund rate, unsubscribe rate, support contacts per user, revenue. Name them before the experiment starts, with the threshold that stops it.
