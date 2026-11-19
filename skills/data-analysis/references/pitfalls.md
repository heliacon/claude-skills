# Named pitfalls and their checks

Each trap below has produced a confident wrong answer in real work. Run the check that matches the
shape of your analysis.

| Pitfall | What happens | Check |
|---|---|---|
| Join explosion | A one-to-many join duplicates rows and inflates sums | Row count before and after each join; aggregate the many side first |
| Incomplete period | This month so far compared with all of last month | Compare complete periods or matched day counts |
| Denominator shift | A rate moves because the population changed, not the behaviour | Show numerator and denominator separately over time |
| Mix shift (Simpson) | Aggregate trend reverses inside segments | Recompute the headline per segment |
| Survivorship | Only survivors are in the data | Ask who dropped out and when; include them if you can |
| Look-ahead and censoring | Recent cohorts have not had time to reach the outcome | Exclude rows whose outcome window has not closed |
| Mean against median | A median hides a large tail; a mean is dragged by it | Report both for skewed data; show the distribution |
| Limit-shaped counts | A count equals an API page size or row cap | Compare against the source's documented limits; paginate |
| Timezone and day boundaries | Events land on the wrong day; a day appears to dip | Fix one timezone for the analysis; check the boundary hours |
| Unstable ordering | Two runs of the same pipeline differ because sort order is not fixed | Run the unchanged pipeline twice and diff; sort on a full key |
| Raw share without a null | A split looks meaningful but chance gives most of it | Compute what random assignment would give; quote the excess |
| Mismatched instrument | Treatment and control measured by different methods | Assert in code that both arms use the same measurement |
| Aggregate tie | Two arms tie overall while differing strongly per target | Report per-target results, not only the total |
| Displacement without a limit | "X crowded out Y" when no shared limit was ever reached | Check the limit was actually reached before claiming displacement |
| Comparison exclusions | A statistic on the overlap of two sets ignores what is in only one | Report how much fell outside the overlap, by weight not only count |
| Two errors cancelling | A better score comes from two mistakes offsetting | Fix one at a time; if the score worsens after a correct fix, look for the partner error |
| Extremes are artefacts | Top of a ranked list is errors and outliers | Inspect the top and bottom items by hand before reporting them |
| Multiple comparisons | Many cuts, one "significant" by chance | Pre-register; correct; label exploration as hypotheses |

## Before you trust a detector or filter

A check that runs and passes can be inert. Before relying on a filter that flags bad rows, feed it
known bad rows and confirm it fires. Count how many positives it produced on the real data. Zero
positives across a large dataset usually means the check never armed, not that the data is clean.
