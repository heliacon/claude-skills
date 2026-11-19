# Replacing or wrapping a legacy system

Read this when a new system must take over from an existing one, or when your code must talk
to a system whose model you do not control.

## Strangler fig

Replace a working system piece by piece. Never a big-bang cut-over of a system that works.

1. Put a facade (proxy or router) in front of the legacy system. All traffic goes through it.
2. Route new data or one narrow capability to the new system. Legacy handles the rest.
3. Migrate existing data for one slice at a time. The facade routes migrated entities to the
   new system and never sends them to legacy again.
4. Repeat until legacy serves nothing, then turn it off and delete it.

Routing keys: entity age, feature flag, tenant or user cohort. Choose one that lets you send a
slice back to legacy quickly if the new path fails.

Rules:
- One owner per entity at any moment. Writing the same entity in both systems needs a
  reconciliation job and is a last resort.
- Compare outputs before switching (shadow traffic: send the request to both, serve legacy,
  diff the results). Switch a slice only when the diff is clean for a stated period.
- Finish. A migration left at 90% means two systems to run forever. Plan the last step,
  deleting the old module, as a deliverable.

## Anti-corruption layer

A translation layer at the boundary with a legacy or external system. Its concepts and field
names stop at the layer.

```python
class LegacyOrderAdapter:
    def to_domain(self, raw: dict) -> Order:
        return Order(
            id=OrderId(raw["ord_num"]),
            customer_id=CustomerId(raw["cust_id"]),
            total=Money.from_minor(raw["tot_amt"], "USD"),   # legacy stores cents
        )
```

- The adapter lives at the edge. The domain never imports it and never sees `ord_num`.
- Test the adapter with real recorded payloads from the legacy system, including the odd ones
  (nulls, legacy sentinels such as `0` for "unknown", mixed date formats).
- Units and encodings are where translation bugs hide: cents versus pounds, local time versus
  UTC, character encodings. Write each conversion explicitly with its unit in the name.
