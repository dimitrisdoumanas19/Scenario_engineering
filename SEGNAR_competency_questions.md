# SEGNAR Ontology — Competency Questions

These competency questions (CQs) specify the requirements the SEGNAR domain-independent narrative ontology must satisfy. Each is expressed in natural language and paired with a Cypher query against an instantiated domain knowledge graph (the form used in the paper). The five questions marked (paper) are the representative subset listed in Section 3.1; the remainder complete the specification and are published here in full as referenced in the manuscript.

The ontology is considered validated against a domain graph when every CQ returns correct, non-empty results on that graph. All three domain graphs (Search-and-Rescue, Border Security, Crisis Negotiation) satisfy the full set.

---

## Scope and intended use

Purpose: to model the universal narrative structure of high-stakes decision-making scenarios so that a single scenario-generation and evaluation framework can be reused across operational domains.
Scope: goal-oriented crisis-and-operations narratives involving actors, goals, resources, events, risks, constraints, values, and outcomes.
Implementation language: OWL 2 (Turtle serialization, segnar_ontology.ttl).
Intended users: scenario engineers, training designers, and researchers building knowledge-grounded LLM generation pipelines.
Knowledge graph realization: Neo4j, with the eight classes as node labels and ontology relationships as typed relationships (see the mapping table in Section 3.1 and README).

---

## Competency questions

### Decision-making and goal conflict

CQ1. Which goals conflict with a given goal, and do they share required resources?
```cypher
MATCH (g1:Goal {goal_id: $gid})-[c:CONFLICTS]->(g2:Goal)
OPTIONAL MATCH (g1)-[:REQUIRES]->(r:Resource)<-[:REQUIRES]-(g2)
RETURN g2.goal_id, g2.name, c.conflict_type, c.conflict_intensity,
       collect(DISTINCT r.resource_id) AS shared_resources
```

CQ2. For a pair of conflicting goals sharing a resource, what is the resource shortfall?
```cypher
MATCH (g1:Goal)-[:CONFLICTS]->(g2:Goal)
MATCH (g1)-[r1:REQUIRES]->(res:Resource)<-[r2:REQUIRES]-(g2)
WITH res, (r1.quantity_needed + r2.quantity_needed) AS need, res.quantity AS have
WHERE need > have
RETURN res.resource_id, res.name, have, need, need - have AS shortfall
```

### Risk management

CQ3. Which risks threaten the goals pursued by a given actor?
```cypher
MATCH (a:Actor {actor_id: $aid})-[:PURSUES]->(g:Goal)<-[:THREATENS]-(risk:Risk)
RETURN a.name, g.goal_id, risk.risk_id, risk.name, risk.risk_score
ORDER BY risk.risk_score DESC
```

CQ4. What cascading risk chains exist, tracing risk to event to further risk?
```cypher
MATCH path = (r1:Risk)-[:CAUSES|THREATENS*1..3]->(r2:Risk)
RETURN [n IN nodes(path) | coalesce(n.risk_id, n.event_id)] AS chain,
       length(path) AS hops
ORDER BY hops DESC
```

CQ5. Which resources or actions mitigate a given risk, and at what cost?
```cypher
MATCH (res:Resource)-[m:MITIGATES]->(risk:Risk {risk_id: $rid})
RETURN res.resource_id, res.name, risk.risk_score, risk.mitigation_cost
```

### Resource optimization

CQ6. Which resources are required by more than one goal, and are they scarce?
```cypher
MATCH (g:Goal)-[req:REQUIRES]->(res:Resource)
WITH res, count(DISTINCT g) AS demanding_goals, sum(req.quantity_needed) AS total_need
WHERE demanding_goals > 1 AND total_need > res.quantity
RETURN res.resource_id, res.name, demanding_goals, total_need, res.quantity,
       total_need - res.quantity AS shortfall
```

CQ7. Which consumable resources are at risk of depletion across the scenario timeline?
```cypher
MATCH (res:Resource)
WHERE res.consumable = true OR res.type = 'consumable'
OPTIONAL MATCH (res)<-[:DEPLETES]-(e:Event)
RETURN res.resource_id, res.name, res.quantity, collect(e.event_id) AS depleting_events
```

### Team coordination

CQ8. Which actors pursue a shared goal, and through which resources or events do they coordinate?
```cypher
MATCH (a1:Actor)-[:PURSUES]->(g:Goal)<-[:PURSUES]-(a2:Actor)
WHERE a1.actor_id < a2.actor_id
RETURN g.goal_id, g.name, collect(DISTINCT a1.actor_id) + collect(DISTINCT a2.actor_id) AS actors
```

### Ethical decision-making

CQ9. Which values constrain the goals involved in a given decision point?
```cypher
MATCH (v:Value)-[:CONSTRAINS]->(g:Goal {goal_id: $gid})
RETURN v.value_id, v.name, v.priority_weight, g.goal_id, g.name
```

CQ10. Which values conflict with one another, and which prioritized goals do they link to?
```cypher
MATCH (v1:Value)-[c:CONFLICTS]->(v2:Value)
OPTIONAL MATCH (v1)-[:CONSTRAINS]->(g:Goal)
RETURN v1.value_id, v2.value_id, c.conflict_intensity, collect(DISTINCT g.goal_id) AS goals
```

### Causal tracing and outcomes

CQ11. What event sequence leads to a given outcome?
```cypher
MATCH path = (e:Event)-[:CAUSES*1..5]->(:Event)-[:ACHIEVES]->(o:Outcome {outcome_id: $oid})
RETURN [n IN nodes(path) | coalesce(n.event_id, n.outcome_id)] AS sequence
ORDER BY length(path) DESC
LIMIT 1
```

CQ12. For a given outcome, which goals were satisfied and which values were upheld or compromised?
```cypher
MATCH (o:Outcome {outcome_id: $oid})
OPTIONAL MATCH (v:Value)-[:EVALUATES]->(o)
RETURN o.outcome_id, o.goals_satisfied, o.values_upheld, o.values_compromised,
       collect(v.value_id) AS evaluating_values
```

---

## Validation record

| CQ | SAR | Border Security | Crisis Negotiation |
|----|-----|-----------------|--------------------|
| CQ1–CQ12 | satisfied | satisfied | satisfied* |

*In Crisis Negotiation the resource- and event-dependent questions (CQ2, CQ4, CQ7, CQ11) return sparse results, consistent with that graph's lower relationship density (81 nodes, 80 relationships) discussed in Section 4.3 of the paper. This is a property of the instantiated graph, not of the ontology.
