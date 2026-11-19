# Domain-driven design: tactical patterns

Read this when the domain has complex business rules, several distinct sub-domains or will
be maintained by several teams over years. For simple CRUD these patterns cost more than they
return.

## Bounded contexts

A bounded context is the boundary inside which one model is consistent and one team owns it.
The same word may mean different things in different contexts, and that is correct.

```
Order management
  "Customer" = who placed the order, delivery address
  Owns: Order, OrderLine, DeliveryAddress, Fulfilment

Billing
  "Customer" = the billed entity, payment method, invoice history
  Owns: Invoice, PaymentMethod, Subscription
```

Never share a domain model class across contexts. Share ids and events only. A shared
`Customer` class becomes the place where every team's needs collide.

## Ubiquitous language

Code uses the words domain experts use. If the business says "reservation", the class is
`Reservation`, not `Booking`, `Slot` or `Entry`.

- Keep a glossary (for example `docs/glossary.md`) with each term, its meaning and the context
  it belongs to.
- A new domain term in a code review needs a glossary entry first.
- When code and business disagree on a word, that is a modelling bug, not a naming nit.

## Aggregates

An aggregate is a cluster of objects changed as one unit. Only the root is reachable from
outside; it enforces the invariants.

```python
order.add_item(product_id, quantity)                  # right: root checks invariants
order.items.append(OrderItem(product_id, quantity))   # wrong: bypasses them
```

- One aggregate per transaction. A use case that must change two aggregates atomically is a
  sign the boundary is wrong, or that the second change should be eventual (an event).
- Aggregates reference each other by id, never by object reference.
- Keep them small. More than about five entity types in one aggregate usually means two.
- Load and save the whole aggregate through a repository; no partial updates from outside.

## Domain events

A domain event names something that happened in past tense (`OrderConfirmed`). Raise it in
the aggregate, persist it with the state change (outbox), and let other contexts react. Events
carry ids and the facts other contexts need, not the full internal state.

## Context mapping

When two contexts integrate, name the relationship: one conforms to the other's model, they
share a published language, or one protects itself with an anti-corruption layer (see
`legacy-migration.md`). Unnamed relationships drift into shared models.
