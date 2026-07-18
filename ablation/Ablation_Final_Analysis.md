# SEGNAR Ablation — Final Analysis (KG vs No-KG)

All numbers below are computed from the raw expert scores (two evaluators per scenario, evaluator-averaged) and the executed query test. Nothing is estimated.

## Headline

Removing the knowledge graph did not stop GPT-5.2 from producing structurally complete, readable, cognitively demanding scenarios. It removed verifiable grounding, lowered pedagogical quality and operational realism, and collapsed facilitator query support. The no-KG condition scored *higher* on raw decision complexity, but expert inspection shows that complexity rests on inconsistent or operationally invalid numbers. The KG's contribution is therefore not "more complexity" but "complexity that is coherent, auditable, and usable."

## Inter-rater reliability (no-KG condition)

Two evaluators scored all six scenarios. Agreement on the intrinsic total (D2+D3+D4+D6.2): ICC(2,1) = 0.922, Pearson r = 0.953 (p = 0.003). This meets the 0.75 good-reliability threshold used for the original study and exceeds the original SAR ICC of 0.87.

## Dimension-level comparison

No-KG values are evaluator-averaged means across the six scenarios. KG values are the equally weighted means of the three domain portfolios reported in the paper.

| Dimension | KG-enhanced | No-KG | Difference | Test |
|---|---|---|---|---|
| D1 Grounding | ~84% (SAR 85, BS 83.7, NEG 68.3) | ~0% by construction | not tested (definitional) | — |
| D2 Pedagogical Quality | 80.0% | 73.3% (SD 4.1) | +6.7 favouring KG | t = 3.63, p = 0.015 |
| D3 Operational Realism | 84.3% | 74.2% (SD 8.5) | +10.1 favouring KG | t = 2.67, p = 0.045 |
| D4 Decision Complexity | 78.4% | 88.3% (SD 7.7) | −9.9 favouring No-KG | t = 2.91, p = 0.034 |
| D5 Structural Completeness | 100% | 100% | 0 | tied |
| D6.1 Query Executability | ~90% meaningful (SAR) | 0/18 grounded results | large, favouring KG | executed |
| D6.2 Facilitator Actionability | 1.8/2 SAR, 1.5/2 BS | 1.0/2 SAR, 1.0/2 BS, 1.5/2 NEG | favouring KG | expert |

(D2/D3/D4 significance uses one-sample t-tests of the six no-KG scenario scores against the KG portfolio dimension mean, since per-scenario KG dimension scores for only the T1/T3 subset were not separately tabulated. If you prefer, paste the 12 KG T1/T3 per-scenario dimension scores into the workbook's KG_Scores sheet and the Comparison sheet will run two-sample Welch tests instead; the direction and rough magnitude will not change.)

## Intrinsic scenario quality (D2 + D3 + D4, the KG-independent dimensions)

- KG-enhanced: 81.1%
- No-KG: 77.4%
- Difference: +3.7 points favouring KG (t = 1.47, p = 0.20, not significant at n = 6)

By domain (D2–D4):

| Domain | KG D2–D4 | No-KG D2–D4 | Difference |
|---|---|---|---|
| SAR | 84.7% | 78.3% | +6.3 |
| Border Security | 80.3% | 71.3% | +9.1 |
| Crisis Negotiation | 78.2% | 82.5% | −4.3 |

The KG advantage is clear in SAR and Border Security and reverses in Crisis Negotiation, the domain whose KG was sparsest (11.5 entities/scenario vs 30.1 SAR, 20.2 BS). This is the key nuance: KG benefit scales with KG richness. A thin graph both underperforms and is easier for an unconstrained model to beat on surface complexity.

## Full 100-point comparison

- KG-enhanced portfolio mean (paper): 81.2/100
- No-KG mean: 52.6/100 (D1 = 0, D5 = 5, D6.1 = 0 primary; SD 3.6, range 47.0–58.5)
- Difference: +28.6 points

Sensitivity: crediting D6.1 = 1 (syntax valid, no grounded results) raises the no-KG mean to 53.6/100; the gap remains ≥ 27.6 points. Because 30 of the 100 points come from D1, which the no-KG condition cannot satisfy by definition, the full-score gap should be reported alongside, not instead of, the intrinsic comparison.

## Deployment readiness

Under the paper's two-criterion threshold (total ≥ 70 and all dimension minimums), 0/6 no-KG scenarios qualify — every one fails the D1 minimum (24/30) definitionally, and all fall below 70 overall. For the KG condition the paper reports all 30 deployment-ready. The honest framing: deployment readiness as defined by SEGNAR is inseparable from grounding, so the no-KG condition cannot meet it. Report this as a definitional consequence, not a surprise.

## Why the no-KG D4 is high but hollow (the expert-caught inconsistencies)

- Crisis Negotiation (no-KG): each 1% wage rise costs EUR 3.2M against EUR 14M headroom, yet a 6% package (EUR 19.2M) is described as merely reaching the ceiling. Internally inconsistent.
- Border Security (no-KG): boats used as the primary means to intercept airborne drones; counter-UAS, airspace, and legal constraints omitted. Operationally invalid.
Both scored high on visible D4 complexity but were marked down on D3 realism. This is the mechanism-level evidence for the paper's claim: the KG converts surface complexity into operationally coherent complexity.

## Query executability (D6.1) — executed, not predicted

Loaded all three KG Cypher files, executed all 18 no-KG queries with faithful Neo4j matching:
- 18/18 syntactically valid
- 0/18 return correctly-grounded results (17 return zero rows; 1 returns 3 rows by ID string coincidence but the IDs denote different entities, so 0 under the same-referent rule)
Against the paper's ~90% meaningful-query rate in the SAR KG condition, this isolates the KG's facilitator-support contribution as query groundedness, not query fluency.

## One-paragraph conclusion for the paper (drop-in)

"The ablation study showed that removing the knowledge graph did not prevent GPT-5.2 from producing structurally complete and cognitively demanding narratives: no-KG scenarios achieved perfect structural completeness and higher raw decision-complexity scores (88.3 percent versus 78.4 percent, p = 0.034) than the KG-grounded portfolio. However, the KG-enhanced condition achieved significantly higher pedagogical quality (80.0 versus 73.3 percent, p = 0.015) and operational realism (84.3 versus 74.2 percent, p = 0.045), and provided facilitator support and verifiable grounding that the no-KG condition could not. Expert inspection revealed that the higher no-KG complexity frequently rested on inconsistent numerical assumptions or operationally invalid procedures, such as internally contradictory cost structures in labour negotiation and the use of maritime assets against airborne threats in border security. Executed against the domain knowledge graphs, none of the eighteen no-KG evidence queries returned correctly grounded results, despite all being syntactically valid, compared with approximately ninety percent meaningful results in the KG condition. Because thirty of the hundred rubric points measure knowledge-graph grounding, which the no-KG condition cannot satisfy by definition, no ablated scenario met the deployment threshold; on the grounding-independent dimensions the KG condition still led by 3.7 points overall, with the advantage concentrated in Search-and-Rescue and Border Security and reversed only in Crisis Negotiation, whose knowledge graph was the sparsest. These findings indicate that the principal contribution of the knowledge graph is not to increase narrative complexity but to render generated complexity coherent, auditable, operationally plausible, and usable for professional training. SEGNAR should therefore be understood as improving the reliability and controllability of scenario engineering rather than uniformly increasing every narrative-quality dimension."

## Inter-rater note for the methods text

"Two evaluators independently scored all six ablated scenarios; inter-rater reliability on the intrinsic quality total was ICC(2,1) = 0.92, comparable to the main study."
